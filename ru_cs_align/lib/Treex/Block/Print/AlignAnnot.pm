package Treex::Block::Print::AlignAnnot;

use Moose;
use Moose::Util::TypeConstraints;

use Treex::Core::Common;

use List::Util qw/first/;

use Treex::Tool::Align::Utils;


extends 'Treex::Block::Write::BaseTextWriter';
with 'Treex::Block::Filter::A';

subtype 'Treex::Type::CommaArrayRef' => as 'ArrayRef';
coerce 'Treex::Type::CommaArrayRef' 
    => from 'Str'
    => via { [ split /,/ ] };

has 'annot_langs' => (is => 'ro', isa => 'Treex::Type::CommaArrayRef', required => 1, coerce => 1);
has 'align_types' => (is => 'ro', isa => 'Treex::Type::CommaArrayRef', required => 1, coerce => 1);
has 'layer' => (is => 'ro', isa => 'Str', default => 't');

sub _gold_and_other_aligned_nodes {
    my ($curr_node, $align_lang, $align_type) = @_;
    my ($nodes, $types) = Treex::Tool::Align::Utils::get_aligned_nodes_by_filter(
        $curr_node,
        { language => $align_lang, rel_types => [ $align_type ] },
    );
    my @gold_nodes = map {$nodes->[$_]} grep {$types->[$_] eq "gold"} 0 .. $#$types;
    return (scalar @gold_nodes ? @gold_nodes : @$nodes);
}

sub _aligned_nodes {
    my ($self, $node) = @_;

    my @all_aligned_nodes = ( [ $node ] );
    for (my $i = 0; $i < @{$self->annot_langs}; $i++) {
        my $annot_lang = $self->annot_langs->[$i];
        my $align_type = $self->align_types->[$i];
        my @aligned_nodes = ();
        my $source_nodes_idx = 0;
        while ($source_nodes_idx < @all_aligned_nodes && !@aligned_nodes) {
            @aligned_nodes = map {
                _gold_and_other_aligned_nodes($_, $annot_lang, $align_type)
            } @{$all_aligned_nodes[$source_nodes_idx]};
            if (!@aligned_nodes && $node->get_layer eq "a") {
                @aligned_nodes = map {
                    my ($tnode) = ($_->get_referencing_nodes('a/lex.rf'), $_->get_referencing_nodes('a/aux.rf'));
                    my @aligned_tnodes = _gold_and_other_aligned_nodes($tnode, $annot_lang, $align_type);
                    grep {defined $_} map {$_->get_lex_anode} @aligned_tnodes;
                } @{$all_aligned_nodes[$source_nodes_idx]};
            }
            $source_nodes_idx++;
        }
        push @all_aligned_nodes, \@aligned_nodes;
        #print STDERR "ALI_".$annot_lang.": " . join " ", map {$_->id} @aligned_nodes;
        #print STDERR "\n";
    }
    
    return @all_aligned_nodes;
}

sub _process_node {
    my ($self, $node) = @_;

    my @nodes = $self->_aligned_nodes($node);
    my @langs = ($self->language, @{$self->annot_langs});
    my @zones = map {$node->get_bundle->get_zone($_, $self->selector)} @langs;

    print {$self->_file_handle} "ID: " . $node->get_address . "\n";
    
    if ($self->layer eq "a") {
        for (my $i = 0; $i < @langs; $i++) {
            print {$self->_file_handle} uc($langs[$i])."_A:\t" . _linearize_atree($zones[$i], $nodes[$i]) . "\n";
        }
    }
    else {
        for (my $i = 0; $i < @langs; $i++) {
            print {$self->_file_handle} uc($langs[$i]).":\t" . $zones[$i]->sentence . "\n";
        }
        for (my $i = 0; $i < @langs; $i++) {
            print {$self->_file_handle} uc($langs[$i])."_T:\t" . _linearize_ttree_structured($zones[$i], $nodes[$i]) . "\n";
        }
    }

    for (my $i = 1; $i < @langs; $i++) {
        print {$self->_file_handle} "INFO_".uc($langs[$i]).":\t\n";
    }
    print {$self->_file_handle} "\n";
}


sub process_filtered_tnode {
    my ($self, $tnode) = @_;
    return if ($self->layer ne "t");
    $self->_process_node($tnode);
}

sub process_filtered_anode {
    my ($self, $anode) = @_;
    return if ($self->layer ne "a");
    $self->_process_node($anode);
}

sub _linearize_atree {
    my ($zone, $on_nodes) = @_;

    my %on_nodes_indic = map {$_->id => 1} @$on_nodes;

    my @tree_nodes = $zone->get_atree->get_descendants({ordered => 1});
    my @tree_forms = map {
        $on_nodes_indic{$_->id} ? "<" . $_->form . ">" : $_->form;
    } @tree_nodes;

    return join " ", @tree_forms;
}

sub _linearize_tnode {
    my ($tnode, $highlight_indic) = @_;
   
    my $word = "";
    
    my $anode = $tnode->get_lex_anode;
    if (defined $anode) {
        $word = $anode->form;
    }
    else {
        $word = $tnode->t_lemma .".". $tnode->functor;
    }
    $word =~ s/ /_/g;
    $word =~ s/</&lt;/g;
    $word =~ s/>/&gt;/g;
    $word =~ s/\[/&osb;/g;
    $word =~ s/\]/&csb;/g;

    if ($highlight_indic->{$tnode->id}) {
        $word = "<" . $word . ">";
    }
    my @hl_anodes = grep {$_->get_layer eq "a"} values %$highlight_indic;
    my ($hl_anode_idx) = grep {
        my ($hl_tnode) = $hl_anodes[$_]->get_referencing_nodes('a/aux.rf');
        defined $hl_tnode && $hl_tnode == $tnode
    } 0 .. $#hl_anodes;
    if (defined $hl_anode_idx) {
        $word = "<__A:". $hl_anodes[$hl_anode_idx]->id ."__". $word . ">";
    }
    return $word;
}

sub _linearize_ttree {
    my ($ttree, $highlight_arr) = @_;

    my $highlight_indic = { map {$_->id => $_} grep {defined $_} @$highlight_arr };

    my @words = map {_linearize_tnode($_, $highlight_indic)} $ttree->get_descendants({ordered => 1});
    return join " ", @words;
}

sub _linearize_ttree_structured {
    my ($ttree, $highlight_arr) = @_;
    
    my $highlight_indic = { map {$_->id => $_} grep {defined $_} @$highlight_arr };

    my ($sub_root) = $ttree->get_children({ordered => 1});
    my $str = _linearize_subtree_recur($sub_root, $highlight_indic);
    return $str;
}

sub _linearize_subtree_recur {
    my ($subtree, $highlight_indic) = @_;
    
    my $str = _linearize_tnode($subtree, $highlight_indic);
    my @childs = $subtree->get_children({ordered => 1});
    if (@childs) {
        $str .= " [ ";
        my @child_strs = map {_linearize_subtree_recur($_, $highlight_indic)} @childs;
        $str .= join " ", @child_strs;
        $str .= " ]";
    }
    return $str;
}

1;

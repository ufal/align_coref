package Treex::Block::Print::AlignAnnot;

use Moose;
use Treex::Core::Common;

use List::Util qw/first/;

use Treex::Tool::Align::Utils;


extends 'Treex::Block::Write::BaseTextWriter';
with 'Treex::Block::Filter::A';

subtype 'Treex::Type::LangArrayRef' => as 'ArrayRef';
coerce 'Treex::Type::LangArrayRef' 
    => from 'Str'
    => via { [ split /,/ ] };

has 'annot_lang' => (is => 'ro', isa => 'Str', required => 1);
has 'other_langs' => (is => 'ro', isa => 'Treex::Type::LangArrayRef');
has 'layer' => (is => 'ro', isa => 'Str', default => 't');

sub _aligned_nodes {
    my ($self, $node) = @_;

    my @other_lang_nodes = map {
        my ($nodes, $types) = Treex::Tool::Align::Utils::get_aligned_nodes_by_filter(
            $node,
            { language => $_, rel_types => [ "gold" ] },
        );
        defined $nodes ? $nodes->[0] : undef;
    } @{$self->other_langs};
    
    my $annot_lang_node = first {defined $_} map {
        my ($nodes, $types) = Treex::Tool::Align::Utils::get_aligned_nodes_by_filter(
            $_,
            { language => $self->annot_lang },
        );
        defined $nodes ? $nodes->[0] : undef;
    } ($node, @other_lang_nodes);

    return ($annot_lang_node, @other_lang_nodes);
}

sub _process_node {
    my ($self, $node) = @_;

    my @nodes = ($node, $self->_aligned_nodes($node));
    my @langs = ($self->language, $self->annot_lang, @{$self->other_langs});
    my @zones = map {$_->get_bundle->get_zone($_, $self->selector)} @langs;

    print {$self->_file_handle} $node->get_address . "\n";
    
    if ($self->layer eq "a") {
        for (my $i = 0; $i < @langs; $i++) {
            print {$self->_file_handle} $langs[$i]."_A:\t" . _linearize_atree($zones[$i], $nodes[$i]) . "\n";
        }
    }
    else {
        for (my $i = 0; $i < @langs; $i++) {
            print {$self->_file_handle} $langs[$i].":\t" . $zones[$i]->sentence . "\n";
        }
        for (my $i = 0; $i < @langs; $i++) {
            print {$self->_file_handle} $langs[$i]."_T:\t" . _linearize_ttree_structured($zones[$i], $nodes[$i]) . "\n";
        }
    }

    print {$self->_file_handle} "INFO:\n";
    print {$self->_file_handle} "\n";
}


sub process_filtered_tnode {
    my ($self, $tnode) = @_;
    
}

sub process_filtered_anode {
}

sub _linearize_atree {
    my ($zone, $node) = @_;

    my @tree_nodes = $zone->get_atree->get_descendants({ordered => 1});
    my @tree_forms = map {
        $_ == $node ? "<" . $_->form . ">" : $_->form;
    } @tree_nodes;

    return join " ", @tree_nodes;
}

sub _linearize_tnode {
    my ($tnode, @highlight) = @_;
   
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

    if (any {$_ == $tnode} @highlight) {
        $word = "<" . $word . ">";
    }
    my @hl_anodes = grep {$_->get_layer eq "a"} @highlight;
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
    my ($ttree, @highlight) = @_;

    @highlight = grep {defined $_} @highlight; 

    my @words = map {_linearize_tnode($_, @highlight)} $ttree->get_descendants({ordered => 1});
    return join " ", @words;
}

sub _linearize_ttree_structured {
    my ($ttree, @highlight_arr) = @_;
    
    my $highlight = [ grep {defined $_} @highlight_arr ];

    my ($sub_root) = $ttree->get_children({ordered => 1});
    my $str = _linearize_subtree_recur($sub_root, $highlight);
    return $str;
}

sub _linearize_subtree_recur {
    my ($subtree, $highlight) = @_;
    
    my $str = _linearize_tnode($subtree, @$highlight);
    my @childs = $subtree->get_children({ordered => 1});
    if (@childs) {
        $str .= " [ ";
        my @child_strs = map {_linearize_subtree_recur($_, $highlight)} @childs;
        $str .= join " ", @child_strs;
        $str .= " ]";
    }
    return $str;
}

1;

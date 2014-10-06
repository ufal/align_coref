package Treex::Block::My::AnnotAlignWrite;

use Moose;
use Treex::Core::Common;

use Treex::Tool::Align::Utils;

extends 'Treex::Block::Write::BaseTextWriter';

has 'align_lang' => (is => 'ro', isa => 'Str', required => 1);

has 'robust_align_filter' => (is => 'ro', isa => 'HashRef', builder => '_build_raf');

sub BUILD {
    my ($self) = @_;
    $self->robust_align_filter;
}

sub _build_raf {
    my ($self) = @_;
    return { language => $self->align_lang, rel_types => ['robust','.*'] };
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

sub _process_node {
    my ($self, $l1_node) = @_;

    log_fatal "Must be run on 'ref'."
        if ($self->selector ne "ref");

    log_info $l1_node->id;
    my ($l2_node) = Treex::Tool::Align::Utils::aligned_transitively([$l1_node], [$self->robust_align_filter]);
    if (!defined $l2_node && $l1_node->get_layer eq "t") {
        my $l1_anode = $l1_node->get_lex_anode;
        if (defined $l1_anode) {
            ($l2_node) = Treex::Tool::Align::Utils::aligned_transitively([$l1_anode], [$self->robust_align_filter]);
        }
    }

    my $l1_zone = $l1_node->get_zone;
    my $l2_zone = $l1_node->get_bundle->get_zone($self->align_lang, "ref");

    my $l1_lang = uc($l1_zone->language);
    my $l2_lang = uc($l2_zone->language);

    print {$self->_file_handle} $l1_node->get_address . "\n";
    print {$self->_file_handle} $l1_lang .":\t" . $l1_zone->sentence . "\n";
    print {$self->_file_handle} $l2_lang .":\t" . $l2_zone->sentence . "\n";
    #print {$self->_file_handle} $l1_lang ."_T:\t" . _linearize_ttree($l1_zone->get_ttree, $l1_node) . "\n";
    print {$self->_file_handle} $l1_lang ."_TT:\t" . _linearize_ttree_structured($l1_zone->get_ttree, $l1_node) . "\n";
    #print {$self->_file_handle} $l2_lang ."_T:\t" . _linearize_ttree($l2_zone->get_ttree, $l2_node) . "\n";
    print {$self->_file_handle} $l2_lang ."_TT:\t" . _linearize_ttree_structured($l2_zone->get_ttree, $l2_node) . "\n";
    print {$self->_file_handle} "ERR:\n";
    print {$self->_file_handle} "\n";
}

sub process_tnode {
    my ($self, $l1_tnode) = @_;
    $self->_process_node($l1_tnode);
}

sub process_anode {
    my ($self, $l1_anode) = @_;
    $self->_process_node($l1_anode);
}

1;

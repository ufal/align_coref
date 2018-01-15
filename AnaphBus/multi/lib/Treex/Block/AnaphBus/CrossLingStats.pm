package Treex::Block::AnaphBus::CrossLingStats;

use Moose;
use Treex::Core::Common;

use Treex::Tool::Align::Utils;
use Treex::Tool::Coreference::NodeFilter;

use Data::Printer;

extends 'Treex::Block::Write::BaseTextWriter';
with 'Treex::Block::Filter::Node';

has 'align_lang' => (is => 'ro', isa => 'Str', required => 1);

has 'gold_align_filter' => (is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build_gaf');
has 'align_type' => ( is => 'ro', isa => 'Str', default => 'gold' );
has 'counter_types' => ( is => 'ro', isa => 'ArrayRef[Str]', builder => '_build_counter_types', lazy => 1 );

sub BUILD {
    my ($self) = @_;
    $self->counter_types;
    $self->gold_align_filter;
}

sub _build_node_types {
    my ($self) = @_;
    return [
        'perspron', 
        'perspron_unexpr', 
        'relpron',
        'cor',
    ];
}

sub _build_counter_types {
    my ($self) = @_;
    my @types = @{$self->node_types};
    push @types, (
        '#perspron.12.no_refl',
        'demonpron',
        'noun.only',
    );
    return \@types;
}

sub _build_gaf {
    my ($self) = @_;
    return { language => $self->align_lang, selector => $self->selector, rel_types => [$self->align_type] };
}

sub feats_for_tnode {
    my ($self, $tnode) = @_;

    return map {"undef"} 1..7 if (!defined $tnode);

    my @feats = ();

    push @feats, $tnode->get_address;
    push @feats, $self->get_type($tnode);
    push @feats, $tnode->t_lemma // "undef";
    push @feats, $tnode->gram_sempos // "undef";

    my $anode = $tnode->get_lex_anode;
    if (defined $anode) {
        push @feats, $anode->lemma;
        push @feats, substr($anode->tag, 0, 2);
    }
    else {
        push @feats, ("undef", "undef");
    }

    my @g_antes = $tnode->get_coref_gram_nodes();
    my @t_antes = $tnode->get_coref_text_nodes();
    my $coref_label = @g_antes > 0 ? "g" :
                      (@t_antes > 0 ? "t" : "0");
    push @feats, $coref_label;

    return @feats;
}

sub feats_for_anode {
    my ($self, $anode) = @_;
    
    return map {"undef"} 1..7 if (!defined $anode);
    
    my @feats = ();
    push @feats, $anode->get_address;
    push @feats, $self->get_type($anode);
    push @feats, map {"undef"} 1..2;
    push @feats, $anode->lemma;
    push @feats, substr($anode->tag, 0, 2);
    push @feats, "undef";
    return @feats;
}

sub get_ali_info {
    my ($l1_node, $l2_node) = @_;
    my $ali_info = defined $l1_node->wild->{align_info} ? uc($l1_node->language) . ":\t" . $l1_node->wild->{align_info} :
                  (defined $l2_node && defined $l2_node->wild->{align_info} ? uc($l2_node->language) . ":\t" . $l2_node->wild->{align_info} : undef);
    return $ali_info;
}

sub get_type {
    my ($self, $node) = @_;
    my $node_types;
    if ($node->language eq $self->language) {
        $node_types = $self->node_types;
    }
    else {
        $node_types = $self->counter_types;
    }
    my @matched_types = Treex::Tool::Coreference::NodeFilter::get_matched_set($node, $node_types);
    if (!@matched_types) {
        @matched_types = ( "undef" );
    }
    my $type = $node->language . "_" . join(";", sort @matched_types);
    return $type;
}

sub process_filtered_tnode {
    my ($self, $l1_tnode) = @_;

    my @l1_feats = $self->feats_for_tnode($l1_tnode);
    my ($l2_tnode) = Treex::Tool::Align::Utils::aligned_transitively([$l1_tnode], [$self->gold_align_filter]);
    my @l2_feats;
    my $l1_anode = $l1_tnode->get_lex_anode;
    my $ali_info = undef;
    if (!defined $l2_tnode && defined $l1_anode) {
        my ($l2_anode) = Treex::Tool::Align::Utils::aligned_transitively([$l1_anode], [$self->gold_align_filter]);
        @l2_feats = $self->feats_for_anode($l2_anode);
        $ali_info = get_ali_info($l1_anode, $l2_anode);
    }
    else {
        @l2_feats = $self->feats_for_tnode($l2_tnode);
    }
    if (!defined $ali_info) {
        $ali_info = get_ali_info($l1_tnode, $l2_tnode);
    }
    push @l2_feats, ($ali_info // "No ali info");

    my @feats = (@l1_feats, @l2_feats);

    print {$self->_file_handle} join "\t", (@l1_feats, @l2_feats);
    print {$self->_file_handle} "\n";
}

#sub process_anode {
#    my ($self, $l1_anode) = @_;
#    
#    my @l1_feats = $self->feats_for_anode($l1_anode);
#    my ($l2_anode) = Treex::Tool::Align::Utils::aligned_transitively([$l1_anode], [$self->gold_align_filter]);
#    my @l2_feats = $self->feats_for_anode($l2_anode);
#
#    my @feats = (@l1_feats, @l2_feats);
#    push @feats, get_ali_info($l1_anode, $l2_anode);
#
#    print {$self->_file_handle} (join "\t", @feats);
#    print {$self->_file_handle} "\n";
#}

# TODO process_anode

1;
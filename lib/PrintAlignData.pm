package Treex::Block::My::PrintAlignData;

use Moose;
use Treex::Core::Common;

use Treex::Tool::ML::TabSpace::Util;

use Treex::Tool::Align::Utils;

use Treex::Tool::Align::FeaturesRole;
use Treex::Tool::Align::Features;

extends 'Treex::Block::Write::BaseTextWriter';

has 'align_language' => (is => 'ro', isa => 'Str', required => 1);
has 'gold_align_filter' => (is => 'ro', isa => 'HashRef', builder => '_build_gaf');

has '_feat_extractor' => (is => 'ro', isa => 'Treex::Tool::Align::FeaturesRole', builder => '_build_feat_extractor');

sub _build_feat_extractor {
    my ($self) = @_;
    return Treex::Tool::Align::Features->new();
}

sub BUILD {
    my ($self) = @_;
    $self->gold_align_filter;
}

sub _build_gaf {
    my ($self) = @_;
    return { language => $self->align_language, rel_types => ['gold'] };
}

sub _get_candidates {
    my ($self, $tnode) = @_;
    my $aligned_ttree = $tnode->get_bundle->get_zone($self->align_language, $self->selector)->get_ttree();
    my @candidates = $aligned_ttree->get_descendants({ordered => 1});
    
    # add the src node itself as a candidate -> it means no alignment
    unshift @candidates, $tnode;
    
    return @candidates;
}

sub _get_positive_candidate {
    my ($self, $tnode) = @_;

    # TODO: My::ProjectAlignment has to be called upfront
    # better to put it here

    my ($gold_ali_node) = Treex::Tool::Align::Utils::aligned_transitively([$tnode], [$self->gold_align_filter]);
    return $gold_ali_node // $tnode;
}

sub _get_positive_cand_idx {
    my ($cands, $pos_cand) = @_;

    my ($pos_idx) = grep {$cands->[$_] == $pos_cand} 0 .. $#$cands;
    return $pos_idx;
}

sub process_tnode {
    my ($self, $tnode) = @_;

    my @cands = $self->_get_candidates($tnode);
    my $feats = $self->_feat_extractor->create_instances($tnode, \@cands);
    
    my ($gold_aligned_node) = $self->_get_positive_candidate($tnode);
    #log_info "GOLD_ALIGNED_NODE: ". $gold_aligned_node->id;
    my $pos_cand_idx = _get_positive_cand_idx(\@cands, $gold_aligned_node);
    #log_info "CAND_IDX: $pos_cand_idx";

    my $instance_str = Treex::Tool::ML::TabSpace::Util::format_multiline($feats, [$pos_cand_idx]);
    print {$self->_file_handle} $instance_str;
}

1;

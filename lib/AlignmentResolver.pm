package Treex::Block::My::AlignmentResolver;

use Moose;
use Treex::Core::Common;

use Treex::Tool::Align::Utils;

use Treex::Tool::Coreference::NodeFilter::PersPron;
use Treex::Tool::Align::Features;
use Treex::Tool::ML::VowpalWabbit::Ranker;

extends 'Treex::Core::Block';

has 'align_language' => (is => 'ro', isa => 'Str', required => 1);
has 'model_path' => (is => 'ro', isa => 'Str', required => 1);

has '_feat_extractor' => (is => 'ro', isa => 'Treex::Tool::Align::Features', builder => '_build_feat_extractor');
has '_ranker' => (is => 'ro', isa => 'Treex::Tool::ML::VowpalWabbit::Ranker', builder => '_build_ranker', lazy => 1);

sub BUILD {
    my ($self) = @_;
    $self->_ranker;
}

sub _build_feat_extractor {
    my ($self) = @_;
    return Treex::Tool::Align::Features->new();
}

sub _build_ranker {
    my ($self) = @_;
    return Treex::Tool::ML::VowpalWabbit::Ranker->new({model_path => $self->model_path})
}

sub _get_candidates {
    my ($self, $tnode) = @_;
    my $aligned_ttree = $tnode->get_bundle->get_zone($self->align_language, $self->selector)->get_ttree();
    my @candidates = $aligned_ttree->get_descendants({ordered => 1});
    
    # add the src node itself as a candidate -> it means no alignment
    unshift @candidates, $tnode;
    
    return @candidates;
}

sub process_tnode {
    my ($self, $tnode) = @_;
    
    return if (!Treex::Tool::Coreference::NodeFilter::PersPron::is_3rd_pers($tnode));

    my @cands = $self->_get_candidates($tnode);
    if (@cands > 100) {
        log_warn "[Block::My::AlignmentResolver]\tMore than 100 alignment candidates.";
        return;
    }
    my $feats = $self->_feat_extractor->create_instances($tnode, \@cands);
    my $winner_idx = $self->_ranker->pick_winner($feats);

    Treex::Tool::Align::Utils::remove_aligned_nodes_by_filter($tnode, {language => $self->align_language, selector => $self->selector});
    if ($cands[$winner_idx] != $tnode) {
        log_info "Adding alignment: " . $tnode->id . " --> " . $cands[$winner_idx]->id;
        Treex::Tool::Align::Utils::add_aligned_node($tnode, $cands[$winner_idx], "supervised");
    }
}

1;

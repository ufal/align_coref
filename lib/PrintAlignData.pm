package Treex::Block::My::PrintAlignData;

use Moose;
use Treex::Core::Common;

use Treex::Tool::ML::VowpalWabbit::Util;

use Treex::Tool::Align::Utils;

use Treex::Tool::Align::FeaturesRole;
use Treex::Tool::Align::Features;

use Treex::Tool::Coreference::NodeFilter::PersPron;
use Treex::Tool::Coreference::NodeFilter::RelPron;
use Treex::Block::My::CorefExprAddresses;

extends 'Treex::Block::Write::BaseTextWriter';

has 'align_language' => (is => 'ro', isa => 'Str', required => 1);
has 'type' => ( is => 'ro', isa => 'Str', default => 'all' );
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

sub _get_losses {
    my ($cands, $pos_cand) = @_;

    my @losses = map {$cands->[$_] == $pos_cand ? 0 : 1} 0 .. $#$cands;
    return \@losses;
}

sub get_type {
    my ($node) = @_;
    my $type = undef;
    if (Treex::Tool::Coreference::NodeFilter::PersPron::is_3rd_pers($node, {expressed => 1})) {
        $type = "perspron";
    }
    elsif (Treex::Tool::Coreference::NodeFilter::PersPron::is_3rd_pers($node, {expressed => -1})) {
        #$type = "perspron_unexpr";
        $type = "zero";
    }
    elsif (Treex::Tool::Coreference::NodeFilter::RelPron::is_relat($node)) {
        $type = "relpron";
    }
    elsif (Treex::Block::My::CorefExprAddresses::_is_cor($node)) {
        #$type = "cor";
        $type = "zero";
    }
    #elsif (Treex::Block::My::CorefExprAddresses::_is_cs_ten($node)) {
    #    $type = "ten";
    #}
    return $type;
}

sub process_tnode {
    my ($self, $tnode) = @_;

    my $type = get_type($tnode);
    
    return if (!defined $type);
    return if (($self->type ne "all") && ($self->type ne $type));
    
    #print join "\t", ($type, $tnode->get_address);
    #print "\n";

    my @cands = $self->_get_candidates($tnode);
    my $feats = $self->_feat_extractor->create_instances($tnode, \@cands);
    
    my ($gold_aligned_node) = $self->_get_positive_candidate($tnode);
    #log_info "GOLD_ALIGNED_LEMMA: ". ($gold_aligned_node != $tnode ? $gold_aligned_node->t_lemma : "undef");
    my $losses = _get_losses(\@cands, $gold_aligned_node);
    #log_info "CAND_IDX: $pos_cand_idx";
    my @comments = map {$_->get_address()} @cands;

    my $instance_str = Treex::Tool::ML::VowpalWabbit::Util::format_multiline($feats, $losses, [ \@comments, "" ]);
    print {$self->_file_handle} $instance_str;
}

1;

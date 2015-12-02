package Treex::Block::My::AlignmentEval;

use Moose;
use Treex::Core::Common;

use List::MoreUtils qw/any/;

use Treex::Tool::Align::Utils;

extends 'Treex::Block::Write::BaseTextWriter';
with 'Treex::Block::Filter::Node::T';

has '+node_types' => ( default => 'all_anaph' );
has 'align_language' => (is => 'ro', isa => 'Str', required => 1);
has 'align_reltypes' => (is => 'ro', isa => 'Str', default => '!gold,!robust,!supervised,.*');
has 'anaph_type' => ( is => 'ro', isa => 'Str', default => 'all' );

sub _process_node {
    my ($self, $node) = @_;
    
    # get true and predicted aligned nodes
    my ($true_nodes, $true_types) = Treex::Tool::Align::Utils::get_aligned_nodes_by_filter($node,
        {language => $self->align_language, selector => $self->selector, rel_types => ['gold']});
    log_debug "TRUE_TYPES: " . (join " ", @$true_types), 1;
    my @rel_types = split /,/, $self->align_reltypes;
    my ($pred_nodes, $pred_types) = Treex::Tool::Align::Utils::get_aligned_nodes_by_filter($node,
        {language => $self->align_language, selector => $self->selector, rel_types => \@rel_types });
    log_debug "PRED_TYPES: " . (join " ", @$pred_types), 1;
   
    # get all candidates for alignment
    my $layer = $node->get_layer;
    my $aligned_tree = $node->get_bundle->get_tree($self->align_language, $layer, $self->selector);
    my @aligned_cands = ( $node, $aligned_tree->get_descendants({ordered => 1}) );
    
    # set true indexes
    my $true_idx;
    if (!defined $true_nodes || !@$true_nodes) {
        $true_nodes = [ $node ];
    }
    # +1 because the candidates are indexed from 1
    my @true_idxs = map {$_ + 1} grep {my $ali_c = $aligned_cands[$_]; any {$_ == $ali_c} @$true_nodes} 0 .. $#aligned_cands;
    $true_idx = join ",", @true_idxs;
    
    if (!defined $pred_nodes || !@$pred_nodes) {
        $pred_nodes = [ $node ];
    }
    for (my $i = 0; $i < @aligned_cands; $i++) {
        my $ali_c  = $aligned_cands[$i];
        my $loss = (any {$_ == $ali_c} @$pred_nodes) ? "0.00" : "1.00";
        print {$self->_file_handle} ($i+1).":$loss $true_idx-1\n";
    }
    print {$self->_file_handle} "\n";
}

sub process_filtered_tnode {
    my ($self, $tnode) = @_;
    
    $self->_process_node($tnode);
}

# TODO for the time being, ignoring alignment of anodes with no tnode counterpart
#sub process_anode {
#    my ($self, $anode) = @_;
#    $self->_process_node($anode);
#}

1;

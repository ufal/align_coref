package Treex::Block::My::AlignmentEval;

use Moose;
use Treex::Core::Common;

use List::MoreUtils qw/any/;

use Treex::Tool::Align::Utils;
use Treex::Block::My::PrintAlignData;

extends 'Treex::Block::Write::BaseTextWriter';

has 'align_language' => (is => 'ro', isa => 'Str', required => 1);
has 'align_reltypes' => (is => 'ro', isa => 'Str', default => '!gold,!robust,!supervised,.*');
has 'anaph_type' => ( is => 'ro', isa => 'Str', default => 'all' );

sub intersect {
    my ($a1, $a2) = @_;
    return grep {my $i = $_; any {$_ == $i} @$a2} @$a1;
}

sub _process_node {
    my ($self, $node) = @_;
    
    my ($true_nodes, $true_types) = Treex::Tool::Align::Utils::get_aligned_nodes_by_filter($node,
        {language => $self->align_language, selector => $self->selector, rel_types => ['gold']});
    log_info "TRUE_TYPES: " . (join " ", @$true_types);
    my @rel_types = split /,/, $self->align_reltypes;
    my ($pred_nodes, $pred_types) = Treex::Tool::Align::Utils::get_aligned_nodes_by_filter($node,
        {language => $self->align_language, selector => $self->selector, rel_types => \@rel_types });
    log_info "PRED_TYPES: " . (join " ", @$pred_types);

    my @both_nodes = intersect($true_nodes, $pred_nodes);
    print {$self->_file_handle} join " ", (scalar @$true_nodes, scalar @$pred_nodes, scalar @both_nodes);
    print {$self->_file_handle} "\n";
}

sub process_tnode {
    my ($self, $tnode) = @_;
    
    my $type = Treex::Block::My::PrintAlignData::get_type($tnode);
    return if (!defined $type);
    return if (($self->anaph_type ne "all") && ($self->anaph_type ne $type));
    
    $self->_process_node($tnode);
}

# TODO for the time being, ignoring alignment of anodes with no tnode counterpart
#sub process_anode {
#    my ($self, $anode) = @_;
#    $self->_process_node($anode);
#}

1;

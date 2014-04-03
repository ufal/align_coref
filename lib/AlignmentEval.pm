package Treex::Block::My::AlignmentEval;

use Moose;
use Treex::Core::Common;

use List::MoreUtils qw/any/;

use Treex::Tool::Align::Utils;

extends 'Treex::Block::Write::BaseTextWriter';

has 'align_language' => (is => 'ro', isa => 'Str', required => 1);

sub intersect {
    my ($a1, $a2) = @_;
    return grep {my $i = $_; any {$_ == $i} @$a2} @$a1;
}

sub process_tnode {
    my ($self, $tnode) = @_;

    my ($true_nodes, $true_types) = Treex::Tool::Align::Utils::get_aligned_nodes_by_filter($tnode,
        {language => $self->align_language, selector => $self->selector, rel_types => ['gold']});
    log_info "TRUE_TYPES: " . (join " ", @$true_types);
    my ($pred_nodes, $pred_types) = Treex::Tool::Align::Utils::get_aligned_nodes_by_filter($tnode,
        {language => $self->align_language, selector => $self->selector, rel_types => ['!gold', '!robust', '!supervised', '.*']});
    log_info "PRED_TYPES: " . (join " ", @$pred_types);

    my @both_nodes = intersect($true_nodes, $pred_nodes);
    print {$self->_file_handle} join " ", (scalar @$true_nodes, scalar @$pred_nodes, scalar @both_nodes);
    print {$self->_file_handle} "\n";
}

1;

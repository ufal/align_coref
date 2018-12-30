package Treex::Block::PAWS::UnifyAlignDirection;

use Moose;
use Treex::Core::Common;
use Treex::Tool::Coreference::Utils;

extends 'Treex::Core::Block';

has 'to_lang' => ( is => 'ro', isa => 'Str', required => 1 );

sub process_anode {
    my ($self, $anode) = @_;
    $self->_process_node($anode);
}
sub process_tnode {
    my ($self, $tnode) = @_;
    $self->_process_node($tnode);
}

sub _process_node {
    my ($self, $node) = @_;

    my @change_list = ();
    
    # find gold alignments
    my ($to_nodes, $types) = $node->get_undirected_aligned_nodes({
        language => $self->to_lang,
        selector => $node->selector});
    # delete gold alignments and add them again with a new label
    for (my $i = 0; $i < @$to_nodes; $i++) {
        my $to_node = $to_nodes->[$i];
        if ($to_node->is_directed_aligned_to($node, { rel_types => [$types->[$i]] })) {
            push @change_list, [ $to_node, $types->[$i] ];
        }
    }

    foreach my $pair (@change_list) {
        my ($to_node, $type) = @$pair;
        $to_node->delete_aligned_node($node, $type);
        $node->add_aligned_node($to_node, $type);
    }
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Treex::Block::PAWS::UnifyAlignDirection

=head1 DESCRIPTION

Ensure that all alignment links between C<language> and C<to_lang> go in this direction.

=head1 ATTRIBUTES

=over

=item to_lang

The target language of the links between C<language> and C<to_lang>.

=back

=head1 AUTHOR

Michal Novák

=head1 COPYRIGHT AND LICENSE

Copyright © 2018 by Institute of Formal and Applied Linguistics, Charles University in Prague

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

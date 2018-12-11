package Treex::Block::Write::SentencesWithZeros;

use Moose;
use Treex::Core::Common;
use Treex::Tool::Coreference::Utils;
extends 'Treex::Block::Write::BaseTextWriter';

use Data::Printer;

has '+language' => ( required => 1 );

has '+extension' => ( default => '.txt' );

sub process_zone {
    my ($self, $zone) = @_;

    my @sorted_all_nodes = Treex::Tool::Coreference::Utils::get_anodes_with_zero_tnodes($zone);

    my $sent = "";
    my $no_space = 1;
    for (my $i = 0; $i < @sorted_all_nodes; $i++) {
        my $node = $sorted_all_nodes[$i];
        if (($node->get_layer eq 't' && $i > 0) || !$no_space) {
            $sent .= " ";
        }
        else {
            $no_space = 0;
        }
        $sent .= $node->get_layer eq 't' ? $node->t_lemma.":".$node->functor : $node->form;
        if ($node->get_layer eq 'a' && $node->no_space_after) {
            $no_space = 1;
        }
    }

    print {$self->_file_handle} "$sent\n";
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Treex::Block::Write::SentencesWithZeros

=head1 DESCRIPTION

Document writer for plain text format, one sentence
(L<bundle|Treex::Core::Bundle>) per line.
It also prints out generated nodes from the tectogrammatical layer.


=head1 ATTRIBUTES

=over

=item encoding

Output encoding. C<utf8> by default.

=item to

The name of the output file, STDOUT by default.

=back

=head1 AUTHOR

Michal Novák

=head1 COPYRIGHT AND LICENSE

Copyright © 2018 by Institute of Formal and Applied Linguistics, Charles University in Prague

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

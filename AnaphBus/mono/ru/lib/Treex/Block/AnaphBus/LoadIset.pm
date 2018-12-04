package Treex::Block::AnaphBus::LoadIset;

use Moose;
use JSON;
use Data::Printer;

extends 'Treex::Core::Block';

has 'extension' => ( is => 'ro', isa => 'Str', default => '.iset.ids' );

sub process_document {
    my ($self, $doc) = @_;

    my $filename = $doc->path . $doc->file_stem . $self->extension;
    open my $fh, "<:utf8", $filename;

    while (my $line = <$fh>) {
        chomp $line;
        my ($id, $iset) = split /\t/, $line;
        my $anode = $doc->get_node_by_id("a-".$id);
        $anode->set_iset(decode_json($iset));
    }
    close $fh;
}

1;
=encoding utf-8

=head1 NAME 

Treex::Block::AnaphBus::LoadIset

=head1 DESCRIPTION

Load Interset features back to the Treex file converted from the PDT-like file.
This is needed, as manual post-editing and annotation of coreference is done
in PDT-like documents, which, however, do not store Interset features.

=head1 AUTHORS

Michal Novák <mnovak@ufal.mff.cuni.cz>

=head1 COPYRIGHT AND LICENSE

Copyright © 2017 by Institute of Formal and Applied Linguistics, Charles University in Prague

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

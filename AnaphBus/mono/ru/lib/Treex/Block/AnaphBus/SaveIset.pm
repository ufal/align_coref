package Treex::Block::AnaphBus::SaveIset;

use Moose;
use JSON;

extends 'Treex::Block::Write::BaseTextWriter';

has '+extension' => ( default => '.iset.ids' );

sub process_anode {
    my ($self, $anode) = @_;
    
    my $id = $anode->id;
    my $iset = encode_json($anode->get_iset_structure);

    printf {$self->_file_handle} "%s\t%s\n", $id, $iset;
}

1;
=encoding utf-8

=head1 NAME 

Treex::Block::AnaphBus::SaveIset

=head1 DESCRIPTION

Store Interset features for every a-node to a file corresponfing to a document.
Later, use Treex::Block::AnaphBus::LoadIset to load Interset features back.
This is needed, as manual post-editing and annotation of coreference is done
in PDT-like documents, which, however, do not store Interset features.

=head1 AUTHORS

Michal Novák <mnovak@ufal.mff.cuni.cz>

=head1 COPYRIGHT AND LICENSE

Copyright © 2017 by Institute of Formal and Applied Linguistics, Charles University in Prague

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

package Treex::Block::AnaphBus::FixAToT;

use Moose;

extends 'Treex::Core::Block';

sub process_anode {
    my ($self, $anode) = @_;

	my @tlex = $anode->get_referencing_nodes("a/lex.rf");
    my @taux = $anode->get_referencing_nodes("a/aux.rf");

    return if (@tlex || @taux);

    my @all_tnodes = $anode->get_zone->get_ttree->get_descendants({ordered => 1});
    my @eq_lemma_tnodes = grep {lc($_->t_lemma) eq lc($anode->lemma)} @all_tnodes;

    print STDERR "AFUN ".$anode->afun."\n";
    print STDERR "TAG ".$anode->tag."\n";
    #print STDERR join "\t", ($anode->lemma, join " ", map {$_->t_lemma} @all_tnodes);
    #print STDERR "\n";

    if (scalar(@eq_lemma_tnodes) == 1) {
        $eq_lemma_tnodes[0]->set_lex_anode($anode);
    }
}

1;
=encoding utf-8

=head1 NAME 

Treex::Block::AnaphBus::FixAToT

=head1 DESCRIPTION

After manual annotation of coreference, some of the a-nodes miss a link to the tectogrammatical layer.
This block attempts to fix it automatically.

A) missing links

1. try to find a t-node with the a-node's lemma. Make a link if there is exactly one such node.

=head1 AUTHORS

Michal Novák <mnovak@ufal.mff.cuni.cz>

=head1 COPYRIGHT AND LICENSE

Copyright © 2017 by Institute of Formal and Applied Linguistics, Charles University in Prague

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

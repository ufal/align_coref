package Treex::Block::AnaphBus::PrintNoTToA;

use Moose;
use List::MoreUtils qw/any/;

extends 'Treex::Core::Block';

sub print_item {
    my ($anode, $tlex, $taux, $all_anodes, $all_tnodes) = @_;

    print "ID:\t".$anode->get_address."\n";
    print "A:\t";
    print join " ", (map {my $form = $_->form; $form =~ s/\[/(/g; $form =~ s/\]/)/g;  ($_ == $anode) ? "[".$form."]" : $form } @$all_anodes);
    print "\n";
    print "T:\t";
    print join " ", (map {
            my $tnode = $_;
            my $tlemma = $tnode->t_lemma; 
            $tlemma =~ s/\[/(/g;
            $tlemma =~ s/\]/)/g; 
            (any {$_ == $tnode} @$tlex) ? "[[".$tlemma."]]" :
                (any {$_ == $tnode} @$taux) ? "[".$tlemma."]" :
                $tlemma
        } @$all_tnodes);
    print "\n";
    print "\n";
}

sub process_anode {
    my ($self, $anode) = @_;

	my @tlex = $anode->get_referencing_nodes("a/lex.rf");
    my @taux = $anode->get_referencing_nodes("a/aux.rf");
    my @tall = (@tlex, @taux);

    return if (scalar(@tall) == 1 || $anode->tag =~ /^Z/);

    my @all_anodes = $anode->get_root->get_descendants({ordered => 1});
    my @all_tnodes = $anode->get_zone->get_ttree->get_descendants({ordered => 1});

    print_item($anode, \@tlex, \@taux, \@all_anodes, \@all_tnodes);
}

1;
=encoding utf-8

=head1 NAME 

Treex::Block::AnaphBus::PrintNoTToA

=head1 DESCRIPTION

Print a-nodes and t-nodes in a format to easily annotate a link between them.
This is applied for all a-nodes that have no corresponding t-node and are not punctuation.

=head1 AUTHORS

Michal Novák <mnovak@ufal.mff.cuni.cz>

=head1 COPYRIGHT AND LICENSE

Copyright © 2017 by Institute of Formal and Applied Linguistics, Charles University in Prague

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

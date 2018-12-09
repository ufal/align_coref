package Treex::Block::Write::SentencesWithZeros;

use Moose;
use Treex::Core::Common;
extends 'Treex::Block::Write::BaseTextWriter';

use Data::Printer;

has '+language' => ( required => 1 );

has '+extension' => ( default => '.txt' );

# a function for sigmoid with its values ranging (-1, 1)
sub sigmoid {
    my ($x) = @_;
    return 2*1/(1+exp(-$x)) - 1;
}

sub get_ord_for_generated {
    my ($tnode, $ords) = @_;
    return if (!$tnode->is_generated);
    return if ($tnode->t_lemma !~ /^#(PersPron|Cor|Gen)/);
#        log_info "GENER LEMMA: ".$tnode->t_lemma;
    
    my $par = $tnode->get_parent;
    my $deepord_diff = $tnode->ord - $par->ord;
    
    # get parent's ord first
    my $par_ord = $ords->{$par->id};
    if (!defined $par_ord) {
        # Option 1: take the first of all a-nodes assocciated with the parental t-node, if the t-node precedes the parental t-node. Otherwise, take the last node.
        #my @apars = sort {$a->ord <=> $b->ord} $par->get_anodes;
        #$par_ord = $deepord_diff > 0 ? $apars[$#apars]->ord : $apars[0]->ord;
        # Option 2: take the lexical a-node
        my $par_anode = $par->get_lex_anode;
        return if (!defined $par_anode);
        $par_ord = $par_anode->ord;
    }
  
    return $par_ord + sigmoid($deepord_diff);
}

sub get_generated_ords {
    my ($ttree) = @_;
    my $ords = {};
    my @node_queue = ( $ttree );
    my $curr_node;
    while (@node_queue) {
        $curr_node = shift @node_queue;
        my $ord = get_ord_for_generated($curr_node, $ords);
        if (defined $ord) {
            $ords->{$curr_node->id} = $ord;
        }
        my @children = $curr_node->get_children;
        push @node_queue, @children;
    }
    return $ords;
}

sub get_form_for_generated {
    my ($tnode) = @_;
    return if (!$tnode->is_generated);
    my $tlemma = $tnode->t_lemma;
    if ($tlemma !~ /^#/) {
        return "#CopyWord:$tlemma";
    }
    if ($tlemma =~ /^#(PersPron|Cor|Gen)/) {
        return "#Zero:".$tnode->functor;
    }
    return $tlemma;
}

sub get_form_ords {
    my ($tnode, $gener_ords) = @_;
    my $ord = $gener_ords->{$tnode->id};
    if (defined $ord) {
        return [ get_form_for_generated($tnode), $ord, 0];
    }
    return;
}

sub process_zone {
    my ($self, $zone) = @_;

    my $ttree = $zone->get_ttree;
    
    my @all_form_ords = ();
    my $gener_ords = get_generated_ords($ttree);
    my @all_tnodes = $ttree->get_descendants;
    push @all_form_ords, grep {defined $_} map {get_form_ords($_, $gener_ords)} @all_tnodes;

    my $atree = $zone->get_atree;
    my @all_anodes = $atree->get_descendants;
    push @all_form_ords, map {[$_->form, $_->ord, $_->no_space_after]} @all_anodes;
    
    my @sorted_all_form_ords = sort {$a->[1] <=> $b->[1]} @all_form_ords;
#    p @sorted_all_form_ords;

    my $sent = "";
    my $no_space = 1;
    for (my $i = 0; $i < @sorted_all_form_ords; $i++) {
        my $form_ord = $sorted_all_form_ords[$i];
        if (int($form_ord->[1]) != $form_ord->[1] || !$no_space) {
            $sent .= " ";
        }
        else {
            $no_space = 0;
        }
        $sent .= $form_ord->[0];
        if ($form_ord->[2]) {
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

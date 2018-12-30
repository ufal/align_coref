package Treex::Block::PAWS::FinalizeAlign;

use Moose;
use Treex::Core::Common;
use Treex::Tool::Coreference::Utils;
use Moose::Util::TypeConstraints;

extends 'Treex::Core::Block';
with 'Treex::Block::Filter::Node';

#subtype 'LangsArrayRef', as 'ArrayRef';
#coerce 'LangsArrayRef',
#    from 'Str',
#via { [ split /,/, $_ ] };

has 'align_name' => ( is => 'ro', isa => 'Str', default => 'coref_gold' );
#has 'align_langs' => ( is => 'ro', isa => 'LangsArrayRef', coerce => 1, required => 1 );
#has '_align_langs' => ( is => 'rw', isa => 'ArrayRef' );

sub _build_node_types {
    return 'all_anaph';
}

#before 'process_anode' => sub {
#    my ($self, $anode) = @_;
#    $self->_process_node($anode);
#};
#before 'process_tnode' => sub {
#    my ($self, $tnode) = @_;
#    $self->_process_node($tnode);
#};

before 'process_bundle' => sub {
    my ($self, $bundle) = @_;
    
    my %lang_hash = map {$_->language => 1} $bundle->get_all_zones;
    my @langs = sort keys %lang_hash;

    for (my $i = 0; $i < @langs; $i++) {
        my $l1 = $langs[$i];
        my $l1_zone = $bundle->get_zone($l1, $self->selector);
        for (my $j = $i+1; $j < @langs; $j++) {
            my $l2 = $langs[$j];

            my $atree = $l1_zone->get_atree;
            $self->_replace_align_label($_, $l2) foreach ($atree->get_descendants({ordered => 1}));
            my $ttree = $l1_zone->get_ttree;
            $self->_replace_align_label($_, $l2) foreach ($ttree->get_descendants({ordered => 1}));
        }
    }

};

sub _replace_align_label {
    my ($self, $node, $to_lang) = @_;
    
    # find gold alignments
    my ($nodes, $types) = $node->get_undirected_aligned_nodes({
        language => $to_lang,
        selector => $node->selector,
        rel_types => ['gold','coref_gold']});
    # delete gold alignments and add them again with a new label
    for (my $i = 0; $i < @$nodes; $i++) {
        my $ali_node = $nodes->[$i];
        if ($node->is_directed_aligned_to($ali_node, { rel_types => [$types->[$i]] })) {
            $node->delete_aligned_node($ali_node, $types->[$i]);
            $node->add_aligned_node($ali_node, $self->align_name);
        }
        else {
            $ali_node->delete_aligned_node($node, $types->[$i]);
            $ali_node->add_aligned_node($node, $self->align_name);
        }
    }
}

sub process_filtered_tnode {
    my ($self, $tnode) = @_;
        
    #    # delete other than gold alignments (undirected)
    #    $tnode->delete_aligned_nodes_by_filter({
    #        language => $to_lang,
    #        selector => $tnode->selector,
    #        rel_types => ['!coref_gold', '!gold', '.*']});

    # set the attribute that the alignment for this node has been annotated manually
    return if ($tnode->language eq "pl");
    $tnode->set_attr('is_align_coref', 1);
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Treex::Block::PAWS::Finalize

=head1 DESCRIPTION

A block to finalize annotation of alignment, especially, in PAWS before it is released.
So far the block performs the following actions:
1) rename gold alignments to a common label
2) delete the automatically gathered alignment from the nodes aligned manually
3) flag the manually aligned nodes with the C<is_align_coref> attribute


=head1 ATTRIBUTES

=over

=item align_name

A new name for gold alignment.

=back

=head1 AUTHOR

Michal Novák

=head1 COPYRIGHT AND LICENSE

Copyright © 2018 by Institute of Formal and Applied Linguistics, Charles University in Prague

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

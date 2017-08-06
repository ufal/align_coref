package Treex::Block::Filter::A;

use Moose::Role;
use Treex::Core::Common;

use Treex::Tool::Coreference::NodeFilter::PersPron;
use Treex::Tool::Coreference::NodeFilter::RelPron;
use Treex::Block::My::CorefExprAddresses;

requires 'process_filtered_tnode';

has 'filter' => ( is => 'ro', isa => 'Str', default => 'all' );

sub get_types {
    my ($node) = @_;
    my $types = { all => 1 };
    if (Treex::Tool::Coreference::NodeFilter::PersPron::is_3rd_pers($node, {expressed => 1})) {
        $types->{perspron} = 1;
    }
    if (Treex::Tool::Coreference::NodeFilter::PersPron::is_3rd_pers($node, {expressed => -1})) {
        #$type = "perspron_unexpr";
        $types->{zero} = 1;
    }
    if (Treex::Tool::Coreference::NodeFilter::RelPron::is_relat($node)) {
        $types->{relpron} = 1;
    }
    if (Treex::Block::My::CorefExprAddresses::_is_cor($node)) {
        #$type = "cor";
        $types->{zero} = 1;
    }
    if (Treex::Tool::Coreference::NodeFilter::PersPron::is_3rd_pers($node, {expressed => 1, possessive => 1})) {
        $types->{poss} = 1;
    }
    #elsif (Treex::Block::My::CorefExprAddresses::_is_cs_ten($node)) {
    #    $type = "ten";
    #}
    return $types;
}


sub process_anode {
    my ($self, $anode) = @_;

    my $types = get_types($anode);
    return if (!$types->{$self->filter});

    $self->process_filtered_anode($anode);
}

1;

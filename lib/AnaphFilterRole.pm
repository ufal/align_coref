package Treex::Block::My::AnaphFilterRole;

use Moose::Role;
use Treex::Core::Common;

use Treex::Tool::Coreference::NodeFilter::PersPron;
use Treex::Tool::Coreference::NodeFilter::RelPron;
use Treex::Block::My::CorefExprAddresses;

requires 'process_filtered_tnode';

has 'anaph_type' => ( is => 'ro', isa => 'Str', default => 'all' );

sub get_type {
    my ($node) = @_;
    my $type = undef;
    if (Treex::Tool::Coreference::NodeFilter::PersPron::is_3rd_pers($node, {expressed => 1})) {
        $type = "perspron";
    }
    elsif (Treex::Tool::Coreference::NodeFilter::PersPron::is_3rd_pers($node, {expressed => -1})) {
        #$type = "perspron_unexpr";
        $type = "zero";
    }
    elsif (Treex::Tool::Coreference::NodeFilter::RelPron::is_relat($node)) {
        $type = "relpron";
    }
    elsif (Treex::Block::My::CorefExprAddresses::_is_cor($node)) {
        #$type = "cor";
        $type = "zero";
    }
    #elsif (Treex::Block::My::CorefExprAddresses::_is_cs_ten($node)) {
    #    $type = "ten";
    #}
    return $type;
}


sub process_tnode {
    my ($self, $tnode) = @_;
    
    my $type = get_type($tnode);
    return if (!defined $type);
    return if (($self->anaph_type ne "all") && ($self->anaph_type ne $type));

    $self->process_filtered_tnode($tnode);
}

1;

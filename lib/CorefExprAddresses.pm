package Treex::Block::My::CorefExprAddresses;

use Moose;
use Moose::Util::TypeConstraints;
use Treex::Core::Common;
use Cwd;
    
use Treex::Tool::Coreference::NodeFilter::PersPron; 
use Treex::Tool::Coreference::NodeFilter::RelPron;

use Treex::Tool::Align::Utils;

extends 'Treex::Core::Block';

has 'anaphor_type' => (
    is => 'ro',
    required => 1,
    isa => enum([qw/perspron relpron perspron_unexpr cor/])
);

has 'ignore_align_type' => (
    is => 'ro',
    isa => 'Str',
    #default => 'gold',
);

has '_filter' => (is => 'ro', isa => 'ArrayRef', builder => '_build_filter', lazy => 1);

#sub BUILD {
#    my ($self) = @_;
#    $self->_filter;
#}

sub _build_filter {
    my ($self) = @_;
    
    my $func;
    my $params = {};
    if ($self->anaphor_type eq "perspron") {
        $func = \&Treex::Tool::Coreference::NodeFilter::PersPron::is_3rd_pers;
        $params->{expressed} = 1;
    }
    elsif ($self->anaphor_type eq "perspron_unexpr") {
        $func = \&Treex::Tool::Coreference::NodeFilter::PersPron::is_3rd_pers;
        $params->{expressed} = -1;
    }
    elsif ($self->anaphor_type eq "relpron") {
        $func = \&Treex::Tool::Coreference::NodeFilter::RelPron::is_relat;
    }
    elsif ($self->anaphor_type eq "cor") {
        $func = \&_is_cor;
    }
    return [$func, $params];
}

# TODO: this should be in another place
# TODO: this works reliably only for gold annotations
sub _is_cor {
    my ($node, $params) = @_;
    return 0 if ($node->get_layer ne "t");
    return ($node->t_lemma eq "#Cor");
}

sub _is_ignored {
    my ($self, $node) = @_;
    my $type = $self->ignore_align_type;
    return 0 if (!defined $type);
    my ($ali_nodes, $ali_types) = Treex::Tool::Align::Utils::get_aligned_nodes_by_filter($node, {rel_types => [$type]});
    return @$ali_nodes > 0 ? 1 : 0;
}

sub process_tnode {
    my ($self, $tnode) = @_;
    my $func = $self->_filter->[0];
    my $params = $self->_filter->[1];
    if ($func->($tnode, $params)) {
        return if ($self->_is_ignored($tnode));
        print cwd() . "/" .$tnode->get_address() . "\n";
    } 
    else { 
        my @aux = $tnode->get_aux_anodes();
        my @aux_pp = grep {$func->($_, $params)} @aux;
        if (@aux_pp) {
            foreach my $aux_pp_1 (@aux_pp) {
                next if $self->_is_ignored($aux_pp_1);
                print cwd() . "/" .$aux_pp_1->get_address() ."\n";
            }
        }
    }
}

1;

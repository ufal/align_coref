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
    isa => enum([qw/perspron relpron/])
);

has 'ignore_align_type' => (
    is => 'ro',
    isa => 'Str',
    #default => 'gold',
);

has '_filter' => (is => 'ro', isa => 'CodeRef', builder => '_build_filter', lazy => 1);

#sub BUILD {
#    my ($self) = @_;
#    $self->_filter;
#}

sub _build_filter {
    my ($self) = @_;
    if ($self->anaphor_type eq "perspron") {
        return \&Treex::Tool::Coreference::NodeFilter::PersPron::is_3rd_pers;
    }
    elsif ($self->anaphor_type eq "relpron") {
        return \&Treex::Tool::Coreference::NodeFilter::RelPron::is_relat;
    }
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
    if ($self->_filter->($tnode)) {
        return if ($self->_is_ignored($tnode));
        print cwd() . "/" .$tnode->get_address() . "\n";
    } 
    else { 
        my @aux = $tnode->get_aux_anodes();
        my @aux_pp = grep {$self->_filter->($_)} @aux;
        if (@aux_pp) {
            foreach my $aux_pp_1 (@aux_pp) {
                next if $self->_is_ignored($aux_pp_1);
                print cwd() . "/" .$aux_pp_1->get_address() ."\n";
            }
        }
    }
}

1;

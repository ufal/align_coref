package Treex::Block::My::CorefExprAddresses;

use Moose;
use Moose::Util::TypeConstraints;
use Treex::Core::Common;
    
use Treex::Tool::Coreference::NodeFilter::PersPron; 

extends 'Treex::Core::Block';

has 'type' => (
    is => 'ro',
    required => 1,
    isa => enum([qw/perspron relpron/])
);

has '_filter' => (is => 'ro', isa => 'CodeRef', builder => '_build_filter', lazy => 1);

sub BUILD {
    my ($self) = @_;
    $self->_filter;
}

sub _build_filter {
    my ($self) = @_;
    if ($self->type eq "perspron") {
        return \&Treex::Tool::Coreference::NodeFilter::PersPron::is_3rd_pers;
    }
    elsif ($self->type eq "relpron") {
        return \&Treex::Tool::Coreference::NodeFilter::RelPron::is_relat;
    }
}

sub process_tnode {
    my ($self, $tnode) = @_;
    if ($self->_filter($tnode)) {
        print $tnode->get_address() . "\n";
    } 
    else { 
        my @aux = $tnode->get_aux_anodes();
        my @aux_pp = grep {$self->_filter($_)} @aux;
        if (@aux_pp) {
            print join "\n", map {$_->get_address()} @aux_pp;
            print "\n";
        }
    }
}

1;

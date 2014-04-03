package Treex::Block::My::PersPronAddresses;

use Moose;
use Treex::Core::Common;
    
use Treex::Tool::Coreference::NodeFilter::PersPron; 

extends 'Treex::Core::Block';

sub process_tnode {
    my ($self, $tnode) = @_;
    if (Treex::Tool::Coreference::NodeFilter::PersPron::is_3rd_pers($tnode)) {
        print $tnode->get_address() . "\n";
    } 
    else { 
        my @aux = $tnode->get_aux_anodes();
        my @aux_pp = grep {Treex::Tool::Coreference::NodeFilter::PersPron::is_3rd_pers($_)} @aux;
        if (@aux_pp) {
            print join "\n", map {$_->get_address()} @aux_pp;
            print "\n";
        }
    }
}

1;

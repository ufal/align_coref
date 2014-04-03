package Treex::Block::My::PrintRefNodes;

use Moose;
use Treex::Tool::Align::Utils;

extends 'Treex::Core::Block';

sub process_tnode {
    my ($self, $tnode) = @_;
    print STDERR $tnode->get_address . "\n";
    my ($cp) = Treex::Tool::Align::Utils::aligned_transitively([$tnode],[{language => $tnode->language, selector => "ref"}]);
    if (!$cp) {
        ($cp) = Treex::Tool::Align::Utils::aligned_transitively([$tnode->get_lex_anode],[{language => $tnode->language, selector => "ref"}]);
    }
    print $cp->get_address . "\n";
}

1;

package Treex::Block::My::AddRobustAlignment::EnPerspron;

use Moose;
use Treex::Core::Common;

use Treex::Tool::Align::Robust::EN::PersPron;
use Treex::Tool::Coreference::NodeFilter::PersPron;

extends 'Treex::Block::My::AddRobustAlignment';

has '+_align_lang' => (default => 'cs');
has '_align_zone' => (is => 'ro', isa => 'HashRef[Str]', builder => '_build_align_zone', lazy => 1);

sub _does_apply {
    my ($self, $tnode) = @_;
    my $applies = Treex::Tool::Coreference::NodeFilter::PersPron::is_3rd_pers($tnode, {reflexive => 0});
    if ($applies) {
        log_debug "IS_3RD_PERSON_NONREFLEX_PRONOUN\t" . $tnode->get_address(), 1;
    }
    return $applies;
}

sub _get_align_selectors {
    return [ 
        'self',
        'eparents',
        'siblings',
        \&Treex::Tool::Align::Robust::EN::PersPron::access_via_ancestor
    ];
}

sub _get_align_filters {
    return [ 
        \&Treex::Tool::Align::Robust::EN::PersPron::filter_self,
        \&Treex::Tool::Align::Robust::EN::PersPron::filter_eparents,
        \&Treex::Tool::Align::Robust::EN::PersPron::filter_siblings,
        \&Treex::Tool::Align::Robust::EN::PersPron::filter_ancestor,
    ];
}

1;

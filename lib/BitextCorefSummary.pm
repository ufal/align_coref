package Treex::Block::My::BitextCorefSummary;

use Moose;
use Treex::Core::Common;

use Treex::Tool::Align::Utils;

extends 'Treex::Block::Write::BaseTextWriter';

has 'align_lang' => (is => 'ro', isa => 'Str', required => 1);

has 'gold_align_filter' => (is => 'ro', isa => 'HashRef', builder => '_build_gaf');

sub BUILD {
    my ($self) = @_;
    $self->gold_align_filter;
}

sub _build_gaf {
    my ($self) = @_;
    return { language => $self->align_lang, rel_types => ['gold'] };
}

sub feats_for_tnode {
    my ($tnode) = @_;

    return map {"undef"} 1..6 if (!defined $tnode);

    my @feats = ();

    push @feats, $tnode->get_address;
    push @feats, $tnode->t_lemma // "undef";
    push @feats, $tnode->gram_sempos // "undef";

    my $anode = $tnode->get_lex_anode;
    if (defined $anode) {
        push @feats, $anode->lemma;
        push @feats, substr($anode->tag, 0, 2);
    }
    else {
        push @feats, ("undef", "undef");
    }

    my @g_antes = $tnode->get_coref_gram_nodes();
    my @t_antes = $tnode->get_coref_text_nodes();
    my $coref_label = @g_antes > 0 ? "g" :
                      (@t_antes > 0 ? "t" : "0");
    push @feats, $coref_label;

    return @feats;
}

sub process_tnode {
    my ($self, $l1_tnode) = @_;

    my @l1_feats = feats_for_tnode($l1_tnode);
    my ($l2_tnode) = Treex::Tool::Align::Utils::aligned_transitively([$l1_tnode], [$self->gold_align_filter]);
    my @l2_feats = feats_for_tnode($l2_tnode);

    my @feats = (@l1_feats, @l2_feats);
    push @feats, $l1_tnode->wild->{align_info} // "undef";

    print {$self->_file_handle} (join "\t", @feats);
    print {$self->_file_handle} "\n";
}

# TODO process_anode

1;

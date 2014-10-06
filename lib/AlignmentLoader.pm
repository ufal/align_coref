package Treex::Block::My::AlignmentLoader;

use Moose;
use Treex::Core::Common;
use Treex::Tool::Align::Utils;

extends 'Treex::Core::Block';

has 'from' => (is => 'ro', isa => 'Str', required => 1);

has 'align_language' => (is => 'ro', isa => 'Str', required => 1);

has '_align_records' => (is => 'ro', isa => 'HashRef', builder => '_build_align_records', lazy => 1);

sub BUILD {
    my ($self) = @_;
    $self->_align_records;
}

sub _build_align_records {
    my ($self) = @_;

    my $align_rec = {};

    open my $f, "<:utf8", $self->from;
    while (my $line = <$f>) {
        # read the ID line
        chomp $line;
        my ($src_id) = ($line =~ /^.*\.([^.]*)$/);
        # read surface form lines
        $line = <$f>;
        $line = <$f>;
        # read the source linearized t-tree
        $line = <$f>;
        # read the annotated target linearized t-tree
        $line = <$f>;
        chomp $line;
        # remove leading Label
        $line =~ s/^.*_([^:]+):\t//;
        my $is_structured = ($1 eq "TT");
        my @word_nodes = split / /, $line;
        if ($is_structured) {
            @word_nodes = grep {$_ ne "[" && $_ ne "]"} @word_nodes;
        }
        my @annotated_nodes_idx = grep {$word_nodes[$_] =~ /^<.*>$/ && $word_nodes[$_] !~ /^<__A:.*__.*>$/} 0 .. $#word_nodes;
        my @anodes_ids =  grep {defined $_} map {my ($a_id) = ($_ =~ /^<__A:(.*)__.*>$/); $a_id} @word_nodes;
        # read the additional annotation info
        $line = <$f>;
        chomp $line;
        $line =~ s/^ERR://;
        my @parts = split /\t/, $line;
        my $info = join "\t", grep {$_!~/^TYPE=/} @parts;
        my ($type) = grep {$_ =~ /^TYPE=/} @parts;
        # read the empty line
        $line = <$f>;
        log_warn "The every 7th line of the input annotation file is not empty" if ($line !~ /^\s*$/);

        $align_rec->{$src_id}{trg_idx} = \@annotated_nodes_idx;
        $align_rec->{$src_id}{is_struct} = $is_structured;
        if (@anodes_ids) {
            $align_rec->{$src_id}{anodes_ids} = \@anodes_ids;
        }
        if ($info !~ /^\s*$/) {
            $align_rec->{$src_id}{info} = $info;
        }
        if (defined $type) {
            $type =~ s/^TYPE=//;
            $align_rec->{$src_id}{type} = $type;
        }
    }
    close $f;
    #print STDERR Dumper($align_rec);
    return $align_rec;
}

sub _nodes_linear {
    my ($ttree) = @_;
    return $ttree->get_descendants({ordered => 1});
}

sub _nodes_structured {
    my ($ttree) = @_;
    log_info "STRUCT: " . $ttree->id;
    my @list = ();
    my @stack = $ttree->get_children({ordered => 1});
    while (@stack) {
        my $node = pop @stack;
        push @stack, reverse($node->get_children({ordered => 1}));
        push @list, $node;
    }
    return @list;
}

sub process_document {
    my ($self, $doc) = @_;

    print "UNDF DOC\n" if (!defined $doc);

    foreach my $id (keys %{$self->_align_records}) {
        next if (!$doc->id_is_indexed($id));
        
        my $node = $doc->get_node_by_id($id);
        my $rec = $self->_align_records->{$id};
        
        my $trg_ttree = $node->get_bundle->get_zone($self->align_language, $self->selector)->get_ttree();
        my @all_trg_nodes = ();
        if ($rec->{is_struct}) {
            @all_trg_nodes = _nodes_structured($trg_ttree);
        }
        else {
            @all_trg_nodes = _nodes_linear($trg_ttree);
        }
        my @ali_tnodes = @all_trg_nodes[@{$rec->{trg_idx}}];

        my @ali_anodes = map {$doc->get_node_by_id($_)} @{$rec->{anodes_ids}};

        if ($node->get_layer eq "a") {
            if (@ali_tnodes) {
                push @ali_anodes, map {$_->get_lex_anode()} @ali_tnodes;
            }
            
            _add_a_align($node, @ali_anodes);
        }
        elsif ($node->get_layer eq "t") {
            if (@ali_tnodes) {
                _add_t_align($node, @ali_tnodes);
            }
            if (@ali_anodes) {
                my $anode = $node->get_lex_anode();
                _add_a_align($anode, @ali_anodes);
                $anode->wild->{align_info} = $rec->{info} if (defined $rec->{info});
                $anode->wild->{coref_expr_type} = $rec->{type} if (defined $rec->{type});
            }
        }
        $node->wild->{align_info} = $rec->{info} if (defined $rec->{info});
        $node->wild->{coref_expr_type} = $rec->{type} if (defined $rec->{type});
        
        #if (@ali_tnodes) {
        #    print "ADDRESS: " . $ali_tnodes[0]->get_address . "\n";
        #}
        #else {
        #    print "ADDRESS: " . $trg_ttree->get_address . "\n";
        #}
    }
}

sub _add_a_align {
    my ($anode, @ali_anodes) = @_;
    for my $ali_anode (@ali_anodes) {
        log_info sprintf("Adding alignment between a-nodes: %s and %s (tlemma = %s)", $anode->id, $ali_anode->id, $ali_anode->form);
        Treex::Tool::Align::Utils::add_aligned_node($anode, $ali_anode, "gold");
    }
}

sub _add_t_align {
    my ($tnode, @ali_tnodes) = @_;
    for my $ali_tnode (@ali_tnodes) {
        log_info sprintf("Adding alignment between t-nodes: %s and %s (tlemma = %s)", $tnode->id, $ali_tnode->id, $ali_tnode->t_lemma);
        Treex::Tool::Align::Utils::add_aligned_node($tnode, $ali_tnode, "gold");
    }
}

1;

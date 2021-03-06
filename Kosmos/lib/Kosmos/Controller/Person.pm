package Kosmos::Controller::Person;
use Moose;
use namespace::autoclean;

use File::Basename qw(basename);
use List::MoreUtils qw(uniq);
use LWP::UserAgent;
use XML::LibXML;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Kosmos::Controller::Person - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

my $xml_path = Kosmos->path_to('../xml');

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my @files;
    if ( exists $c->req->params->{file} ) {
        my $file = $c->req->params->{file};
        $file =~ tr{./}{}d;
        $c->detach('/default') unless -e sprintf "%s/%s.TEI-P5.xml", $xml_path, $file;
        @files = glob sprintf "%s/%s*.xml", $xml_path, $file;
    }
    else {
        @files = glob "$xml_path/*.xml";
    }
    $c->forward( 'calc', [ \@files ] );
}

=head2 complete

=cut

sub complete :Local {
    my ( $self, $c ) = @_;

    my @files = glob sprintf '%s/*.xml', $xml_path;

    $c->forward( 'calc', [ \@files ] );
    $c->stash(
        template => 'person/index.tt',
    );
}

=head2 beacon

=cut

sub beacon :Local {
    my ( $self, $c ) = @_;

    my @files = glob sprintf '%s/*.xml', $xml_path;
    $c->forward( 'calc', [ \@files ] );
    $c->stash(
        template => 'person/beacon.tt',
        view     => 'Plain',
    );
    $c->res->content_type( 'text/plain; charset=utf-8' );
}

=head2 csv

=cut

sub csv :Local {
    my ( $self, $c ) = @_;

    my @files = glob sprintf '%s/*.xml', $xml_path;
    $c->forward( 'calc', [ \@files ] );
    $c->stash(
        template => 'person/csv.tt',
        view     => 'Plain',
    );
    $c->res->content_type( 'text/plain; charset=utf-8' );
}

=head2 csv_all

=cut

sub csv_all :Local {
    my ( $self, $c ) = @_;

    my @files = glob sprintf '%s/*.xml', $xml_path;
    $c->forward( 'calc', [ \@files ] );
    $c->stash(
        template => 'person/csv_all.tt',
        view     => 'Plain',
    );
    $c->res->content_type( 'text/plain; charset=utf-8' );
}

=head2 calc

=cut

sub calc :Private {
    my ( $self, $c, $files ) = @_;

    my @files = @$files;

    my $latest = 0;

    my $teins = 'http://www.tei-c.org/ns/1.0';

    my %persons = ();
    my %stat    = ();

    foreach my $file ( @files ) {
        my $xml; eval { $xml = XML::LibXML->new->parse_file( $file ); 1 };
        if ( $@ ) {
            die "Could not parse $file: $@";
            next;
        }

        # timestamp of newest file
        $latest = (stat $file)[9] if (stat $file)[9] > $latest;

        my $basename = basename $file, '.TEI-P5.xml';

        my $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;
        $xpc->registerNs( 'tei', $teins );

        my @nodes = $xpc->findnodes('//tei:text//tei:persName//tei:persName');
        push @nodes, $xpc->findnodes('//tei:text//tei:persName[not(ancestor::tei:note[@type="editorial"]) and not(ancestor::tei:del)] | //tei:text//tei:persName//tei:persName');

        foreach my $persname ( @nodes ) {
            my @unbind = (
                'descendant::tei:note',
                'descendant::tei:del',
                'descendant::tei:abbr',
                'descendant::tei:metamark',
            );

            foreach my $expr ( @unbind ) {
                foreach my $node ( $xpc->findnodes( $expr, $persname ) ) {
                    $node->unbindNode();
                }
            }

            my ( $pb ) = $xpc->findnodes( 'preceding::tei:pb[1]', $persname );
            next unless $pb; # unbinded node
            my $facs = $pb->getAttribute('facs');
            $facs =~ s/^#f(?:0+)//;

            $stat{ total }++;
            $stat{ file }{ $basename }{ total }++;
            my $text = $persname->textContent;

            my $ref = $persname->getAttribute('ref');

            $stat{ with_ref }++    if $ref;
            $stat{ without_ref }++ if !$ref;
            $stat{ file }{ $basename }{ with_ref }++    if $ref;
            $stat{ file }{ $basename }{ without_ref }++ if !$ref;
            $ref ||= 'nognd';
            $stat{ file }{ $basename }{ unique }{ $ref }++;

            my @refs = split /\s+/, $ref;
            foreach my $value ( @refs ) {
                next if $value =~ m{^\Qhttp://www.deutschestextarchiv.de\E};
                $persons{ $value }{ count }{ $basename }++;
                push @{ $persons{ $value }{ forms } }, normalize_text($text);
                push @{ $persons{ $value }{ hits }{ normalize_text($text) } }, {
                    doc  => $basename,
                    facs => $facs,
                };
            }
        }
    }

    %persons = map { $_ => {
        count => $persons{$_}->{count},
        hits  => $persons{$_}->{hits},
        forms => [ uniq @{ $persons{$_}->{forms} } ],
    } } keys %persons;

    $c->forward( 'ehd' );

    while ( my ($key, $value) = each %persons ) {
        next unless $key =~ m{http://d-nb.info/gnd/};
        my ( $gnd ) = $key =~ m{/([^/]+)$};
        next unless $gnd;
        my $file = sprintf '%s/gnd/%s', $c->path_to('..'), $gnd;
        my $xml; eval { $xml = XML::LibXML->new->parse_file( $file ); 1 };
        if ( $@ ) {
            use Data::Dumper; warn Dumper "Could not parse $file: $@";
            next;
        }
        my $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;

        my ( $preferred ) = $xpc->findnodes('//gndo:preferredNameForThePerson');
        next unless $preferred;
        $persons{ $key }{ preferred } = $preferred->textContent;

        my ( $birth ) = $xpc->findnodes('//gndo:dateOfBirth');
        $persons{ $key }{ birth } = $birth->textContent if $birth;

        my ( $death ) = $xpc->findnodes('//gndo:dateOfDeath');
        $persons{ $key }{ death } = $death->textContent if $death;

        $persons{ $key }{ ehd } = $c->stash->{ehd}{$gnd};

        for ( $persons{ $key }{ birth }, $persons{ $key }{ death } ) {
            next unless $_;
            s/^-?0*(\d+).*/$1/;
        }
    }

    $c->stash(
        persons        => \%persons,
        stat           => \%stat,
        normalize_text => \&normalize_text,
        latest         => $latest,
    );
}

sub normalize_text {
    my $s = shift;
    for ( $s ) {
        s/^\s+|\s+$//;
        s/-\r?\n([[:upper:]])/-$1/g;
        s/\s+/ /g;
        s/\r?\n/ /g;
        s/-\s([[:lower:]])/$1/g;
    }
    return $s;
}

# edition humboldt digital
sub ehd :Private {
    my ( $self, $c ) = @_;
    my $ua = LWP::UserAgent->new;
    my $res = $ua->get( 'https://edition-humboldt.de/api/v1/beacon.xql' );
    return unless $res->is_success;
    my $prefix;
    my %ehd;
    my @lines = split /\n/, $res->decoded_content;
    foreach my $line ( @lines ) {
        # skip empty lines
        next if $line =~ /^\s*$/;

        # catch target prefix
        if ( $line =~ /^#TARGET:\s*(.*)/ ) {
            $prefix = $1;
            next;
        }

        #skip comments;
        next if $line =~ /^#/;

        ($ehd{$line} = $prefix) =~ s/\{ID\}/$line/;
    }
    $c->stash->{ehd} = \%ehd;
}

__PACKAGE__->meta->make_immutable;

1;
__END__

=encoding utf8

=head1 AUTHOR

Frank Wiegand

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

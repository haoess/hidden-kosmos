package Kosmos::Controller::Person;
use Moose;
use namespace::autoclean;

use File::Basename qw(basename);
use List::MoreUtils qw(uniq);
use XML::LibXML;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Kosmos::Controller::Person - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->forward( 'complete' );
}

=head2 complete

=cut

sub complete :Private {
    my ( $self, $c ) = @_;

    my @files = glob '/home/wiegand/src/hidden-kosmos/xml/{parthey_msgermqu1711_1828,nn_msgermqu2124_1827,hufeland_privatbesitz_1829}*.xml';
    my $teins = 'http://www.tei-c.org/ns/1.0';

    my %persons = ();
    my %stat    = ();

    foreach my $file ( @files ) {
        my $xml; eval { $xml = XML::LibXML->new->parse_file( $file ); 1 };
        if ( $@ ) {
            die "Could not parse $file: $@";
            next;
        }
        my $basename = basename $file, '.TEI-P5.xml';

        my $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;
        $xpc->registerNs( 'tei', $teins );

        foreach my $persname ( $xpc->findnodes('//tei:text//tei:persName[not(ancestor::tei:note[@type="editorial"])]') ) {
            my $persname_clone = $persname->cloneNode(1);

            # remove <note>s within <persName>
            $persname_clone->removeChild( $_ ) for $xpc->findnodes( 'tei:note', $persname_clone );

            $stat{ total }++;
            $stat{ file }{ $basename }{ total }++;
            my $text = $persname_clone->textContent;
            
            my $ref = $persname_clone->getAttribute('ref');

            $stat{ with_ref }++    if $ref;
            $stat{ without_ref }++ if !$ref;
            $stat{ file }{ $basename }{ with_ref }++    if $ref;
            $stat{ file }{ $basename }{ without_ref }++ if !$ref;
            $ref ||= 'nognd';
            $stat{ file }{ $basename }{ unique }{ $ref }++;

            my ( $pb ) = $xpc->findnodes( 'preceding::tei:pb[1]', $persname );
            my $facs = $pb->getAttribute('facs');
            $facs =~ s/^#f(?:0+)//;

            my @refs = split /\s+/, $ref;
            foreach my $value ( @refs ) {
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

    while ( my ($key, $value) = each %persons ) {
        next unless $key =~ m{http://d-nb.info/gnd/};
        my ( $gnd ) = $key =~ m{/([^/]+)$};
        next unless $gnd;
        my $file = "/home/wiegand/src/hidden-kosmos/gnd/$gnd";
        my $xml; eval { $xml = XML::LibXML->new->parse_file( $file ); 1 };
        if ( $@ ) {
            use Data::Dumper; warn Dumper "Could not parse $file: $@";
            next;
        }
        my $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;
        my ( $preferred ) = $xpc->findnodes('//gndo:preferredNameForThePerson');
        next unless $preferred;
        $persons{ $key }{ preferred } = $preferred->textContent;
    }

    $c->stash(
        persons        => \%persons,
        stat           => \%stat,
        normalize_text => \&normalize_text,
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

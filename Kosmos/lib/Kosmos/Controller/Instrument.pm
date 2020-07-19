package Kosmos::Controller::Instrument;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Text::CSV_XS;
use URI::Escape;
use XML::LibXML;
use XML::LibXSLT;

=head1 NAME

Kosmos::Controller::Instrument - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $xslt = XML::LibXSLT->new;
    $xslt->register_function( 'urn:k', 'urlencode', \&URI::Escape::uri_escape_utf8 );
    
    my $style_doc  = XML::LibXML->load_xml( location => $c->path_to('root/xslt/instrumente.xsl'), no_cdata => 1 );
    my $stylesheet = $xslt->parse_stylesheet( $style_doc );

    my $source = XML::LibXML->load_xml( location => $c->path_to('../lists/avh-instruments.xml') );
    my $results = $stylesheet->transform( $source);
    my $html = $stylesheet->output_as_chars( $results );

    $c->stash(
        template => 'instrument/index.tt',
        html     => $html,
    );
}

=head2 csv

=cut

sub csv :Local {
    my ( $self, $c ) = @_;
    my $xml = XML::LibXML->load_xml( location => $c->path_to('../lists/avh-instruments.xml') );
    my $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;

    my $csv = Text::CSV_XS->new({ always_quote => 1 });
    open( my $fh, '>', \my $out ) or die $!;

    $csv->say( $fh, [ qw(name alternatives wikipedia search_avhkv search_humboldt) ] );

    my @list = $xpc->findnodes('//instrument');
    foreach my $i ( @list ) {
        my $name         = $i->findnodes('name', $i)->to_literal;
        my $wikipedia    = $i->findnodes('name/@ref', $i)->to_literal;
        my $alternatives = $i->findnodes('alternative_names', $i)->to_literal;
        my $avhkv        = $i->findnodes('grep[@type="avhkv"]', $i)->to_literal;
        my $humboldt     = $i->findnodes('grep[@type="humboldt"]', $i)->to_literal;

        $avhkv    = $avhkv    && $avhkv    ne 'no hit' ? _avhkv($avhkv) : '';
        $humboldt = $humboldt && $humboldt ne 'no hit' ? _humboldt($humboldt) : '';

        $csv->say( $fh, [ $name, $alternatives, $wikipedia, $avhkv, $humboldt ]);
    }

    close $fh or die $!;

    $c->res->content_type( 'text/plain; charset=utf-8' );
    $c->res->body( $out );
}

sub _avhkv    { 'http://www.deutschestextarchiv.de/search?in=text&q=' . URI::Escape::uri_escape_utf8( $_[0] ) . '+%23has%5Bflags%2C%2Favhkv%2F%5D' }
sub _humboldt { 'http://www.deutschestextarchiv.de/search?in=text&q=' . URI::Escape::uri_escape_utf8( $_[0] ) . '+%23has%5Bauthor%2C%2Fhumboldt%2Fi%5D' }

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

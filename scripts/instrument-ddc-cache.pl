#!/usr/bin/perl

use warnings;
use strict;

use JSON::XS;
use LWP::UserAgent;
use URI::Escape qw(uri_escape_utf8);
use XML::LibXML;

my $xml = XML::LibXML->load_xml( location => '/home/wiegand/src/hidden-kosmos/lists/avh-instruments.xml' );
my $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;

foreach my $instrument ( $xpc->findnodes('//instrument') ) {
    my ( $name ) = $xpc->findnodes( 'name', $instrument );
    next unless $name;
    $name = $name->to_literal;

    my ( $ddc ) = $xpc->findnodes( 'avhkv-grep', $instrument );
    next unless $ddc;
    $ddc = $ddc->to_literal;
    next if $ddc eq 'no hit';

    my $ua = LWP::UserAgent->new;

    my $q = uri_escape_utf8($ddc) . '+%23has%5Bflags%2C%2Favhkv%2F%5D';
    my $url = "http://kaskade.dwds.de/dstar/dta/dstar.perl?fmt=json&limit=100&q=$q";

    my $res = $ua->get( $url );
    if ( !$res->is_success ) {
        print STDERR "Could not successfully fetch $url, skipping ...\n";
        next;
    }

    my $data;
    eval { $data = decode_json( $res->decoded_content ); 1 };
    if ( $@ ) {
        print STDERR "Could not successfully decode JSON from $url, skipping ...\n";
        next;
    }
    foreach my $hit ( $data->{hits_} ) {
        use Data::Dumper; warn Dumper $hit->[0]{meta_};
        last;
    }
    last;
}

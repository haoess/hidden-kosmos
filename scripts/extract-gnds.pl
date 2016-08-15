#!/usr/bin/perl

use 5.012;
use warnings;

use Carp;
use File::Basename qw(dirname);
use LWP::UserAgent;
use Time::HiRes qw(usleep);
use XML::LibXML;

my $teins = 'http://www.tei-c.org/ns/1.0';
my $project_dir = dirname($0) . '/..';
my $ua = LWP::UserAgent->new;

foreach my $file ( @ARGV ) {
    my $xml; eval { $xml = XML::LibXML->new->parse_file( $file ); 1 };
    if ( $@ ) {
        carp "Could not parse $file: $@";
        next;
    }

    my $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;
    $xpc->registerNs( 'tei', $teins );

    foreach my $ref ( $xpc->findnodes('//tei:text//tei:persName/@ref') ) {
        my $value = $ref->value;
        next unless $value;

        my @values = split /\s+/, $value;
        foreach my $value ( @values ) {
            next unless $value =~ m{http://d-nb.info/gnd/};

            my ( $gnd ) = $value =~ m{/([^/]+)$};
            next unless $gnd;

            my $target = sprintf "%s/gnd/%s", $project_dir, $gnd;
            next if -s $target;

            my $url = sprintf "%s/about/lds.rdf", $value;
            my $res = $ua->get( $url );
            print STDERR "fetching $url ...\n";
            if ( $res->is_success ) {
                open( my $fh, '>:utf8', $target ) or die $!;
                print $fh $res->decoded_content;
                close $fh;
            }
            usleep 300_000;
        }
    }
}

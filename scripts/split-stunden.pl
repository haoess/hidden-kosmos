#!/usr/bin/perl

use 5.012;
use warnings;

use Carp;
use File::Basename qw(basename dirname);
use XML::LibXML;

my $teins = 'http://www.tei-c.org/ns/1.0';

my $project_dir = dirname($0) . '/..';

foreach my $file ( @ARGV ) {
    my $xml; eval { $xml = XML::LibXML->new->parse_file( $file ); 1 };
    if ( $@ ) {
        carp "Could not parse $file: $@";
        next;
    }

    my $base = basename $file;
    $base =~ s/\..*//;
    my $target = sprintf "%s/sessions/%s", $project_dir, $base;
    mkdir $target;

    my $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;
    $xpc->registerNs( 'tei', $teins );

    foreach my $session ( $xpc->findnodes('//tei:div[@type="session"]') ) {
        my $n    = $session->findvalue( '@n' );
        my $data = $session->toString;

        open( my $fh, '>:utf8', "$target/$n.xml" ) or die $!;
        print $fh $data;
        close $fh;
    }
}

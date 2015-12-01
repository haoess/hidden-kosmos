#!/usr/bin/perl

use 5.012;
use warnings;

my $n_total = 0;
my $noref_total = 0;
my %ref_total;

foreach my $file ( @ARGV ) {
    open( my $fh, '<:utf8', $file ) or die $!;
    my $xml = do { local $/; <$fh> };
    close $fh;
    $xml =~ s/<teiHeader>.*?<\/teiHeader>//s;

    my $n_file = 0;
    my $noref_file = 0;
    my %ref_file;

    while ( $xml =~ /<persName([^>]*)>/g ) {
        my $attr = $1;
        if ( $attr =~ /ref="([^"]+)"/ ) {
            my @refs = split /\s/, $1;
            for my $ref ( @refs ) {
                $ref_file{ $ref }++;
                $ref_total{ $ref }++;
            }
        }
        else {
            $noref_file++;
            $noref_total++;
        }
        $n_file++;
    }

    printf "%s:\t%d (total)\t%d (unique)\t%d without \@ref\n", $file, $n_file, scalar keys %ref_file, $noref_file;
    $n_total += $n_file;
}

printf "all:\t%d (total)\t%d (unique)\t%d without \@ref\n", $n_total, scalar keys %ref_total, $noref_total;

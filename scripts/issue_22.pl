#!/usr/bin/perl

use 5.012;
use warnings;

use Carp;
use File::Basename qw(dirname);

my $file = shift;

open( my $fh, '<:utf8', $file ) or die $!;
my $content = do { local $/; <$fh> };
close $fh;

while( $content =~ m{(<note[^>]+type="editorial"[^>]*>.*?\QHamel/Tiemann (Hg.) 1993\E.*?</note>)}sgp ) {
    my $pre         = ${^PREMATCH};
    my $pre_reverse = scalar reverse ${^PREMATCH};
    my $match       = ${^MATCH};
    my $post        = ${^POSTMATCH};
    my ( $facs ) = $pre_reverse =~ m{"([^"]+)f#"=scaf\s+bp<};
    use Data::Dumper; warn Dumper scalar reverse $facs;
    next;
    printf "%s%s%s\n\n", substr( $pre, -50 ), $match, substr( $post, 0, 50 );
}

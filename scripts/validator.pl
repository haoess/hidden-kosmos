#!/usr/bin/perl

use warnings;
use strict;

use Getopt::Long;
use XML::LibXML;

my $uri   = '';
my $stdin = 0;
GetOptions(
    'uri=s' => \$uri,
    'stdin' => \$stdin,
);

binmode(STDOUT, ":utf8");

my $ret = 0;

my $x = XML::LibXML->new;
# read from STDIN
if ( $stdin ) {
    eval { $x->parse_fh( *STDIN, $uri ); 1 };
    if ( $@ ) {
        print $@;
        exit 1;
    }
    else {
        exit 0;
    }
}

for my $file (@ARGV) {
    print "Verarbeite $file ...";
    eval { $x->parse_file($file); 1 };
    if ( $@ ) {
        print "\n$@";
        $ret = 1;
        $ret = 1;
    }
    else {
        print " Ok.\n";
    }
}

exit $ret;

__END__
=head1 NAME

scripts/validator.pl

=head1 SYNOPSIS

    scripts/validator.pl $journal.xml [ $journal.xml ... ]

=head1 DESCRIPTION

Laedt die Journal-Dateien mit L<XML::LibXML> und gibt evtl. vorhandene
Parserfehler aus.

=head1 TODO

=head1 BUGS

=head1 SEE ALSO

L<XML::LibXML>

=head1 AUTHOR

Frank Wiegand <frank.wiegand@gmail.com>, 2010

=cut

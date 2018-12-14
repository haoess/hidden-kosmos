#!/usr/bin/perl

use 5.012;
use warnings;

use File::Temp qw(tempfile);
use List::MoreUtils qw(uniq);

say "Dokument\tSeiten\tZeichen\tTokens\tTypes";

foreach my $file ( @ARGV ) {
    # count <pb>
    my ($count_pb) = `xmllint --xpath 'count(//*[local-name()="pb"])' "$file"`;

    # count characters
    open( my $fh, '<:utf8', $file ) or die "Could not open $file: $!";
    my $xml = do { local $/; <$fh> };
    close $fh;

    for ( $xml ) {
        s{<note[^>]*type="editorial".*?</note>}{}sg;

        # elements to strip
        for my $el ( qw[ corr expan fw teiHeader ] ) {
            s{<$el\b.*?</$el>}{}sg;
        }

        s{<[^>]+>}{}g;
        s{\s+}{ }g;
    }

    my $count_char = length $xml;

    my ( $tmp_fh, $tmp_name ) = tempfile();
    binmode( $tmp_fh, ':utf8' );
    print $tmp_fh $xml;
    close $tmp_fh;

    my @token = `/usr/local/bin/waste -stxd -a /usr/local/share/waste/de-dta-dtiger/abbr.lex -j /usr/local/share/waste/de-dta-dtiger/conj.lex -w /usr/local/share/waste/de-dta-dtiger/stop.lex --model=/usr/local/share/waste/de-dta-dtiger/model.hmm $tmp_name 2>/dev/null`;

    unlink $tmp_name;
    
    my $count_token = grep { /[[:alnum:]]/ } map { utf8::decode($_); $_ } @token;
    my $count_types = uniq @token;
    say sprintf "%s\t%d\t%d\t%d\t%d", $file, $count_pb, $count_char, $count_token, $count_types;
}

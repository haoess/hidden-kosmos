package Kosmos::Controller::Bibliographie;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use CGI qw(escapeHTML);
use Text::CSV_XS qw(csv);
use URI::Find;

=head1 NAME

Kosmos::Controller::Bibliographie - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my @csv = @{ csv( in => $c->path_to('var', 'CdVBibliographie.csv')."" ) };
    my $header_row = shift @csv;

    $c->stash(
        header_row => $header_row,
        csv        => \@csv,
        uri_find   => sub {
            my $str = shift;
            my $finder = URI::Find->new(sub {
                my($uri, $orig_uri) = @_;
                return qq|<a href="$uri">$orig_uri</a>|;
            });
            $finder->find(\$str, \&escapeHTML);
            return $str;
        },
    );
}

=head2 csv_all

=cut

sub csv_all :Local {
    my ( $self, $c ) = @_;
    open( my $fh, '<:utf8', $c->path_to('var', 'CdVBibliographie.csv')."" )
        or die $!;
    
    my $out;
    $out .= $_ while <$fh>;
    close $fh;

    $c->res->content_type( 'text/plain; charset=utf-8' );
    $c->res->body( $out );
}

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 AUTHOR

Frank Wiegand

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

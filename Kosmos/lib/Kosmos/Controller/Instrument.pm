package Kosmos::Controller::Instrument;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

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

    my $source = XML::LibXML->load_xml( location => '/home/wiegand/src/hidden-kosmos/lists/avh-instruments.xml' );
    my $results = $stylesheet->transform( $source);
    my $html = $stylesheet->output_as_chars( $results );

    $c->stash(
        template => 'instrument/index.tt',
        html     => $html,
    );
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

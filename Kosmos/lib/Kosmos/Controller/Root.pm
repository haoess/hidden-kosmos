package Kosmos::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=encoding utf-8

=head1 NAME

Kosmos::Controller::Root - Root Controller for Kosmos

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(
        template => 'index.tt',
    );
}

sub codingdavinci :Local {
    my ( $self, $c ) = @_;
    $c->detach( 'index' );
}

=head2 overview_uni

=cut

sub overview_uni :Private {
    my ( $self, $c ) = @_;

    open( my $fh, '<:utf8', '/home/fw/src/hidden-kosmos/lists/Gliederung_Universitaet.txt' ) or die $!;
    while( my $line = <$fh> ) {
        chomp $line;

        if ( $line =~ /^\d+/ ) {
            my @f = split /\t/, $line;
            #my ( $n, $date, $iai, $parthey, $title, @rest ) = split /\t/, $line;
            use Data::Dumper; warn Dumper \@f;
        }
    }
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {
    my ( $self, $c ) = @_;
    if ( defined $c->stash->{view} && $c->stash->{view} eq 'Plain' ) {
        $c->forward( $c->view('Plain') );
    }
}

=head1 AUTHOR

Frank Wiegand

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

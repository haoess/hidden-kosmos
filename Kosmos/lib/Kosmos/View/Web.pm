package Kosmos::View::Web;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
    PRE_PROCESS        => 'macros.tt',
    WRAPPER            => 'wrapper.tt',
    ENCODING           => 'utf-8',
);

=head1 NAME

Kosmos::View::Web - TT View for Kosmos

=head1 DESCRIPTION

TT View for Kosmos.

=head1 SEE ALSO

L<Kosmos>

=head1 AUTHOR

Frank Wiegand

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

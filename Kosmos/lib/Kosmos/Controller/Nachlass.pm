package Kosmos::Controller::Nachlass;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Kosmos::Controller::Nachlass - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my %hourmap = (
        2 => 14,
        3 => 23,
        4 => 35,
        6 => 61,
        8 => 85,
        12 => 127,
        18 => 184,
        21 => 213,
        22 => 226,
        23 => 239,
        24 => 252,
        27 => 297,
        30 => 335,
        32 => 362,
        34 => 391,
        35 => 409,
        36 => 421,
        37 => 434,
        39 => 460,
        40 => 477,
        41 => 488,
        42 => 506,
        44 => 537,
        45 => 553,
        49 => 610,
        50 => 621,
        52 => 649,
        54 => 677,
        57 => 717,
    );
    $c->stash->{hourmap} = \%hourmap;

    open( my $fh, '<:utf8', sprintf('%s/lists/Nachlass-Dokumente_Uebersicht.txt', $c->path_to('..')) ) or die $!;
    my $i = 0;
    my @list;
    while ( my $line = <$fh> ) {
        chomp $line;
        $i++;
        next if $i == 1;
        next if $line =~ /<!--/;

        my ( $stunde, $thema, $signatur, $art, $datum, $name, $bemerkungen ) = split /\t/, $line;

        $signatur =~ s{(http:[^\]]+)}{<a href="$1">URL</a>}g;

        $bemerkungen =~ s{(http:[^\]]+)}{<a href="$1">URL</a>}g;
        $bemerkungen =~ s{(\])\s([,.-;:_])}{$1$2}g;

        push @list, {
            stunde      => $stunde,
            thema       => $thema,
            signatur    => $signatur,
            art         => $art,
            datum       => $datum,
            name        => $name,
            bemerkungen => $bemerkungen,
        };
    }
    $c->stash(
        fluid    => 1,
        list     => \@list,
        template => 'nachlass/index.tt',
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

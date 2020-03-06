package Kosmos::Controller::Gliederung;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use JSON::XS;

=head1 NAME

Kosmos::Controller::Gliederung - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->forward( 'parse_uni' );
    $c->forward( 'parse_sa' );

    $c->stash(
        template => 'gliederung/index.tt',
    );
}

=head2 parse_uni

=cut

sub parse_uni :Private {
    my ( $self, $c ) = @_;

    open( my $fh, '<:utf8', '/home/wiegand/src/hidden-kosmos/lists/Gliederung_Universitaet.txt' ) or die $!;

    my ( %last, %data, %hours, @topics );

    my $i = 0;
    while ( chomp(my $line = <$fh>) ) {
        $i++; next if $i == 1; # skip first line

        my @fields = qw(stunde datum div1 div2 div3 div4 div5 div6 div7 div8 iai_facs parthey_facs thema);
        my @split = split /\t/, $line;

        foreach my $idx ( 0 .. scalar(@fields) - 1 ) {
            $data{ $fields[$idx] } = $split[$idx] || $last{ $fields[$idx] };
            push @topics, {
                level => reformat_level( $fields[$idx] ),
                value => reformat_value( $data{ $fields[$idx] } ),
            } if $fields[$idx] =~ /^div/ and $split[$idx];
        }

        if ( $data{stunde} != $last{stunde} ) {
            $hours{ $data{stunde} } = {
                datum                     => reformat_datum( $data{datum} ),
                nn_n0171w1_1828           => reformat_facs( $data{iai_facs} ),
                parthey_msgermqu1711_1828 => reformat_facs( $data{parthey_facs} ),
                topics                    => [ @topics ],
            };
            undef @topics;
        }
        %last = %data;
    }

    while ( my ($k, $v) = each %hours ) {
        $c->stash->{map}{ $v->{datum} } = {
            uni => {
                num  => $k,
                refs => [ 'http://www.deutschestextarchiv.de/nn_n0171w1_1828/'.$v->{nn_n0171w1_1828}, 'http://www.deutschestextarchiv.de/parthey_msgermqu1711_1828/'.$v->{parthey_msgermqu1711_1828} ],
            },
            topics => $v->{topics},
        }
    }
}

=head2 parse_sa

=cut

sub parse_sa :Private {
    my ( $self, $c ) = @_;

    open( my $fh, '<:utf8', '/home/wiegand/src/hidden-kosmos/lists/Gliederung_Singakademie.txt' ) or die $!;

    my ( %last, %data, %hours, @topics );

    my $i = 0;
    while ( chomp(my $line = <$fh>) ) {
        $i++; next if $i == 1; # skip first line

        my @fields = qw(stunde datum hufe_facs hufe_n nn2124_facs nn2124_n div1 div2 div3 div4 div5 div6 div7 div8 thema);
        my @split = split /\t/, $line;

        foreach my $idx ( 0 .. scalar(@fields) - 1 ) {
            $data{ $fields[$idx] } = $split[$idx] || $last{ $fields[$idx] };

            push @topics, {
                level => reformat_level( $fields[$idx] ),
                value => reformat_value( $split[$idx] ),
            } if $fields[$idx] =~ /^div/ and $split[$idx];
        }

        if ( $data{stunde} != $last{stunde} ) {
            $hours{ $data{stunde} } = {
                datum                      => reformat_datum( $data{datum} ),
                hufeland_privatbesitz_1829 => reformat_facs( $data{hufe_facs} ),
                nn_msgermqu2124_1827       => reformat_facs( $data{nn2124_facs} ),
                topics                     => [ @topics ],
            };
            undef @topics;
        }
        %last = %data;
    }

    while ( my ($k, $v) = each %hours ) {
        $c->stash->{map}{ $v->{datum} } = {
            sa => {
                num  => $k,
                refs => [ $v->{hufeland_privatbesitz_1829}, $v->{nn_msgermqu2124_1827} ],
            },
            topics => $v->{topics},
        }
    }
}

sub reformat_datum {
    my $s = shift;
    $s =~ s/(\d+)-(\d+)-(\d+)/$3-$2-$1/;
    return $s;
}

sub reformat_facs {
    my $s = shift;
    return $s;
}

sub reformat_level {
    my $s = shift;
    $s =~ s/\D//g;
    return $s;
}

sub reformat_value {
    my $s = shift;
    for ( $s ) {
        s/^\s+|\s+$//g;
    }
    return $s;
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

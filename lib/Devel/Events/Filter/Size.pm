#!/usr/bin/perl

package Devel::Events::Filter::Size;
use Moose;

with qw/Devel::Events::Filter/;

use Devel::Size ();
use Devel::Size::Report ();
use Scalar::Util qw/refaddr reftype/;

has fields => (
	isa => "Any",
	is  => "ro",
);

has one_field => (
	isa => "Bool",
	is  => "ro",
	lazy    => 1,
	default => sub {
		my $self = shift;
		defined $self->fields and not ref $self->fields;
	},
);

has no_total => (
	isa => "Bool",
	is  => "rw",
);

has no_report => (
	isa => "Bool",
	is  => "rw",
);

sub filter_event {
	my ( $self, @event ) = @_;
	my ( $type, @data ) = @event;

	if ( $self->is_one_field(@event) ) {
		my $field = $self->get_field(@event);

		my $ref = { @data }->{ $field };

		return ( $type, $self->calculate_sizes($ref), @data );
	} else {
		my @fields = $self->get_fields(@event);

		my %sizes;
		my %fields = map { $_ => [] } @fields;

		my @data_copy = @data;

		while ( @data_copy ) {
			my ( $key, $value ) = splice( @data_copy, 0, 2 );
			push @{ $fields{$key} }, $value if exists $fields{$key};
		}

		foreach my $field ( @fields ) {
			foreach my $ref ( @{ $fields{$field} ||=[] } ) {
				push @{ $sizes{$field} }, {
					refaddr => refaddr($ref),
					$self->calculate_sizes($ref)
				};
			}
		}

		return (
			$type,
			sizes => \%sizes,
			@data,
		);
	}
}

sub is_one_field {
	my ( $self, @event ) = @_;
	$self->one_field;
}

sub get_fields {
	my ( $self, @args ) = @_;

	my $fields = $self->fields;

	if ( not ref $fields ) {
		if ( defined $fields ) {
			return $fields;
		} else {
			my ( $type, @data ) = @args;
			my ( $i, %seen );
			return ( grep { !$seen{$_}++ } grep { ++$i % 2 == 1 } @data ); # even fields
		}
	} else {
		if ( reftype $fields eq 'ARRAY' ) {
			return @$fields;
		} elsif ( reftype $fields eq 'CODE' ) {
			$self->$fields(@args);
		} else {
			die "Uknown type for field spec: $fields";
		}
	}
}

sub get_field {
	my ( $self, @args ) = @_;
	( $self->get_fields(@args) )[0];
}

sub calculate_sizes {
	my ( $self, $ref ) = @_;

	return (
		$self->calculate_size($ref),
 		$self->calculate_total_size($ref),
		$self->calculate_size_report($ref),
	);
}

sub calculate_size {
	my ( $self, $ref ) = @_;
	return ( size => Devel::Size::size($ref) );
}

sub calculate_total_size {
	my ( $self, $ref ) = @_;
	return if $self->no_total;
	return ( total_size => Devel::Size::total_size($ref) );
}

sub calculate_size_report {
	my ( $self, $ref ) = @_;
	return if $self->no_report;
	return ( size_report => Devel::Size::Report::report_size($ref) );
}

__PACKAGE__;

__END__

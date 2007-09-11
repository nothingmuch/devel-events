#!/usr/bin/perl

package Devel::Events::Handler::Log::Memory;
use Moose;

with qw/Devel::Events::Handler/;

use Scalar::Util qw/reftype/;

use MooseX::AttributeHelpers;

has events => (
	metaclass => 'Collection::Array',
	isa => "ArrayRef",
	is  => "ro",
	default    => sub { [] },
	auto_deref => 1,
	provides   => {
		push => 'add_event',
	},
);

sub clear {
	my $self = shift;
	@{ $self->events } = ();
}

sub compile_cond {
	my ( $self, $cond ) = @_;

	if ( ref $cond ) {
		if ( reftype $cond eq 'CODE' ) {
			return $cond;
		} elsif ( reftype $cond eq 'HASH' ) {

			my %cond = %$cond;

			foreach my $subcond ( values %cond ) {
				$subcond = $self->compile_cond($subcond);
			}

			return sub {
				my ( @data ) = @_;

				if ( @data == 1 ) {
					if ( reftype($data[0]) eq 'ARRAY' ) {
						@data = @{ $data[0] };
					} elsif ( reftype($data[0]) eq 'HASH' ) {
						@data = %{ $data[0] };
					}
				}

				my $type = shift @data if @data % 2 == 1;

				my %data = @data;

				$data{type} = $type if defined $type;

				foreach my $key ( keys %cond ) {
					my $subcond = $cond{$key};
					return unless $subcond->($data{$key});
				}

				return 1;
			}
		} else { die "unknown condition format: $cond" }
	} else {
		return sub {
			my ( $type ) = @_;
			$type eq $cond;
		}
	}
}

sub grep {
	my ( $self, $cond, $events ) = @_;

	my $compiled_cond = $self->compile_cond($cond);

	$events ||= $self->events;

	grep { $compiled_cond->(@$_) } @$events;
}

sub limit {
	my ( $self, %args ) = @_;

	my ( $from, $to ) = @args{qw/from to/};

	$from ||= sub { 1 }; # match immediately
	$to   ||= sub { 0 }; # never match

	$_ = $self->compile_cond($_) for $from, $to;

	my @matches;
	my @events = $self->events;

	before: while ( my $event = shift @events ) {
		if ( $from->(@$event) ) {
			push @matches, $event;
			last before;
		}
	}

	match: while ( my $event = shift @events ) {
		push @matches, $event;
		last match if $to->(@$event);
	}

	return @matches;
}

sub new_event {
	my ( $self, @event ) = @_;
	$self->add_event(\@event);
}

__PACKAGE__;

__END__

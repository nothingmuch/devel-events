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
			defined $type and $type eq $cond;
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
	my @events = @{ $args{events} || $self->events };

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

=pod

=head1 NAME

Devel::Events::Handler::Log::Memory - An optional base role for event generators.

=head1 SYNOPSIS

	use Devel::Events::Handler::Log::Memory;

	my $log = Devel::Events::Handler::Log::Memory->new();

	Some::Geneator->new( handler => $log );

=head1 DESCRIPTION

This convenience role provides a basic C<send_event> method, useful for
implementing generators.

=head1 ATTRIBUTES

=over 4

=item events

The list of events.

Auto derefs.

=back

=head1 METHODS

=over 4

=item clear

Remove all events from the log

=item compile_cond

Used by C<grep> and C<limit>.

Scalars become equality tests, hashes become recursive conditions, and code
reference are retained.

The output is a code reference that can be used to match events.

=item grep $cond

Return the list of events that match a certain condition.

=item limit from => $cond, to => $cond

Return events between two events. If if C<from> or C<to> is omitted then it
returns all the events up to or from the other filter.

=item new_event @event

Log the event to the C<events> list by calling C<add_event>.

=item add_event \@event

Provided by L<MooseX::AttributeHelpers>.

=back

=head1 CAVEATS

If any references are present in the event data then they will be preserved
till the log is clear. This may cause leaks.

To overcome this problem use L<Devel::Events::Filter::Stringify>.

=head1 TODO

Add an option to always hash all the event data for convenience.

Make C<grep> and C<limit> into exportable functions, too.

=cut



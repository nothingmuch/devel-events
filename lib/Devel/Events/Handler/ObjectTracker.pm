#!/usr/bin/perl

package Devel::Events::Handler::ObjectTracker;
use Moose;

with qw/Devel::Events::Handler/;

use Scalar::Util qw/refaddr blessed weaken/;
use Tie::RefHash::Weak;

has live_objects => (
	isa => "HashRef",
	is  => "ro",
	default => sub {
		tie my %hash, 'Tie::RefHash::Weak';
		\%hash;	
	},
);

has object_to_class => (
	isa => "HashRef",
	is  => "ro",
	default => sub {
		tie my %hash, 'Tie::RefHash::Weak';
		\%hash;	
	},
);

has class_counters => (
	isa => "HashRef",
	is  => "ro",
	default => sub { +{} },
);

sub new_event {
	my ( $self, @event ) = @_;

	my ( $type, @data ) = @event;

	if ( $self->can( my $method = "handle_$type" ) ) { # FIXME pattern match? i want erlang =)
		$self->$method( @data );
	}
}

sub handle_object_bless {
	my ( $self, %args ) = @_;

	my $object = $args{object};
	my $class = blessed($object);

	my $class_counters = $self->class_counters;

	$class_counters->{$class}++;

	if ( my $old_class = $args{old_class} ) {
		# rebless
		$class_counters->{$old_class}--;
	} else {
		# new object
		my $entry = $self->event_to_entry( %args );
		$self->live_objects->{$object} = $entry;
	}

	# we need this because in object_destroy it's not blessed anymore
	$self->object_to_class->{$object} = $class;
}

sub event_to_entry {
	my ( $self, %entry ) = @_;

	weaken($entry{object});

	return \%entry;
}

sub handle_object_destroy {
	my ( $self, %args ) = @_;
	
	my $object = $args{object};

	delete $self->live_objects->{$object}; # it will delete itself

	my $class = delete $self->object_to_class->{$object};

	$self->class_counters->{$class}--;

}


__PACKAGE__;

__END__

=pod

=head1 NAME

Devel::Events::Handler::ObjectTracker - A L<Devel::Events> that tracks leaks

=head1 SYNOPSIS

	use Devel::Cycle;

	use Devel::Events::Handler::ObjectTracker;
	use Devel::Events::Filter::Stamp;
	use Devel::Events::Generator::Objects;

	my $tracker = Devel::Events::Handler::ObjectTracker->new();

	my $gen = Devel::Events::Generator::Objects->new(
		handler => Devel::Events::Filter::Stamp->new(
			handler => $tracker,
		),
	);

	$gen->handle_global_bless(); # start generating events

	$code->();

	$gen->clear_global_bless();

	# live_objects is a Tie::RefHash::Weak hash
	foreach my $object ( keys %{ $tracker->live_objects } ) {
		find_cycle( $object );
		print "event id: " . $tracker->live_objects->{$object}{id};
	}

=head1 DESCRIPTION

=cut



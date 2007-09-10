#!/usr/bin/perl

package Devel::Events::Filter;
use Moose::Role;

with qw/Devel::Events::Handler/;

requires 'filter_event';

has handler => (
	# does => "Devel::Events::Handler", # we like duck typing
	isa => "Object",
	is  => "rw",
	required => 0,
);

sub new_event {
	my ( $self, @event ) = @_;

	my @filtered = $self->filter_event( @event );

	if ( my $handler = $self->handler ) {
		$handler->new_event(@filtered);
	} else {
		$self->no_handler_error(@filtered);
	}
}

sub no_handler_error {
	my ( $self, @event ) = @_;

	# silently drop events if we don't have a receiver
}


__PACKAGE__;

__END__

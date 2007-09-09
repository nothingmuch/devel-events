#!/usr/bin/perl

package Devel::Events::Filter;
use Moose::Role;

with qw/Devel::Events::Handler/;

requires 'filter_event';

has handler => (
	# does => "Devel::Events::Handler", # we like duck typing
	isa => "Object",
	is  => "rw",
	required => 1,
);

sub new_event {
	my ( $self, @event ) = @_;

	$self->handler->new_event( $self->filter_event( @event ) );
}


__PACKAGE__;

__END__

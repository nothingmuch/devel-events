#!/usr/bin/perl

package Devel::Events::Generator;
use Moose::Role;

has handler => (
	# does => "Devel::Events::Handler", # we like duck typing
	isa => "Object",
	is  => "rw",
	required => 1,
);

sub send_event {
	my ( $self, @event ) = @_;
	$self->handler->new_event( @event );
}

__PACKAGE__;

__END__


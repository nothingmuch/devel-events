#!/usr/bin/perl

package Devel::Events::Handler::Multiplex;
use Moose;

with qw/Devel::Events::Handler/;

use Set::Object;

has '_handlers' => (
	is        => 'ro',
	isa       => 'Set::Object',
	default   => sub { Set::Object->new },
);

sub BUILD {
	my ( $self, $param ) = @_;

	if ( my $handlers = $param->{handlers} ) {
		$self->add_handler( @$handlers );
	}
}

sub add_handler {
	my ( $self, @h ) = @_;
	$self->_handlers->insert(@h);
}

sub remove_handler {
	my ( $self, @h ) = @_;
	$self->_handlers->remove(@h);
}

sub handlers {
	my ( $self, @h ) = @_;

	if ( @h ) {
		$self->_handlers( Set::Object->new(@h) );
	}

	$self->_handlers->members;
}

sub new_event {
	my ( $self, @event ) = @_;

	foreach my $handler ( $self->handlers ) {
		$handler->new_event(@event);
	}
}

__PACKAGE__;

__END__


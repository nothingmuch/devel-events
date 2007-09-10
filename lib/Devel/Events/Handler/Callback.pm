#!/usr/bin/perl

package Devel::Events::Handler::Callback;
use Moose;

has callback => (
	isa => "CodeRef",
	is  => "rw",
	required => 1,
);

around new => sub {
	my $next = shift;
	my ( $class, @args ) = @_;
	@args = ( callback => @args ) if @args == 1;
	$class->$next(@args);
};

sub new_event {
	my ( $self, @event ) = @_;
	$self->callback->( @event );
}


__PACKAGE__;

__END__


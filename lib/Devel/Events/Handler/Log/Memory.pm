#!/usr/bin/perl

package Devel::Events::Handler::Log::Memory;
use Moose;

with qw/Devel::Events::Handler/;

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

sub new_event {
	my ( $self, @event ) = @_;
	$self->add_event(\@event);
}

__PACKAGE__;

__END__

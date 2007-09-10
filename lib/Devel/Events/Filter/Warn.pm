#!/usr/bin/perl

package Devel::Events::Filter::Warn;
use Moose;

with qw/Devel::Events::Filter/;

sub filter_event {
	my ( $self, @event ) = @_;
	warn "@event";
	return @event;
}

__PACKAGE__;

__END__


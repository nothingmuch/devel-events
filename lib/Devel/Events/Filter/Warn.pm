#!/usr/bin/perl

package Devel::Events::Filter::Warn;
use Moose;

with qw/Devel::Events::Filter::HandlerOptional/;

sub filter_event {
	my ( $self, @event ) = @_;
	warn "@event\n";
	return @event;
}

__PACKAGE__;

__END__

=pod

=head1 NAME

Devel::Events::Filter::Warn - log every event to STDERR

=head1 SYNOPSIS

	# can be used as a handler
	my $h = Devel::Events::Filter::Warn->new();

	# or as a filter in a handler chain

	my $f = Devel::Events::Filter::Warn->new(
		handler => $sub_handler,
	);

=head1 DESCRIPTION

This is a very simple debugging aid to see that your filter/handler chains are
set up correctly.

A useful helper function you can define is something along the lines of:

	sub _warn_events ($) {
		my $handler = shift;
		Devel::Events::Filter::Warn->new( handler => $handler );
	}

and then prefix handlers which seem to not be getting their events with
C<_warn_events> in the source code.

=head1 METHODS

=over 4

=item filter_event @event

calls C<warn "@event">. and returns the event unfiltered.

=back

=cut

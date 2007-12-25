#!/usr/bin/perl

package Devel::Events::Generator::Require;

use strict;
use warnings;

use Sub::Uplevel;
use Scalar::Util qw(weaken);

my $SINGLETON;

BEGIN {
	# before Moose or anything else is parsed, we overload CORE::GLOBAL::bless
	# this will divert bless to an object of our choosing if that variable is filled with something

	require Carp::Heavy;

	*CORE::GLOBAL::require = sub {
		my $file = shift;

		if ( defined $SINGLETON ) {
			$SINGLETON->try_require( file => $file );
		}

		# require is always in scalar context
		local $@;
		my $ret;

	 	eval { uplevel 4, sub { $ret = CORE::require($file) } };

		no warnings 'uninitialized';

		if ( defined $SINGLETON ) {
			my $e = $@;

			if ( $e and not ref $e ) {
				my $file = quotemeta(__FILE__);
				my ( $caller_file, $caller_line ) = (caller)[1,2];
				$e =~ s/at $file line \d+\.$/at $caller_file line $caller_line./;
			}

			$SINGLETON->require_finished(
				file         => $file,
				matched_file => $INC{$file},
				error        => $e,
				return_value => $ret,
			);
		}

		if ( $@ ) {
			die $@;
		} else {
			return $ret;
		}
	}
}

use Moose;

with qw(Devel::Events::Generator);

sub enable {
	my $self = shift;
	$SINGLETON = $self;
	weaken($SINGLETON);
}

sub disable {
	$SINGLETON = undef;
}

sub try_require {
	my ( $self, @args ) = @_;

	$self->send_event( try_require => @args );
}

sub require_finished {
	my ( $self, @args ) = @_;

	$self->send_event( require_finished => @args );
}


__PACKAGE__;

__END__

=pod

=head1 NAME

Devel::Events::Generator::Require - Event generator for loading of code using
C<require>.

=head1 SYNOPSIS

	use Devel::Events::Generator::Require;

	my $g = Devel::Events::Generator::Require->new( handler => $h );

	$g->enable();

	# all calls to require() will generate a try_require and a require_finished event

	$g->disable();

	# events disabled

=head1 DESCRIPTION

This generator allows instrumentation of module/file loading via C<require>.
This includes C<use> statements.

=head1 EVENTS

=over 4

=item try_require

Fired before C<require> actually happens.

=over 4

=item file

The file that C<require> was given.

Note that when doing C<<require Foo::Bar>>, the parameter passed into
C<CORE::require> is actually C<<Foo/Bar.pm>>, and not the module name.

=back

=item require_finished

Fired at the end of every require, successful and unsuccessful.

=over 4

=item file

The file that C<require> was given.

=item matched_file

The entry of C<file> in C<%INC>.

=item error

The load error, if any.

=item return_value

The value returend by the file. This is always a scalar.

=back

=back

=head1 METHODS

=over 4

=item enable

Make this instance the enabled one (disabling any other instance which is
enabled).

This only applies to the C<object_bless> method.

=item disable

Disable this instance. Will stop generating C<object_bless> events.
=item try_require

Generates the C<try_require> event.

=item require_finished

Generates the C<require_finished> event.

=back

=cut



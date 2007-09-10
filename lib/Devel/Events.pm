#!/usr/bin/perl

package Devel::Events;

use strict;
use warnings;



__PACKAGE__;

__END__

=pod

=head1 NAME

Devel::Events - Extensible instrumentation framework.

=head1 SYNOPSIS

	use Devel::Events;

=head1 DESCRIPTION

L<Devel::Events> is an event generation, filtering and analaysis framework for
instrumenting and auditing perl code.

L<Devel::Events::Generator> object fire events, which are mangled by
L<Devel::Event::Filter> objects. Eventually any number of
L<Devel::Event::Handler> objects can receive a given event, and perform
analysis based on it.

For example L<Devel::Event::Handler::ObjectTracker> can be used to detect
leaks.

=cut



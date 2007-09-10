#!/usr/bin/perl -d:Events::Generator::LineTrace

use strict;
use warnings;

use Test::More 'no_plan';

use Devel::Events::Handler::Callback;

my @events;

my $h = Devel::Events::Handler::Callback->new(sub {
	push @events, [ @_ ],
});

my $o = Devel::Events::Generator::LineTrace->new( handler => $h );

$o->enable;

my $line = __LINE__;

$o->disable;

is_deeply(
	\@events,
	[
		[ executing_line => ( package => "main", file => __FILE__, line => $line ) ],
		[ executing_line => ( package => "main", file => __FILE__, line => $line + 2 ) ],
	],
	"line events",
);



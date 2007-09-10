#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';

use ok 'Devel::Events::Handler::Log::Memory';

my $log = Devel::Events::Handler::Log::Memory->new;

$log->new_event( foo => bar   => [ 1, 2, 3 ] );
$log->new_event( bar => moose => [ 3, 2, 1 ] );

is_deeply(
	[ $log->events ],
	[
		[ foo => bar   => [ 1, 2, 3 ] ],
		[ bar => moose => [ 3, 2, 1 ] ],
	],
);


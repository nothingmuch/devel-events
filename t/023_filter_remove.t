#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';


my $m; use ok $m = "Devel::Events::Filter::RemoveFields";

isa_ok(my $o = $m->new( fields => [qw/blah/] ), $m);

is_deeply(
	[ $o->filter_event( event_name => ( blah => 42, foro => 3, blah => "and", moose => "elk" ) ) ],
	[ event_name => ( foro => 3, moose => "elk" ) ],
	"remove fields",
);



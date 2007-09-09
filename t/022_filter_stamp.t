#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';


my $m; use ok $m = "Devel::Events::Filter::Stamp";

my $time = time;
my %data = Devel::Events::Filter::Stamp::stamp_data();

is_deeply( [ sort keys %data ], [ sort qw/time pid/ ], "keys" );

is( $data{pid}, $$, "pid" );

cmp_ok( $time - $data{time}, "<=", 2, "time is within range" );

# TODO
# test threads

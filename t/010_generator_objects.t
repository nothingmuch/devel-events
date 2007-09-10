#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::Exception;

use Devel::Events::Handler::Callback;

use ok 'Devel::Events::Generator::Objects';

my $file = quotemeta(__FILE__);

throws_ok { bless "foo", "bar" } qr/^Can't bless non-reference value at $file line \d+/, "bless doesn't poop errors";

my @events;

my $h = Devel::Events::Handler::Callback->new(sub {
	push @events, [ map { ref($_) ? "$_" : $_ } @_ ]; # don't leak
});

my $gen = Devel::Events::Generator::Objects->new(
	handler => $h,
);

isa_ok( $gen, "Devel::Events::Generator::Objects" );

is( $gen->handler, $h, "right handler" );

is( @events, 0, "no events" );

bless( {}, "Some::Class" );

is( @events, 0, "no events" );

$gen->enable();

throws_ok { bless "foo", "bar" } qr/^Can't bless non-reference value at $file line \d+/, "bless doesn't poop errors after registring handler either";

is( @events, 0, "no events" );

my $obj = bless( {}, "Some::Class" );
my $obj_str = "$obj";

is( @events, 1, "one event" );

is_deeply(
	\@events,
	[
		[ object_bless => ( object => $obj_str, old_class => undef, generator => "$gen" ) ],
	],
	"event log",
);

@events = ();

bless( $obj, "Some::Other::Class" );
$obj_str = "$obj";

is( @events, 1, "one event" );

is_deeply(
	\@events,
	[
		[ object_bless => ( object => $obj_str, old_class => 'Some::Class', generator => "$gen" ) ],
	],
	"event log",
);

my ( $hash_str ) = ( $obj_str =~ /^Some::Other::Class=(HASH\(0x[\w]+\))$/ ); # objects are first unblessed, then they get freed

@events = ();

$obj = undef;

no warnings 'uninitialized'; # wtf?!

is_deeply(
	\@events,
	[
		[ object_destroy => ( object => $hash_str, generator => "$gen" ) ],
	],
	"event log",
);



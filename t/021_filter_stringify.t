#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';

my $m; use ok $m = "Devel::Events::Filter::Stringify";


{
	package Handler;
	sub new {
		my ( $class, $h ) = @_;
		bless $h, $class;
	}

	sub new_event {
		my ( $self, @event ) = @_;
		$self->( @event );
	}
}

my @events;
my $h = Handler->new(sub { push @events, [ @_ ] });

my $f = $m->new( handler => $h );

my @event = ( foo => ( blah => [ bless({}, "zork") ], oink => bless({}, "oink"), gorch => { }, string => "moose" ) );

$f->new_event( @event );

is_deeply(
	\@events,
	[ [ map { "$_" } @event ] ],
	"event stringified",
);


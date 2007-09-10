#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';

use ok 'Devel::Events::Filter::Size';

use Devel::Size;

{
	my $f = Devel::Events::Filter::Size->new( fields => "foo" );

	my ( $type, %fields ) = ( $f->filter_event( blah => foo => [ 1, 2, [ 3, 4 ] ], bar => [ 3, 4 ], gorch => { baz => [ 1, 2, 3 ] } ) );

	is( $fields{size}, Devel::Size::size($fields{foo}), "size" );

	is( $fields{total_size}, Devel::Size::total_size($fields{foo}), "total size" );

	ok( length($fields{size_report}), "size report" );

}

{
	my $f = Devel::Events::Filter::Size->new( fields => [qw/foo bar/] );

	my ( $type, %fields ) = ( $f->filter_event( blah => foo => [ 1, 2, [ 3, 4 ] ], bar => [ 3, 4 ], gorch => { baz => [ 1, 2, 3 ] } ) );

	is( ref($fields{sizes}), "HASH", "sizes" );
	is( scalar( keys %{ $fields{sizes} } ), 2, "2 reports" );
	is( ref($fields{sizes}{bar}), "ARRAY", "size report for 'foo' fields" );
	is( $fields{sizes}{bar}[0]{size}, Devel::Size::size($fields{bar}), "size report" );
}

{
	my $f = Devel::Events::Filter::Size->new;

	my ( $type, %fields ) = ( $f->filter_event( blah => foo => [ 1, 2, [ 3, 4 ] ], bar => [ 3, 4 ], gorch => { baz => [ 1, 2, 3 ] } ) );

	is( ref($fields{sizes}), "HASH", "sizes" );
	is( scalar( keys %{ $fields{sizes} } ), 3, "3 reports" );
	is( ref($fields{sizes}{bar}), "ARRAY", "size report for 'foo' fields" );
	is( $fields{sizes}{bar}[0]{size}, Devel::Size::size($fields{bar}), "size report" );
}

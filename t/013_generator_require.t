#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';

use Devel::Events::Handler::Callback;

use ok 'Devel::Events::Generator::Require';

my @log;

my $g = Devel::Events::Generator::Require->new(
	handler => Devel::Events::Handler::Callback->new(sub { push @log, [@_] } ),
);

$g->enable();

is_deeply( \@log, [], "log empty" );

eval { require "foo.pm" };

is_deeply(
	\@log,
	[
		[ try_require      => generator => $g, file => "foo.pm", ],
		[ require_finished =>
			generator => $g,
			file => "foo.pm",
			matched_file => undef,
			error => "Can't locate foo.pm in \@INC (\@INC contains: @INC) at " . __FILE__ . " line 22.\n",
			return_value => undef
		],
	],
	"log events"
);

@log = ();

eval { require Bar };

is_deeply(
	\@log,
	[
		[ try_require      => generator => $g, file => "Bar.pm", ],
		[ require_finished =>
			generator => $g,
			file => "Bar.pm",
			matched_file => undef,
			error => "Can't locate Bar.pm in \@INC (\@INC contains: @INC) at " . __FILE__ . " line 41.\n",
			return_value => undef
		],
	],
	"log events"
);

@log = ();

eval { require File::Find };

@log = @log[0,-1]; # don't care about what File::Find.pm required

is_deeply(
	\@log,
	[
		[ try_require      => generator => $g, file => "File/Find.pm", ],
		[ require_finished =>
			generator => $g,
			file => "File/Find.pm",
			matched_file => $INC{"File/Find.pm"},
			error => "",
			return_value => 1,
		],
	],
	"log events"
);

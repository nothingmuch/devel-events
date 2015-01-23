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

eval { require "this_file_does_not_exist.pm" };

my $file_check = [
    [ try_require      => generator => $g, file => "this_file_does_not_exist.pm", ],
    [ require_finished =>
        generator => $g,
        file => "this_file_does_not_exist.pm",
        matched_file => undef,
        error => "Can't locate this_file_does_not_exist.pm in \@INC (\@INC contains: @INC) at " . __FILE__ . " line 22.\n",
    ],
];

like $log[1]->[8], qr{Can't locate this_file_does_not_exist\.pm in \@INC};

$file_check->[1]->[8] = $log[1]->[8];

is_deeply \@log, $file_check, "log events";

@log = ();

eval { require This::Module::Does::Not::Exist };

my $module_check = [
    [ try_require      => generator => $g, file => "This/Module/Does/Not/Exist.pm", ],
    [ require_finished =>
        generator => $g,
        file => "This/Module/Does/Not/Exist.pm",
        matched_file => undef,
        error => "Can't locate This/Module/Does/Not/Exist.pm in \@INC (\@INC contains: @INC) at " . __FILE__ . " line 40.\n",
    ],
];

like $log[1]->[8], qr{Can't locate This/Module/Does/Not/Exist\.pm in \@INC};

$module_check->[1]->[8] = $log[1]->[8];

is_deeply \@log, $module_check, "log events";

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
			return_value => 1,
		],
	],
	"log events"
);

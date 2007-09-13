#!/usr/bin/perl -w

use strict;

use ExtUtils::MakeMaker;

WriteMakefile(
	NAME         => 'Devel::Events',
	VERSION_FROM => 'lib/Devel/Events.pm',
	INSTALLDIRS  => 'site',
	SIGN         => 1,
	PL_FILES     => { },
	PREREQ_PM    => {
		'Moose'                    => '0.18',
		'MooseX::AttributeHelpers' => 0,
		'Set::Object'              => 0,
		'Time::HiRes'              => 0,
	},
);


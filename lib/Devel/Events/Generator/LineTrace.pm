#!/usr/bin/perl

package Devel::Events::Generator::LineTrace;
use Moose;

with qw/Devel::Events::Generator/;

use Scalar::Util qw/weaken/;

my $SINGLETON;

sub DB::DB {
	if ( $SINGLETON ) {
		my ( $package, $file, $line ) = caller;
		return if $package eq __PACKAGE__;
		$SINGLETON->line( package => $package, file => $file, line => $line );
	}
}

sub enable {
	my $self = shift;
	$SINGLETON = $self;
	weaken($SINGLETON);
}

sub disable {
	$SINGLETON = undef;
}

sub line {
	my ( $self, @args ) = @_;
	$self->send_event( executing_line => @args );
}

__PACKAGE__;

__END__

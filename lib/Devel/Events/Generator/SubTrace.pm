#!/usr/bin/perl

BEGIN { $^P |= 0x01 }

package Devel::Events::Generator::SubTrace;
use Moose;

with qw/Devel::Events::Generator/;

use Scalar::Util ();
use Sub::ScopeFinalizer ();

my ( $SINGLETON );
our ( $IGNORE, $DEPTH ); # can't local a lexical ;_;

BEGIN { $DEPTH = -1 };

{
	package DB;

	our $sub;

	sub sub {
		local $DEPTH = $DEPTH + 1;

		unless ( $SINGLETON
			and  !$IGNORE,
			and  $sub !~ /^Devel::Events::/
		) {
			no strict 'refs';
			goto &$sub;
		}

		my @ret;
		my $ret;

		my $tsub ="$sub";
		$tsub = 'main' unless $tsub;

		my @args = (
			'name'      => "$tsub",
			'code'      => \&$tsub,
			'args'      => [ @_ ],
			'depth'     => $DEPTH,
			'wantarray' => wantarray(),
		);

		push @args, autoload => do { no strict 'refs'; $$tsub }
			if (( length($tsub) > 10) && (substr( $tsub, -10, 10 ) eq '::AUTOLOAD' ));

		$SINGLETON->enter_sub(@args);

		{
			no strict 'refs';

			if (wantarray) {
				@ret = &$sub;
			}
			elsif (defined wantarray) {
				$ret = &$sub;
			}
			else {
				&$sub;
			}
		}

		$SINGLETON->leave_sub(@args);

		return (wantarray) ? @ret : defined(wantarray) ? $ret : undef;
	}
}

sub enter_sub {
	my ( $self, @data ) = @_;
	local $IGNORE = 1;

	$self->send_event( enter_sub => @data );
}

sub leave_sub {
	my ( $self, @data ) = @_;
	local $IGNORE = 1;

	$self->send_event( leave_sub => @data );
}

sub enable {
	my $self = shift;
	local $IGNORE = 1;
	$SINGLETON = $self;
	Scalar::Util::weaken($SINGLETON);
}

sub disable {
	$SINGLETON = undef;
}

__PACKAGE__;

__END__

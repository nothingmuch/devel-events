#!/usr/bin/perl

package Devel::Events::Generator::Objects;

my $SINGLETON;

BEGIN {
	# before Moose or anything else is parsed, we overload CORE::GLOBAL::bless
	# this will divert bless to an object of our choosing if that variable is filled with something

	*CORE::GLOBAL::bless = sub {
		if ( defined $SINGLETON ) {
			return $SINGLETON->bless(@_);
		} else {
			_core_bless(@_);
		}
	}
}

sub _core_bless {
	my ( $data, $class ) = @_;
	$class = caller unless defined $class;
	CORE::bless($data, $class);
}

use Moose;

with qw/Devel::Events::Generator/;

use Carp qw/croak/;
use Variable::Magic qw/cast/;
use Scalar::Util qw/reftype blessed/;

{
	no warnings 'redefine';

    # for some reason this breaks at compile time
    # we need this version to preserve errors though
	# hopefully no bad calls to bless() are made during the loading of Moose

	*_core_bless = sub {
		my ( $data, $class ) = @_;
		$class = caller unless defined $class;

		my ( $object, $e );
		
		{
			local $@;
			$object = eval { CORE::bless($data, $class) };
			$e = $@;
		}

		if ( $object ) { # can't do CORE::bless(@_) due to proto, can't do &CORE::bless(@_) due to no such sub
			return $object;
		} else {
			my $line = __LINE__ - 7;
			my $file = quotemeta(__FILE__);

			$e =~ s/ at $file line $line\.\n$//o;

			croak($e);
		}
	};
}

sub handle_global_bless {
	my $self = shift;
	$SINGLETON = $self;
}

sub clear_global_bless {
	$SINGLETON = undef;
}

sub bless {
	my ( $self, $data, $class ) = @_;
	$class = caller unless defined $class;

	my $old_class = blessed($data);

	my $object = _core_bless( $data, $class );

	$self->object_bless( $object, old_class => $old_class );

	return $object;
}


sub object_bless {
    my ( $self, $object, @args ) = @_;

	$self->generate_event( object_bless => object => $object, @args );
	
	$self->track_object($object);
}

sub object_destroy {
	my ( $self, $object, @args ) = @_;

	$self->generate_event( object_destroy => object => $object, @args );

	$self->untrack_object( $object );
}

sub generate_event {
	my ( $self, $type, @event ) = @_;

	$self->send_event( $type => ( @event, generator => $self ) );
}

use constant tracker_magic => Variable::Magic::wizard(
	free => sub {
		my ( $object, $self ) = @_;
		$self->object_destroy( $object ) if defined $self; # might disappear in global destruction
	},
	data => sub {
		my ( $object, $self ) = @_;
		return $self;
	},
);

sub track_object {
	my ( $self, $object ) = @_;

    if ( reftype $object eq 'SCALAR' ) {
		cast( $$object, $self->tracker_magic($object), $self );
    } elsif ( reftype $object eq 'HASH' ) {
        cast( %$object, $self->tracker_magic($object), $self );
    } elsif ( reftype $object eq 'ARRAY' ) {
        cast( @$object, $self->tracker_magic($object), $self );
    } elsif ( reftype $object eq 'GLOB' or reftpe $object eq 'IO' ) {
        cast( *$object, $self->tracker_magic($object), $self );
    } else {
        warn "patches welcome: " . reftype($object);
    }
}

sub untrack_object {
	my ( $self, $object );

	return;
}

__PACKAGE__;

__END__



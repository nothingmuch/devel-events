#!/usr/bin/perl

package Devel::Events::Filter::RemoveFields;
use Moose;

with qw/Devel::Events::Filter/;

has fields => (
	isa => "ArrayRef",
	is  => "ro",
	required   => 1,
	auto_deref => 1,
);

has _fields_hash => (
	isa  => "HashRef",
	is   => "ro",
	lazy => 1,
	default => sub {
		my $self = shift;
		return { map { $_ => undef } $self->fields };
	}
);

sub filter_event {
	my ( $self, $type, @data ) = @_;

	my $fields = $self->_fields_hash;
	
	my @ret;
	while ( @data ) {
		my ( $key, $value ) = splice( @data, 0, 2 );
		push @ret, $key, $value unless exists $fields->{$key};
	}

	return ( $type, @ret );
}


__PACKAGE__;

__END__

=pod

=head1 NAME

Devel::Events::Filter::RemoveFields - Remove certain fields from events

=head1 SYNOPSIS

	use Devel::Events::Filter::RemoveFields;

	my $f = Devel::Events::Filter::RemoveFields->new(
		fields => [qw/generator/],
		handler => $h,
	);

	# all events delivered to $f will be proxied to $h without any 'generator'
	# field.

	# field order and multiple instances of a field won't be affected

=head1 DESCRIPTION

=cut



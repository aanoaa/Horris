package Horris::Connection::Plugin::Join;
use Moose;
extends 'Horris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

has channels => (
	is => 'ro', 
	isa => 'ArrayRef', 
);

sub on_connect {
	my ($self) = @_;
	$self->connection->irc->send_srv(JOIN => $_) for @{ $self->channels };
}

1;

__END__

=pod

=head1 NAME

Horris::Connection::Plugin::Join

=head1 SYNOPSIS

	...

=cut

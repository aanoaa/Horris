package Horris::Connection::Plugin::Hit;
use Moose;
extends 'Horris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

has texts => (
	is => 'ro', 
	isa => 'ArrayRef', 
);

sub irc_privmsg {
	my ($self, $message) = @_;
	my $msg = $message->message;
	my $botname = $self->connection->nickname;
	if (my ($nick) = $msg =~ m/^$botname\S*\s+[(:?dis|hit)]+\s+(\w+)/i) {
		$self->connection->irc_privmsg({
			channel => $message->channel, 
			message => $nick . ': ' . $self->texts->[int(rand(scalar @{ $self->texts }))]
		});
	}
}

1;

__END__

=pod

=head1 NAME

Horris::Connection::Plugin::Hit

=head1 SYNOPSIS

	...

=cut

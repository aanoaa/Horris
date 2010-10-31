package Morris::Connection::Plugin::Restart;
use Moose;
extends 'Morris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

sub irc_privmsg {
	my ($self, $msg) = @_;
	my $message = $msg->message;
	$self->connection->irc->disconnect if $message =~ m/^(restart|reconnect|다시들와)$/;
}

sub disconnect {
	my ($self) = @_;
	$self->connection->irc->connect($self->connection->server, $self->connection->port, {
		nick => $self->connection->nickname,
		user => $self->connection->username,
		password => $self->connection->password,
		timeout => 1,
	});
}

1;

__END__

=pod

=head1 NAME

Morris::Connection::Plugin::Restart

=head1 SYNOPSIS

	botname bar [--help|-h]

=cut

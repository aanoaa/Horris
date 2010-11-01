package Morris::Connection::Plugin::Restart;
use Moose;
extends 'Morris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

sub snippet {
	return "restart";
}

sub irc_privmsg {
	my ($self, $message) = @_;
	my $msg = $message->message;
	my $botname = $self->connection->nickname;
	my ($cmd, $raw_opts_args) = $msg =~ m/^$botname\S*\s+(\w+)\s*(.*)$/;
	if (defined $cmd) {
		$self->connection->irc->disconnect if $cmd =~ m/^(restart|reconnect|다시들와)$/i;
		exit(0) if $cmd =~ m/^(quit|exit|disconnect|꺼져|껒여)$/i;
	}
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

=head2 RESTART

	botname restart
	botname reconnect
	botname 다시들와

=head2 KILL

	botname exit
	botname disconnect
	botname 꺼져
	botname 껒여

=cut

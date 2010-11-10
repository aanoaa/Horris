package Horris::Connection::Plugin::PowerManager;
use Moose;
extends 'Horris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

sub irc_privmsg {
	my ($self, $message) = @_;
	my $msg = $message->message;
	my $botname = $self->connection->nickname;
	$self->connection->irc->disconnect if $msg =~ m{^$botname\S*\s+(:?꺼져|껒여|exit|quit)};
}

sub on_disconnect {
	exit(0);
}

1;

__END__

=pod

=head1 NAME

Horris::Connection::Plugin::PowerManager

=head1 SYNOPSIS

	...

=cut

package Horris::Connection::Plugin::Echo;
use Moose;
extends 'Horris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

has '+is_enable' => (
	default => 0
);

sub irc_privmsg {
	my ($self, $message) = @_;
	my $msg = $message->message;
	my $botname = $self->connection->nickname;
	my ($cmd) = $msg =~ m/^$botname\S*\s+(\w+)/;
	
	if (defined $cmd and lc $cmd eq 'echo') {
		$self->_switch;
		$self->connection->irc_notice({
			channel => $message->channel, 
			message => $self->is_enable ? '[echo] on' : '[echo] off'
		});
	} elsif ($self->is_enable) {
		$self->connection->irc_privmsg({
			channel => $message->channel, 
			message => $message->from->nickname . ': ' . $msg
		});
	}
}

1;

__END__

=pod

=head1 NAME

Horris::Connection::Plugin::Echo

=head1 SYNOPSIS

	botname echo [on|off]

=cut

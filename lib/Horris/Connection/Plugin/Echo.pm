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
	my ($cmd, $raw_opts_args) = $msg =~ m/^$botname\S*\s+(\w+)\s*(.*)$/;

	if (defined $cmd and lc $cmd eq 'echo' and defined $raw_opts_args) {
		$self->enable if $raw_opts_args eq 'on';
		$self->disable if $raw_opts_args eq 'off';
		if ($raw_opts_args eq 'help') {
			$self->connection->irc_privmsg({
				channel => $message->channel, 
				message => $self->help
			});
		}
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

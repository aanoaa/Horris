package Morris::Connection::Plugin::Echo;
use Moose;
extends 'Morris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

has enable => (
	is => 'rw', 
	isa => 'Bool', 
	default => 0
);

sub snippet {
	return "echo";
}

sub irc_privmsg {
	my ($self, $message) = @_;
	my $msg = $message->message;
	my $botname = $self->connection->nickname;
	my ($cmd, $raw_opts_args) = $msg =~ m/^$botname\S*\s+(\w+)\s*(.*)$/;
	if (defined $cmd and defined $raw_opts_args) {
		$self->enable(1) if $raw_opts_args eq 'on';
		$self->enable(0) if $raw_opts_args eq 'off';
	} elsif ($self->enable) {
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

Morris::Connection::Plugin::Echo

=head1 SYNOPSIS

	botname echo [on|off]

=cut

package Morris::Connection::Plugin::Echo;
use Moose;
extends 'Morris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

has enable => (
	is => 'rw', 
	isa => 'Bool', 
	default => 0
);

sub irc_privmsg {
	my ($self, $msg) = @_;
	my $message = $msg->message;
	my $botname = $self->connection->nickname;
	my ($cmd, $raw_options_args) = $message =~ m/^$botname[\S]*[\s]+(\w+)[\s]+(.*)$/;
	if ($cmd eq 'echo' and defined $raw_options_args) {
		$self->enable(1) if $raw_options_args eq 'on';
		$self->enable(0) if $raw_options_args eq 'off';
	} elsif ($self->enable) {
		$self->connection->irc_privmsg({
			channel => $msg->channel, 
			message => $msg->from->nickname . ': ' . $msg->message
		});
	}
}

sub help {
	return __PACKAGE__ . "'s help\n";
}

1;

__END__

=pod

=head1 NAME

Morris::Connection::Plugin::Echo

=head1 SYNOPSIS

	echo bot

=cut

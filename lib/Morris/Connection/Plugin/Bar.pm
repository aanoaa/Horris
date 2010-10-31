package Morris::Connection::Plugin::Bar;
use Moose;
extends 'Morris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

sub irc_privmsg {
	my ($self, $msg) = @_;
	# echo
	$self->connection->irc_privmsg({
		channel => $msg->channel, 
		message => '> ' . $msg->message
	});

	# help
}

1;

__END__

=pod

=head1 NAME

Morris::Connection::Plugin::Bar

=head1 SYNOPSIS

	botname bar [--help|-h]

=cut

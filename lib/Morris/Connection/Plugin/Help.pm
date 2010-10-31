package Morris::Connection::Plugin::Help;
use Moose;
extends 'Morris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

sub irc_privmsg {
	my ($self, $msg) = @_;
	my $message = $msg->message;

	if ($message eq 'help') {
		for my $plugin (@{ $self->connection->plugin_list }) {
			$self->connection->irc_privmsg({
				channel => $msg->channel, 
				message => $plugin->help
			});
		}
	}
}

sub help {
	return __PACKAGE__ . "'s help\n";
}

1;

__END__

=pod

=head1 NAME

Morris::Connection::Plugin::Help

=head1 SYNOPSIS

	print out [usage|help]

=cut

package Morris::Connection::Plugin::Help;
use Moose;
use Pod::Usage;
use Getopt::Long;
use IO::Capture::Stderr;
extends 'Morris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

sub irc_privmsg {
	my ($self, $message) = @_;
	my $msg = $message->message;
	my $botname = $self->connection->nickname;
	my ($cmd, $raw_opts_args) = $msg =~ m/^$botname\S*\s+(\w+)\s*(.*)$/;
	return unless (defined $cmd and lc $cmd eq 'help');

	$raw_opts_args =~ s/^\s+//;
	$raw_opts_args =~ s/\s+$//;

	my %options;
	if ($raw_opts_args ne '') {
		local @ARGV = split(/\s+/, $raw_opts_args);
		my $capture = IO::Capture::Stderr->new;
		$capture->start;
		GetOptions(\%options, "--list");
		$capture->stop;

		for my $err ($capture->read) {
			$self->connection->irc_privmsg({
				channel => $message->channel, 
				message => $err
			});
		}

		if ($options{list}) {
			for my $plugin (@{ $self->connection->plugin_list }) {
				if ($plugin->is_enable) {
					$self->connection->irc_privmsg({
						channel => $message->channel, 
						message => $plugin->snippet
					});
				}
			}
		}

		return;
	}

	for my $line ($self->help) {
		$self->connection->irc_privmsg({
			channel => $message->channel, 
			message => $line
		});
	}
}

1;

__END__

=pod

=head1 NAME

Morris::Connection::Plugin::Help

=head1 SYNOPSIS

	botname help [--list]
	botname [COMMAND] [OPTS] ARG ARG ..

=head2 HOW TO GET COMMAND?

C<botname help --list> will return all enabled COMMAND

=cut

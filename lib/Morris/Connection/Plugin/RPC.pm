package Morris::Connection::Plugin::RPC;
use Moose;
use AnyEvent::MP qw(configure port rcv);
use AnyEvent::MP::Global qw(grp_reg);
use namespace::clean -except => qw/meta/;
extends 'Morris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

has '+is_enable' => (
	default => 0
);

use Data::Dumper qw/Dumper/;

after init => sub {
	my $self = shift;
	configure nodeid => "eg_receiver", binds => ["*:4040"];
	my $port = port;
	grp_reg eg_receivers => $port;
	rcv $port, test => sub {
		my ($data) = @_;
		print Dumper($data);
		$self->connection->irc_privmsg({
				#channel => $message->channel, 
			channel => '#aanoaa', 
			message => $data
		});
	}
};

#sub irc_privmsg {
#	my ($self, $message) = @_;
#	my $msg = $message->message;
#	my $botname = $self->connection->nickname;
#	my ($cmd, $raw_opts_args) = $msg =~ m/^$botname\S*\s+(\w+)\s*(.*)$/;
#
#	if (defined $cmd and lc $cmd eq 'echo' and defined $raw_opts_args) {
#		$self->enable if $raw_opts_args eq 'on';
#		$self->disable if $raw_opts_args eq 'off';
#		if ($raw_opts_args eq 'help') {
#			$self->connection->irc_privmsg({
#				channel => $message->channel, 
#				message => $self->help
#			});
#		}
#	} elsif ($self->is_enable) {
#		$self->connection->irc_privmsg({
#			channel => $message->channel, 
#			message => $message->from->nickname . ': ' . $msg
#		});
#	}
#}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

Morris::Connection::Plugin::RPC

=head1 SYNOPSIS

	botname echo [on|off]

=cut

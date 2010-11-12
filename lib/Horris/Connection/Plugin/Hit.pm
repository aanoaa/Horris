package Horris::Connection::Plugin::Hit;
use Moose;
extends 'Horris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

has texts => (
	is => 'ro', 
	isa => 'ArrayRef', 
);

sub irc_privmsg {
	my ($self, $message) = @_;
	my $msg = $message->message;
	my $botname = $self->connection->nickname;
	if (my ($nick, $typed) = $msg =~ m/^$botname\S*\s+[(:?dis|hit)]+\s+(\w+)\s*(.*)$/i) {
		my $output = $nick . ': ';
		$output .= $typed eq '' ? $self->texts->[int(rand(scalar @{ $self->texts }))] : $typed;
		$self->connection->irc_privmsg({
			channel => $message->channel, 
			message => $output
		});
	}
}

sub on_privatemsg {
	my ($self, $nick, $message) = @_;
	my $msg = $message->message;
	if (my ($nick, $typed) = $msg =~ m/^[(:?dis|hit)]+\s+(\w+)\s*(.*)$/i) {
		my $output = $nick . ': ';
		$output .= $typed eq '' ? $self->texts->[int(rand(scalar @{ $self->texts }))] : $typed;
		my %channel_list = %{ $self->connection->irc->channel_list };
		for my $channel (keys %channel_list) {
			if (grep { m/$nick/ } keys %{ $channel_list{$channel} }) {
				$self->connection->irc_privmsg({
					channel => $channel, 
					message => $output
				});
			}
		}
	}
}

1;

__END__

=pod

=head1 NAME

Horris::Connection::Plugin::Hit

=head1 SYNOPSIS

	...

=cut

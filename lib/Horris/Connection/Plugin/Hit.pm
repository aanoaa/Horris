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
	if (my ($nick) = $msg =~ m/^$botname\S*\s+[(:?dis|hit)]+\s+(\w+)/i) {
		$self->connection->irc_privmsg({
			channel => $message->channel, 
			message => $nick . ': ' . $self->texts->[int(rand(scalar @{ $self->texts }))]
		});
	}
}

sub on_privatemsg {
	my ($self, $nick, $message) = @_;
	my $msg = $message->message;
	if (my ($nick) = $msg =~ m/^[(:?dis|hit)]+\s+(\w+)/i) {
		my %channel_list = %{ $self->connection->irc->channel_list };
		for my $channel (keys %channel_list) {
			if (grep { m/$nick/ } keys %{ $channel_list{$channel} }) {
				$self->connection->irc_privmsg({
					channel => $channel, 
					message => $nick . ': ' . $self->texts->[int(rand(scalar @{ $self->texts }))]
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

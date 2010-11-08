package Horris::Connection::Plugin::Eng2kor;
use Moose;
use App::eng2kor;
use Encode qw/decode/;
extends 'Horris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

has app => (
	is => 'ro', 
	isa => 'App::eng2kor', 
	lazy_build => 1
);

sub _build_app { new App::eng2kor }

sub irc_privmsg {
	my ($self, $message) = @_;
	my $msg = $message->message;
	my $botname = $self->connection->nickname;
	if (my ($source) = $msg =~ m/^$botname\S*\s+[(:?eng2kor|e2k)]+\s+(.*)$/i) {
		my @result = $self->app->translate($source);
		for my $item (@result) {
			print decode('utf8', $item->{translated}), "\n";
			$self->connection->irc_privmsg({
				channel => $message->channel, 
				#message => $item->{origin} . ': ' . decode('utf8', $item->{translated})
				message => $item->{origin}
			});
		}
	}
}

1;

__END__

=pod

=head1 NAME

Horris::Connection::Plugin::Eng2kor

=head1 SYNOPSIS

	...

=cut

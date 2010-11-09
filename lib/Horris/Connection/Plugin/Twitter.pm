package Horris::Connection::Plugin::Twitter;
use Moose;
use HTTP::Request;
use HTTP::Response;
use LWP::UserAgent;
extends 'Horris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

sub irc_privmsg {
	my ($self, $message) = @_;
	my $url = $message->message;
	$url =~ s/#!\///;
	if ($url !~ m{^\s*http://twitter.com/(.*)?/status/[0-9]+\s*$}) {
		return;
	}

	print "recv Twitter URI\n" if $Horris::DEBUG;

	my $msg;
	my $request  = HTTP::Request->new( GET => $url );
	my $ua       = LWP::UserAgent->new;
	my $response = $ua->request($request);
	$msg = $response->status_line unless $response->is_success;
	($msg) = $response->content =~ m{<meta content="(.*?)" name="description" />};
	$self->connection->irc_notice({
		channel => $message->channel, 
		message => $msg
	});
}

1;

__END__

=pod

=head1 NAME

Horris::Connection::Plugin::Twitter

=head1 SYNOPSIS

	...

=cut

package Horris::Connection::Plugin::Eval;
use Moose;
use JSON;
use URI::Escape;
use HTTP::Request;
use LWP::UserAgent;
extends 'Horris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

sub irc_privmsg {
	my ($self, $message) = @_;
	my $msg = $self->_eval($message);

	return unless defined $msg;

    for (split /\n/, $msg) {
	    $self->connection->irc_privmsg({
		    channel => $message->channel, 
		    message => $_
	    });
    }
}

sub _eval {
	my ($self, $message) = @_;
	my $raw = $message->message;

	unless ($raw =~ m/^eval/i) {
        return undef;
    }

    $raw =~ s/^eval[\S]*\s+//;
    $raw = "#!/usr/bin/perl\n" . $raw;
    my $uri = "http://api.dan.co.jp/lleval.cgi?s=" . URI::Escape::uri_escape_utf8($raw);
    my $ua  = LWP::UserAgent->new;
    my $req = HTTP::Request->new(GET => $uri);
    my $res = $ua->request($req);
    if ($res->is_success) {
        my $scalar = JSON::from_json($res->content, { utf8  => 1 });
        return $scalar->{stderr} eq '' ? $self->decode_hex($scalar->{stdout}) : $scalar->{stderr};
    } else {
        return $res->status_line;
    }
}

sub decode_hex {
    my ($self, $hex) = @_;
    $hex =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
    return $hex;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

Horris::Connection::Plugin::Eval

=head1 SYNOPSIS

evaluate perl code

=head1 SEE ALSO

L<http://colabv6.dan.co.jp/lleval.html>

=cut

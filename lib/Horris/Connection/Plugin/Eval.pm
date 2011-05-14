package Horris::Connection::Plugin::Eval;
# ABSTRACT: Evaluate Plugin on Horris

=head1 SYNOPSIS

    # assume here at a irc channel
    HH:MM:SS    NICK | eval print 'hello world'
    HH:MM:SS BOTNAME | hello world
    HH:MM:SS    NICK | eval use 5.0.10; say $^V
    HH:MM:SS BOTNAME | v5.10.1

=head1 DESCRIPTION

Evaluate perl code using L<http://colabv6.dan.co.jp/lleval.html>

=head1 SEE ALSO

L<http://colabv6.dan.co.jp/lleval.html>

=cut

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

    return $self->pass;
}

sub _eval {
    my ($self, $message) = @_;
    my $raw = $message->message;

    unless ($raw =~ m/^eval/i) {
        return undef;
    }

    $raw =~ s/^eval[\S]*\s+//i;
    $raw = "#!/usr/bin/perl\n" . $raw;
    my $uri = "http://api.dan.co.jp/lleval.cgi?s=" . URI::Escape::uri_escape_utf8($raw);
    my $ua  = LWP::UserAgent->new;
    my $req = HTTP::Request->new(GET => $uri);
    my $res = $ua->request($req);
    if ($res->is_success) {
        my $scalar = JSON::from_json($res->content, { utf8  => 1 });
        return $scalar->{stderr} eq '' ? $scalar->{stdout} : $scalar->{stderr};
    } else {
        return $res->status_line;
    }
}

__PACKAGE__->meta->make_immutable;

1;

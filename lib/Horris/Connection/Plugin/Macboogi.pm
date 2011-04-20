package Horris::Connection::Plugin::Macboogi;
# ABSTRACT: Macboogiuate Plugin on Horris

=head1 SYNOPSIS

    # assume here at a irc channel
    HH:MM:SS    NICK | macboogi 안녕
    HH:MM:SS BOTNAME | 아ㄴ녀ㅇ

=head1 DESCRIPTION

What The Descrption?

=cut

use utf8;
use Moose;
use Encode qw/encode decode/;
extends 'Horris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

sub irc_privmsg {
    my ($self, $message) = @_;
    my $msg = $self->_process($message);

    return unless defined $msg;

    for (split /\n/, $msg) {
        $self->connection->irc_privmsg({
            channel => $message->channel, 
            message => $_
        });
    }

    return $self->pass;
}

sub _process {
    my ($self, $message) = @_;
    my $raw = $message->message;

    unless ($raw =~ m/^macboogi/i) {
        return undef;
    }

    $raw =~ s/^macboogi[\S]*\s+//i;
#    $raw = "#!/usr/bin/perl\n" . $raw;
#    my $uri = "http://api.dan.co.jp/lleval.cgi?s=" . URI::Escape::uri_escape_utf8($raw);
#    my $ua  = LWP::UserAgent->new;
#    my $req = HTTP::Request->new(GET => $uri);
#    my $res = $ua->request($req);
#    if ($res->is_success) {
#        my $scalar = JSON::from_json($res->content, { utf8  => 1 });
#        return $scalar->{stderr} eq '' ? $scalar->{stdout} : $scalar->{stderr};
#    } else {
#        return $res->status_line;
#    }
}

__PACKAGE__->meta->make_immutable;

1;

package Horris::Connection::Plugin::Echo;
# ABSTRACT: Echo Plugin on Horris

=head1 SYNOPSIS

    # assume here at a irc channel
    HH:MM:SS    NICK | BOTNAME echo
    HH:MM:SS    NICK | hi
    HH:MM:SS      -- | Notice(BOTNAME) echo on
    HH:MM:SS BOTNAME | NICK: hi
    HH:MM:SS    NICK | BOTNAME echo
    HH:MM:SS      -- | Notice(BOTNAME) echo off
    HH:MM:SS    NICK | hi
    # and no echo here..

=head1 DESCRIPTION

anybody can toggle BOT's echo feature by C<BOTNAME echo> command.

=cut

use Moose;
extends 'Horris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

has '+is_enable' => (
    default => 0
);

sub irc_privmsg {
    my ($self, $message) = @_;
    my $msg = $message->message;
    my $botname = $self->connection->nickname;
    my ($cmd) = $msg =~ m/^$botname\S*\s+(\w+)/;

    if (defined $cmd and lc $cmd eq 'echo') {
        $self->_switch;
        $self->connection->irc_notice({
            channel => $message->channel,
            message => $self->is_enable ? '[echo] on' : '[echo] off'
        });
    } elsif ($self->is_enable) {
        $self->connection->irc_privmsg({
            channel => $message->channel,
            message => $message->from->nickname . ': ' . $msg
        });
    }

    return $self->pass;
}

__PACKAGE__->meta->make_immutable;

1;

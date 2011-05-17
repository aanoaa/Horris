package Horris::Connection::Plugin::Ignore;
# ABSTRACT: Ignore Plugin on Horris

=head1 SYNOPSIS

Ignore specific user (like bot)

    BOTNAME ignore help

Configuration file:

    <Config>
        <Connection freenode>
            Network freenode

            LoadModule Ignore
            LoadModule Echo
            ...

            <Plugin Ignore>
                <channel>
                    <lotto>
                        jeenbot 1
                        hongbot 1
                    </lotto>
                </channel>
            </Plugin>
            <Plugin Echo/>
            ...
        </Connection>
        ...
    </Config>

=head1 DESCRIPTION

To prevent flooding user who like bot speaking will be ignored.

=cut

use 5.010;
use Moose;
extends 'Horris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

has channel => (
    is  => 'ro',
    isa => 'HashRef',
);

sub irc_privmsg {
    my ($self, $message) = @_;

    (my $channel = $message->channel) =~ s/^#//;
    my $ignores = $self->channel->{$channel};
    return $self->pass unless $ignores;

    my $botname = $self->connection->nickname;
    my ( $trigger, $ignore, $toggle, $nick )
        = split ' ', $message->message, 4;

    if (
        $trigger =~ /^$botname/
        && $ignore eq 'ignore'
    ) {
        given ($toggle) {
            when ('on') {
                if ($nick) {
                    $ignores->{$nick} = 1;
                    $self->connection->irc_notice({
                        channel => $message->channel,
                        message => "ignore $nick",
                    });
                }
            }
            when ('off') {
                if ($nick) {
                    $ignores->{$nick} = 0;
                    $self->connection->irc_notice({
                        channel => $message->channel,
                        message => "not ignore $nick",
                    });
                }
            }
            when ('list') {
                for ( keys %$ignores ) {
                    next unless $ignores->{$_};

                    $self->connection->irc_privmsg({
                        channel => $message->channel,
                        message => $_,
                    });
                }
            }
            when ('help') {
                my @messages;

                push @messages,  q{Usage:};
                push @messages, qq{  $botname: ignore list};
                push @messages, qq{  $botname: ignore on <nick>};
                push @messages, qq{  $botname: ignore off <nick>};
                push @messages, qq{  $botname: ignore help};

                $self->connection->irc_privmsg({
                    channel => $message->channel,
                    message => $_,
                }) for @messages;
            }
        }
    }

    return $self->done if $ignores->{$message->from->nickname};
    return $self->pass;
}

__PACKAGE__->meta->make_immutable;

1;

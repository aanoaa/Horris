package Horris::Connection::Plugin::LogWriter;
# ABSTRACT: LogWriter Plugin on Horris

=head1 SYNOPSIS

Not yet Implemented.

=head1 DESCRIPTION

Not yet Implemented.

=cut

use 5.010;
use Moose;
use AnyEvent::JSONRPC;
extends 'Horris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

has apikeys => (
    is  => 'ro',
    isa => 'HashRef',
);

has port => (
    is      => 'ro',
    isa     => 'Int',
    default => 9090,
);

my $server;
after init => sub {
    my $self = shift;

    $server = jsonrpc_server '127.0.0.1', $self->port;
    $server->reg_cb(
        logwriter => sub {
            my ($cb, %params) = @_;

            $cb->result('fail', 'parameter is needed'), return
                unless %params;

            my $id     = $params{id};
            my $apikey = $params{apikey};
            my $ch     = $params{channel};
            my $nick   = $params{nick};
            my $msg    = $params{message};

            $cb->result( 'fail', 'id is needed' ),      return unless $id;
            $cb->result( 'fail', 'apikey is needed' ),  return unless $apikey;
            $cb->result( 'fail', 'channel is needed' ), return unless $ch;
            $cb->result( 'fail', 'nick is needed' ),    return unless $nick;
            $cb->result( 'fail', 'message is needed' ), return unless $msg;

            if ( $self->apikeys->{$id} && $self->apikeys->{$id} eq $apikey ) {
                $self->connection->irc_privmsg({
                    channel => $ch,
                    message => "$nick: $msg",
                });

                $cb->result( 'ok' );
            }
            else {
                $cb->result( 'fail', 'unauthorized' );
            }
        },
    );
};

__PACKAGE__->meta->make_immutable;

1;

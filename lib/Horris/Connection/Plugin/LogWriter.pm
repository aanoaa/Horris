package Horris::Connection::Plugin::LogWriter;
# ABSTRACT: LogWriter Plugin on Horris

=head1 SYNOPSIS

You can send message to Horris via JSON-RPC protocol.

    use 5.010;
    use AnyEvent::JSONRPC;
    use Encode qw(decode_utf8);

    my $client = jsonrpc_client '127.0.0.1', '8080';

    my $d = $client->call(
            logwriter => {
            id      => 'logwriter',
            #apikey  => '6d164e9d-27a1-49f2-9b1e-42a27378bef8',
            apikey  => '6d164e9d-27a1-49f2-9b1e-42a27378bef4',
            channel => '#aanoaa',
            nick    => 'keedi',
            message => decode_utf8('Enjoy Perl! ;-)'),
        },
    );

    my $result = $d->recv;
    if (ref $result) {
        say join ':', @$result;
    }
    else {
        say $result;
    }

Configuration file:

    <Config>
        <Connection freenode>
            Network freenode

            LoadModule Echo
            ...
            LoadModule LogWriter

            <Plugin Echo/>
            ...
            <Plugin LogWriter>
                port 8080
                <APIKeys>
                    logwriter    6d164e9d-27a1-49f2-9b1e-42a27378bef4
                    aanoaa-phone 98881796-cbf0-4aaf-b7cf-f780081f84e5
                </APIKeys>
            </Plugin>
        </Connection>
        ...
    </Config>

=head1 DESCRIPTION

LogWriter plugin accept external request
which sends message to IRC channel via Horris.

It uses two parameters from configuration file.

=over

=item * port

Default port is 9090 and you can change port via configuration file.

=item * APIKeys

LogWriter uses apikey authorization.
Only specified client id could send message to Horris.

=back

=cut

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

package Horris::Connection::Plugin::Retry;
use Moose;
use AnyEvent::RetryTimer;
extends 'Horris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

my $timer;
sub on_connect {
    if( $timer ) {
        $timer->success;
        undef $timer;
    }
}
sub on_disconnect {
    my ($self) = @_;
    $timer ||= AnyEvent::RetryTimer->new (
            on_retry => sub {
                my ($timer) = @_;
                $self->connection->irc->connect($self->connection->server, $self->connection->port, {
                    nick => $self->connection->nickname,
                    user => $self->connection->username,
                    password => $self->connection->password,
                    timeout => 1,
                });

                $timer->retry;
            },
    );
}

__PACKAGE__->meta->make_immutable;

1;

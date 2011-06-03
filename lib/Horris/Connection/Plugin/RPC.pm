package Horris::Connection::Plugin::RPC;
# ABSTRACT: RPC Plugin on Horris

=head1 SYNOPSIS

Not yet implemented.

=head1 DESCRIPTION

Not yet implemented.

=cut

use Moose;
use AnyEvent::MP qw(configure port rcv);
use AnyEvent::MP::Global qw(grp_reg);
use namespace::clean -except => qw/meta/;
extends 'Horris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

has '+is_enable' => (
    default => 0
);

after init => sub {
    my $self = shift;
    configure nodeid => "eg_receiver", binds => ["*:4040"];
    my $port = port;
    grp_reg eg_receivers => $port;
    rcv $port, test => sub {
        my ($data) = @_;
        $self->connection->irc_privmsg({
            channel => '#aanoaa', # for test
            message => $data
        });
    }
};

__PACKAGE__->meta->make_immutable;

1;

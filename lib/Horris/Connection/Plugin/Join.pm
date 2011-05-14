package Horris::Connection::Plugin::Join;
# ABSTRACT: Auto Join Channel Plugin on Horris

=head1 SYNOPSIS

BOT connected IRC, then auto joinning typed(config) channel

    # single channel
    <Plugin Join>
        channels [ \#test ] # for a single channel
    </Plugin>

    # multi channels
    <Plugin Join>
        channels #test1
        channels #test2
    </Plugin>

=cut

use Moose;
extends 'Horris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

has channels => (
    is => 'ro', 
    isa => 'ArrayRef', 
);

sub on_connect {
    my ($self) = @_;
    $self->connection->irc->send_srv(JOIN => $_) for @{ $self->channels };
    return $self->pass;
}

__PACKAGE__->meta->make_immutable;

1;

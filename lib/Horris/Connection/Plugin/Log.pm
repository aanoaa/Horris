package Horris::Connection::Plugin::Log;
# ABSTRACT: Log to Database plugin for Horris
use Moose;
use AnyEvent::DBI;
use namespace::autoclean;
extends 'Horris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

has dsn => (
    is => 'ro',
    isa => 'Str'
);

has username => (
    is => 'ro',
    isa => 'Str'
);

has password => (
    is => 'ro',
    isa => 'Str'
);

has dbh => (
    is => 'ro',
    isa => 'Object',
    lazy_build => 1,
);

sub _build_dbh {
    my ($self) = @_;
    return AnyEvent::DBI->new(
        $self->{dsn},
        $self->{username},
        $self->{password}
    );  
}

=head1 METHODS

=head2 irc_privmsg

hook method that invoked by connection instance about all private message event.

=cut

sub irc_privmsg {
    my ($self, $message) = @_;
    $self->_log($message);
    return $self->pass;
}

=head2 _log

make a row for log and insert to Database.

=cut

sub gmt_today {
    my @d = gmtime(time);
    return sprintf("%04d-%02d-%02d", $d[5]+1900, $d[4] + 1, $d[3]);
}

sub _log {
    my ($self, $message) = @_;
    $self->dbh->exec("INSERT INTO irclog (channel, day, nick, timestamp, line) VALUES(?, ?, ?, ?, ?)",
        $message->channel,
        gmt_today(),
        $message->from->nickname,
        time,
        $message->message,
        sub {
            my ($dbh, $rows, $rv) = @_;
            # do something
        }
    );
}

__PACKAGE__->meta->make_immutable;

=head1 SYNOPSIS

F<hongbot.conf>

    <Log>
        dsn         dbi:mysql:DATABASE
        username    susan
        password    secret_number
    </Log>

=head1 DESCRIPTION

Should have top priority at configutaion.

=cut

1;

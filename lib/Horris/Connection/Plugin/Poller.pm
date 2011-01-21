package Horris::Connection::Plugin::Poller;
use Moose;
use DBI;
use Data::Dumper;
extends 'Horris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

use constant {
    ROWID  => 0,
    MSG_ID => 1,
    TIME   => 2,
    SEND   => 3,
    MSG    => 4,
};

has channel => (
    is => 'ro',
    isa => 'HashRef',
);

has dbfile => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

my $w;
my $dbh;
my $sth_select;
my $sth_update;
my $interval = 3;

sub on_connect {

    warn __PACKAGE__ . " on_connect\n";

    my ($self) = @_;

    # create table messages (msg_id text, time int, send int, msg text);

    my $dbfile = $self->dbfile;
    $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile", "", "");
    $sth_select = $dbh->prepare("SELECT rowid, msg_id, time, send, msg FROM messages WHERE send=0 and time > 1295640655");
    $sth_update = $dbh->prepare("UPDATE messages SET send=1 WHERE rowid=?");

    # Polling $self->dbfile every $interval secs.
    $w = AnyEvent->timer(
        after       => 10,
        interval    => $interval,
        cb          => sub {

            my %anti_excess;

            # select messages to say
            $sth_select->execute;
            foreach my $row (@{ $sth_select->fetchall_arrayref }) {

                warn 'Poller : ' . join(", ", @$row);

                foreach my $channel (keys %{ $self->channel }) {
                    for my $feed (@{ $self->channel->{$channel}->{feed} }) {

                        if($row->[MSG_ID] eq $feed) {

                            # drop '\' from channel name
                            my $cname = substr $channel, 1;

                            $self->connection->irc_privmsg({
                                channel => $cname,
                                message => $row->[MSG],
                            });

                            if($anti_excess{ scalar time }++ > 3) {
                                print Dumper(\%anti_excess);
                                sleep 5;
                            }
                        }

                    }
                }

                $sth_update->execute($row->[ROWID]);
            }
        },
    );

    $self->pass;
}

sub on_disconnect {
    undef $w;
    undef $sth_select;
    undef $sth_update;
    undef $dbh;
}

__PACKAGE__->meta->make_immutable;

1;

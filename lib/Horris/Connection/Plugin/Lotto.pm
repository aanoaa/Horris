package Horris::Connection::Plugin::Lotto;
# ABSTRACT: Lotto Plugin on Horris

=head1 SYNOPSIS

Lotto!  Change your life! :-)

    BOTNAME lotto help

=head1 DESCRIPTION

anybody can run BOT's lotto feature by C<BOTNAME lotto> command.

=cut

use 5.010;
use Moose;
use Readonly;
use Text::CSV;
use List::Util qw/shuffle/;
use List::MoreUtils qw/each_array/;

extends 'Horris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

Readonly::Scalar my $ENTRY => q{yongbin,keedi,aanoaa,jeen,mintegrals,"Zeus 7000","SyncMaster CX919B by am0c","SyncMaster 179N","SyncMaster 20","Antique Desk"};

has _entry => (
    is      => 'rw',
    isa     => 'Str',
    default => $ENTRY,
);

sub _get_entry_pair {
    my $self = shift;

    my $entry = $self->_entry;
    return unless $entry;

    my $csv = Text::CSV->new( { binary => 1 } );
    $csv->parse($self->_entry);
    my @fields = $csv->fields;

    my $idx = (@fields + 1) / 2;

    return [@fields[0 .. $idx - 1]], [@fields[$idx ..  $#fields]];
}

sub irc_privmsg {
    my ($self, $message) = @_;

    my $msg = $message->message;
    my $botname = $self->connection->nickname;
    my ( $trigger, $lotto, $cmd, $args ) = split ' ', $msg, 4;

    return $self->pass unless $trigger eq "$botname:";
    return $self->pass unless $lotto eq 'lotto';

    my @messages;
    given ( $cmd ) {
        when ('add') {
            $self->_entry($args);
        }
        when ('reset') {
            $self->_entry(q{});
        }
        when ('list') {
            my ( $pair_a, $pair_b ) = $self->_get_entry_pair;

            break unless $pair_a;
            break unless $pair_b;

            push @messages, join('-', @$pair_a);
            push @messages, join('-', @$pair_b);
        }
        when ('run') {
            my ( $pair_a, $pair_b ) = $self->_get_entry_pair;

            break unless $pair_a;
            break unless $pair_b;

            my @result_a = shuffle @$pair_a;
            my @result_b = shuffle @$pair_b;

            my $ea = each_array( @result_a, @result_b );
            while ( my ( $a, $b ) = $ea->() ) {
                $b //= 'Sorry. :-(';
                push @messages, "$a - $b";
            }
        }
        when ('help') {
            push @messages,  q{Usage:};
            push @messages, qq{  $botname: lotto reset};
            push @messages, qq{  $botname: lotto add } . $ENTRY;
            push @messages, qq{  $botname: lotto list};
            push @messages, qq{  $botname: lotto run};
            push @messages, qq{  $botname: lotto help};
        }
    }

    return $self->pass unless @messages;

    $self->connection->irc_privmsg({
        channel => $message->channel,
        message => $_,
    }) for @messages;

    return $self->pass;
}

__PACKAGE__->meta->make_immutable;

1;

package Horris::Connection::Plugin::Bugzilla;
# ABSTRACT: Bugzilla Plugin on Horris

=head1 SYNOPSIS

Give information about a bug of bugzilla.

Configuration file:

    <Config>
        <Connection freenode>
            Network freenode

            LoadModule Echo
            ...
            LoadModule Bugzilla

            <Plugin Echo/>
            ...
            <Plugin Bugzilla>
                <bot silex>
                    channel  #silex
                    xmlrpc   http://bugzilla.silex.kr/xmlrpc.cgi
                    showbug  http://bugzilla.silex.kr/show_bug.cgi?id=%s
                    user     bot@bugzilla.silex.kr
                    password passwordofbot
                    keyword  bug
                </bot>
                <bot seoulpm>
                    channel  #seoulpm
                    xmlrpc   http://bugzilla.perl.kr/xmlrpc.cgi
                    showbug  http://bugzilla.perl.kr/show_bug.cgi?id=%s
                    user     bot@bugzilla.perl.kr
                    password passwordofbot
                    keyword  이슈|버그|bug
                </bot>
            </Plugin>
        </Connection>
        ...
    </Config>

=head1 DESCRIPTION

Bugzilla plugin parses user message then
give information about a bug to everyone.

It uses a bot parameter from configuration file.
C<bot> parameter has six sub parameters

=over

=item * channel

Specify which channel needs bugzilla support.

=item * xmlrpc

Bugzilla XML-RPC server url.

=item * showbug

Bugzilla show bug cgi url.

=item * user
=item * password

Bugzilla username and password.

=item * keyword

Trigger for activate bugzilla plugin.

=item * timezone

Display datetime with local time

=back

=cut

use utf8;
use Moose;
use BZ::Client;
use BZ::Client::Bug;
use Encode qw(encode_utf8);

extends 'Horris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

has bot => (
    is  => 'ro',
    isa => 'HashRef',
);

sub irc_privmsg {
    my ($self, $message) = @_;

    my $msg = $message->message;
    my @bots = map {
        $self->bot->{$_}{channel} eq $message->channel ? $self->bot->{$_} : ()
    } keys %{ $self->bot };
    for my $bot ( @bots ) {
        my $keyword = qr|$bot->{keyword}|i;
        my @bug_numbers = $msg =~ m/$keyword\s+(\w+)/g;

        my $client = BZ::Client->new(
            'url'      => $bot->{xmlrpc},
            'user'     => $bot->{user},
            'password' => $bot->{password},
        );
        $client->login;
        my $bugs = BZ::Client::Bug->get($client, [ @bug_numbers ]);

        for my $bug ( @$bugs ) {

            my ( $y, $m, $d, $h, $mm, $s )
                = $bug->last_change_time =~ m/(....)(..)(..)T(..):(..):(..)/g;
            my $last_dt = DateTime->new(
                time_zone => 'UTC',
                year      => $y,
                month     => $m,
                day       => $d,
                hour      => $h,
                minute    => $mm,
                second    => $s,
            );
            $last_dt->set_time_zone( $bot->{timezone} ) if $bot->{timezone};

            my $result = sprintf(
                q{[Bug %s] %s - %s %s - %s(%s)},
                $bug->id,
                $bug->summary,
                $last_dt->ymd,
                $last_dt->hms,
                $bug->assigned_to,
                $bug->status,
            );
            $result .= sprintf(' - ' . $bot->{showbug}, $bug->id) if $bot->{showbug};

            $self->connection->irc_privmsg({
                channel => $message->channel,
                message => encode_utf8($result),
            });
        }
    }

    return $self->pass;
}

__PACKAGE__->meta->make_immutable;

1;

package App::CLI::Horris::Command::twitter_stream;

# ABSTRACT: anyevent twitter streaming script

=head1 SYNOPSIS

    sample code base here

=head1 DESCRIPTION

F<$HOME/.twitter_key> sample

    "Consumer key"              cosumer key here
    "Consumer secret"           cosumer secret here
    "Access Token"              access token here           # oauth_token
    "Access Token Secret"       access token secret here    # (oauth_token_secret)

=cut

use Moose;
use Moose::Util::TypeConstraints;
use Config::General qw/ParseConfig/;
use DBI;
use AnyEvent::Twitter::Stream;
use namespace::autoclean;
extends 'MooseX::App::Cmd::Command';

subtype 'Config::General'
    => as 'Config::General';

coerce 'Config::General'
    => from 'Str'
    => via { ParseConfig($_) };

has database => (
    is            => 'ro',
    isa           => 'Str',
    traits        => ['Getopt'],
    required      => 1,
    documentation => "sqlite3 database file",
);

has key => (
    is          => 'rw',
    isa         => 'Config::General',
    traits      => ['Getopt'],
    default     => "$ENV{HOME}/.twitter_key",
    coerce      => 1,
    cmd_aliases => 'k',
    documentation =>
      "twitter api key file. default using $ENV{HOME}/.twitter_key",
);

has track => (
    is            => 'ro',
    isa           => 'Str',
    traits        => ['Getopt'],
    default       => 'perl,anyevent,catalyst,dancer,plack,psgi',
    cmd_aliases   => 't',
    documentation => "tracking keywords",
);

sub execute {
    my ( $self, $opt, $args ) = @_;

    my $consumer_key        = $self->key->{"Consumer key"};
    my $consumer_secret     = $self->key->{"Consumer secret"};
    my $access_token        = $self->key->{"Access Token"};
    my $access_token_secret = $self->key->{"Access Token Secret"};
    my $track               = 'perl,anyevent,catalyst,dancer,plack,psgi';

    my $dbh = DBI->connect( "dbi:SQLite:dbname=" . $self->database, "", "" );
    my $sth_insert = $dbh->prepare("insert into messages values (?, ?, 0, ?)");

    my $done = AE::cv;

    # to use OAuth authentication
    my $listener = AnyEvent::Twitter::Stream->new(
        consumer_key    => $consumer_key,
        consumer_secret => $consumer_secret,
        token           => $access_token,
        token_secret    => $access_token_secret,
        method          => "filter",
        track           => $track,
        on_tweet        => sub {
            my $tweet = shift;
            print "$tweet->{user}{screen_name}: $tweet->{text}\n";
            #$sth_insert->execute( 'twitter_stream', scalar time,
                #"$tweet->{user}{screen_name}: $tweet->{text}" );
        },
        on_keepalive => sub {
            warn "ping\n";
        },
        on_error => sub {
            my $error = shift;
            warn "Error : $error\n";
            $done->send;
        },
        on_eof => sub {
            $done->send;
        },
        timeout => 60,
    );

    $done->recv;

}

1;

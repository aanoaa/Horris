#!/usr/bin/env perl
use strict;
use warnings;
use DBI;
use AnyEvent::Twitter::Stream;

my $consumer_key        = '';
my $consumer_secret     = '';
my $access_token        = '';
my $access_token_secret = '';
my $track = 'perl,anyevent,catalyst,dancer,plack,psgi';

my $dbfile = 'misc/poll.db';
my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile", "", "");
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
        $sth_insert->execute('twitter_stream', scalar time, "$tweet->{user}{screen_name}: $tweet->{text}");
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

#!/usr/bin/env perl
use strict;
use warnings;
use DBI;
use JSON;
use AnyEvent;
use File::Temp;
use LWP::Simple;
use DateTime::Format::W3CDTF;

my $dbfile = 'misc/poll.db';
my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile", "", "");
my $starttime = scalar time;
my $lastest_time = 0;
my $file;
my $interval = 60;

my $sth_insert = $dbh->prepare("insert into messages values (?, ?, 0, ?)");

my $cv = AnyEvent->condvar;
my $w; $w = AnyEvent->timer(
    after       => 10,
    interval    => $interval,
    cb          => sub {
        my $data = get "http://me2day.net/api/get_posts/aanoaa.json";
        my $content = from_json($data);
        for my $tweet (@{ $content }) {
            my $out = $tweet->{textBody};
            $tweet->{pubDate} =~ s/0900$/09:00/;
            if ($tweet->{media}{photoUrl}) {
                my $url = $tweet->{media}{photoUrl};
                my $uri = URI->new($url);
                next unless $uri->scheme && $uri->scheme =~ /^http/i;
                next unless $uri->authority;

                if (length "$uri" > 50 && $uri->authority !~ /tinyurl|bit\.ly/) {
                    $url = makeashorterlink($uri);
                }

                $out .= ' ' . $url;
            }

            my $dt = DateTime::Format::W3CDTF->parse_datetime($tweet->{pubDate});
            if ($dt->epoch > $lastest_time and $dt->epoch > $starttime) {
                $lastest_time = $dt->epoch;
                $sth_insert->execute('me2day_iu', scalar time, $out);
            }
        }
    }
);

$cv->recv;

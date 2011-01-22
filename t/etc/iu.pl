#!/usr/bin/env perl
use strict;
use warnings;
use DBI;
use JSON;
use AnyEvent;
use File::Temp;
use LWP::Simple;
use DateTime::Format::W3CDTF;

my $starttime = scalar time;
my $lastest_time = 0;
my $interval = 60;
my $json_url = "http://me2day.net/api/get_posts/aanoaa.json";

my ($dbfile, $dbh, $sth_insert);
unless($ENV{NODB}) {
    $dbfile = 'misc/poll.db';
    $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile", "", "");
    $sth_insert = $dbh->prepare("insert into messages values (?, ?, 0, ?)");
}
print "NODB option is turned on.\n" if $ENV{NODB};

my $cv = AnyEvent->condvar;
my $w; $w = AnyEvent->timer(
    interval    => $interval,
    cb          => sub {
        print "Checking $json_url\n";
        my $data = get $json_url;
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
                $sth_insert->execute('me2day_iu', scalar time, $out) unless $ENV{NODB};
                printf "%s : %s\n", $dt->epoch, $out if $ENV{NODB};
            }
        }
    }
);

$cv->recv;

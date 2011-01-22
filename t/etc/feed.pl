#!/usr/bin/env perl
use strict;
use warnings;
use AnyEvent;
use AnyEvent::Feed;
use Data::Dumper;
use Encode;
use HTML::Strip;
use DBI;

my $seconds = 300;
my $dbfile = 'misc/poll.db';
my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile", "", "");

my $sth_insert = $dbh->prepare("insert into messages values (?, ?, 0, ?)");

my @urls = (
    "http://www.blogger.com/feeds/5137684887780288527/posts/default",
    "http://www.perl.com/pub/atom.xml",
    "http://feeds.feedburner.com/YetAnotherCpanRecentChanges",
    "http://jeen.tistory.com/rss",
    "http://blogs.perl.org/atom.xml",
    "http://planet.perl.org/rss20.xml",
    "http://perlsphere.net/atom.xml",
    "http://use.perl.org/index.rss",
    "http://blogsearch.google.co.kr/blogsearch_feeds?q=perl+dancer+OR+catalyst+OR+anyevent+OR+moose&hl=ko&lr=&newwindow=1&prmdo=1&prmd=ivns&output=atom",
); 

my $hs = HTML::Strip->new();
my $w = AnyEvent->condvar;
my @feeders;
my %firstfeed;
foreach my $url (@urls) {
    my $feed_reader; $feed_reader = AnyEvent::Feed->new (
         url      => $url,
         interval => $seconds,

         on_fetch => sub {
            my ($feed_reader, $new_entries, $feed, $error) = @_;

            if (defined $error) {
               warn "ERROR: $error\n";
               return;
            }

            #warn "$url\n";
            unless($firstfeed{$feed->link}) {
                warn "Skip the first feeding. :: $url\n";
                $firstfeed{$feed->link}++;
                return;
            }
            warn "\n";

            #print "feed_reader : $feed_reader\n";
            #print "\tnew_entries : $new_entries\n";
            printf "Added %d entries..\n", scalar @$new_entries;
            for (@$new_entries) {
                #print Dumper($_);
                my ($hash, $entry) = @$_;

                my $body = $hs->parse(encode('utf8', $entry->content->body));
                $body =~ s/[\r\n]//g;
                $body =~ s/\s+/ /g;

                my $message = sprintf "%s :: %s :: %s\n\n",
                    encode('utf8', $entry->title),
                    substr($body, 0, 100),
                    $entry->link;

                my $issue_time = $entry->issued ? $entry->issued->epoch : time;
                $sth_insert->execute('rss_atom', $issue_time, $message);
            }
         }
    );
    push @feeders, $feed_reader;
}

$w->recv;

1;

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
    "http://ironman.enlightenedperl.org/?feed=atom",
    "http://perlsphere.net/atom.xml",
    "http://use.perl.org/index.rss",
    "http://blogsearch.google.co.kr/blogsearch_feeds?q=perl+dancer&hl=ko&newwindow=1&prmdo=1&output=rss",
    "http://blogsearch.google.co.kr/blogsearch_feeds?q=perl+catalyst&hl=ko&newwindow=1&prmdo=1&output=rss",
    "http://blogsearch.google.co.kr/blogsearch_feeds?q=perl+any+event&hl=ko&newwindow=1&prmdo=1&output=rss",
    "http://blogsearch.google.co.kr/blogsearch_feeds?q=perl+Moose&hl=ko&newwindow=1&prmdo=1&output=rss",
    "http://blogsearch.google.co.kr/blogsearch_feeds?q=perl+python&hl=ko&newwindow=1&prmdo=1&output=rss",
); 

my $hs = HTML::Strip->new();
my $w = AnyEvent->condvar;
my @feeders;
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

=comment
use AnyEvent::HTTP;
use Data::Dumper;

my $seconds = 3;

http_get 'http://cfs.tistory.com/custom/named/je/jeen/rss.xml', sub {
    print $_[1];
    my ($body, $hdr) = @_;
    if ($hdr->{Status} =~ /^2/) {
        print $body;
    } else {
        print "error, $hdr->{Status} $hdr->{Reason}\n";
    } 
};
=cut

1;

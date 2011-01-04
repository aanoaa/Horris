#!/usr/bin/env perl
use strict;
use warnings;
use lib ('lib', 't/lib');
use Horris::Message;
use Horris::Instance;
use Horris::Connection::Plugin::Twitter;
use Test::MockObject::Extends;
use Test::More (tests => 2);

my @sample_tweets = (
    'http://twitter.com/#!/umma_coding_bot/status/8721128864350209', 
    'https://twitter.com/#!/umma_coding_bot/status/8721128864350209', 
    'http://twitter.com/#!/umma_coding_bot/statuses/8721128864350209', 
    'http://twitter.com/umma_coding_bot/status/8721128864350209', 
    'https://twitter.com/umma_coding_bot/statuses/8721128864350209', 
    'something!http://twitter.com/#!/umma_coding_bot/status/8721128864350209'
);

my $mobile_tweet_url = 'http://mobile.twitter.com/alexbonkoo/status/9181735065493504';

my $plugin_name = 'Twitter';
my $horris = Horris::Instance->new([$plugin_name]);
my $plugin = Horris::Connection::Plugin::Twitter->new({
    parent => $horris->{conn}, 
    name => $plugin_name, 
    $plugin_name => {} # other configuration here
});

my $conn = Test::MockObject::Extends->new('Horris::Connection');
$plugin->_connection($conn);

my @result;
my $event = 'irc_privmsg';

$conn->mock($event, sub {
    my ($self, $args) = @_;
    push @result, $args->{message} if defined $args->{message};
});

foreach my $url (@sample_tweets) {
	my $message = Horris::Message->new(
		channel => '#test', # not used, but required for L<Horris::Connection>
		message => $url, 
		from	=> 'test',  # not used, but required for L<Horris::Connection>
	);

    $plugin->$event($message);
}

is(scalar @result, scalar @sample_tweets, 'trying count');
my %hash;
for my $result (@result) {
	$hash{$result}++;
}
is(scalar keys %hash, 1, 'all equal');






#my $message = Horris::Message->new(
#    channel => '#test',
#    message => 'http://twitter.com/#!/umma_coding_bot/status/8721128864350209', 
#    from	=> 'test',
#);
#
#
#$plugin->irc_privmsg($message);




#local @ARGV = qw(--configfile t/plugin_twitter.conf);
#my $app = App::Horris->new_with_options();
#my $horris = Horris->new({ config => $app->config });
#$horris->run;

#my $message = Horris::Message->new(
#    channel => '#test',
#    message => 'http://twitter.com/#!/umma_coding_bot/status/8721128864350209', 
#    from	=> 'test',
#);
#
#use Data::Dumper;
#print Dumper($horris->all_connections);
#
#my $w; $w = AnyEvent->timer(after => 20, cb => sub {
#    my $event = 'irc_privmsg';
#    for my $plugin (@{ $horris->all_connections->[0]->plugin_list }) {
#        my $msg = $plugin->$event($message) if $plugin->can($event);
#        like($msg, qr/perl/, 'correct stdout');
#    }
#});


#my @sample_tweets = qw{
#    http://twitter.com/#!/umma_coding_bot/status/8721128864350209
#    https://twitter.com/#!/umma_coding_bot/status/8721128864350209
#    http://twitter.com/#!/umma_coding_bot/statuses/8721128864350209
#    http://twitter.com/umma_coding_bot/status/8721128864350209
#    https://twitter.com/umma_coding_bot/statuses/8721128864350209
#    something!http://twitter.com/#!/umma_coding_bot/status/8721128864350209
#};
#
#my $mobile_tweet_url = 'http://mobile.twitter.com/alexbonkoo/status/9181735065493504';
#
#
#
#
#
#
#
#
#
#my @TEST_URLS = (
#	'http://twitter.com/#!/umma_coding_bot/status/8721128864350209', 
#	'https://twitter.com/#!/umma_coding_bot/status/8721128864350209', 
#	'http://twitter.com/#!/umma_coding_bot/statuses/8721128864350209', 
#	'http://twitter.com/umma_coding_bot/status/8721128864350209', 
#	'https://twitter.com/umma_coding_bot/statuses/8721128864350209', 
#	'something!http://twitter.com/#!/umma_coding_bot/status/8721128864350209', 
#);
#
#my $TEST_URL_MOBILE = 'http://mobile.twitter.com/alexbonkoo/status/9181735065493504';
#
#my $conn = Horris::Connection->new(
#	nickname => '', 
#	port     => '', 
#	password => '', 
#	server   => '', 
#	username => '', 
#	plugins	 => ['Twitter'], 
#);
#
#my @results;
#
#foreach my $url (@TEST_URLS) {
#	my $message = Horris::Message->new(
#		channel => '#test', # not used, but required for L<Horris::Connection>
#		message => $url, 
#		from	=> 'test',  # not used, but required for L<Horris::Connection>
#	);
#
#	foreach my $plugin (@{ $conn->plugin_list }) {
#		my $msg = $plugin->_parse_status($message) if $plugin->can('_parse_status');
#		push @results, $msg if defined $msg;
#	}
#}
#
#is(scalar @results, scalar @TEST_URLS, 'trying count');
#my %hash;
#for my $result (@results) {
#	$hash{$result}++;
#}
#is(scalar keys %hash, 1, 'all equal');
#
#my $message = Horris::Message->new(
#    channel => '#test', # not used, but required for L<Horris::Connection>
#    message => $TEST_URL_MOBILE, 
#    from	=> 'test',  # not used, but required for L<Horris::Connection>
#);
#
#foreach my $plugin (@{ $conn->plugin_list }) {
#    my $msg = $plugin->_parse_status($message) if $plugin->can('_parse_status');
#    ok(defined $msg, 'mobile tweet');
#}

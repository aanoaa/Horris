#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use Horris::Connection;
use Test::More (tests => 3);

my @TEST_URLS = (
	'http://twitter.com/#!/umma_coding_bot/status/8721128864350209', 
	'https://twitter.com/#!/umma_coding_bot/status/8721128864350209', 
	'http://twitter.com/umma_coding_bot/status/8721128864350209', 
	'https://twitter.com/umma_coding_bot/status/8721128864350209', 
);

my $TEST_URL_MOBILE = 'http://mobile.twitter.com/alexbonkoo/status/9181735065493504';

my $conn = Horris::Connection->new(
	nickname => '', 
	port     => '', 
	password => '', 
	server   => '', 
	username => '', 
	plugins	 => ['Twitter'], 
);

my @results;

foreach my $url (@TEST_URLS) {
	my $message = Horris::Message->new(
		channel => '#test', # not used, but required for L<Horris::Connection>
		message => $url, 
		from	=> 'test',  # not used, but required for L<Horris::Connection>
	);

	foreach my $plugin (@{ $conn->plugin_list }) {
		my $msg = $plugin->_parse_status($message) if $plugin->can('_parse_status');
		push @results, $msg if defined $msg;
	}
}

is(scalar @results, scalar @TEST_URLS, 'trying count');
my %hash;
for my $result (@results) {
	$hash{$result}++;
}
is(scalar keys %hash, 1, 'all equal');

my $message = Horris::Message->new(
    channel => '#test', # not used, but required for L<Horris::Connection>
    message => $TEST_URL_MOBILE, 
    from	=> 'test',  # not used, but required for L<Horris::Connection>
);

foreach my $plugin (@{ $conn->plugin_list }) {
    my $msg = $plugin->_parse_status($message) if $plugin->can('_parse_status');
    ok(defined $msg, 'mobile tweet');
}

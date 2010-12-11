#!/usr/bin/env perl
use strict;
use warnings;
use lib ('lib', 't/lib');
use Horris::Instance;
use Horris::Connection;
use Test::More (tests => 2);

my $instance = Horris::Instance->new(['Eval']);
my $test_message;
my $expected_message;
my $message;

$test_message = 'eval: print 1 .. 10;';
$expected_message = '12345678910';
$message = Horris::Message->new(
    channel => '#test',
    message => $test_message, 
    from	=> 'test',
);

foreach my $plugin (@{ $instance->{conn}->plugin_list }) {
    my $msg = $plugin->_eval($message) if $plugin->can('_eval');
    is ($msg, $expected_message, 'correct stdout');
}

$test_message = 'eval: print "나는미남";';
$expected_message = '나는미남';
$message = Horris::Message->new(
    channel => '#test',
    message => $test_message, 
    from	=> 'test',
);

foreach my $plugin (@{ $instance->{conn}->plugin_list }) {
    my $msg = $plugin->_eval($message) if $plugin->can('_eval');
    is ($msg, $expected_message, 'correct stdout - unicode');
}

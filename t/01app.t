#!/usr/bin/env perl
use strict;
use warnings;
use Test::More 'no_plan';
use App::Morris;

BEGIN { use_ok 'Morris', 'Morris' }

local @ARGV = qw{--configfile misc/sample.conf};
my $app;
my $morris;

ok( $app = App::Morris->new_with_options(), 'new App::Morris' );
ok( $morris = Morris->new({config => $app->config}), 'new Morris' );
#is( $morris->nickname, 'aanoaa', 'nickname correct');

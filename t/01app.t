#!/usr/bin/env perl
use strict;
use warnings;
use Test::More 'no_plan';
use App::Morris;

BEGIN { use_ok 'Morris', 'Morris' }

local @ARGV = qw{--configfile misc/sample.conf};
my $app;

ok( $app = App::Morris->new_with_options()->run, 'new App::Morris' );

#!/usr/bin/env perl
use strict;
use warnings;
use Test::More 'no_plan';
use App::Horris;

BEGIN { use_ok 'Horris', 'Horris' }

local @ARGV = qw{--configfile misc/sample.conf};
my $app;
ok( $app = App::Horris->new_with_options->run, 'new App::Horris' );

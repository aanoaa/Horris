#!/usr/bin/env perl
use strict;
use warnings;

use Pod::Simple::Text;

my $parser = Pod::Simple::Text->new;
my $foo;
$parser->output_string(\$foo);
my $data = do { local $/; <DATA> };
$parser->parse_string_document($data);

print ">>> $foo\n";


__DATA__

=pod

=head1 NAME

F<a.pl>

=head1 SYNOPSIS

	foo [bar] [baz] arg arg arg ..

=cut

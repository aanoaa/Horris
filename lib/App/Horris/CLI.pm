package App::Horris::CLI;
# ABSTRACT: Command Line Interface For Horris etc scripts

=head1 SYNOPSIS

    horris
    # output all available command list & help

=cut

use Moose;
use namespace::autoclean;
extends 'MooseX::App::Cmd';

1;

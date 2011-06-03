package App::Horris::CLI::Command::log;
# ABSTRACT: init log environment

=head1 SYNOPSIS

    horris log --dsn dbi:mysql:DATABASE --username username --password secret
    horris log -d dbi:mysql:DATABASE -u username -p secret

following command for more detail.

    horris help log

=cut

use Moose;
use namespace::autoclean;
use autodie;
use Carp qw/croak/;
use DBI;
use DBIx::Simple;
use SQL::Abstract;
extends 'MooseX::App::Cmd::Command';

binmode STDIN, ':encoding(UTF-8)';
binmode STDOUT, ':encoding(UTF-8)';

has dsn => (
    traits => ['Getopt'],
    is => 'ro',
    isa => 'Str',
    required => 1,
    cmd_aliases => 'd',
    documentation => 'database source name',
);

has username => (
    traits => ['Getopt'],
    is => 'ro',
    isa => 'Str',
    cmd_aliases => 'u',
    documentation => 'database username'
);

has password => (
    traits => ['Getopt'],
    is => 'ro',
    isa => 'Str',
    cmd_aliases => 'p',
    documentation => 'database password'
);

sub query { my $db = shift; $db->query( $_[0] ) or croak; }

sub execute {
    my ( $self, $opt, $args ) = @_;
    die $self->usage if ($opt->{help_flag});
    my $db = DBIx::Simple->connect($self->dsn, $self->username, $self->password) or croak;
    $db->abstract = SQL::Abstract->new( { quota_char => q{`}, name_sep => q{.} } );
    query $db, 'set names utf8';

    my $dbh = DBI->connect($self->dsn, $self->username, $self->password) or croak;;

    my $sql = <<SQL;
    CREATE TABLE IF NOT EXISTS `irclog` (
      `id` int(11) NOT NULL auto_increment,
      `channel` varchar(30) default NULL,
      `day` char(10) default NULL,
      `nick` varchar(40) default NULL,
      `timestamp` int(11) default NULL,
      `line` mediumtext,
      `spam` tinyint(1) default '0',
      PRIMARY KEY  (`id`),
      KEY `nick_index` (`nick`),
      KEY `day_index` (`day`),
      KEY `irclog_day_channel_idx` (`day`,`channel`),
      KEY `channel_idx` (`channel`),
      FULLTEXT KEY `message_index` (`line`)
    ) ENGINE=MyISAM AUTO_INCREMENT=2533349 DEFAULT CHARSET=utf8
SQL
    $dbh->do($sql);
}

1;

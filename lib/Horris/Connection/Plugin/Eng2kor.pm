package Horris::Connection::Plugin::Eng2kor;
# ABSTRACT: Acme::eng2kor Plugin on Horris

=head1 SYNOPSIS

    # assume here at a irc channel
    HH:MM:SS    NICK | eng2kor hello
    HH:MM:SS BOTNAME | 안녕하세요

=head1 DESCRIPTION

Translate Plugin

=head1 SEE ALSO

L<Acme::eng2kor>

=cut

use Moose;
use Encode qw/encode decode/;
use Getopt::Long;
use Acme::eng2kor;
extends 'Horris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

sub irc_privmsg {
    my ($self, $message) = @_;
    my @msg = $self->_eng2kor($message);

    return unless @msg;

    for (@msg) {
        $self->connection->irc_privmsg({
            channel => $message->channel,
            message => $_
        });
    }

    return $self->pass;
}

sub _eng2kor {
    my ($self, $message) = @_;
    my $raw = $message->message;

    unless ($raw =~ m/^eng2kor/i) {
        return undef;
    }

    $raw =~ s/^eng2kor[\S]*\s+//i;
    $raw = decode('utf8', $raw);
    my %options;

    $raw =~ s/^\s+//;
    $raw =~ s/\s+$//;
    local @ARGV;
    while (my ($m) = $raw =~ m/(['"]|\s+)/) {
        my $i = index($raw, $m);
        my $arg;
        if ($m eq "'" or $m eq '"') {
            my $pair = index($raw, $m, $i + 1);
            if ($pair == -1) {
                warn "Couldn't match pair\n";
                return ();
            }

            $arg = substr($raw, $i + 1, $pair - 1);
            $raw = substr($raw, $pair + 1);
        } else {
            $arg = substr($raw, 0, $i);
            $raw = substr($raw, $i + 1);
        }

        push @ARGV, $arg if $arg;
    }

    push @ARGV, $raw if $raw;
    GetOptions( \%options, "--src=s", "--dst=s", "--reverse", "--help", "--list" );
    my $src = $options{src} || $ENV{E2K_SRC} || 'en';
    my $dst = $options{dst} || $ENV{E2K_DST} || 'ko';
    ($src, $dst) = ($dst, $src) if $options{reverse};
    my $app = Acme::eng2kor->new(src => $src, dst => $dst);
    my @result;
    for my $word (@ARGV) {
        $app->translate($word);
        push @result, encode('utf8', $app->translated);
    }

    return @result;
}

__PACKAGE__->meta->make_immutable;

1;

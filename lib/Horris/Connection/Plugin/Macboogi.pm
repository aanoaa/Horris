package Horris::Connection::Plugin::Macboogi;
# ABSTRACT: Macboogiuate Plugin on Horris

=head1 SYNOPSIS

    # assume here at a irc channel
    HH:MM:SS    NICK | macboogi 안녕
    HH:MM:SS BOTNAME | 아ㄴ녀ㅇ
    HH:MM:SS    NICK | macboogi use Catalyst;
    HH:MM:SS BOTNAME | use CATALYST;

    # 종성 'ㄷ': 11AE
    # 음절 'ㄷ': 3137
    # 음절 'ㄸ' 이 종성엔 없다.
    
    # 종성 'ㅂ': 11B8
    # 음절 'ㅂ': 3143
    # 음절 'ㅃ' 이 종성엔 없다.
    
    # 나머진 무시하자

=head1 DESCRIPTION

What The Descrption?

=cut

use utf8;
use Moose;
use Const::Fast;
use Encode qw/decode_utf8 encode_utf8/;
use Lingua::KO::Hangul::Util qw(:all);
extends 'Horris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

const my $JONGSUNG_BEGIN    => 0x11A8;
const my $JONGSUNG_END      => 0x11FF;
const my $JONGSUNG_DIGEUG   => 0x11AE; # ㄷ
const my $JONGSUNG_BIEUP    => 0x11B8; # ㅂ
const my $SELLABLE_BEGIN    => 0x3131;
const my $INTERVAL          => $SELLABLE_BEGIN - $JONGSUNG_BEGIN;

sub irc_privmsg {
    my ($self, $message) = @_;
    my $msg = $self->_process($message);
    #$msg = encode_utf8( $msg );

    return unless defined $msg;

    for (split /\n/, $msg) {
        $self->connection->irc_privmsg({
            channel => $message->channel, 
            message => $_
        });
    }

    return $self->pass;
}

sub _process {
    my ($self, $message) = @_;
    my $raw = $message->message;

    #$raw = decode_utf8( $raw );
    #warn $raw;
    #warn utf8::is_utf8($raw);

    unless ($raw =~ m/^macboogi/i) {
        return undef;
    }

    $raw =~ s/^macboogi[\S]*\s+//i;
    #$raw = decode('utf8', $raw);
    #use Devel::Peek;
    #warn utf8::is_utf8($raw);
    #warn Dump($raw);
    return macboogi($raw);
}

sub macboogi {
    my $input = decode_utf8(uc shift);
    my @chars = split //, $input;
    my @mac_chars;
    for my $char (@chars) {
        my $ord = ord $char;
        if ($ord >= 65 && $ord <= 90) {
            push @mac_chars, $char;
            next;
        }

        my @jamo = split //, decomposeSyllable($char);
        for (@jamo) {
            my $code = unpack 'U*', $_;
            if ($code >= $JONGSUNG_BEGIN && $code <= $JONGSUNG_DIGEUG) {
                $code += $INTERVAL;
            } elsif ($code > $JONGSUNG_DIGEUG && $code <= $JONGSUNG_BIEUP) {
                $code += $INTERVAL + 1;
            } elsif ($code > $JONGSUNG_BIEUP && $code <= $JONGSUNG_END) {
                $code += $INTERVAL + 2;
            }

            $_ = pack 'U*', $code;
        }

        push @mac_chars, composeSyllable(join '', @jamo);
    }

    my $chars = join '', @mac_chars;
    $chars =~ s/^use /use /i;
    return encode_utf8($chars);
}

__PACKAGE__->meta->make_immutable;

1;

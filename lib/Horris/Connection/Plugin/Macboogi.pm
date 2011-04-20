#!/usr/bin/env perl

use 5.010;
use Lingua::KO::Hangul::Util qw(:all);
use utf8;

#say join(' ', unpack 'U*', decomposeSyllable("\x{AC00}"));

say "decosed 가 : ", join(' ', map { sprintf "%X", $_ } unpack 'U*', decomposeSyllable("가"));

say "가 : ", join(' ', map { sprintf "%X", $_ } unpack 'U*', "가");
say "ㄱㅏ : ", join(' ', map { sprintf "%X", $_ } unpack 'U*', "ㄱㅏ");

my $hangul = "맥부기";
say "$hangul : ", printUnicode($hangul);
my $jamo = decomposeSyllable($hangul);
say "맥부기 : $jamo";

my @jamo = split //, $jamo;
my $macjamo = composeJamo(join "\x{200B}", split(//, $jamo));
say "macjamo : ", printUnicode($macjamo);
say "macjamo : ", $jamo;

my $gap = 0x3131 - 0x11A8;
say "gap : ", sprintf("%X", $gap);
foreach(@jamo) {
    my $code = unpack 'U*', $_;
    say "each jamo : $_, code : ", sprintf("%X", $code);
    if($code >= 0x11A8 and $code <= 0x11FF) {
        say "added gap";
        $_ = pack 'U', ($code + $gap);
    }
}

say "\@jamo : ", join(', ', @jamo);
say "macbugi : ", (join '', @jamo);
say "macbugi : ", composeSyllable(join '', @jamo);

sub printUnicode {
    return join(' ', map { sprintf "%X", $_ } unpack('U*', shift));
}

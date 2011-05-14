package Horris::Connection::Plugin::Kspell;
# ABSTRACT: KoreanSpeller Plugin on Horris

=head1 SYNOPSIS

    # assume here at a irc channel
    HH:MM:SS    NICK | kspell 키디님
    HH:MM:SS BOTNAME | 키디님 -> 캐디님

=head1 DESCRIPTION

Checking Korean Spell and Fixed It As Right

=head1 SEE ALSO

L<WebService::KoreanSpeller>

=cut

use Moose;
use Encode qw/encode decode/;
use WebService::KoreanSpeller;
extends 'Horris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

sub irc_privmsg {
    my ($self, $message) = @_;
    my @msg = $self->_kspell($message);

    return unless @msg;

    for (@msg) {
        $self->connection->irc_privmsg({
            channel => $message->channel,
            message => $_
        });
    }

    return $self->pass;
}

sub _kspell {
    my ($self, $message) = @_;
    my $raw = $message->message;

    unless ($raw =~ m/^kspell/i) {
        return undef;
    }

    $raw =~ s/^kspell[\S]*\s+//i;
    $raw = decode('utf8', $raw);
    my $checker = WebService::KoreanSpeller->new( text=> $raw );
    my @results = $checker->spellcheck;
    my @correct;
    for my $item (@results) {
        push @correct, encode('utf8', $item->{incorrect} . ' -> ' . $item->{correct});
    }

    return @correct;
}

__PACKAGE__->meta->make_immutable;

1;

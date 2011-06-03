package Horris::Connection::Plugin::Letter;
# ABSTRACT: Acme::Letter Plugin on Horris

=head1 SYNOPSIS

    # assume here at a irc channel
    HH:MM:SS    NICK | letter PDF
    HH:MM:SS BOTNAME |  ____  _____  _____
                       |  _ \|  _  \|  ___|
                       | |_) | | \  | |_
                       |  __/| |_/  |  _|
                       |_|   |_____/|_|

=head1 SEE ALSO

L<Acme::Letter>

=cut

use Moose;
use Time::HiRes;
use Acme::Letter;
extends 'Horris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

has 'letter' => (
    is => 'rw',
    isa => 'Acme::Letter',
    lazy_build => 1
);

sub _build_letter { Acme::Letter->new };

sub irc_privmsg {
    my ($self, $message) = @_;
    for my $msg ($self->_letter($message)) {
        $self->connection->irc_privmsg({
            channel => $message->channel,
            message => $msg
        });

        Time::HiRes::sleep(0.1);
    }

    return $self->pass;
}

sub _letter {
    my ($self, $message) = @_;
    my $msg = $message->message;

    unless ($msg =~ m/^letter/i) {
        return ();
    }

    $msg =~ s/^letter[\S]*\s+//i;
    $self->letter->_createString($msg);
    my $lines_ref = $self->letter->{"lines"};
    my @letters;
    for(my $i = 0; $i <= 4; $i++) {
        my $line = '';
        my $temps=$$lines_ref[$i];
        foreach my $temp (@$temps) {
            if(not defined $temp) {
                $line .= " ";
            } elsif($temp eq "*") {
                $line .= " ";
            } else {
                $line .= $temp;
            }
        }
        $line .= "\n";
        push @letters, $line;
    }

    return @letters;
}

__PACKAGE__->meta->make_immutable;

1;

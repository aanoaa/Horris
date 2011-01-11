package Horris::Connection::Plugin::Kspell;
use Moose;
use URI::Escape;
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
    my $checker = WebService::KoreanSpeller->new( text=> $raw );
    my @results = $checker->spellcheck;
    my @correct;
    for my $item (@results) {
        push @correct, $item->{incorrect} . ' -> ' . $item->{correct};
    }

    return @correct;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

Horris::Connection::Plugin::Kspell

=head1 SYNOPSIS

evaluate perl code

=head1 SEE ALSO

L<http://colabv6.dan.co.jp/lleval.html>

=cut

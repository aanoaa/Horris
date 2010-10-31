package Morris::Connection::Plugin::Eng2kor;
use Moose;
use App::eng2kor;
use Getopt::Long;
extends 'Morris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

has src => (
	is => 'rw', 
	isa => 'Str', 
	default => 'en', 
	writer => '_src'
);

has dst => (
	is => 'rw', 
	isa => 'Str', 
	default => 'ko', 
	writer => '_dst'
);

sub init {
	my ($self, $conn, $args) = @_;
	$self->_connection($conn);
	$self->_src($args->{src}) if $args->{src};
	$self->_dst($args->{dst}) if $args->{dst};
	print __PACKAGE__ . " init\n";
	use Data::Dumper qw/Dumper/;
	print Dumper($args);
}

sub irc_privmsg {
	my ($self, $msg) = @_;
	local @ARGV = split(/\s+/, $msg->message);
	print join("\n", @ARGV), "\n";
	my %options;
	GetOptions( \%options, "--src=s", "--dst=s", "--reverse" );
	my $src = $options{src} || $self->src || 'en';
	my $dst = $options{dst} || $self->dst || 'ko';
	($src, $dst) = ($dst, $src) if $options{reverse};
	my $app = App::eng2kor->new(src => $src, dst => $dst);
	for my $word (@ARGV) {
		my @result = $app->translate($word);
		for my $item (@result) {
			$self->connection->irc_privmsg({
				channel => $msg->channel, 
				message => $item->{origin}
			});

			$self->connection->irc_privmsg({
				channel => $msg->channel, 
				message => "\t" . $item->{translated}
			});
		}
	}
}

sub help {
	return __PACKAGE__ . "'s help\n";
}

1;

__END__

=pod

=head1 NAME

Morris::Connection::Plugin::Eng2kor

=head1 SYNOPSIS

	echo bot

=cut

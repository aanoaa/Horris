package Horris;
use Moose;
use AnyEvent;
use Const::Fast;
use Horris::Connection;
use namespace::clean -except => qw/meta/;

our $VERSION = '0.0.1';
$VERSION = eval $VERSION;

const our $DEBUG => $ENV{PERL_HORRIS_DEBUG};

has condvar => (
	is => 'ro', 
	lazy_build => 1, 
);

has connections => (
	traits => ['Array'],
	is => 'ro', 
	isa => 'ArrayRef[Horris::Connection]', 
	lazy_build => 1, 
	handles => {
		all_connections => 'elements', 
		push_connection => 'push', 
	}, 
);

has config => (
	is => 'ro', 
	isa => 'HashRef', 
	required => 1, 
);

sub _build_condvar { AnyEvent->condvar }
sub _build_connections {
	my ($self) = @_;
	my @connections;
	while (my ($name, $conn) = each %{$self->{config}{connection}}) {
		confess "No network specified connection '$name'" unless $conn->{network};
		print "Connection Name: $name\n" if $Horris::DEBUG;

		my $network = $self->{config}{network}->{ $conn->{network} };
		my $connection = Horris::Connection->new({
			%$network,
			%$conn,
			plugins => [keys %{ $conn->{plugin} }]
		});
		push @connections, $connection;
	}

	return \@connections;
}

sub run {
	my $self = shift;
	my $cv = $self->condvar;
	$cv->begin;
	foreach my $conn ($self->all_connections) {
		$conn->run;
	}

	$cv->recv;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Horris - An IRC Bot Based On Moose/AnyEvent

=head1 SYNOPSIS

	...

=cut

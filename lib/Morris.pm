package Morris;
use Moose;
use AnyEvent;
use Const::Fast;
use Morris::Connection;
use namespace::clean -except => qw/meta/;

our $VERSION = '0.0.1';
$VERSION = eval $VERSION;

const my $DEBUG => $ENV{PERL_MORRIS_DEBUG};

has condvar => (
	is => 'ro', 
	lazy_build => 1, 
);

has connections => (
	traits => ['Array'],
	is => 'ro', 
	isa => 'ArrayRef[Morris::Connection]', 
	lazy_build => 1, 
	handles => {
		all_connections => 'elements', 
	}, 
);

has config => (
	is => 'ro', 
	isa => 'HashRef', 
	required => 1, 
);

sub _noop_cb {}
sub _build_condvar { AnyEvent->condvar }
sub _build_connections {
	my ($self) = @_;
	my $config = $self->{config};
	my @connections;
	while (my ($name, $conn) = each %{$config->{connection}}) {
		confess "No network specified connection '$name'" unless $conn->{network};

		my $network = $config->{network}->{ $conn->{network} };
		$network->{server} ||= $conn->{network};

		my $connection = Morris::Connection->new(%$network, %$conn, (name => $name));
		$connection->load_plugins(keys %{ $conn->{plugin} });
		push @connections, $connection;
	}

	return \@connections;
}

sub run {
	my $self = shift;
	my $config = $self->{config};
	my $cv = $self->condvar;
	$cv->begin;
	foreach my $conn ($self->all_connections) {
		$conn->run($self->config->{connection}{ $conn->name }{plugin});
	}
}

__PACKAGE__->meta->make_immutable;

1;

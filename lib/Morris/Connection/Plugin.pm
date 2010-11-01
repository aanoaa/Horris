package Morris::Connection::Plugin;
use Moose;
use Pod::Text;
use IO::String;
use namespace::clean -except => qw/meta/;

has connection => (
	is => 'ro', 
	isa => 'Morris::Connection', 
	writer => '_connection', 
);

has snippet => (
	is => 'ro', 
	isa => 'Str', 
	lazy_build => 1
);

has is_enable => (
	is => 'rw', 
	isa => 'Bool', 
	default => 1
);

has _pod_file => (
	is => 'ro', 
	isa => 'Str', 
	default => __FILE__
);

sub _build_snippet {
	my $package = ref $_[0];
	my ($snippet) = $package =~ m/(\w+)$/;
	return $snippet;
}

sub init {
	my ($self, $conn) = @_;
	$self->_connection($conn);
	print __PACKAGE__ . " init\n" if $Morris::DEBUG;
}

sub disconnect {
	print __PACKAGE__ . " disconnect\n" if $Morris::DEBUG;
}

sub help {
	my ($self) = @_;
	my $buf;
	my $io = IO::String->new($buf);
	my $parser = Pod::Text->new(sentence => 0, width => 78);
	$parser->parse_from_file($self->_pod_file, $io);
	return split("\n", $buf);
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Morris::Connection::Plugin - require interfaces for plugins

=head1 SYNOPSIS

    package Morris::Connection::Plugin::Foo;
    use Moose;
    with qw/Morris::Connection::Plugin MooseX::Role::Pluggable::Plugin/;

	sub init {
		# stuff before connect
	}

	sub run {
		# all stuff here
	}

	sub disconnect {
		# stuff with disconnect
	}

    # see the documentation for MooseX::Role::Pluggable,
	# MooseX::Role::Pluggable::Plugin for info on how to get your Moose
	# class to use this plugin...

=head1 SEE ALSO

L<MooseX::Role::Pluggable> L<MooseX::Role::Pluggable::Plugin>

=cut

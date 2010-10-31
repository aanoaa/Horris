package Morris::Connection::Plugin;
use Moose;
use namespace::clean -except => qw/meta/;

has connection => (
	is => 'ro', 
	isa => 'Morris::Connection', 
	writer => '_connection', 
);

sub init {
	my ($self, $conn) = @_;
	$self->_connection($conn);
	print __PACKAGE__ . " init\n";
}

sub disconnect {
	print __PACKAGE__ . " disconnect\n";
}

sub help {
	return '';
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

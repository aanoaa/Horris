package Morris::Connection::Plugin;
use Moose;
use namespace::clean -except => qw/meta/;

has connection => (
	is => 'ro', 
	isa => 'Morris::Connection', 
	writer => '_connection'
);

has is_enable => (
	traits => ['Bool'], 
	is => 'rw', 
	isa => 'Bool', 
	default => 1, 
	handles => {
		enable => 'set', 
		disable => 'unset', 
		switch => 'toggle', 
		is_disable => 'not'
	}
);

has help => (
	is => 'ro', 
	isa => 'Str', 
	lazy_build => 1, 
);

sub _build_help { return ref $_[0]; } # 현재pod를 사용해서 슥샥

sub init {
	my ($self, $conn) = @_;
	$self->_connection($conn);
}

sub disconnect { }

around BUILDARGS => sub {
	my ($orig, $class, @args) = @_;
	my $self = $class->$orig(@args);
	my @reserve_keys = qw/parent name/;
	while (my ($key, $value) = each %{ $self->{parent}{plugin}{$self->{name}} }) {
		confess 'keys [' . join(', ', @reserve_keys) . "] are reserved\n" if grep { $key eq $_ } @reserve_keys;
		$self->{$key} = $value;
	}

	return $self;
};

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

	sub disconnect {
		# stuff with disconnect
	}

    # see the documentation for MooseX::Role::Pluggable,
	# MooseX::Role::Pluggable::Plugin for info on how to get your Moose
	# class to use this plugin...

=head1 SEE ALSO

L<MooseX::Role::Pluggable> L<MooseX::Role::Pluggable::Plugin>

=cut

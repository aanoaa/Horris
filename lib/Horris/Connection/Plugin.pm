package Horris::Connection::Plugin;
use Moose;
use namespace::clean -except => qw/meta/;

has connection => (
	is => 'ro', 
	isa => 'Horris::Connection', 
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

sub _build_help { ref $_[0] }

sub init {
	my ($self, $conn) = @_;
	my $pname = ref $self;
	print ref $self, " on - ", $self->is_enable ? 'enable' : 'disable', "\n" if $Horris::DEBUG;
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

Horris::Connection::Plugin - require interfaces for plugins

=head1 SYNOPSIS

    package Horris::Connection::Plugin::Foo;
    use Moose;
    with qw/Horris::Connection::Plugin MooseX::Role::Pluggable::Plugin/;

	sub init {
		# stuff before connect
	}

	sub disconnect {
		# stuff on disconnect
	}

    # see the documentation for MooseX::Role::Pluggable,
	# MooseX::Role::Pluggable::Plugin for info on how to get your Moose
	# class to use this plugin...

=head1 SEE ALSO

L<MooseX::Role::Pluggable> L<MooseX::Role::Pluggable::Plugin>

=cut

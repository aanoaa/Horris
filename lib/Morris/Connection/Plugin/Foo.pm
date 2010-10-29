package Morris::Connection::Plugin::Foo;
use Moose;
with qw/MooseX::Role::Pluggable::Plugin Morris::Connection::Plugin/;

sub init {
	my ($self, $opt) = @_;
	print __PACKAGE__, " init\n" if $Morris::DEBUG;
	use Data::Dumper 'Dumper';
	print Dumper($opt);
}

sub run {
	print __PACKAGE__, " run\n" if $Morris::DEBUG;
}

sub disconnect {
	print __PACKAGE__, " disconnect\n" if $Morris::DEBUG;
}

1;

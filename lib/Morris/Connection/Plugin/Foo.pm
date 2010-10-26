package Morris::Connection::Plugin::Foo;
use Moose::Role;

sub foo {
	my ($self, $opt) = @_;
	print __PACKAGE__, " start\n";
	use Data::Dumper 'Dumper';
	print Dumper($opt);
	print __PACKAGE__, " end\n";
}

1;

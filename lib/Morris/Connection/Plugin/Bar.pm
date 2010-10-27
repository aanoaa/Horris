package Morris::Connection::Plugin::Bar;
use Moose;
with 'MooseX::Role::Pluggable::Plugin';

sub run {
	my ($self, $opt) = @_;
	print __PACKAGE__, " start\n";
	use Data::Dumper 'Dumper';
	print Dumper($opt);
	print __PACKAGE__, " end\n";
}

1;

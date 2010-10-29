package Morris::Connection::Plugin::Bar;
use Moose;
use Getopt::Long;
use IO::String;
use Pod::Text;
with qw/MooseX::Role::Pluggable::Plugin Morris::Connection::Plugin/;

sub init {
	my $self = shift;
}

sub bar {
	my $self = shift;
	local @ARGV = @_;

	print join(", ", @ARGV), "\n";

	my %options;
	GetOptions(\%options, "--help");
	if ($options{help}) {
		print "in help\n";
		my $buffer;
		my $io = IO::String->new($buffer);
		my $p2t = Pod::Text->new;
		$p2t->parse_from_file(__PACKAGE__, $io);
		return $buffer;
	}
	print " ... \n";
}

sub disconnect {
}

1;

__END__

=pod

=head1 NAME

Morris::Connection::Plugin::Bar

=head1 SYNOPSIS

	botname bar [--help|-h]

=cut

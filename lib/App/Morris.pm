package App::Morris;
use Moose;
use Config::Any;
use Morris;
use namespace::clean -except => qw/meta/;

with qw/MooseX::Getopt MooseX::SimpleConfig/;

has '+configfile' => (
	default => '/home/hshong/tmp/perl/plug/Morris/misc/sample.conf'
);

has config => (
	traits => ['NoGetopt'], 
	is => 'ro', 
	isa => 'HashRef', 
);

around _usage_format => sub {
	return "usage: %c %o (run 'perldoc " . __PACKAGE__ . "' for more info)";
};

sub run {
	my $self = shift;
	my $morris = Morris->new(config => $self->config);
	$morris->run;
	$morris->condvar->recv;
}

sub config_any_args {
	return {
		driver_args => {
			General => {
				-LowerCaseNames => 1
			}
		}
	};
}

__PACKAGE__->meta->make_immutable;

1;

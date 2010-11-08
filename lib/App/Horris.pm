package App::Horris;
use Moose;
use Config::Any;
use Horris;
use namespace::clean -except => qw/meta/;

with qw/MooseX::Getopt MooseX::SimpleConfig/;

has '+configfile' => (
	default => '/etc/horris.conf'
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
	my $horris = Horris->new(config => $self->config);
	$horris->run;
}

sub config_any_args {
	return {
		driver_args => {
			General => {
				-LowerCaseNames => 1, 
			}
		}
	};
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

App::Horris - Command Line Interface For Horris

=head1 SYNOPSIS

    horris --configfile=/path/to/config.conf

=head1 OPTIONS

=head2 configfile

The location to find the config file. The default is /etc/horris.conf

=cut

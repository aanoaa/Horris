package Morris::Connection::CmdParameter;
use Moose;
use namespace::clean -except => qw/meta/;

has raw_text => (
	is => 'ro', 
	isa => 'Str', 
	required => 1, 
	trigger => sub {
		my ($self) = shift;
		$self->_parse;
	}
);

has command => (
	is => 'ro', 
	isa => 'Str', 
	writer => '_command'
);

has param => (
	is => 'ro', 
	isa => 'Str', 
	writer => '_param'
);

sub _parse {
	my ($self) = @_;
	my ($cmd, $param) = $self->raw_text =~ m/^\b\w+\b\S*\s+(\w+)\s*(.*)$/;
	$self->_command($cmd);
	$self->_param($param);
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Morris::Connection::CmdParameter

=head1 SYNOPSIS

	..

=cut

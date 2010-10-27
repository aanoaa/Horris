package Morris::Connection;
use Moose;
use AnyEvent::IRC::Client;
use Const::Fast;
use namespace::clean -except => qw/meta/;

with 'MooseX::Role::Pluggable';

const my $IRC_DEFAULT_PORT => 6667;

has irc => (
	is => 'rw', 
	isa => 'AnyEvent::IRC::Client', 
	handles => {
		send_srv => 'send_srv', 
	}
);

has nickname => (
	is => 'ro', 
	isa => 'Str', 
	required => 1
);

has password => (
	is => 'ro', 
	isa => 'Str', 
);

has port => (
	is => 'ro', 
	isa => 'Str', 
	default => $IRC_DEFAULT_PORT, 
);

has server => (
	is => 'ro', 
	isa => 'Str', 
	required => 1
);

has username => (
	is => 'ro', 
	isa => 'Str', 
	lazy_build => 1
);

has 'plugin' => (
	traits => ['Hash'], 
	is => 'ro', 
	isa => 'HashRef', 
	handles => {
		get_args => 'get',
	}, 
);

sub _build_username { $_[0]->nickname }

sub run {
	my $self = shift;
	foreach my $plugin (@{ $self->plugin_list }) {
		if ($plugin->can('run')) {
			$plugin->run( $self->get_args($plugin->name) ); # $plugin->{parent} == $self
		}
	}

#	my $irc = AnyEvent::IRC::Client->new();
#	$self->irc($irc);
#	$irc->connect( $self->server, $self->port, {
#			nick => $self->nickname,
#			user => $self->username,
#			password => $self->password,
#			timeout => 1,
#	} );
#	$irc->reg_cb(
#		connect     => sub {
#			warn "connected to: ". $self->server . ":" . $self->port;
#			$self->call_hook( 'server.connected', @_ )
#		},
#		disconnect  => sub { $self->call_hook( 'server.disconnect', @_ ) },
#		irc_privmsg => sub { 
#			my ($nick, $raw) = @_;
#			my $message = Morris::Message->new(
#				channel => $raw->{params}->[0],
#				message => $raw->{params}->[1],
#				from    => $raw->{prefix},
#			);
#			$self->call_hook( 'chat.privmsg', $message )
#		},
#		#
#		# XXX - we want the /full/ details of this user, not his nick
#		#       so we override the original irc_join callback
#		irc_join => sub { 
#			my $object = shift;
#			$object->AnyEvent::IRC::Client::join_cb(@_);
#			# and /THEN/ call our callback
#			# fix the param thing to be just a simple 'channel' parameter
#			my $channel = $_[0]->{params}->[0];
#			my $addr    = Morris::Message::Address->new( $_[0]->{prefix} );
#			$self->call_hook( 'channel.joined', $channel, $addr );
#		},
#		registered  => sub { $self->call_hook( 'server.registered', @_ ) },
#	);
}

#around BUILDARGS => sub {
#	use Data::Dumper 'Dumper';
#	print Dumper(@_);
#};

1;

__END__

=head1 NAME

Morris::Connection - Single IRC Connection

=head1 SYNOPSIS

    use Morris::Connection;

    my $conn = Morris::Connection->new(
        nickname => $nickname,
        port     => $port_number,
        password => $optional_password,
        server   => $server_name,
        username => $username,
    );

    # to receive events
    $conn->register_hook( $hook_name => $code );

    # to send events
    $conn->irc_notice( { channel => $channel, message => $message } );
    $conn->irc_privmsg( { channel => $channel, message => $message } );
    $conn->irc_mode( { channel => $channel, mode => $new_mode, who => $target } );

=cut

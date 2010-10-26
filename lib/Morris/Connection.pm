package Morris::Connection;
use Moose;
use AnyEvent::IRC::Client;
#use Morris::Message;
use namespace::clean -except => qw/meta/;

with 'MooseX::Object::Pluggable';

has irc => (
	is => 'rw', 
	isa => 'AnyEvent::IRC::Client', 
	handles => {
		send_srv => 'send_srv', 
	}
);

has name => (
	is => 'ro', 
	isa => 'Str', 
	required => 1
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
	default => 6667, 
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

sub _build_username { $_[0]->nickname }

sub run {
	my ($self, $plugins) = @_;
	while (my ($name, $opt) = each %$plugins) {
		$name = lc $name;
		$self->$name($opt);
	}

#    my $irc = AnyEvent::IRC::Client->new();
#    $self->irc($irc);
#    $irc->connect( $self->server, $self->port, {
#        nick => $self->nickname,
#        user => $self->username,
#        password => $self->password,
#        timeout => 1,
#    } );
#    $irc->reg_cb(
#        connect     => sub {
#            warn "connected to: ". $self->server . ":" . $self->port;
#            $self->call_hook( 'server.connected', @_ )
#        },
#        disconnect  => sub { $self->call_hook( 'server.disconnect', @_ ) },
#        irc_privmsg => sub { 
#            my ($nick, $raw) = @_;
#            my $message = Morris::Message->new(
#                channel => $raw->{params}->[0],
#                message => $raw->{params}->[1],
#                from    => $raw->{prefix},
#            );
#            $self->call_hook( 'chat.privmsg', $message )
#        },
	#
#        # XXX - we want the /full/ details of this user, not his nick
#        #       so we override the original irc_join callback
#        irc_join => sub { 
#            my $object = shift;
#            $object->AnyEvent::IRC::Client::join_cb(@_);
#            # and /THEN/ call our callback
#            # fix the param thing to be just a simple 'channel' parameter
#            my $channel = $_[0]->{params}->[0];
#            my $addr    = Morris::Message::Address->new( $_[0]->{prefix} );
#            $self->call_hook( 'channel.joined', $channel, $addr );
#        },
#        registered  => sub { $self->call_hook( 'server.registered', @_ ) },
#    );
}

1;

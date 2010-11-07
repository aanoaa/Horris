package Morris::Connection;
use Moose;
use AnyEvent::IRC::Client;
use Const::Fast;
use Morris::Message;
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

has channels => (
	is => 'ro', 
	isa => 'ArrayRef[Str]', 
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
		$plugin->init($self);
	}

	my $irc = AnyEvent::IRC::Client->new();
	$self->irc($irc);

	$irc->reg_cb(disconnect => sub {
		foreach my $plugin (@{ $self->plugin_list }) {
			$plugin->disconnect;
		}
	});

	$irc->reg_cb(connect => sub {
		my ($con, $err) = @_;
		if (defined $err) {
			warn "connect error: $err\n";
			return;
		}

		warn "connected to: " . $self->server . ":" . $self->port if $Morris::DEBUG;
		$irc->send_srv(JOIN => $_) for @{ $self->channels }
	});

	$irc->reg_cb(irc_privmsg => sub {
		my ($con, $raw) = @_;
		my $message = Morris::Message->new(
			channel => $raw->{params}->[0], 
			message => $raw->{params}->[1], 
			from	=> $raw->{prefix}
		);

		if ($message->from->nickname ne $self->nickname) { # loop guard
			foreach my $plugin (@{ $self->plugin_list }) {
				$plugin->irc_privmsg($message) if $plugin->can('irc_privmsg');
			}
		}
	});

	$irc->connect($self->server, $self->port, {
		nick => $self->nickname,
		user => $self->username,
		password => $self->password,
		timeout => 1,
	});
}

sub irc_notice {
    my ($self, $args) = @_;
    $self->send_srv(NOTICE => $args->{channel} => $args->{message});
}

sub irc_privmsg {
    my ($self, $args) = @_;
    $self->send_srv(PRIVMSG => $args->{channel} => $args->{message});
}

sub irc_mode {
    my ($self, $args) = @_;
    $self->send_srv(MODE => $args->{channel} => $args->{mode}, $args->{who});
}

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

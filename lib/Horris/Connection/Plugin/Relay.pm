package Horris::Connection::Plugin::Relay;

use Moose;
use AnyEvent::MP qw(configure port rcv snd);
use AnyEvent::MP::Global qw(grp_reg grp_mon grp_get);
use namespace::clean -except => qw(meta);
use Encode ();
 
extends 'Horris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

has group => (
    is => 'ro',
    isa => 'Str',
    default => 'morris',
    required => 1,
);

has profile => (
    is => 'ro',
    isa => 'Str',
    default => 'morris',
    required => 1,
);
 
has from => (
    traits => [ 'Hash' ],
    is => 'ro',
    isa => 'HashRef',
    required => 1,
    handles => {
      get_instance => 'get',
    }
);
 
has __guard => (
    is => 'rw',
    clearer => 'clear_guard',
);
 
around BUILDARGS => sub {
    my ($next, $class, @args) = @_;
    my $args = $next->($class, @args);

	#use Data::Dumper;
	#print Dumper($args);
	#print Dumper($args->{from});
	#print $args->{parent}->{server};
 
	#my $configs = $args->{from};
    #foreach my $name (keys %{ $configs }) {
    #    my $config = $configs->{$name};
    #    $config->{to} = [ (split /,/, $config->{to}) ];
    #    $config->{type} = 'privmsg' unless $config && $config->{type} && $config->{type} =~ /(?:privmsg|notice)/;
    # }
    return $args;
};

sub on_connect {
	my ($self) = @_;

	my $conn = $self->connection;
    my $server = port;
    rcv $server, notice => sub {
        my ($channel, $message) = @_;
        $conn->irc_notice( {
            channel => $channel,
            message => $message
        });
    };
    rcv $server, privmsg => sub {
        my ($channel, $message) = @_;
        $conn->irc_privmsg( {
            channel => $channel,
            message => $message
        });
    };
	warn "MP Server - $server\n";
    $self->__guard( grp_reg $self->group, $server );
}

sub irc_privmsg {
    my ($self, $msg) = @_;
 
    my $channel = $msg->channel;
    my $message = $msg->message;
    my $nickname = $msg->nickname;

	warn "channel, message, nickname = $channel, $message, $nickname\n";
 
    return unless $channel;
    return unless $message;

	use Data::Dumper;
	#warn Dumper($self->from);
 
    my $config = $self->from->{'\\'.$channel};

	warn Dumper($config);
	
	return unless $config;

	print "before __guard \n";

	my $ports = grp_get $config->{target};
	if($ports) {
		my $server = $ports->[0];
		my $msg = sprintf('<%s::%s> %s', $channel, $nickname, $message);
		warn "$msg\n";
		warn Dumper($config);

		if ($config->{encode} && $config->{decode}) {
		$msg = Encode::encode($config->{encode}, Encode::decode($config->{decode}, $msg));
		}

		snd $server, $config->{type} => $_, $msg for @{ $config->{to} };
	}
}
 
#after register => sub {
#    my ($self, $conn) = @_;
#
#	#configure profile => $self->profile;
#	warn 'profile : ', $self->profile, " group :", $self->group, "\n";
#
#    my $server = port;
#	warn $self->profile, ' > ', $server, "\n";
#    rcv $server, notice => sub {
#        my ($channel, $message) = @_;
#        $conn->irc_notice( {
#            channel => $channel,
#            message => $message
#        });
#    };
#    rcv $server, privmsg => sub {
#        my ($channel, $message) = @_;
#        $conn->irc_privmsg( {
#            channel => $channel,
#            message => $message
#        });
#    };
#    $self->__guard( grp_reg $self->group, $server );
# 
#    $conn->register_hook( 'chat.privmsg', sub { $self->handle_message(@_) } );
#};
# 
#sub handle_message {
#    my ($self, $msg) = @_;
# 
#    my $channel = $msg->channel;
#    my $message = $msg->message;
#    my $nickname = $msg->nickname;
#
#	warn "channel, message, nickname = $channel, $message, $nickname\n";
# 
#    return unless $channel;
#    return unless $message;
#
#	use Data::Dumper;
#	#warn Dumper($self);
# 
#    my $config = $self->from->{'\\'.$channel};
#
#	warn Dumper($config);
#	
#	return unless $config;
#
#	print "before __guard \n";
#
#	my $ports = grp_get $config->{target};
#	if($ports) {
#		my $server = $ports->[0];
#		my $msg = sprintf('<%s::%s> %s', $channel, $nickname, $message);
#		warn "$msg\n";
#		warn Dumper($config);
#
#		if ($config->{encode} && $config->{decode}) {
#		$msg = Encode::encode($config->{encode}, Encode::decode($config->{decode}, $msg));
#		}
#
#		snd $server, $config->{type} => $_, $msg for @{ $config->{to} };
#	}
#
#	#$self->__guard(grp_mon $config->{target}, sub {
#	#	my ($ports, $add, $del) = @_;
#
#	#	warn "ports, add, del = <@$ports>, <@$add>, <@$del>\n";
#
#	#	my $server = $ports->[0];
#	#	my $msg = sprintf('<%s::%s %s> %s', $self->profile, $channel, $nickname, $message);
#	#	warn "$msg\n";
#	#	warn Dumper($config);
#
#	#	if ($config->{encode} && $config->{decode}) {
#	#	$msg = Encode::encode($config->{encode}, Encode::decode($config->{decode}, $msg));
#	#	}
#
#	#	snd $server, $config->{type} => $_, $msg for @{ $config->{to} };
#	#});
#}
 
__PACKAGE__->meta->make_immutable();
 
1;
 
__END__
 
config
 
...
<Plugin MP::Relay>
<From \#perl-kr>
Target freenode
To \#perl
Type privmsg
</From>
</Plugin>
...

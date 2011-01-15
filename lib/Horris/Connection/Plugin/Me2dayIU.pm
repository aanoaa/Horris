package Horris::Connection::Plugin::Me2dayIU;
use Moose;
use JSON;
use AnyEvent::HTTP;
use AnyEvent;
use LWP::UserAgent;
use WWW::Shorten 'TinyURL';
use Encode qw/encode decode/;
extends 'Horris::Connection::Plugin';
with 'MooseX::Role::Pluggable::Plugin';

sub on_connect {
    warn __PACKAGE__ . " on_connect\n";
#    my ($self) = shift;
#    my $timer = AnyEvent->timer (
#        after => 1,
#        interval => 1, 
#        cb => sub {
#            warn "timeout\n";
#        }
#    );
};

sub irc_privmsg {
	my ($self, $message) = @_;
    my $file;

	unless ($message->message =~ m/^iu/i) {
        return undef;
    }

    my $guard; $guard = http_get "http://me2day.net/api/get_posts/i_u0516.json",
        timeout   => 30,
        recurse   => 10,
        on_header => sub {
            my ($headers) = @_;
            if ($headers->{Status} ne '200') {
                undef $guard;
                return;
            }
            return 1;
        }, 
        on_body => sub {
            $file ||= File::Temp->new(UNLINK => 1);
            print $file $_[0];
            return 1;
        }, 
        sub {
            undef $guard;
            return unless $file;
            seek($file, 0, 0);
            my $data = do { local $/; <$file> };
            my $content = from_json($data);
            for my $tweet (@{ $content }) {
                my $out = $tweet->{textBody};
                if ($tweet->{media}{photoUrl}) {
                    my $url = $tweet->{media}{photoUrl};
                    my $uri = URI->new($url);
                    next unless $uri->scheme && $uri->scheme =~ /^http/i;
                    next unless $uri->authority;

                    if (length "$uri" > 50 && $uri->authority !~ /tinyurl|bit\.ly/) {
                        $url = makeashorterlink($uri);
                    }

                    $out .= ' ' . $url;
                }

                $self->connection->irc_privmsg({
                    channel => $message->channel, 
                    message => encode('utf8', $out)
                });
            }
        };

	return $self->pass;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

Horris::Connection::Plugin::Me2dayIU

=head1 SYNOPSIS

...

=cut

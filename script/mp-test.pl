use AnyEvent;
use AnyEvent::MP;
use AnyEvent::MP::Global;

$| = 1;

print "Before Configure... \n";
configure nodeid => "eg_sender", seeds => ["192.168.0.211:4040"];
print "Done.\n";

my $find_timer =
    AnyEvent->timer (after => 0, interval => 1, cb => sub {

	print "Getting 'eg_receivers'...\n";
         my $ports = grp_get "eg_receivers"
	     or return;
	print "Done.\n";

	my $msg = $$ . ', ' . time;
	print $msg, "\n";
         snd $_, test => $msg
	     for @$ports;
		     });

AnyEvent->condvar->recv;


### run
### PERL_ANYEVENT_MP_RC=./perl-anyevent-mp PERL_ANYEVENT_MP_WARNLEVEL=9 PERL_ANYEVENT_MP_TRACE=1 perl t_anyevent_mp_2_2.pl

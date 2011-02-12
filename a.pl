use Horris;
my $config = {
    'network' => {
        'freenode' => {
            'nickname' => 'hongbot',
            'server' => 'irc.freenode.net',
            'port' => '6667',
            'username' => 'hongbot'
        }
    },
    'connection' => {
        'freenode' => {
            'plugin' => {
                'Join' => {
                    'channels' => [ '#perl-kr' ]
                },
                'Twitter' => {},
            }, 
            'network' => 'freenode',
            'loadmodule' => [
                'Twitter',
            'Join',
            ]
        }
    }
};

my $horris = Horris->new(config => $config);
$horris->run;

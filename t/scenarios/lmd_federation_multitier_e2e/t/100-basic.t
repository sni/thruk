use warnings;
use strict;
use Cpanel::JSON::XS;
use HTML::Entities;
use Test::More;
use URI::Escape qw/uri_escape/;

BEGIN {
    plan skip_all => 'backends required' if(!-s 'thruk_local.conf' and !defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'});
    plan tests => 315;
}


BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

###############################################################################
TestUtils::test_page(
    'url'    => '/thruk/cgi-bin/status.cgi?hostgroup=all&style=hostdetail',
    'like'   => [
                '"total":12', '"disabled":0', '"up":12', ,'"down":0',
            ],
);

###############################################################################
# fetch backend ids
my $test = TestUtils::test_page(
    'url'    => '/thruk/cgi-bin/extinfo.cgi?type=0&view_mode=json',
    'like'   => [
                'peer_addr',
                'https://127.0.0.3:60443/demo/thruk/',
                'data_source_version',
            ],
);
my $procinfo = Cpanel::JSON::XS::decode_json($test->{'content'});
my $ids      = {map { $_->{'peer_name'} => $_->{'peer_key'} } values %{$procinfo}};
is(scalar keys %{$ids}, 12, 'got backend ids') || die("all backends required");
ok(defined $ids->{'tier1a'}, 'got backend ids II');

###############################################################################
# force reschedule checks
for my $hst (sort keys %{$ids}) {
    TestUtils::test_page(
        'url'    => '/thruk/r/hosts/'.$hst.'/cmd/schedule_forced_host_check',
        'method' => 'POST',
        'like'   => [ 'Command successfully submitted' ],
    );
    my @svc = qw/Ping Load/;
    if($hst eq 'tier3c') {
        @svc = qw/ping4 disk/;
    }
    for my $svc (@svc) {
        TestUtils::test_page(
            'url'    => '/thruk/r/services/'.$hst.'/'.$svc.'/cmd/schedule_forced_svc_check',
            'method' => 'POST',
            'like'   => [ 'Command successfully submitted' ],
        );
    }
}

###############################################################################
# send multiple commands to sub peers
TestUtils::test_page(
    'url'    => '/thruk/cgi-bin/cmd.cgi',
    'post'   => {
        'referer'           => 'status.cgi',
        'selected_services' => 'tier3b;Load;e984d;e984d,tier3b;Ping;e984d',
        'selected_hosts'    => '',
        'quick_command'     => '1', # reschedule
        'start_time'        => time(),
    },
    'like'   => [ 'Commands successfully submitted' ],
    'follow' => 1,
);

###############################################################################
{
    # create a downtime
    my $rand    = rand();
    my $comment = 'test downtime '.$rand;
    TestUtils::test_page(
        'url'    => '/thruk/cgi-bin/cmd.cgi',
        'post'   => {
            'referer'            => 'status.cgi',
            'selected_services'  => 'tier2a;Ping;c21da',
            'selected_hosts'     => '',
            'quick_command'      => '2', # add downtime
            'start_time'         => time(),
            'end_time'           => time()+60,
            'com_data'           => $comment,
            'childoptions'       => 0,
            'fixed'              => 1,
            'hostserviceoptions' => 0,
        },
        'like'   => [ 'Commands successfully submitted' ],
        'follow' => 1,
    );

    # delete command should only go to a single backend
    local $ENV{'THRUK_TEST_NO_AUDIT_LOG'} = undef;
    my $test = {
        cmd     => './script/thruk "cmd.cgi?quick_command=5&active_downtimes=1&selected_services='.uri_escape("tier2a;Ping;c21da").'" -v',
        errlike => ['/Your command request was successfully submitted to the backend/', '/\[tier2a\]\s+/', '/cmd: COMMAND \[\d+\]\ DEL_SVC_DOWNTIME;\d+\s+\(tier2a;Ping\)/' ],
        like    => ['/^\s*$/'],
        exit    => 0,
    };
    TestUtils::test_command($test);
    my @matches = $test->{'stderr'} =~ m/^(.*cmd:\s+COMMAND.*)$/gmx;
    require Data::Dumper;
    is(scalar @matches, 2, "one command sent") or diag(Data::Dumper::Dumper(\@matches));
    like($matches[0], qr/DEL_SVC_DOWNTIME;/, "downtime delete command") or diag(Data::Dumper::Dumper(\@matches));
    like($matches[1], qr/LOG;SERVICE NOTE:/, "downtime delete command") or diag(Data::Dumper::Dumper(\@matches));
};

###############################################################################
TestUtils::test_command({
    cmd     => './script/thruk selfcheck lmd',
    like => ['/lmd running with pid/',
             '/12\/12 backends online/',
            ],
    exit    => 0,
});

###############################################################################

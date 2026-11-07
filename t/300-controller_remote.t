use warnings;
use strict;
use Test::More tests => 61;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    $ENV{'THRUK_TEST_NO_LOG'} = 1;
}

use_ok 'Thruk::Controller::remote';
use_ok 'Thruk::Config';

TestUtils::test_page(
    'url'          => '/thruk/cgi-bin/remote.cgi',
    'like'         => 'OK',
    'skip_doctype' => 1,
);

TestUtils::test_page(
    'url'          => '/thruk/cgi-bin/remote.cgi?startup',
    'like'         => 'startup done',
    'skip_doctype' => 1,
);

TestUtils::test_page(
    'url'          => '/thruk/cgi-bin/remote.cgi?compile',
    'like'         => '(already compiled|\d+ templates precompiled in \d+\.\d+s)',
    'skip_doctype' => 1,
);

TestUtils::test_page(
    'url'          => '/thruk/cgi-bin/remote.cgi?log',
    'post'         => { 'test log data' => '' },
    'like'         => 'OK',
    'skip_doctype' => 1,
);

# make sure we have a secret key
if(!Thruk::Config::secret_key()) {
    require Thruk;
    local $ENV{'THRUK_MODE'} = 'FASTCGI';
    Thruk::_create_secret_file();
}
# backends required for this test
my $c        = TestUtils::get_c();
my $backends = $c->db->get_peers();
SKIP: {
    skip "backends required", 7 if (scalar @{$backends} == 0);
    TestUtils::test_page(
        'url'          => '/thruk/cgi-bin/remote.cgi',
        'post'         => { data => '{"options":{"action": "raw", "sub":"get_processinfo"},"credential":"'.Thruk::Config::secret_key().'"}' },
        'like'         => ['version', 'configtool', 'data_source_version'],
        'unlike'       => ['ARRAY'],
    );
};

###########################################################
# Lifecycle commands must never signal real workers in this test.
{
    require Thruk::Utils::CLI;
    require Thruk::Authentication::User;
    no warnings 'redefine';
    my $stops = 0;
    my $roles;
    local *Thruk::stop_all = sub { $stops++; return 1; };
    local *Thruk::Context::authenticate = sub {
        my($ctx, %args) = @_;
        return 0 unless $args{'apikey'} eq 'dummykey';
        $ctx->{'user'} = bless({roles => $roles}, 'Thruk::Authentication::User');
        return 1;
    };
    local $c->{'user'};

    for my $role ([], ['authorized_for_read_only'], ['authorized_for_admin']) {
        $roles = $role;
        my $admin = grep { $_ eq 'authorized_for_admin' } @{$roles};
        for my $action ('stop', 'restart') {
            $stops = 0;
            my $res = Thruk::Utils::CLI::from_fcgi($c,
                '{"credential":"dummykey","options":{"action":"'.$action.'","src":"local"}}');
            is($res->{'rc'}, $admin ? 0 : 1, $action.' remote exit status for '.join(',', @{$roles}));
            like($res->{'output'}, $admin ? qr/^OK -/ : qr/admin privileges required/, $action.' remote output');
            is($stops, $admin ? 1 : 0, $action.' only stops workers for remote admins');
        }
    }

    $c->{'user'} = bless({roles => []}, 'Thruk::Authentication::User');
    for my $action ('stop', 'restart') {
        $stops = 0;
        my $res = Thruk::Utils::CLI::_run_commands($c, {action => $action}, 'local');
        is($res->{'rc'}, 0, $action.' local exit status');
        like($res->{'output'}, qr/^OK -/, $action.' local output');
        is($stops, 1, $action.' remains available to trusted local CLI');
    }
}

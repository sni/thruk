use warnings;
use strict;
use Test::More;

BEGIN {
    plan skip_all => 'internal test only' if defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'};

    use lib('t');
    require TestUtils;
    import TestUtils;
}

use Thruk::Request ();
use Thruk::Utils::OAuth ();

my $c = TestUtils::get_c();

subtest 'OAuth callbacks require the initiating browser' => sub {
    no warnings qw/redefine once/;
    local *Thruk::Utils::OAuth::_cleanup_oauth_files = sub { return; };
    local *Thruk::Context::detach_error = sub { return $_[1]->{'code'}; };
    local *Thruk::UserAgent::new = sub { die("token exchange reached\n"); };

    for my $pkce (0, 1) {
        local $c->{'config'} = { %{$c->config}, auth_oauth => { provider => [{ enable_pkce => $pkce }] } };
        my $data = { oauth => 0, browser_token => 'browser-a-secret', pkce_code => 'dummy-verifier' };
        local *Thruk::Utils::IO::json_lock_retrieve = sub { return $data; };

        for my $token (undef, 'browser-b-secret', 'browser-a-secret') {
            local $c->{'req'} = Thruk::Request->new({
                'psgi.url_scheme' => 'http',
                REQUEST_METHOD => 'GET',
                HTTP_HOST => 'localhost',
                HTTP_COOKIE => defined $token ? 'thruk_oauth_dummy-state='.$token : '',
                QUERY_STRING => 'code=dummy-code&state=dummy-state',
            });
            my $result = eval { Thruk::Utils::OAuth::handle_oauth_login($c, '/', '/thruk/', undef) };
            if(defined $token && $token eq 'browser-a-secret') {
                is($@, "token exchange reached\n", "matching browser reaches token exchange (PKCE=$pkce)");
                is($c->res->cookies->{'thruk_oauth_dummy-state'}->{'value'}, '', 'browser cookie is cleared');
            } else {
                is($@, '', 'no token exchange for a different browser');
                is($result, 400, "missing or mismatched browser cookie rejected (PKCE=$pkce)");
            }
        }

        delete $data->{'browser_token'};
        local $c->{'req'} = Thruk::Request->new({
            'psgi.url_scheme' => 'http',
            REQUEST_METHOD => 'GET',
            HTTP_HOST => 'localhost',
            HTTP_COOKIE => 'thruk_oauth_dummy-state=browser-a-secret',
            QUERY_STRING => 'code=dummy-code&state=dummy-state',
        });
        is(Thruk::Utils::OAuth::handle_oauth_login($c, '/', '/thruk/', undef), 400, 'unbound legacy state rejected');
    }
    done_testing();
};

done_testing();

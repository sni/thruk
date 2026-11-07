use warnings;
use strict;
use Test::More;

BEGIN {
    plan skip_all => 'backends required' if(!-s 'thruk_local.conf' and !defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'});
    plan tests => 39;
}

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}
BEGIN { use_ok 'Thruk::Controller::user' }

my $pages = [
    { url => '/thruk/cgi-bin/user.cgi', like => ['Username', 'Change Password'] },
    { url => '/thruk/cgi-bin/user.cgi?clear_auth_cache=1', like => ['Username', 'Change Password'], follow => 1 },
    { url => '/thruk/cgi-bin/user.cgi?action=apikeys', like => ['Select Roles', 'Save New API Key'] },
];

for my $url (@{$pages}) {
    if(ref $url eq 'HASH') {
        TestUtils::test_page( %{$url} );
    } else {
        TestUtils::test_page( 'url' => $url );
    }
}

subtest 'tokenless api key mutations are rejected before the sink' => sub {
    my $c = TestUtils::get_c();
    no warnings qw/redefine once/;
    local *Thruk::Action::AddDefaults::add_defaults = sub { return 1; };
    local *Thruk::Utils::set_message    = sub { return; };
    my $mutation = '';
    local *Thruk::Utils::APIKeys::remove_key           = sub { $mutation = 'remove'; };
    local *Thruk::Utils::APIKeys::create_key_by_params = sub { $mutation = 'create'; return (undef, undef, undef); };
    # simulate a tokenless request: the real check_csrf would detach here
    local *Thruk::Utils::check_csrf = sub { return 0; };
    $c->stash->{'remote_user'} = 'dummy-user';
    for my $action (qw/create remove_key/) {
        $c->req->parameters({ action => $action, file => 'dummy-key' });
        my $result = Thruk::Controller::user::index($c);
        is($result, undef, "$action: tokenless request aborted");
        is($mutation, '', "$action: no mutation performed without csrf token");
    }
    done_testing();
};

#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use utf8;

BEGIN {
    plan skip_all => 'internal test only' if defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'};
    plan tests => 9;

    use lib('t');
    require TestUtils;
    import TestUtils;
}

use_ok('Thruk::Utils::APIKeys');
use_ok('Thruk::Authentication::User');
use_ok('Thruk::Utils');
use_ok('Thruk::Request');

#########################
my $c = TestUtils::get_c();

#########################
subtest 'derived credentials preserve role restrictions' => sub {
    my $username = 'derived-credentials-test';
    local $c->{'config'} = { %{$c->config}, authorized_for_admin => [$username] };
    local $c->{'stash'} = { %{$c->stash}, remote_user => $username };
    local $c->{'session'};

    for my $restriction (undef, ['authorized_for_all_hosts'], []) {
        local $c->{'user'} = Thruk::Authentication::User->new($c, $username);
        $c->user->set_dynamic_attributes($c, 1, $restriction);
        my $expected_roles = [ @{$c->user->{'roles'}} ];

        for my $params ({}, { roles => ['authorized_for_system_commands'], restrict_only => 1 }) {
            my($privatekey, undef, $file) = Thruk::Utils::APIKeys::create_key_by_params($c, $params);
            my $key = Thruk::Utils::APIKeys::get_key_by_private_key($c->config, $privatekey);
            is_deeply($key->{'roles'}, $restriction, 'child key inherits the role ceiling');
            unlink($file);
        }

        my($sessionid, $sessiondata) = Thruk::Utils::get_fake_session($c);
        is_deeply($sessiondata->{'roles_restriction'}, $restriction, 'session retains the role ceiling');
        local $c->{'req'} = Thruk::Request->new({ HTTP_COOKIE => 'thruk_auth='.$sessionid });
        $c->{'user'} = undef;
        my $user = $c->authenticate(apikey => '', skip_db_access => 1);
        is_deeply($user->{'roles'}, $expected_roles, 'cookie authentication preserves effective roles');
        unlink($sessiondata->{'file'});
    }
    done_testing();
};

#########################
{
    my($username, $comment, $roles, $system) = ('test', 'comment', [], 0);
    my($privatekey, $hashed_key, $file) = Thruk::Utils::APIKeys::create_key($c, $username, $comment, $roles, $system);
    ok(-f $file, 'api key created');
    my $apikey = Thruk::Utils::APIKeys::get_key_by_private_key($c->config, $privatekey);
    is($apikey->{'user'}, $username, "got api key user");
    is($apikey->{'comment'}, $comment, "got api key comment");
    is($apikey->{'file'}, $file, "got api key file");
    unlink($file);
}

#########################

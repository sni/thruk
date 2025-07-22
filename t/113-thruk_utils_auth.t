use warnings;
use strict;
use Test::More;

plan tests => 10;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

undef $ENV{'THRUK_MODE'}; # do not die on backend errors

use_ok('Thruk::Utils::Auth');

################################################################################
my $c = TestUtils::get_c();
ok($c->user, "user object exists");

################################################################################
# permissions with selected services
{
    my $permissions = [{
        'hostgroups' => ['*'],
        'hostgroups_op' => '=',
        'hosts' => ['*'],
        'hosts_op' => '=',
        'services' => ['Https', 'Http', 'Disk /'],
        'services_op' => '=',
        'with_services' => '2'
    }];
    my $expected_hst_filter = [{ 'name' => { '!=' => '' } }];
    $c->user->{'permissions'} = $permissions;
    my $filter = Thruk::Utils::Auth::_permission_filter($c, 'hosts');
    is_deeply($filter, $expected_hst_filter, "hosts filter is correct");

    # host cmd filter
    $filter = Thruk::Utils::Auth::_permission_filter($c, 'hosts', 1);
    is_deeply($filter, [], "hosts cmd filter is correct");

    my $expected_svc_filter = [{
        '-and' => [
                    { 'host_name' => { '!=' => '' } },
                    { '-or' => [
                            { 'description' => { '=' => 'Https' } },
                            { 'description' => { '=' => 'Http' } },
                            { 'description' => { '=' => 'Disk /' } }
                        ]
                    }
                ]
    }];
    $filter = Thruk::Utils::Auth::_permission_filter($c, 'services');
    is_deeply($filter, $expected_svc_filter, "hosts filter is correct");

    # service cmd filter
    $filter = Thruk::Utils::Auth::_permission_filter($c, 'services', 1);
    is_deeply($filter, [], "service filter is correct");
};

################################################################################
# permissions with custom variables
{
    my $permissions = [{
        'hst_custom_val' => '1',
        'hst_custom_op' => '=',
        'hst_custom_var' => 'TEST',
        'svc_custom_var' => 'TEST',
        'svc_custom_op' => '=',
        'svc_custom_val' => '2',
        'with_services' => '2'
    }];
    my $expected_hst_filter = [ { 'custom_variables' => { '=' => 'TEST 1' } } ];
    $c->user->{'permissions'} = $permissions;
    my $filter = Thruk::Utils::Auth::_permission_filter($c, 'hosts');
    is_deeply($filter, $expected_hst_filter, "hosts filter is correct");

    # host cmd filter
    $filter = Thruk::Utils::Auth::_permission_filter($c, 'hosts', 1);
    is_deeply($filter, [], "hosts cmd filter is correct");

    my $expected_svc_filter = [{
        '-and' => [{ 'host_custom_variables' => { '=' => 'TEST 1' } },
                   { 'custom_variables'      => { '=' => 'TEST 2' } } ],
    }];
    $filter = Thruk::Utils::Auth::_permission_filter($c, 'services');
    is_deeply($filter, $expected_svc_filter, "hosts filter is correct");

    # service cmd filter
    $filter = Thruk::Utils::Auth::_permission_filter($c, 'services', 1);
    is_deeply($filter, [], "service filter is correct");
};

################################################################################

use warnings;
use strict;
use Test::More;

plan tests => 6;

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
{
    my $permissions = [{
        'allowed_commands' => '',
        'hostgroups' => [
                            '*'
                        ],
        'hostgroups_op' => '=',
        'hosts' => [
                        '*'
                    ],
        'hosts_op' => '=',
        'hst_custom_op' => '=',
        'hst_custom_val' => '',
        'hst_custom_var' => '',
        'services' => [
                        'Https',
                        'Http',
                        'Disk /'
                        ],
        'services_op' => '=',
        'svc_custom_op' => '=',
        'svc_custom_val' => '',
        'svc_custom_var' => '',
        'with_services' => '2'
    }];
    my $expected_hst_filter = { 'name' => { '!=' => '' } };
    $c->user->{'permissions'} = $permissions;
    my $filter = Thruk::Utils::Auth::_permission_filter($c, 'hosts');
    is_deeply($filter, $expected_hst_filter, "hosts filter is correct");

    # host cmd filter
    $filter = Thruk::Utils::Auth::_permission_filter($c, 'hosts', 1);
    is_deeply($filter, [], "hosts cmd filter is correct");

    my $expected_svc_filter = {
        '-and' => [
                    { 'host_name' => { '!=' => '' } },
                    { '-or' => [
                            { 'description' => { '=' => 'Https' } },
                            { 'description' => { '=' => 'Http' } },
                            { 'description' => { '=' => 'Disk /' } }
                        ]
                    }
                ]
    };
    $filter = Thruk::Utils::Auth::_permission_filter($c, 'services');
    is_deeply($filter, $expected_svc_filter, "hosts filter is correct");

    # host cmd filter
    $filter = Thruk::Utils::Auth::_permission_filter($c, 'services', 1);
    is_deeply($filter, [], "service filter is correct");
};

################################################################################

use warnings;
use strict;
use Test::More;
use utf8;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    plan tests => 257;
}

###############################################################################
# login as omdadmin
{
    TestUtils::test_page(
        'url'     => '/thruk/cgi-bin/login.cgi',
        'post'    => { 'oauth' => 1, submit => 'login' },
        'like'    => ['tac.cgi', 'omdadmin'],
        'follow'  => 1,
    );

    ###########################################################################
    TestUtils::test_page(
        'url'   => '/thruk/cgi-bin/user.cgi',
        'like'  => ['omdadmin', 'authorized_for_admin', 'group1', 'from teams: group1' ],
    );

    ###########################################################################
    TestUtils::test_page(
        'url'   => '/thruk/cgi-bin/conf.cgi?sub=teams&action=edit&team=group1',
        'like'  => ['authorized_for_admin', 'Create a new team' ],
    );

    ###########################################################################
    TestUtils::test_page(
        'url'   => '/thruk/cgi-bin/login.cgi?logout',
        'like'  => ['omdadmin sso'],
        'code'  => 401,
        'follow'  => 1,
    );
};

###############################################################################
# login as user
{
    TestUtils::test_page(
        'url'     => '/thruk/cgi-bin/login.cgi',
        'post'    => { 'oauth' => 0, submit => 'login' },
        'like'    => ['tac.cgi', 'clientö'],
        'follow'  => 1,
    );

    ###########################################################################
    TestUtils::test_page(
        'url'   => '/thruk/cgi-bin/user.cgi',
        'like'  => ['clientö', 'authorized_for_broadcasts', 'group2', 'from teams: group2' ],
    );

    ###########################################################################
    TestUtils::test_page(
        'url'   => '/thruk/cgi-bin/login.cgi?logout',
        'like'  => ['user sso'],
        'code'  => 401,
        'follow'  => 1,
    );
};

###############################################################################
# login as test
{
    TestUtils::test_page(
        'url'     => '/thruk/cgi-bin/login.cgi',
        'post'    => { 'oauth' => 2, submit => 'login' },
        'like'    => ['tac.cgi', 'testuser'],
        'follow'  => 1,
    );

    ###########################################################################
    TestUtils::test_page(
        'url'   => '/thruk/cgi-bin/user.cgi',
        'like'  => ['testuser', 'group3' ],
    );

    ###########################################################################
    TestUtils::test_page(
        'url'    => '/thruk/cgi-bin/status.cgi?style=detail',
        'like'   => ['testuser', 'Https', 'Disk /', 'Ping' ],
        'unlike' => ['Zombie', 'Load' ],
    );

    ###########################################################################
    # _HOST_: no command permissions
    TestUtils::test_page(
        'url'    => '/thruk/cgi-bin/extinfo.cgi?type=1&host=localhost',
        'like'   => ['localhost', 'Host Information', 'does not have permissions to execute commands' ],
    );

    ###########################################################################
    # Http: service with command permissions
    TestUtils::test_page(
        'url'    => '/thruk/cgi-bin/extinfo.cgi?type=2&host=localhost&service=Http',
        'like'   => ['localhost', 'Http', 'Service Information', 'Disable active checks of this service' ],
        'unlike' => ['Configuration Information', 'lib/monitoring-plugins/check_http' ],
    );
    TestUtils::test_page(
        'url'    => '/thruk/cgi-bin/cmd.cgi?cmd_typ=7&host=localhost&service=Http',
        'like'   => ['localhost', 'Http', 'Command Description', 'You are requesting to schedule a service check' ],
    );

    ###########################################################################
    # Https: service with command permissions and command line
    TestUtils::test_page(
        'url'    => '/thruk/cgi-bin/extinfo.cgi?type=2&host=localhost&service=Https',
        'like'   => ['localhost', 'Https', 'Service Information', 'Disable active checks of this service', 'Configuration Information', 'lib/monitoring-plugins/check_http' ],
    );
    TestUtils::test_page(
        'url'    => '/thruk/cgi-bin/cmd.cgi?cmd_typ=7&host=localhost&service=Https',
        'like'   => ['localhost', 'Https', 'Command Description', 'You are requesting to schedule a service check' ],
    );

    ###########################################################################
    # Load: no permission at all for this service
    TestUtils::test_page(
        'url'    => '/thruk/cgi-bin/extinfo.cgi?type=2&host=localhost&service=Load',
        'like'   => ['you do not have permission' ],
        'code'   => 403,
    );
    TestUtils::test_page(
        'url'    => '/thruk/cgi-bin/cmd.cgi?cmd_typ=7&host=localhost&service=Load',
        'like'   => ['you are not authorized for this command' ],
    );

    ###########################################################################
    # Ping: read-only permission for this service
    TestUtils::test_page(
        'url'    => '/thruk/cgi-bin/extinfo.cgi?type=2&host=localhost&service=Ping',
        'like'   => ['localhost', 'Ping', 'Service Information', 'does not have permissions to execute commands' ],
        'unlike' => ['Disable active checks of this service', 'Configuration Information', 'lib/monitoring-plugins/check_ping' ],
    );
    TestUtils::test_page(
        'url'    => '/thruk/cgi-bin/cmd.cgi?cmd_typ=7&host=localhost&service=Ping',
        'like'   => ['you are not authorized for this command' ],
    );

    ###########################################################################
    TestUtils::test_page(
        'url'   => '/thruk/cgi-bin/login.cgi?logout',
        'like'  => ['test sso'],
        'code'  => 401,
        'follow'  => 1,
    );
};

###############################################################################

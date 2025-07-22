use warnings;
use strict;
use Test::More;
use utf8;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    plan tests => 139;
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
        'like'   => ['testuser', 'Https', 'Disk /' ],
        'unlike' => ['Zombie', 'Ping' ],
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

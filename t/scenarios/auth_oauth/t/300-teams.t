use warnings;
use strict;
use Test::More;
use utf8;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    plan tests => 51;
}

###############################################################################
# login as omdadmin
TestUtils::test_page(
    'url'     => '/thruk/cgi-bin/login.cgi',
    'post'    => { 'oauth' => 1, submit => 'login' },
    'like'    => ['tac.cgi', 'omdadmin'],
    'follow'  => 1,
);

###############################################################################
TestUtils::test_page(
    'url'   => '/thruk/cgi-bin/user.cgi',
    'like'  => ['omdadmin', 'authorized_for_admin', 'group1', 'group2' ],
);

###############################################################################
TestUtils::test_page(
    'url'   => '/thruk/cgi-bin/conf.cgi?sub=teams&action=edit&team=group1',
    'like'  => ['authorized_for_admin', 'Create a new team' ],
);

###############################################################################
TestUtils::test_page(
    'url'   => '/thruk/cgi-bin/login.cgi?logout',
    'like'  => ['omdadmin sso'],
    'code'  => 401,
    'follow'  => 1,
);

###############################################################################

use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

plan tests => 17;

$ENV{'THRUK_TEST_AUTH'}               = 'omdadmin:omd';
$ENV{'PLACK_TEST_EXTERNALSERVER_URI'} = 'https://127.0.0.1/demo';
$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'}  = 0;

###########################################################
# verify that we use the correct thruk binary
TestUtils::test_command({
    cmd  => '/bin/bash -c "type thruk"',
    like => ['/\/thruk\/script\/thruk/'],
}) or BAIL_OUT("wrong thruk path");

###########################################################
# check cron entries
TestUtils::test_command({
    cmd  => '/usr/bin/env crontab -l | grep thruk',
    like => ['/bp all/', '/thruk maintenance/', '/cron\.log/'],
});

###########################################################
TestUtils::test_page( url => '/thruk/cgi-bin/bp.cgi?view_mode=json&no_drafts=1&type=all', like => ['Test Business Process'] );

###########################################################

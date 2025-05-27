use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

plan tests => 11;

###########################################################
# verify that we use the correct thruk binary
TestUtils::test_command({
    cmd  => '/bin/bash -c "type thruk"',
    like => ['/\/thruk\/script\/thruk/'],
}) or BAIL_OUT("wrong thruk path");

###########################################################
# clean up mail spool
TestUtils::test_command({
    cmd     => '/bin/bash -c ">/var/spool/mail/demo"',
    like    => [],
    errlike => [],
    exit    => undef,
});
ok(!-s '/var/spool/mail/demo', 'mail spool is empty');

###########################################################
# thruk cli reports
TestUtils::test_command({
    cmd  => "/usr/bin/env thruk report mail 4",
    like => ['/mail sent successfully/'],
    unlike => ['/ERROR/'],
});

###########################################################

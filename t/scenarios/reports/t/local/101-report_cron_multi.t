use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

plan tests => 14;

###########################################################
# verify that we use the correct thruk binary
TestUtils::test_command({
    cmd  => '/bin/bash -c "type thruk"',
    like => ['/\/thruk\/script\/thruk/'],
}) or BAIL_OUT("wrong thruk path");

###########################################################
# reset all reports
TestUtils::test_command({
    cmd     => '/bin/bash -c "rm var/thruk/reports/*.{log,dat,html}"',
    like    => [],
    errlike => [],
    exit    => undef,
});
# remove start dates, otherwise it would not be generated in the same minute again
TestUtils::test_command({
    cmd     => '/bin/bash -c "sed \'/start_time/d\' -i var/thruk/reports/*.rpt"',
    like    => [],
    errlike => [],
    exit    => undef,
});

###########################################################
# thruk cli cron reports
TestUtils::test_command({
    cmd  => '/bin/bash -c "THRUK_CRON=1 thruk report \'1|2|3|4\'"',
    like => [],
    unlike => ['/ERROR/'],
});

###########################################################
# all should have been generated
TestUtils::test_command({
    cmd     => '/bin/bash -c "ls -l1 var/thruk/reports/*.dat | wc -l"',
    like    => ['/4/'],
    waitfor => '4',
    errlike => [],
    exit    => undef,
});

###########################################################

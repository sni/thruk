#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

BEGIN {
    plan skip_all => 'internal test only' if defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'};
    plan tests => 5;

    use lib('t');
    require TestUtils;
    import TestUtils;
}

use_ok("Thruk");

# regression test: the SIGPIPE handler used to re-trigger itself when the output
# pipe was dead (e.g. an orphaned test run whose reader is gone). it printed a
# stacktrace to the dead pipe, which raised SIGPIPE again and re-entered the
# handler, looping at 100% cpu forever. the fix is in Thruk::_check_exit_reason,
# which must ignore further sigpipes before it prints any diagnostics.

$ENV{THRUK_TEST_NO_LOG} = 1;    # keep _warn/_error off the real log files
local $ENV{THRUK_NO_SHUTDOWN_WARNINGS} = 1;

{
    my $dummy_c = TestUtils::get_c();
    no warnings qw/once/;
    local $Thruk::Globals::c = $dummy_c;
    my $rc = eval { Thruk::_check_exit_reason('PIPE'); 1 };
    ok($rc, "sigpipe handler returns without looping: $@");
    is($SIG{PIPE}, 'IGNORE', 'sigpipe is ignored after the handler ran, so it cannot re-trigger');
}

# end-to-end: run a real suite test with its output pipe reader gone - exactly
# what happened to the orphaned prove runs. before the fix the child spins in
# the sigpipe handler until the alarm kills it; after the fix it finishes in a
# couple of seconds. THRUK_KEEP_CONTEXT keeps the request context alive at exit
# (so the handler takes the print path) and the parent's
# THRUK_NO_SHUTDOWN_WARNINGS must not leak in (it would suppress the print
# before the fix, masking the loop).
pipe(my $r, my $w) or die "pipe: $!";
my $pid = fork();
die "fork: $!" unless defined $pid;
if($pid == 0) {
    close($r);
    open(STDERR, '>&', $w) or die "dup stderr: $!";
    open(STDOUT, '>&', $w) or die "dup stdout: $!";
    close($w);
    # run like the plain orphaned prove child did: keep the request context at
    # exit (so the handler takes the print path) and drop the masking vars the
    # parent test set (they would suppress the print before the fix).
    $ENV{THRUK_KEEP_CONTEXT} = 1;
    delete $ENV{THRUK_NO_SHUTDOWN_WARNINGS};
    delete $ENV{THRUK_TEST_NO_LOG};
    exec('perl', 't/019-Thruk-Utils-OAuth.t') or die "exec: $!";
}
close($w);
close($r);    # kill the read end -> the child's stdout/stderr pipe is dead
local $SIG{ALRM} = sub { die "sigpipe handler looped (dead output pipe)\n" };
alarm(30);
my $reaped = eval { waitpid($pid, 0); 1 };
my $status = $?;
alarm(0);
ok($reaped, "test run with dead output pipe finished within the timeout: $@");
is($status & 127, 0, "test run was not killed by a signal (status=$status)");

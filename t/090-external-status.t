use warnings;
use strict;
use Errno qw/EPERM ESRCH/;
use File::Temp qw/tempdir/;
use Test::More;

my($kill_result, $kill_errno);
BEGIN {
    # Simulate process probes without requiring different user accounts.
    *CORE::GLOBAL::kill = sub {
        $! = $kill_errno;
        return $kill_result;
    };
}

my $dir = tempdir(CLEANUP => 1);
for my $case (
    [1, 0,     1, 'live process'],
    [0, EPERM, 1, 'permission denied'],
    [0, ESRCH, 0, 'missing process'],
) {
    ($kill_result, $kill_errno, my $expected, my $description) = @{$case};
    open(my $fh, '>', $dir.'/pid') or die("open pid failed: $!");
    print {$fh} $$;
    close($fh) or die("close pid failed: $!");
    is(Thruk::Utils::External::_is_running(undef, $dir), $expected, $description);
    is(-e $dir.'/pid' ? 1 : 0, $expected, $description.' pid marker');
}

done_testing();

use warnings;
use strict;
use Cwd;
use Test::More;

use lib Cwd::cwd().'/lib';

use_ok("Thruk::Utils::IO");

# get running container
chdir($ENV{'THRUK_CONFIG'});
my($rc, $services) = Thruk::Utils::IO::cmd("docker compose config --services");
for my $svc (split/\n/mx, $services) {
    my($rc, $container) = Thruk::Utils::IO::cmd("docker compose ps -q $svc");
    my $index = 0;
    for my $cont (split/\n/mx, $container) {
        $index++;
        my $logfiles_printed = {};
        ok(1, sprintf("%s_%d - %s", $svc, $index, $cont));
        my($rc, $log) = Thruk::Utils::IO::cmd("docker exec -t --user root $cont ps -efl");
        next unless $rc == 0;

        my $matcher = qr/^(.*?)perl.*defunct/mx;

        if($log =~ $matcher) {
            # found zombies, wait some seconds to disappear (renewing perl processes is a normal process in mod_fcgi)
            sleep(10);
            ($rc, $log) = Thruk::Utils::IO::cmd("docker exec -t --user root $cont ps -efl");
            next unless $rc == 0;
        }

        if($log =~ $matcher) {
            my $found   = 0;
            my $details = [];
            for my $line (split/\n/mx, $log) {
                if($line =~ $matcher) {
                    my $line_details = [];
                    my($f, $s, $uid, $pid) = split(/\s+/, $1);
                    my $still_exists = 1;
                    for my $cmd ("ls -la /proc/$pid/", "cat /proc/$pid/cmdline | xargs -0 echo", "cat /proc/$pid/environ", "cat /proc/$pid/status", "cat /proc/$pid/maps", "stat /proc/$pid") {
                        push @{$line_details}, "%> ".$cmd;
                        my(undef, $output) = Thruk::Utils::IO::cmd("docker exec -t --user root $cont $cmd 2>&1");
                        push @{$line_details}, $output;
                        if($output =~ m/\QNo such file or directory\E/mxi) {
                            $still_exists = 0;
                            last;
                        }
                    }
                    if($still_exists) {
                        $found = 1;
                        push @{$details}, @{$line_details};
                    }
                }
            }
            if($found) {
                fail(sprintf("%s_%d: has perl zombies", $svc, $index));
                diag("#> ps -efl");
                diag($log);
                diag(join("\n", @{$details}));
            }
        }
    }
}

done_testing();

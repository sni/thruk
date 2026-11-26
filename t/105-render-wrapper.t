use warnings;
use strict;
use Cwd qw/abs_path/;
use File::Copy qw/copy/;
use File::Temp qw/tempdir/;
use Test::More;

# tests script/html2pdf.sh and script/grafana_export.sh with a fake renderer:
# the wrappers are copied into a temp folder next to a fake render_url.pl
# which records how it has been called.

my $tmp = tempdir(CLEANUP => 1);
mkdir("$tmp/$_") for qw/script home out/;
for my $wrapper (qw/html2pdf.sh grafana_export.sh/) {
    copy(abs_path("script/$wrapper"), "$tmp/script/$wrapper") or die("copy failed: $!");
    chmod(0755, "$tmp/script/$wrapper");
}
my @settings = qw/THRUK_BROWSER THRUK_BROWSER_NO_SANDBOX WAIT_TIMEOUT START_TIMEOUT THRUK_COOKIE_AUTH_DOMAIN/;
my $record   = "$tmp/record";
{
    open(my $fh, '>', "$tmp/script/render_url.pl") or die("cannot write fake renderer: $!");
    # These imports belong to the generated renderer, not this test.
    ## no lint
    print $fh <<'EOT';
use warnings;
use strict;
use File::Basename qw/dirname/;
open(my $fh, '>', $ENV{'FAKE_RECORD'}) or die("cannot write record: $!");
print $fh "ARG:$_\n" for @ARGV;
for my $key (qw/THRUK_BROWSER THRUK_BROWSER_NO_SANDBOX WAIT_TIMEOUT START_TIMEOUT THRUK_COOKIE_AUTH_DOMAIN/) {
    print $fh "ENV:$key=$ENV{$key}\n" if defined $ENV{$key};
}
close($fh);
print "output of the fake renderer\n";
print STDERR "error output of the fake renderer\n";
if($ENV{'FAKE_WRITE'}) {
    open(my $out, '>', $ARGV[1]) or die("cannot write output: $!");
    print $out ($ENV{'FAKE_CONTENT'} // "new content");
    close($out);
}
sleep($ENV{'FAKE_SLEEP'}) if $ENV{'FAKE_SLEEP'};
chmod(0555, dirname($ARGV[1])) if $ENV{'FAKE_LOCK_DIR'};
exit($ENV{'FAKE_RC'} // 0);
EOT
    ## use lint
    close($fh);
}

sub _wrapper {
    my($args, %env) = @_;
    unlink($record);
    local %ENV = (
        PATH        => $ENV{'PATH'},
        HOME        => "$tmp/home",
        FAKE_RECORD => $record,
        %env,
    );
    open(my $ph, '-|', "/bin/bash", "-c", 'exec "$0" "$@" 2>&1', @{$args}) or die("cannot run wrapper: $!");
    local $/ = undef;
    my $out = <$ph> // '';
    close($ph);
    my $rc = $? >> 8;
    my $rec = _slurp($record);
    my @args = $rec =~ m/^ARG:(.*)$/gmx;
    my %seen = $rec =~ m/^ENV:(\w+)=(.*)$/gmx;
    return({ rc => $rc, out => $out, called => (-e $record ? 1 : 0), args => \@args, env => \%seen });
}
sub _slurp {
    my($file) = @_;
    open(my $fh, '<', $file) or return '';
    local $/ = undef;
    my $data = <$fh> // '';
    close($fh);
    return $data;
}
sub _write {
    my($file, $content) = @_;
    open(my $fh, '>', $file) or die("cannot write $file: $!");
    print $fh $content;
    close($fh);
    return;
}
my $html2pdf = "$tmp/script/html2pdf.sh";
my $grafana  = "$tmp/script/grafana_export.sh";

###########################################################
# settings from rc files reach the renderer, with and without export
for my $wrapper ([$html2pdf, ['file:///in.html', "$tmp/out/rc.pdf"]], [$grafana, [800, 300, 100, 200, 'http://localhost/grafana/x?a=1', "$tmp/out/rc.png"]]) {
    my($cmd, $args) = @{$wrapper};
    my($name) = $cmd =~ m|([^/]+)$|mx;
    for my $prefix ('', 'export ') {
        my $n = 70;
        _write("$tmp/home/.thruk", join("", map { $prefix.$_."=value".($n++)."\n" } @settings));
        my $r = _wrapper([$cmd, @{$args}], FAKE_WRITE => 1);
        is($r->{'rc'}, 0, "$name: rc file with '${prefix}VAR=value': exit code 0");
        $n = 70;
        for my $key (@settings) {
            is($r->{'env'}->{$key}, "value".($n++), "$name: $key set as '${prefix}$key=...' in ~/.thruk reaches the renderer");
        }
    }
    unlink("$tmp/home/.thruk");

    # nothing set: nothing reaches the renderer
    my $r = _wrapper([$cmd, @{$args}], FAKE_WRITE => 1);
    is(scalar keys %{$r->{'env'}}, 0, "$name: unset settings are not passed on");

    # settings from the environment
    $r = _wrapper([$cmd, @{$args}], FAKE_WRITE => 1, WAIT_TIMEOUT => 55, THRUK_BROWSER => '/from/env');
    is($r->{'env'}->{'WAIT_TIMEOUT'}, 55, "$name: WAIT_TIMEOUT from the environment");
    is($r->{'env'}->{'THRUK_BROWSER'}, '/from/env', "$name: THRUK_BROWSER from the environment");
}

###########################################################
# html2pdf.sh
{
    my $out = "$tmp/out/report.pdf";
    my $r = _wrapper([$html2pdf, 'file:///some where/in.html', $out, '', 1], FAKE_WRITE => 1, THRUK_SESSION_ID => 'sess1');
    is($r->{'rc'}, 0, "html2pdf.sh: exit code 0");
    my $stage = $r->{'args'}->[1] // '';
    like($stage, qr/^\Q$out\E\.\d+\.pdf$/mx, "html2pdf.sh: renderer writes to a staging file of this call");
    is_deeply([@{$r->{'args'}}[0,2..5]], ['file:///some where/in.html', 1600, 1200, 'sess1', 1], "html2pdf.sh: arguments of the renderer");
    is(_slurp($out), "new content", "html2pdf.sh: output is at the target");
    ok(!-e $stage, "html2pdf.sh: staging file is gone");
    is(_staging($out), 0, "html2pdf.sh: no staging file left");
    like($r->{'out'}, qr/^output\ of\ the\ fake\ renderer$/mx, "html2pdf.sh: output of the renderer is printed");
    like($r->{'out'}, qr/^error\ output\ of\ the\ fake\ renderer$/mx, "html2pdf.sh: error output of the renderer is printed");

    $r = _wrapper([$html2pdf, 'http://localhost/thruk/', $out], FAKE_WRITE => 1);
    is_deeply([@{$r->{'args'}}[0,2..4]], ['http://localhost/thruk/', 1600, 1200, ''], "html2pdf.sh: arguments without session and report flag");
    is(scalar @{$r->{'args'}}, 5, "html2pdf.sh: no report flag passed");

    # with logfile nothing is printed
    my $log = "$tmp/out/report.log";
    _write($log, "old line\n");
    $r = _wrapper([$html2pdf, 'file:///in.html', $out, $log, 1], FAKE_WRITE => 1);
    is($r->{'rc'}, 0, "html2pdf.sh with logfile: exit code 0");
    is($r->{'out'}, "", "html2pdf.sh with logfile: nothing is printed");
    like(_slurp($log), qr/\Aold\ line\n.*output\ of\ the\ fake\ renderer\n/smx, "html2pdf.sh with logfile: output is appended to the logfile");
    like(_slurp($log), qr/^error\ output\ of\ the\ fake\ renderer$/mx, "html2pdf.sh with logfile: error output is in the logfile");

    # failed run: exit code is passed on, target stays as it was, nothing stale is published
    _write($out, "old content");
    _write($out.".pdf", "stale staging file of an older version");
    $r = _wrapper([$html2pdf, 'file:///in.html', $out], FAKE_RC => 2);
    is($r->{'rc'}, 2, "html2pdf.sh failed run: exit code of the renderer");
    is(_slurp($out), "old content", "html2pdf.sh failed run: existing target is untouched");

    unlink($out);
    $r = _wrapper([$html2pdf, 'file:///in.html', $out], FAKE_RC => 2);
    ok(!-e $out, "html2pdf.sh failed run: stale staging file is not published");
    unlink($out.".pdf");

    # a failed run which left a file behind
    $r = _wrapper([$html2pdf, 'file:///in.html', $out], FAKE_RC => 2, FAKE_WRITE => 1);
    is($r->{'rc'}, 2, "html2pdf.sh failed run with output: exit code of the renderer");
    ok(!-e $out, "html2pdf.sh failed run with output: nothing is published");
    is(_staging($out), 0, "html2pdf.sh failed run with output: staging file is removed");

    # two calls for the same target at the same time: the first one succeeds while the second
    # one is still writing and fails later. Only the output of the first call may be published.
    unlink($out);
    my $first  = _start_wrapper([$html2pdf, 'file:///in.html', $out], FAKE_WRITE => 1, FAKE_CONTENT => "first", FAKE_SLEEP => 2, FAKE_RECORD => "$tmp/record1");
    sleep(1);
    my $second = _start_wrapper([$html2pdf, 'file:///in.html', $out], FAKE_WRITE => 1, FAKE_CONTENT => "second, incomplete", FAKE_SLEEP => 3, FAKE_RC => 2, FAKE_RECORD => "$tmp/record2");
    is(_wait_wrapper($first), 0, "html2pdf.sh parallel calls: first call succeeds");
    is(_wait_wrapper($second), 2, "html2pdf.sh parallel calls: second call fails");
    is(_slurp($out), "first", "html2pdf.sh parallel calls: output of the successful call is published");
    is(_staging($out), 0, "html2pdf.sh parallel calls: no staging file left");

    # the wrapper and the renderer get a signal while the renderer runs
    unlink($out);
    my $h = _start_wrapper([$html2pdf, 'file:///in.html', $out], FAKE_WRITE => 1, FAKE_SLEEP => 10);
    sleep(1);
    is(_staging($out), 1, "html2pdf.sh killed: staging file exists while the renderer runs");
    kill('TERM', -$h);
    _wait_wrapper($h);
    ok(!-e $out, "html2pdf.sh killed: nothing is published");
    is(_staging($out), 0, "html2pdf.sh killed: staging file is removed");

    $r = _wrapper([$html2pdf, 'file:///in.html', $out], FAKE_RC => 1);
    is($r->{'rc'}, 1, "html2pdf.sh: exit code 1 of the renderer is passed on");

    # directory as target
    mkdir("$tmp/out/dir");
    $r = _wrapper([$html2pdf, 'file:///in.html', "$tmp/out/dir"], FAKE_WRITE => 1);
    is($r->{'rc'}, 1, "html2pdf.sh directory as target: exit code 1");
    like($r->{'out'}, qr/\Q$tmp\E\/out\/dir\ is\ a\ directory/mx, "html2pdf.sh directory as target: message");
    is($r->{'called'}, 0, "html2pdf.sh directory as target: renderer is not called");

    # the move fails
    SKIP: {
        skip("root can always move files", 3) if $> == 0;
        mkdir("$tmp/out/locked");
        $r = _wrapper([$html2pdf, 'file:///in.html', "$tmp/out/locked/x.pdf"], FAKE_WRITE => 1, FAKE_LOCK_DIR => 1);
        chmod(0755, "$tmp/out/locked");
        is($r->{'called'}, 1, "html2pdf.sh failed move: renderer was called");
        isnt($r->{'rc'}, 0, "html2pdf.sh failed move: exit code not 0");
        ok(!-e "$tmp/out/locked/x.pdf", "html2pdf.sh failed move: no target file");
    }
}

###########################################################
# grafana_export.sh
{
    my $out = "$tmp/out/graph.png";
    my $url = 'http://localhost/demo/grafana/dashboard-solo/script/histou.js?host=a b&panelId=1';
    my $r = _wrapper([$grafana, 800, 300, 1700000000, 1700003600, $url, $out], FAKE_WRITE => 1, THRUK_SESSION_ID => 'sess2');
    is($r->{'rc'}, 0, "grafana_export.sh: exit code 0");
    like($r->{'args'}->[1] // '', qr/^\Q$out\E\.\d+\.png$/mx, "grafana_export.sh: renderer writes to a staging file of this call");
    is_deeply([@{$r->{'args'}}[0,2..4]], [$url.'&from=1700000000000&to=1700003600000', 800, 300, 'sess2'], "grafana_export.sh: arguments of the renderer, time range in milliseconds");
    is(_slurp($out), "new content", "grafana_export.sh: output is at the target");
    is(_staging($out, 'png'), 0, "grafana_export.sh: staging file is gone");
    like($r->{'out'}, qr/^output\ of\ the\ fake\ renderer$/mx, "grafana_export.sh: output of the renderer is printed");

    _write($out, "old content");
    $r = _wrapper([$grafana, 800, 300, 1, 2, $url, $out], FAKE_RC => 2);
    is($r->{'rc'}, 2, "grafana_export.sh failed run: exit code of the renderer");
    is(_slurp($out), "old content", "grafana_export.sh failed run: existing target is untouched");

    unlink($out);
    $r = _wrapper([$grafana, 800, 300, 1, 2, $url, $out], FAKE_RC => 2, FAKE_WRITE => 1);
    ok(!-e $out, "grafana_export.sh failed run with output: nothing is published");
    is(_staging($out, 'png'), 0, "grafana_export.sh failed run with output: staging file is removed");

    my $h = _start_wrapper([$grafana, 800, 300, 1, 2, $url, $out], FAKE_WRITE => 1, FAKE_SLEEP => 10);
    sleep(1);
    kill('TERM', -$h);
    _wait_wrapper($h);
    ok(!-e $out, "grafana_export.sh killed: nothing is published");
    is(_staging($out, 'png'), 0, "grafana_export.sh killed: staging file is removed");

    $r = _wrapper([$grafana, 800, 300, 1, 2, $url, "$tmp/out/dir"], FAKE_WRITE => 1);
    is($r->{'rc'}, 1, "grafana_export.sh directory as target: exit code 1");
    is($r->{'called'}, 0, "grafana_export.sh directory as target: renderer is not called");

    SKIP: {
        skip("root can always move files", 2) if $> == 0;
        mkdir("$tmp/out/locked2");
        $r = _wrapper([$grafana, 800, 300, 1, 2, $url, "$tmp/out/locked2/x.png"], FAKE_WRITE => 1, FAKE_LOCK_DIR => 1);
        chmod(0755, "$tmp/out/locked2");
        isnt($r->{'rc'}, 0, "grafana_export.sh failed move: exit code not 0");
        ok(!-e "$tmp/out/locked2/x.png", "grafana_export.sh failed move: no target file");
    }
}

done_testing();

###########################################################
# number of staging files of the given output file
sub _staging {
    my($out, $ext) = @_;
    my @files = glob($out.".*.".($ext // 'pdf'));
    return(scalar @files);
}

###########################################################
# starts a wrapper in its own process group, returns its pid
sub _start_wrapper {
    my($args, %env) = @_;
    my $pid = fork();
    die("fork failed: $!") unless defined $pid;
    if(!$pid) {
        setpgrp(0, 0);
        %ENV = (PATH => $ENV{'PATH'}, HOME => "$tmp/home", FAKE_RECORD => "$tmp/record_bg", %env);
        open(STDIN,  '<', '/dev/null');
        open(STDOUT, '>', '/dev/null');
        open(STDERR, '>', '/dev/null');
        { exec("/bin/bash", @{$args}); }
        exit(127);
    }
    return $pid;
}

###########################################################
sub _wait_wrapper {
    my($pid) = @_;
    waitpid($pid, 0);
    return($? >> 8);
}

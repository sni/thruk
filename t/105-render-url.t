use warnings;
use strict;
use Cwd qw/abs_path/;
use Fcntl qw/O_RDONLY O_NONBLOCK/;
use File::Temp qw/tempdir/;
use IO::Socket::INET ();
use POSIX ();
use Test::More;
use Time::HiRes qw/sleep time/;

# tests script/render_url.pl with a real browser against t/lib/TestRenderServer.pl.
#
# rules: checks in scalar context, request paths are matched from their start,
# processes are stopped by their recorded pid or process group only.

my $required = $ENV{'THRUK_TEST_BROWSER_REQUIRED'};
my $renderer = abs_path('script/render_url.pl');
my $html2pdf = abs_path('script/html2pdf.sh');
my $server   = abs_path('t/lib/TestRenderServer.pl');
my $fixtures = abs_path('t/data/render_url');

# clean environment, the wrapper must not read rc files of the user running the test
my $tmp = tempdir(CLEANUP => 1);
mkdir("$tmp/home");
$ENV{'HOME'} = "$tmp/home";
delete $ENV{$_} for qw/THRUK_SESSION_ID THRUK_COOKIE_AUTH_DOMAIN WAIT_TIMEOUT START_TIMEOUT THRUK_BROWSER_NO_SANDBOX THRUK_RENDER_DEBUG/;

my($find_rc, $real_browser) = _cmd($^X, $renderer, '--find-browser');
chomp($real_browser);
if($find_rc != 0) {
    BAIL_OUT("THRUK_TEST_BROWSER_REQUIRED is set but there is no browser: ".$real_browser) if $required;
    plan skip_all => 'no browser found, renderer cannot be tested: '.$real_browser;
}
diag("using browser ".$real_browser);
# where the browser cannot start with sandbox (root, no user namespaces, ubuntu apparmor), the
# renderer says so on every run. The wrapper then starts it without sandbox, so the output of the
# other tests stays the same; the retry itself is tested with its own wrapper below.
my $wrapper_args = '';
{
    local $ENV{'THRUK_BROWSER'} = $real_browser;
    my(undef, $probe) = _cmd($^X, $renderer, '--selftest');
    if($probe =~ m/did\ not\ start\ with\ sandbox/mx) {
        diag("browser does not start with sandbox here, test wrapper adds --no-sandbox");
        $wrapper_args = '--no-sandbox ';
    }
}
my $has_pdftotext = scalar grep { -x $_."/pdftotext" } split(/:/mx, $ENV{'PATH'} // '');

# the browser is started by wrappers which record the pid and map *.example.test to this host
_script("$tmp/br.sh",        'echo $$ > "$THRUK_TEST_PIDFILE"', 'exec "'.$real_browser.'" '.$wrapper_args.'$THRUK_TEST_BROWSER_ARGS --host-resolver-rules="MAP *.example.test 127.0.0.1" "$@"');
_script("$tmp/br_hang.sh",   'echo $$ > "$THRUK_TEST_PIDFILE"', 'exec sleep 300');
_script("$tmp/br_nosbx.sh",  'echo $$ > "$THRUK_TEST_PIDFILE"', 'case " $* " in *" --no-sandbox "*) ;; *) echo "FATAL: this test browser only starts without sandbox" >&2; exit 1;; esac', 'exec "'.$real_browser.'" "$@"');
$ENV{'THRUK_BROWSER'} = "$tmp/br.sh";

# test server
my $port   = _free_port();
my $reqlog = "$tmp/requests.log";
my $srvpid = fork();
die("fork failed: $!") unless defined $srvpid;
if(!$srvpid) {
    POSIX::setpgid(0, 0);
    open(STDIN,  '<', '/dev/null');
    open(STDOUT, '>', "$tmp/server.log");
    open(STDERR, '>&', \*STDOUT);
    { exec($^X, $server, $port, $reqlog); }
    POSIX::_exit(127);
}
POSIX::setpgid($srvpid, $srvpid);
END {
    if($srvpid) {
        my $rc = $?;
        kill('TERM', -$srvpid);
        waitpid($srvpid, 0);
        $? = $rc;
    }
}
for (1..50) {
    last if IO::Socket::INET->new(PeerAddr => '127.0.0.1', PeerPort => $port);
    sleep(0.1);
}
my $local   = "http://127.0.0.1:$port";
my $foreign = "http://127.0.0.2:$port";
my $third   = "http://127.0.0.3:$port";
my $thruk   = "http://thruk.example.test:$port";
my $sibling = "http://other.example.test:$port";
my $secret  = 'SECRET';

###########################################################
# report pdf from a local file whose chart labels are created by javascript
{
    my $f = "$tmp/report.pdf";
    my $r = _run(_renderer("file://$fixtures/report.html", $f, 1600, 1200, "", 1));
    is($r->{'rc'}, 0, "report: exit code 0") or diag($r->{'out'}.$r->{'err'});
    is($r->{'out'}, "", "report: no output");
    my $pdf = _slurp($f);
    like($pdf, qr/^%PDF/mx, "report: output is a pdf");
    is(_pages($pdf), 1, "report: one page");
    my($w, $h) = _pagesize($pdf);
    ok(_near($w, 595) && _near($h, 842), "report: A4 page (got $w x $h)");
    SKIP: {
        if(!$has_pdftotext) {
            fail("pdftotext is required when THRUK_TEST_BROWSER_REQUIRED is set") if $required;
            skip("pdftotext not installed, the text of the chart cannot be checked", 3);
        }
        my(undef, $text) = _cmd('pdftotext', $f, '-');
        like($text, qr/Render\ Test\ Report/mx, "report: text of the page");
        like($text, qr/avail98pct/mx, "report: axis labels drawn by javascript");
        like($text, qr/week5/mx, "report: axis labels drawn by javascript");
    }
    _no_leftovers($r, "report");

    # the page size from the stylesheet wins
    $f = "$tmp/pagesize.pdf";
    $r = _run(_renderer("file://$fixtures/pagesize.html", $f, 1600, 1200, "", 1));
    is($r->{'rc'}, 0, "page size: exit code 0") or diag($r->{'out'}.$r->{'err'});
    ($w, $h) = _pagesize(_slurp($f));
    ok(_near($w, 595) && _near($h, 420), "page size: A5 landscape from the stylesheet (got $w x $h)");

    # without report flag: screen page of 1600x1200px
    $f = "$tmp/screen.pdf";
    $r = _run(_renderer("file://$fixtures/pagesize.html", $f, 1600, 1200, $secret));
    is($r->{'rc'}, 0, "screen pdf from a file url with session id: exit code 0") or diag($r->{'out'}.$r->{'err'});
    ($w, $h) = _pagesize(_slurp($f));
    ok(_near($w, 1200) && _near($h, 900), "screen pdf: page of 1600x1200px (got $w x $h)");
}

###########################################################
# responses with status 500 - 520 abort the run
{
    my @cases = (
        ["5xx main page",                        "$local/status/503",                           "$local/status/503"],
        ["5xx sub-resource",                     "$local/sub5xx",                               "$local/status/503"],
        ["5xx inside cross-site frame",          "$local/embed?f=$foreign/sub5xx",              "$foreign/status/503"],
        ["5xx in frame below cross-site frame",  "$local/embed?f=$foreign/nest?f=$third/sub5xx", "$third/status/503"],
    );
    for my $c (@cases) {
        my($name, $url, $failed) = @{$c};
        my $f = "$tmp/5xx.pdf";
        my $r = _run(_renderer($url, $f, 1600, 1200, ""));
        is($r->{'rc'}, 2, "$name: exit code 2");
        is($r->{'out'}, "url $failed failed with status: 503. Aborting...\n", "$name: message with url and status");
        ok($r->{'elapsed'} < 10, "$name: aborted without waiting for the pending image (".sprintf("%.1f", $r->{'elapsed'})."s)");
        ok(!-e $f, "$name: no output file");
        _no_leftovers($r, $name);
    }
}

###########################################################
# page which cannot be loaded
{
    for my $status (404, 403) {
        my $f = "$tmp/status.pdf";
        my $r = _run(_renderer("$local/status/$status", $f, 1600, 1200, ""));
        is($r->{'rc'}, 2, "main page $status: exit code 2");
        is($r->{'out'}, "fetching url $local/status/$status failed: $status X\n", "main page $status: message with url and status");
        ok(!-e $f, "main page $status: no output file");
        _no_leftovers($r, "main page $status");
    }

    my $f = "$tmp/refused.pdf";
    my $closed = _free_port();
    my $r = _run(_renderer("http://127.0.0.1:$closed/nothing", $f, 1600, 1200, ""));
    is($r->{'rc'}, 2, "connection refused: exit code 2");
    like($r->{'out'}, qr/^fetching\ url\ http:\/\/127\.0\.0\.1:$closed\/nothing\ failed:\ .*REFUSED/mx, "connection refused: message names the cause");
    ok(!-e $f, "connection refused: no output file");

    $f = "$tmp/hang.pdf";
    $r = _run(_renderer("$local/hangpage", $f, 1600, 1200, ""));
    is($r->{'rc'}, 2, "page never finishes loading: exit code 2");
    is($r->{'out'}, "timeout while loading url $local/hangpage, giving up after 30s\n", "page never finishes loading: message");
    ok($r->{'elapsed'} >= 29 && $r->{'elapsed'} < 40, "page never finishes loading: gives up after 30s (".sprintf("%.1f", $r->{'elapsed'})."s)");
    ok(!-e $f, "page never finishes loading: no output file");
    _no_leftovers($r, "page never finishes loading");

    $f = "$tmp/nodir/x.pdf";
    $r = _run(_renderer("$local/plain", $f, 1600, 1200, ""));
    is($r->{'rc'}, 1, "output folder missing: exit code 1");
    like($r->{'out'}, qr/^cannot\ write\ \Q$f\E/mx, "output folder missing: message");
    ok(!defined $r->{'run_dir'}, "output folder missing: browser not started");
}

###########################################################
# browser gets killed
{
    _requests();
    my $f = "$tmp/killed.pdf";
    my $h = _start(_renderer("$local/hangpage", $f, 1600, 1200, ""));
    ok(_wait_for(sub { scalar grep { $_->[1] =~ m|^/hangpage|mx } _requests(1) }, 20), "browser killed during navigation: page requested");
    sleep(0.3);
    my $bpid = _browser_pid($h);
    ok($bpid, "browser killed during navigation: pid of the browser recorded");
    kill('KILL', $bpid) if $bpid;
    my $r = _finish($h, 20);
    is($r->{'rc'}, 2, "browser killed during navigation: exit code 2");
    is($r->{'out'}, "browser closed the connection\n", "browser killed during navigation: one line");
    unlike($r->{'out'}.$r->{'err'}, qr/\ line\ \d+/mx, "browser killed during navigation: no perl location");
    ok(!-e $f, "browser killed during navigation: no output file");
    _no_leftovers($r, "browser killed during navigation");

    # the output is a fifo nobody reads from, so the renderer blocks in the middle of the transfer
    _requests();
    $f = "$tmp/fifo.pdf";
    POSIX::mkfifo($f, 0600) or die("mkfifo failed: $!");
    sysopen(my $fifo, $f, O_RDONLY|O_NONBLOCK) or die("cannot open fifo: $!");
    $h = _start(_renderer("$local/big", $f, 1600, 1200, ""));
    ok(_wait_for(sub { scalar(_slurp($h->{'errfile'}) =~ m/pdf\ stream\ opened/mx) }, 30), "browser killed during pdf transfer: transfer started");
    sleep(0.5);
    $bpid = _browser_pid($h);
    kill('KILL', $bpid) if $bpid;
    my $got = 0;
    my $deadline = time() + 20;
    while(time() < $deadline) { # drain the fifo till the renderer is gone
        my $n = sysread($fifo, my $data, 65536);
        $got += $n if $n;
        last if waitpid($h->{'pid'}, POSIX::WNOHANG) != 0;
        sleep(0.01) unless $n;
    }
    $h->{'status'} = $?;
    close($fifo);
    $r = _finish($h, 20);
    is($r->{'rc'}, 2, "browser killed during pdf transfer: exit code 2");
    is($r->{'out'}, "browser closed the connection\n", "browser killed during pdf transfer: one line");
    unlike($r->{'out'}.$r->{'err'}, qr/\ line\ \d+/mx, "browser killed during pdf transfer: no perl location");
    ok($got > 0, "browser killed during pdf transfer: part of the pdf had been written ($got bytes)");
    ok(!-e $f, "browser killed during pdf transfer: no output file");
    _no_leftovers($r, "browser killed during pdf transfer");
}

###########################################################
# renderer gets a signal
for my $sig (qw/TERM INT HUP/) {
    _requests();
    my $f = "$tmp/signal.pdf";
    my $h = _start(_renderer("$local/hangpage", $f, 1600, 1200, ""));
    ok(_wait_for(sub { scalar grep { $_->[1] =~ m|^/hangpage|mx } _requests(1) }, 20), "SIG$sig: page requested");
    sleep(0.3);
    kill($sig, $h->{'pid'});
    my $r = _finish($h, 20);
    is($r->{'rc'}, 1, "SIG$sig: exit code 1");
    ok(!-e $f, "SIG$sig: no output file");
    _no_leftovers($r, "SIG$sig");
}

# signal while the pdf is written: the output is a fifo nobody reads from, so the renderer blocks in the middle of the transfer
{
    my $f = "$tmp/signal_fifo.pdf";
    POSIX::mkfifo($f, 0600) or die("mkfifo failed: $!");
    sysopen(my $fifo, $f, O_RDONLY|O_NONBLOCK) or die("cannot open fifo: $!");
    my $h = _start(_renderer("$local/big", $f, 1600, 1200, ""));
    ok(_wait_for(sub { scalar(_slurp($h->{'errfile'}) =~ m/pdf\ stream\ opened/mx) }, 30), "SIGTERM during pdf transfer: transfer started");
    sleep(0.5);
    kill('TERM', $h->{'pid'});
    my $r = _finish($h, 20);
    close($fifo);
    is($r->{'rc'}, 1, "SIGTERM during pdf transfer: exit code 1");
    ok(!-e $f, "SIGTERM during pdf transfer: partial output removed");
    _no_leftovers($r, "SIGTERM during pdf transfer");
}

###########################################################
# no usable home, several runs at once
{
    my $f = "$tmp/nohome.pdf";
    my $r = _run(_renderer("$local/plain", $f, 1600, 1200, ""), HOME => '/nonexistent');
    is($r->{'rc'}, 0, "HOME=/nonexistent: exit code 0") or diag($r->{'out'}.$r->{'err'});
    like(_slurp($f), qr/^%PDF/mx, "HOME=/nonexistent: output is a pdf");
    _no_leftovers($r, "HOME=/nonexistent");

    # the working directory cannot be read, ex.: the home of another user
    SKIP: {
        skip("root can read every folder", 5) if $> == 0;
        $f = "$tmp/nocwd.pdf";
        mkdir("$tmp/nocwd");
        $r = _run(_renderer("$local/plain", $f, 1600, 1200, ""), THRUK_TEST_CWD => "$tmp/nocwd");
        chmod(0755, "$tmp/nocwd");
        is($r->{'rc'}, 0, "working directory not accessible: exit code 0") or diag($r->{'out'}.$r->{'err'});
        is($r->{'out'}.(join("", grep { !m/^\[debug\]/mx } split(/^/mx, $r->{'err'}))), "", "working directory not accessible: no output");
        _no_leftovers($r, "working directory not accessible");
    }

    my @h = map { _start(_renderer("$local/c/page", "$tmp/multi$_.pdf", 1600, 1200, "")) } (1..3);
    for my $n (1..3) {
        $r = _finish($h[$n-1]);
        is($r->{'rc'}, 0, "three runs at once, run $n: exit code 0") or diag($r->{'out'}.$r->{'err'});
        like(_slurp("$tmp/multi$n.pdf"), qr/^%PDF/mx, "three runs at once, run $n: output is a pdf");
        _no_leftovers($r, "three runs at once, run $n");
    }
    my %dirs = map { ($_->{'run_dir'} // '') => 1 } @h;
    is(scalar keys %dirs, 3, "three runs at once: every run has its own folder");

    # characters special to the shell or json reach the browser unchanged
    _requests();
    $r = _run(_renderer($local.'/plain?q="it\'s"&x=$HOME&y=ä', "$tmp/special.pdf", 1600, 1200, ""));
    is($r->{'rc'}, 0, "special characters in url: exit code 0") or diag($r->{'out'}.$r->{'err'});
    my($path) = map { $_->[1] } grep { $_->[1] =~ m|^/plain\?q=|mx } _requests();
    is($path, '/plain?q=%22it%27s%22&x=$HOME&y=%C3%A4', "special characters in url: requested as given");
}

###########################################################
# grafana
{
    my $f = "$tmp/chart.png";
    my $r = _run(_renderer("$local/grafana/chart?a=1", $f, 320, 200, ""));
    is($r->{'rc'}, 0, "grafana chart: exit code 0") or diag($r->{'out'}.$r->{'err'});
    is($r->{'out'}, "chart panel found, export OK\n", "grafana chart: output");
    is(join("x", _pngsize($f)), "320x200", "grafana chart: png has the requested size");
    _no_leftovers($r, "grafana chart");

    $f = "$tmp/chart2.png";
    $r = _run(_renderer("$local/grafana/chart?a=1", $f, 1400, 900, ""));
    is(join("x", _pngsize($f)), "1400x900", "grafana chart: png has the requested size");

    $f = "$tmp/nochart.png";
    $r = _run(_renderer("$local/grafana/nochart?a=1", $f, 800, 400, ""), WAIT_TIMEOUT => 3);
    is($r->{'rc'}, 2, "grafana without chart: exit code 2");
    is($r->{'out'}, "timeout while waiting for chart, export failed\n", "grafana without chart: message");
    ok($r->{'elapsed'} >= 3 && $r->{'elapsed'} < 12, "grafana without chart: stops after WAIT_TIMEOUT (".sprintf("%.1f", $r->{'elapsed'})."s)");
    ok(!-e $f, "grafana without chart: no output file");
    _no_leftovers($r, "grafana without chart");

    # javascript keeps the page busy, the page does not answer at all
    $r = _run(_renderer("$local/grafana/busy?a=1", $f, 800, 400, ""), WAIT_TIMEOUT => 3);
    is($r->{'rc'}, 2, "grafana page busy with javascript: exit code 2");
    is($r->{'out'}, "timeout while waiting for chart, export failed\n", "grafana page busy with javascript: message");
    ok($r->{'elapsed'} >= 3 && $r->{'elapsed'} < 12, "grafana page busy with javascript: stops after WAIT_TIMEOUT (".sprintf("%.1f", $r->{'elapsed'})."s)");
    ok(!-e $f, "grafana page busy with javascript: no output file");
    _no_leftovers($r, "grafana page busy with javascript");

    $r = _run(_renderer("$local/grafana/login?a=1", $f, 800, 400, ""), WAIT_TIMEOUT => 3);
    is($r->{'rc'}, 2, "grafana login window: exit code 2");
    is($r->{'out'}, "login window present, export failed\n", "grafana login window: message");
    ok(!-e $f, "grafana login window: no output file");

    $r = _run(_renderer("$local/grafana/alert?a=1", $f, 800, 400, ""), WAIT_TIMEOUT => 3);
    is($r->{'rc'}, 2, "grafana alert: exit code 2");
    is($r->{'out'}, "alert message found, export failed\ndatasource exploded\n", "grafana alert: message with the text shown");
    ok(!-e $f, "grafana alert: no output file");
}

###########################################################
# session cookie
{
    my $f = "$tmp/cookie.pdf";
    my $with    = sub { my(@r) = @_; return(scalar grep { $_->[2] =~ m/thruk_auth=\Q$secret\E/mx } @r); };
    my $leaks   = sub { my($allowed, @r) = @_; return(scalar grep { $_->[0] !~ $allowed && $_->[2] =~ m/\Q$secret\E/mx } @r); };
    my $missed  = sub { my($allowed, @r) = @_; return(scalar grep { $_->[0] =~ $allowed && $_->[1] !~ m|^/favicon|mx && $_->[2] !~ m/thruk_auth=\Q$secret\E/mx } @r); };
    my $on      = sub { my($host, $path, @r) = @_; return(grep { $_->[0] =~ $host && $_->[1] =~ $path } @r); };
    my $render  = sub { my($url, %env) = @_; _requests(); my $r = _run(_renderer($url, $f, 800, 600, $secret), %env); sleep(0.5); return($r, _requests()); };
    my $domain  = 'thruk.example.test';

    # AS-8a: allowed host, sub-resources on other paths, foreign sub-resource, sub-resource redirected to foreign host
    my($r, @r) = $render->("$local/c/page");
    is($r->{'rc'}, 0, "AS-8a allowed host 127.0.0.1: exit code 0") or diag($r->{'out'}.$r->{'err'});
    ok(scalar($on->(qr/^127\.0\.0\.1:/mx, qr|^/c/page|mx, @r)) && scalar($on->(qr/^127\.0\.0\.1:/mx, qr|^/c/sub\.js|mx, @r)) && scalar($on->(qr/^127\.0\.0\.1:/mx, qr|^/other/deep/img\.png|mx, @r)), "AS-8a: allowed host requested on three paths");
    is($missed->(qr/^127\.0\.0\.1:/mx, @r), 0, "AS-8a: cookie sent to every path of the allowed host");
    ok(scalar($on->(qr/^127\.0\.0\.2:/mx, qr|^/foreign_sub\.js|mx, @r)) && scalar($on->(qr/^127\.0\.0\.2:/mx, qr|^/after_sub_redirect|mx, @r)), "AS-8a: foreign host requested directly and after redirect");
    is($leaks->(qr/^127\.0\.0\.1:/mx, @r), 0, "AS-8a: no cookie at the foreign host");
    _no_leftovers($r, "AS-8a");

    # AS-8b: foreign host as target
    ($r, @r) = $render->("$foreign/c/page");
    is($r->{'rc'}, 0, "AS-8b foreign host as target: page is rendered");
    ok(scalar($on->(qr/^127\.0\.0\.2:/mx, qr|^/c/page|mx, @r)), "AS-8b: foreign host requested");
    is($with->(@r), 0, "AS-8b: no request carries the cookie");

    # AS-8c: main page redirects from allowed to foreign host
    ($r, @r) = $render->("$local/redirect?to=$foreign/plain");
    is($r->{'rc'}, 0, "AS-8c main page redirects to foreign host: exit code 0");
    ok(scalar($on->(qr/^127\.0\.0\.2:/mx, qr|^/plain|mx, @r)), "AS-8c: foreign host requested");
    is($leaks->(qr/^127\.0\.0\.1:/mx, @r), 0, "AS-8c: no cookie at the foreign host");

    # AS-8d: localhost and ::1
    for my $host ('localhost', '[::1]') {
        SKIP: {
            skip("no ipv6 on this host", 3) if($host eq '[::1]' && !_has_ipv6());
            ($r, @r) = $render->("http://$host:$port/c/page");
            my $re = qr/^\Q$host\E:/mx;
            is($r->{'rc'}, 0, "AS-8d allowed host $host: exit code 0") or diag($r->{'out'}.$r->{'err'});
            ok(scalar($on->($re, qr|^/c/sub\.js|mx, @r)) && $missed->($re, @r) == 0, "AS-8d $host: cookie sent to every path of the allowed host");
            is($leaks->($re, @r), 0, "AS-8d $host: no cookie at the foreign host");
        }
    }

    # AS-8e, AS-8f: cookie auth domain
    ($r, @r) = $render->("http://a.thruk.example.test:$port/c/page", THRUK_COOKIE_AUTH_DOMAIN => '.thruk.example.test');
    is($r->{'rc'}, 0, "AS-8e host inside cookie auth domain: exit code 0") or diag($r->{'out'}.$r->{'err'});
    ok(scalar($on->(qr/^a\.thruk\.example\.test:/mx, qr|^/c/sub\.js|mx, @r)) && $missed->(qr/^a\.thruk\.example\.test:/mx, @r) == 0, "AS-8e: cookie sent to every path of the allowed host");
    is($leaks->(qr/^a\.thruk\.example\.test:/mx, @r), 0, "AS-8e: no cookie at the foreign host");

    ($r, @r) = $render->("$thruk/c/page", THRUK_COOKIE_AUTH_DOMAIN => $domain);
    ok(scalar($on->(qr/^thruk\.example\.test:/mx, qr|^/c/sub\.js|mx, @r)) && $missed->(qr/^thruk\.example\.test:/mx, @r) == 0, "AS-8e the cookie auth domain itself: cookie sent to every path");
    is($leaks->(qr/^thruk\.example\.test:/mx, @r), 0, "control: allowed page keeps the cookie, foreign sub-resources do not get it");

    ($r, @r) = $render->("http://evilthruk.example.test:$port/c/page", THRUK_COOKIE_AUTH_DOMAIN => $domain);
    is($r->{'rc'}, 0, "AS-8f host which only ends like the cookie auth domain: exit code 0");
    ok(scalar($on->(qr/^evilthruk\.example\.test:/mx, qr|^/c/sub\.js|mx, @r)), "AS-8f: host requested");
    is($with->(@r), 0, "AS-8f: no request carries the cookie");

    # AS-8g - AS-8i: url tricks and foreign pages which send the browser back to the allowed host
    my @tricks = (
        ['AS-8g allowed host only in the userinfo part of the url', "http://127.0.0.1:$port\@127.0.0.2:$port/redirect?to=$local/plain?g", qr|^/plain\?g|mx],
        ['AS-8h foreign target redirects to the allowed host',      "$foreign/redirect?to=$local/plain?h",                               qr|^/plain\?h|mx],
        ['AS-8i backslash in front of the allowed host',            "http://127.0.0.2:$port\\\@127.0.0.1:$port/plain?i",                   qr|^/|mx],
    );
    for my $t (@tricks) {
        ($r, @r) = $render->($t->[1]);
        ok(scalar($on->(qr/./mx, $t->[2], @r)), $t->[0].": request seen");
        is($with->(@r), 0, $t->[0].": no request carries the cookie") or diag(join(" ", map { $_->[0].$_->[1] } @r));
    }

    # AS-8k: allowed target redirects to a foreign page, whose javascript sends the browser back to the allowed host
    ($r, @r) = $render->("$local/redirect?to=$foreign/bounce?to=$local/plain?k");
    my @back = $on->(qr/^127\.0\.0\.1:/mx, qr|^/plain\?k|mx, @r);
    ok(scalar @back >= 1, "AS-8k foreign page navigates back to the allowed host: request seen");
    is($with->(@back), 0, "AS-8k: the request caused by the foreign page carries no cookie");

    # AS-8l, AS-8m: frame from a sibling host / another site calls back to the allowed host
    for my $c (['AS-8l frame from sibling host', $sibling], ['AS-8m frame from other site', $foreign]) {
        ($r, @r) = $render->("$thruk/embed?f=".$c->[1]."/framepage?t=$thruk", THRUK_COOKIE_AUTH_DOMAIN => $domain);
        is($r->{'rc'}, 0, $c->[0].": exit code 0") or diag($r->{'out'}.$r->{'err'});
        my @calls = $on->(qr/^thruk\.example\.test:/mx, qr/fromframe/mx, @r);
        ok(scalar @calls >= 3, $c->[0].": the frame called the allowed host (".scalar(@calls)." requests)");
        is($with->(@calls), 0, $c->[0].": no request of the frame carries the cookie");
        ok($with->($on->(qr/^thruk\.example\.test:/mx, qr|^/embed|mx, @r)) == 1, $c->[0].": the allowed page itself got the cookie");
    }

    # AS-8n: popups are blocked by default
    ($r, @r) = $render->("$thruk/popup?t=$sibling/popped?t=$thruk", THRUK_COOKIE_AUTH_DOMAIN => $domain);
    is($r->{'rc'}, 0, "AS-8n popup with default settings: exit code 0") or diag($r->{'out'}.$r->{'err'});
    ok($with->($on->(qr/^thruk\.example\.test:/mx, qr|^/popup|mx, @r)) == 1, "AS-8n: the allowed page was requested with the cookie");
    is($with->($on->(qr/./mx, qr/frompopup/mx, @r)), 0, "AS-8n: no request from a popup carries the cookie");

    # AS-8o: further page with popup blocking switched off
    for my $c (['AS-8o popup on sibling host', $sibling], ['AS-8o popup on other site', $foreign]) {
        ($r, @r) = $render->("$thruk/popup?t=".$c->[1]."/popped?t=$thruk", THRUK_COOKIE_AUTH_DOMAIN => $domain, THRUK_TEST_BROWSER_ARGS => '--disable-popup-blocking');
        is($r->{'rc'}, 0, $c->[0].": exit code 0") or diag($r->{'out'}.$r->{'err'});
        my @calls = $on->(qr/^thruk\.example\.test:/mx, qr/frompopup/mx, @r);
        ok(scalar @calls >= 1, $c->[0].": the popup called the allowed host");
        is($with->(@calls), 0, $c->[0].": no request of the popup carries the cookie");
        _no_leftovers($r, $c->[0]);
    }
}

###########################################################
# rendering test and browser start
{
    my $r = _run([$html2pdf, '--find-browser']);
    is($r->{'rc'}, 0, "html2pdf.sh --find-browser: exit code 0");
    is($r->{'out'}, "$tmp/br.sh\n", "html2pdf.sh --find-browser: prints the browser");

    $r = _run([$html2pdf, '--selftest']);
    is($r->{'rc'}, 0, "html2pdf.sh --selftest: exit code 0") or diag($r->{'out'}.$r->{'err'});
    like($r->{'out'}, qr/^rendering\ test\ OK\n\z/mx, "selftest: ends with rendering test OK");
    like($r->{'out'}, qr/^browser:\ \Q$tmp\E\/br\.sh$/mx, "selftest: names the browser");
    like($r->{'out'}, qr/^version:\ \S+/mx, "selftest: names the version");
    like($r->{'out'}, qr/^sandbox:\ (on|off)$/mx, "selftest: says whether the sandbox is on");
    like($r->{'out'}, qr/^user\ id:\ $>$/mx, "selftest: names the user id");
    like($r->{'out'}, qr/^temp\ folder:\ \S+thruk_browser_\w+$/mx, "selftest: names the temp folder");
    _no_leftovers($r, "selftest");

    $r = _run([$html2pdf, '--selftest'], THRUK_BROWSER_NO_SANDBOX => 1);
    is($r->{'rc'}, 0, "selftest without sandbox: exit code 0") or diag($r->{'out'}.$r->{'err'});
    like($r->{'out'}, qr/^sandbox:\ off$/mx, "selftest without sandbox: says so");
    unlike($r->{'out'}, qr/did\ not\ start\ with\ sandbox/mx, "selftest without sandbox: no start with sandbox was tried");

    # browser which only starts without sandbox
    $r = _run([$html2pdf, '--selftest'], THRUK_BROWSER => "$tmp/br_nosbx.sh");
    is($r->{'rc'}, 0, "sandbox retry: exit code 0") or diag($r->{'out'}.$r->{'err'});
    like($r->{'out'}, qr/^browser\ did\ not\ start\ with\ sandbox\ \(.*only\ starts\ without\ sandbox.*\),\ sandbox\ is\ off\ for\ this\ run$/mx, "sandbox retry: line says why");
    like($r->{'out'}, qr/^sandbox:\ off$/mx, "sandbox retry: sandbox is off");
    like($r->{'out'}, qr/^rendering\ test\ OK$/mx, "sandbox retry: rendering works");
    _no_leftovers($r, "sandbox retry");

    # the retry gets other fd numbers than the first start, some open fds put its pipes on 10 and 11
    for my $n (0..8) {
        my $open = join(" ", map { ($_ + 2)."</dev/null" } 1..$n);
        $r = _run(['/bin/bash', '-c', ($open ? 'exec '.$open.'; ' : '').'exec "$0" --selftest', $html2pdf], THRUK_BROWSER => "$tmp/br_nosbx.sh");
        is($r->{'rc'}, 0, "sandbox retry with $n more open fds: exit code 0") or diag($r->{'out'}.$r->{'err'});
        like($r->{'out'}, qr/^rendering\ test\ OK$/mx, "sandbox retry with $n more open fds: rendering works");
    }

    # browser which hangs at start: one time limit per attempt
    $r = _run(_renderer("$local/plain", "$tmp/hangstart.pdf", 1600, 1200, ""), THRUK_BROWSER => "$tmp/br_hang.sh", START_TIMEOUT => 3);
    is($r->{'rc'}, 1, "browser hangs at start: exit code 1");
    ok($r->{'elapsed'} >= 5.5 && $r->{'elapsed'} < 12, "browser hangs at start: two attempts of 3s each (".sprintf("%.1f", $r->{'elapsed'})."s)");
    like($r->{'out'}, qr/^failed\ to\ start\ browser\ \Q$tmp\E\/br_hang\.sh:\ no\ answer\ within\ 3s$/mx, "browser hangs at start: message");
    ok(!-e "$tmp/hangstart.pdf", "browser hangs at start: no output file");
    _no_leftovers($r, "browser hangs at start");

    $r = _run(_renderer("$local/plain", "$tmp/false.pdf", 1600, 1200, ""), THRUK_BROWSER => "/bin/false");
    is($r->{'rc'}, 1, "browser which cannot start: exit code 1");
    like($r->{'out'}, qr/\Abrowser\ did\ not\ start\ with\ sandbox\ \(.*\),\ sandbox\ is\ off\ for\ this\ run\nfailed\ to\ start\ browser\ \/bin\/false:\ [^\n]+\n\z/mx, "browser which cannot start: retry line, then start failed line");
    unlike($r->{'out'}.$r->{'err'}, qr/\ line\ \d+/mx, "browser which cannot start: no perl location");

    $r = _run(_renderer("$local/plain", "$tmp/nobrowser.pdf", 1600, 1200, ""), THRUK_BROWSER => "$tmp/missing");
    is($r->{'rc'}, 1, "unusable browser setting: exit code 1");
    is($r->{'out'}, "THRUK_BROWSER is set to $tmp/missing but this is not an executable file\n", "unusable browser setting: message");

    $r = _run(_renderer("$local/plain"));
    is($r->{'rc'}, 1, "wrong number of arguments: exit code 1");
    like($r->{'err'}, qr/^usage:/mx, "wrong number of arguments: usage");
}

done_testing();

###########################################################
sub _renderer {
    my(@args) = @_;
    return([$^X, $renderer, @args]);
}

###########################################################
sub _script {
    my($file, @lines) = @_;
    open(my $fh, '>', $file) or die("cannot write $file: $!");
    print $fh join("\n", "#!/bin/bash", @lines), "\n";
    close($fh);
    chmod(0755, $file);
    return;
}

###########################################################
# starts a command, returns a handle for _finish
my $runs = 0;
sub _start {
    my($cmd, %env) = @_;
    my $n = ++$runs;
    my $h = { outfile => "$tmp/run$n.out", errfile => "$tmp/run$n.err", pidfile => "$tmp/run$n.pid", t0 => time() };
    my $pid = fork();
    die("fork failed: $!") unless defined $pid;
    if(!$pid) {
        %ENV = (%ENV, THRUK_RENDER_DEBUG => 1, THRUK_TEST_PIDFILE => $h->{'pidfile'}, %env);
        if(my $cwd = delete $ENV{'THRUK_TEST_CWD'}) {
            # relative library paths (ex.: PERL5LIB=./lib in CI) cannot be searched from there
            $ENV{'PERL5LIB'} = join(':', grep { m|^/|mx } split(/:/mx, $ENV{'PERL5LIB'} // ''));
            chdir($cwd) or die("cannot chdir to $cwd: $!");
            chmod(0000, $cwd); # the working directory of the renderer is not accessible now
        }
        open(STDIN,  '<', '/dev/null');
        open(STDOUT, '>', $h->{'outfile'});
        open(STDERR, '>', $h->{'errfile'});
        { exec(@{$cmd}); }
        POSIX::_exit(127);
    }
    $h->{'pid'} = $pid;
    return $h;
}

###########################################################
sub _finish {
    my($h, $timeout) = @_;
    my $deadline = time() + ($timeout // 120);
    while(!defined $h->{'status'}) {
        if(waitpid($h->{'pid'}, POSIX::WNOHANG) != 0) { $h->{'status'} = $?; last; }
        if(time() > $deadline) {
            kill('KILL', $h->{'pid'});
            waitpid($h->{'pid'}, 0);
            $h->{'status'} = -1;
            $h->{'timeout'} = 1;
            last;
        }
        sleep(0.02);
    }
    $h->{'elapsed'} = time() - $h->{'t0'};
    $h->{'rc'}      = $h->{'timeout'} ? 'timeout' : ($h->{'status'} & 127) ? 'signal '.($h->{'status'} & 127) : $h->{'status'} >> 8;
    $h->{'out'}     = _slurp($h->{'outfile'});
    $h->{'err'}     = _slurp($h->{'errfile'});
    my @dirs        = $h->{'err'} =~ m/^\[debug\]\ temp\ folder:\ (\S+)$/gmx;
    $h->{'run_dir'} = $dirs[-1];
    $h->{'browser_pid'} = _browser_pid($h);
    return $h;
}

###########################################################
sub _run {
    my($cmd, %env) = @_;
    return(_finish(_start($cmd, %env)));
}

###########################################################
sub _browser_pid {
    my($h) = @_;
    my $pid = _slurp($h->{'pidfile'});
    chomp($pid);
    return($pid =~ m/^\d+$/mx ? $pid : undef);
}

###########################################################
# the browser runs in its own process group, which has the pid of the browser
sub _no_leftovers {
    my($h, $name) = @_;
    my $gone = sub { return((!$h->{'browser_pid'} || !kill(0, -$h->{'browser_pid'})) ? 1 : 0); };
    my $removed = sub { return((!$h->{'run_dir'} || !-e $h->{'run_dir'}) ? 1 : 0); };
    _wait_for(sub { $gone->() && $removed->() }, 5);
    ok(defined $h->{'run_dir'} && defined $h->{'browser_pid'}, "$name: browser was started");
    ok($gone->(), "$name: no process of the browser left");
    ok($removed->(), "$name: temp folder of the run removed");
    return;
}

###########################################################
sub _wait_for {
    my($cb, $timeout) = @_;
    my $deadline = time() + $timeout;
    while(1) {
        return 1 if $cb->();
        return 0 if time() > $deadline;
        sleep(0.05);
    }
    return;
}

###########################################################
# returns requests seen by the test server as [host, path, cookie] and forgets them
sub _requests {
    my($keep) = @_;
    open(my $fh, '<', $reqlog) or return;
    my @r = map { chomp; [split(/\t/mx, $_, -1)] } <$fh>;
    close($fh);
    truncate($reqlog, 0) unless $keep;
    return @r;
}

###########################################################
sub _slurp {
    my($file) = @_;
    open(my $fh, '<:raw', $file) or return '';
    local $/ = undef;
    my $data = <$fh> // '';
    close($fh);
    return $data;
}

###########################################################
sub _cmd {
    my(@cmd) = @_;
    open(my $ph, '-|', @cmd) or return(127, "cannot run ".$cmd[0].": ".$!);
    local $/ = undef;
    my $out = <$ph> // '';
    close($ph);
    return($? >> 8, $out);
}

###########################################################
sub _free_port {
    my $sock = IO::Socket::INET->new(LocalAddr => '127.0.0.1', LocalPort => 0, Listen => 1, ReuseAddr => 1) or die("cannot find free port: $!");
    my $free = $sock->sockport();
    close($sock);
    return $free;
}

###########################################################
sub _has_ipv6 {
    require IO::Socket::IP;
    return(IO::Socket::IP->new(PeerHost => '::1', PeerPort => $port) ? 1 : 0);
}

###########################################################
# pdf files written by chromium have plain page objects
sub _pages {
    my($pdf) = @_;
    my @pages = $pdf =~ m/\/Type\s*\/Page\b/gmx;
    return(scalar @pages);
}
sub _pagesize {
    my($pdf) = @_;
    my($w, $h) = $pdf =~ m/\/MediaBox\s*\[\s*0\s+0\s+([\d.]+)\s+([\d.]+)\s*\]/mx;
    return($w // 0, $h // 0);
}
sub _pngsize {
    my($file) = @_;
    my $data = _slurp($file);
    return(0, 0) unless substr($data, 0, 8) eq "\x89PNG\r\n\x1a\n";
    return(unpack("NN", substr($data, 16, 8)));
}
sub _near {
    my($a, $b) = @_;
    return(abs($a - $b) <= 1.5 ? 1 : 0);
}

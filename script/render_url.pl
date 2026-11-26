#!/usr/bin/perl

=head1 NAME

render_url.pl - save html pages, urls and grafana panels as pdf or png

=head1 SYNOPSIS

  render_url.pl <url> <output file> <width> <height> <sessionid> [<is_report>]
  render_url.pl --find-browser
  render_url.pl --selftest

=head1 DESCRIPTION

This script starts a chromium browser with C<--remote-debugging-pipe> and
controls it directly with the chrome devtools protocol. It is called by
C<html2pdf.sh> and C<grafana_export.sh> and is not meant to be used directly.

An output file ending in C<.pdf> results in a pdf, everything else in a png
image of exactly width x height pixel.

Settings are read from the environment: C<THRUK_BROWSER>,
C<THRUK_BROWSER_NO_SANDBOX>, C<WAIT_TIMEOUT>, C<START_TIMEOUT> and
C<THRUK_COOKIE_AUTH_DOMAIN>.

Exit codes:

  0 - output written
  1 - nothing rendered (bad arguments, no browser, browser did not start,
      output not writable, interrupted)
  2 - failure while rendering

See https://www.thruk.org/documentation/faq.html#chromium for details.

=cut

use warnings;
use strict;
use Errno;
use Fcntl ();
use File::Basename qw/dirname/;
use File::Temp qw/tempdir/;
use IO::Handle;
use MIME::Base64 qw/decode_base64/;
use POSIX ();
use Time::HiRes qw/time sleep/;

# Cpanel::JSON::XS is not in the perl path of the wrappers on all installations, JSON::PP is in the perl core
my $has_xs     = eval { require Cpanel::JSON::XS; 1 } ? 1 : do { require JSON::PP; 0 };
my $json       = _new_json()->utf8;                 # protocol messages
my $json_text  = _new_json()->ascii->allow_nonref;  # javascript literals and page content
my($T, $F)     = (\1, \0);

my $load_timeout = 30;   # seconds to wait for a page to load
my $pdf_timeout  = 600;  # seconds to wait for the pdf
my $faq_url      = 'https://www.thruk.org/documentation/faq.html#chromium';
my $debug        = $ENV{'THRUK_RENDER_DEBUG'};

# browser process and connection
my($pid, $run_dir, $to_browser, $from_browser) = (0);
my($msgid, $buf, $scanned) = (0, "", 0);
my(%want, %replies);     # commands waiting for a reply and replies not fetched yet
# page state
my($session, $main_target, $main_frame) = ('', '', '');
my %nav;                 # state of the current navigation of the main frame
my($cookie_host, $cookie_url);
my $partial_output;      # output file which has been started but is not complete
my $active;              # set as soon as main() runs

## no critic
END { if($active) { my $rc = $?; cleanup(); $? = $rc; } }
## use critic

main() unless caller;

###########################################################
sub main {
    $active = 1;
    binmode(STDOUT, ':encoding(UTF-8)');
    binmode(STDERR, ':encoding(UTF-8)');
    STDOUT->autoflush(1);
    STDERR->autoflush(1);
    ## no critic
    $SIG{'PIPE'} = 'IGNORE';
    for my $sig (qw/TERM INT HUP/) {
        $SIG{$sig} = sub { cleanup(); exit 1; };
    }
    ## use critic

    my $mode = $ARGV[0] // '';
    if($mode eq '--find-browser') {
        my($exe, $err) = find_browser();
        print(($exe // $err), "\n");
        exit($exe ? 0 : 1);
    }

    my $selftest = $mode eq '--selftest' ? 1 : 0;
    my($url, $output, $width, $height, $sessionid, $is_report) = @ARGV;
    if($selftest) {
        ($width, $height) = (320, 200);
    }
    elsif(scalar @ARGV < 5 || scalar @ARGV > 6 || $width !~ m/^\d+$/mx || $height !~ m/^\d+$/mx) {
        print STDERR "usage: $0 <url> <output file> <width> <height> <sessionid> [<is_report>]\n";
        print STDERR "       $0 --find-browser\n";
        print STDERR "       $0 --selftest\n";
        exit 1;
    }

    # everything which fails before the browser runs ends with exit code 1, later failures with 2
    my $started = 0;
    my $ok = eval {
        if(!$selftest) {
            my $dir = dirname($output);
            _fail(1, "cannot write ".$output.": ".$dir." is not a writable folder") unless(-d $dir && -w $dir);
        }
        my($exe, $err) = find_browser();
        _fail(1, $err) unless $exe;
        my $sandbox = (($ENV{'THRUK_BROWSER_NO_SANDBOX'} // '') eq '1') ? 0 : 1;
        $err = start_browser($exe, $sandbox, $width, $height);
        if($err && $sandbox) {
            print "browser did not start with sandbox (".$err."), sandbox is off for this run\n";
            $sandbox = 0;
            $err = start_browser($exe, $sandbox, $width, $height);
        }
        _fail(1, "failed to start browser ".$exe.": ".$err) if $err;
        $started = 1;

        if($selftest) {
            selftest($exe, $sandbox, $width, $height);
        } else {
            utf8::decode($url);
            utf8::decode($sessionid) if defined $sessionid;
            render($url, $output, $width, $height, $sessionid, $is_report);
        }
        eval { call('Browser.close', {}, undef, 5); };
        1;
    };
    my $err = $@;
    if($ok) {
        cleanup();
        exit 0;
    }

    my($rc, $msg);
    if(ref $err eq 'HASH') {
        ($rc, $msg) = ($err->{'rc'}, $err->{'msg'});
    } else {
        ($rc, $msg) = ($started ? 2 : 1, "".$err);
        $msg =~ s/\s+at\s+\S+\s+line\s+\d+\.?\s*$//mx; # no perl location
    }
    $msg =~ s/\s+$//mx;
    print $msg, "\n";
    cleanup();
    exit($selftest ? 1 : $rc);
}

###########################################################
sub _new_json {
    return($has_xs ? Cpanel::JSON::XS->new : JSON::PP->new);
}

###########################################################
sub _debug {
    my(@msg) = @_;
    print STDERR "[debug] ", @msg, "\n" if $debug;
    return;
}

###########################################################
# end the run with the given exit code and message
sub _fail {
    my($rc, $msg) = @_;
    die({ rc => $rc, msg => $msg });
}

###########################################################
# run code and ignore its errors, except those which end the run
sub _quiet {
    my($code) = @_;
    my $res = eval { $code->() };
    if($@) {
        die($@) if ref $@;
        my $err = $@;
        chomp($err);
        _debug("ignored: ".$err);
    }
    return $res;
}

###########################################################

=head1 FUNCTIONS

=head2 find_browser

  find_browser([$options])

returns (path) of the browser to use or (undef, message). This is the only
place which knows where to look for a browser. Order:

  1. THRUK_BROWSER, must be an absolute path to an executable file. No fallback.
  2. the browser installed by install_browser.sh
  3. a system chromium in the standard folders, then in PATH

Options (used by tests): setting, installed, dirs, path, names.

=cut

sub find_browser {
    my($in) = @_;
    $in = {} unless $in;
    my $setting   = exists $in->{'setting'}   ? $in->{'setting'}   : $ENV{'THRUK_BROWSER'};
    my $installed = exists $in->{'installed'} ? $in->{'installed'} : '/var/lib/thruk/browser/chrome-headless-shell/chrome-headless-shell';
    my $dirs      = $in->{'dirs'}  || [qw(/usr/bin /usr/local/bin /snap/bin)];
    my $path      = exists $in->{'path'}      ? $in->{'path'}      : $ENV{'PATH'};
    my $names     = $in->{'names'} || [qw/chromium chromium-browser chrome-headless-shell google-chrome google-chrome-stable/];

    if(defined $setting && $setting ne '') {
        return($setting) if($setting =~ m|^/|mx && -f $setting && -x $setting);
        return(undef, "THRUK_BROWSER is set to ".$setting." but this is not an executable file");
    }
    return($installed) if(defined $installed && -f $installed && -x $installed);
    for my $dir (@{$dirs}, split(/:/mx, $path // '')) {
        next unless $dir =~ m|^/|mx;
        for my $name (@{$names}) {
            return($dir."/".$name) if(-f $dir."/".$name && -x $dir."/".$name);
        }
    }
    return(undef, "no usable chromium browser found, set THRUK_BROWSER or run install_browser.sh, see ".$faq_url);
}

###########################################################

=head2 start_browser

  start_browser($exe, $sandbox, $width, $height)

starts the browser in its own process group with its own temp folder.
Returns undef on success or the reason why it did not start.

=cut

sub start_browser {
    my($exe, $sandbox, $width, $height) = @_;
    my $start_timeout = _seconds($ENV{'START_TIMEOUT'}, 30);

    # TMPDIR is not used, so housekeeping knows all places
    my $base = '/tmp';
    if($ENV{'OMD_ROOT'}) {
        $base = $ENV{'OMD_ROOT'}.'/tmp/thruk';
        mkdir($base) unless -d $base;
    }
    $run_dir = tempdir("thruk_browser_XXXXXXXX", DIR => $base);
    chmod(0700, $run_dir);
    _debug("temp folder: ".$run_dir);

    pipe(my $c_rd, my $p_wr) or die("pipe: ".$!."\n");
    pipe(my $p_rd, my $c_wr) or die("pipe: ".$!."\n");
    $pid = fork();
    die("fork: ".$!."\n") unless defined $pid;
    if(!$pid) {
        # the browser reads commands from fd 3 and writes to fd 4
        ## no critic
        $SIG{$_} = 'DEFAULT' for qw/TERM INT HUP PIPE/;
        $ENV{'XDG_CONFIG_HOME'} = $run_dir;  # works without writable home
        $ENV{'XDG_CACHE_HOME'}  = $run_dir;
        ## use critic
        POSIX::setpgid(0, 0);
        close($p_wr); close($p_rd);
        # move them out of the way first, they might be 3 or 4 already. Copies to free fds above 4,
        # fixed numbers could be taken by another open fd (the web server has many open).
        my $rd2 = fcntl($c_rd, Fcntl::F_DUPFD(), 5); my $wr2 = fcntl($c_wr, Fcntl::F_DUPFD(), 5);
        POSIX::dup2($rd2, 3); POSIX::dup2($wr2, 4);
        POSIX::close($rd2); POSIX::close($wr2);
        open(STDIN,  '<', '/dev/null');
        open(STDOUT, '>', $run_dir."/stdout.log");
        open(STDERR, '>', $run_dir."/stderr.log");
        my @args = (
            '--headless', '--remote-debugging-pipe', '--user-data-dir='.$run_dir.'/data', '--window-size='.$width.','.$height,
            '--disable-gpu', '--ignore-certificate-errors', '--hide-scrollbars', '--mute-audio',
            '--no-first-run', '--no-default-browser-check', '--disable-extensions', '--disable-sync',
            '--disable-background-networking', '--disable-default-apps', '--disable-breakpad',
            '--disable-dev-shm-usage', '--password-store=basic', '--use-mock-keychain',
            # chrome-headless-shell hints fonts fully, full Chrome (used by the node renderer before) does not.
            # Hinting snaps glyphs to whole pixels, small text gets narrower and ocr of small graphs fails.
            '--font-render-hinting=none',
        );
        push @args, '--no-sandbox', '--disable-setuid-sandbox' unless $sandbox;
        { exec($exe, @args, 'about:blank'); }
        print STDERR "cannot execute ".$exe.": ".$!."\n";
        $active = 0; # the temp folder belongs to the parent
        exit(127);
    }
    POSIX::setpgid($pid, $pid);
    close($c_rd); close($c_wr);
    ($to_browser, $from_browser, $buf, $scanned, $msgid) = ($p_wr, $p_rd, "", 0, 0);
    %want = (); %replies = ();

    my $res = eval { call('Browser.getVersion', {}, undef, $start_timeout) };
    if(!$res) {
        my $err = $@;
        if(ref $err) { $err = "browser ended during start"; }
        elsif($err =~ m/timeout/mx) { $err = "no answer within ".$start_timeout."s"; }
        chomp($err);
        my $log = '';
        if(open(my $fh, '<', $run_dir."/stderr.log")) { local $/ = undef; $log = <$fh> // ''; close($fh); }
        my($fatal) = grep { /FATAL|No\ usable\ sandbox|error\ while\ loading|cannot\ open\ shared|not\ supported|cannot\ execute/mx } split(/\n/mx, $log);
        cleanup();
        return($err.($fatal ? ": ".substr($fatal, 0, 300) : ""));
    }
    _debug("started ".$res->{'product'}." sandbox=".($sandbox ? 1 : 0));
    return;
}

###########################################################

=head2 cleanup

  cleanup()

ends the browser process group and removes the temp folder of this run.

=cut

sub cleanup {
    my $p = $pid;
    $pid = 0;
    # an output file which has not been written completely, also after a signal
    if(defined $partial_output) {
        unlink($partial_output);
        $partial_output = undef;
    }
    if($p) {
        kill('TERM', -$p);
        for (1..30) {
            last if waitpid($p, POSIX::WNOHANG) != 0;
            sleep(0.1);
        }
        kill('KILL', -$p);
        waitpid($p, 0);
    }
    my $dir = $run_dir;
    $run_dir = undef;
    _remove_folder($dir) if($dir && -d $dir);
    return;
}

###########################################################
# does not change the working directory, which might not be accessible for this user
sub _remove_folder {
    my($dir) = @_;
    if(opendir(my $dh, $dir)) {
        for my $entry (readdir($dh)) {
            next if($entry eq '.' || $entry eq '..');
            my $path = $dir.'/'.$entry;
            if(!-l $path && -d $path) {
                _remove_folder($path);
            } else {
                unlink($path);
            }
        }
        closedir($dh);
    }
    rmdir($dir);
    return;
}

###########################################################
sub _seconds {
    my($value, $default) = @_;
    return $value if(defined $value && $value =~ m/^\d+(\.\d+)?$/mx && $value > 0);
    return $default;
}

###########################################################
# the only place which writes to the browser
sub _write_all {
    my($data) = @_;
    my($off, $len) = (0, length($data));
    while($off < $len) {
        my $n = syswrite($to_browser, $data, $len - $off, $off);
        if(!defined $n) {
            next if $!{EINTR};
            if($!{EAGAIN}) { sleep(0.01); next; }
            _fail(2, "browser closed the connection") if $!{EPIPE};
            _fail(2, "writing to browser failed: ".$!);
        }
        $off += $n;
    }
    return;
}

###########################################################
# returns next message from the browser, dies with "timeout\n" when the deadline passed
sub _read_msg {
    my($deadline) = @_;
    while(1) {
        my $i = index($buf, "\0", $scanned);
        if($i >= 0) {
            my $msg = substr($buf, 0, $i);
            substr($buf, 0, $i+1, "");
            $scanned = 0;
            return $json->decode($msg);
        }
        $scanned = length($buf);
        my $left = $deadline - time();
        die("timeout\n") if $left <= 0;
        my $rin = '';
        vec($rin, fileno($from_browser), 1) = 1;
        my $n = select(my $rout = $rin, undef, undef, $left);
        next if $n <= 0;
        my $r = sysread($from_browser, $buf, 262144, length($buf));
        next if(!defined $r && $!{EINTR});
        _fail(2, "browser closed the connection") unless $r;
    }
    return;
}

###########################################################
# sends a command, returns its id
sub _send {
    my($method, $params, $sid) = @_;
    my $id = ++$msgid;
    $want{$id} = $method;
    _write_all($json->encode({ id => $id, method => $method, params => $params || {}, $sid ? (sessionId => $sid) : () })."\0");
    return $id;
}

###########################################################
# replies are kept by command id, so a command sent while handling
# an event does not take the reply somebody else waits for
sub _dispatch {
    my($msg) = @_;
    if(defined $msg->{'id'}) {
        $replies{$msg->{'id'}} = $msg if $want{$msg->{'id'}};
        return;
    }
    _on_event($msg);
    return;
}

###########################################################
# waits for the reply of a command and returns the result, handles events meanwhile
sub _wait_reply {
    my($id, $deadline) = @_;
    my $method = $want{$id} // '';
    my $ok = eval {
        while(!exists $replies{$id}) {
            _dispatch(_read_msg($deadline));
        }
        1;
    };
    if(!$ok) {
        delete $want{$id};
        die($@) if ref $@;
        my $err = $@;
        chomp($err);
        die($method.": ".$err."\n");
    }
    delete $want{$id};
    my $reply = delete $replies{$id};
    die($method.": ".($reply->{'error'}->{'message'} // 'unknown error')."\n") if $reply->{'error'};
    return($reply->{'result'} || {});
}

###########################################################

=head2 call

  call($method, [$params], [$session], [$timeout])

sends a command to the browser and returns the result.

=cut

sub call {
    my($method, $params, $sid, $timeout) = @_;
    my $id = _send($method, $params, $sid);
    return(_wait_reply($id, time() + ($timeout || 60)));
}

###########################################################
# handle events for the given time
sub _pump {
    my($seconds) = @_;
    my $deadline = time() + $seconds;
    while(1) {
        my $msg = eval { _read_msg($deadline) };
        if(!$msg) {
            return if(!ref $@ && $@ eq "timeout\n");
            die($@);
        }
        _dispatch($msg);
    }
    return;
}

###########################################################
sub _evaluate {
    my($expr, $await, $timeout) = @_;
    my $r = call('Runtime.evaluate', { expression => $expr, returnByValue => $T, awaitPromise => $await ? $T : $F }, $session, $timeout);
    die("javascript error: ".($r->{'exceptionDetails'}->{'text'} // '')."\n") if $r->{'exceptionDetails'};
    return $r->{'result'}->{'value'};
}

###########################################################
# the session cookie is removed for the rest of the run. The run fails if that does not work.
sub _remove_cookie {
    my($reason) = @_;
    return unless $cookie_host;
    _debug($reason.", removing session cookie");
    my $ok = eval { call('Network.deleteCookies', { name => 'thruk_auth', url => $cookie_url }, $session, 10); 1 };
    if(!$ok) {
        die($@) if ref $@;
        my $err = $@;
        chomp($err);
        _fail(2, "cannot remove session cookie: ".$err);
    }
    $cookie_host = undef;
    return;
}

###########################################################
sub _on_event {
    my($e) = @_;
    my $m = $e->{'method'} || '';
    my $p = $e->{'params'} || {};
    if($m eq 'Network.responseReceived') {
        my $r = $p->{'response'};
        _debug("response: ".$r->{'url'}." ".$r->{'status'});
        if($r->{'status'} >= 500 && $r->{'status'} <= 520) {
            _fail(2, "url ".$r->{'url'}." failed with status: ".$r->{'status'}.". Aborting...");
        }
        if(($p->{'type'} || '') eq 'Document' && ($e->{'sessionId'} // '') eq $session && ($p->{'frameId'} // '') eq ($nav{'frame'} || '')) {
            $nav{'docs'}->{$p->{'loaderId'}} = [$r->{'status'}, $r->{'statusText'} // ''];
        }
    }
    elsif($m eq 'Page.loadEventFired') {
        $nav{'loaded'} = 1 if(($e->{'sessionId'} // '') eq $session);
    }
    elsif($m eq 'Fetch.requestPaused') {
        # a document of any frame is about to load from another host than the one
        # which got the session cookie: remove the cookie before the request goes on.
        # The url is the one the browser is going to request, in the browsers own notation.
        my($host) = $p->{'request'}->{'url'} =~ m{^https?://(?:[^/?\#@]*@)?(\[[^\]]+\]|[^/:?\#]+)}mxi;
        $host = lc($host // '');
        $host =~ s/^\[|\]$//gmx;
        if($cookie_host && $host ne $cookie_host) {
            _remove_cookie("document from ".$p->{'request'}->{'url'}." instead of ".$cookie_host);
        }
        _quiet(sub { call('Fetch.continueRequest', { requestId => $p->{'requestId'} }, $e->{'sessionId'}, 10) });
    }
    elsif($m eq 'Target.attachedToTarget') {
        my $sid  = $p->{'sessionId'};
        my $info = $p->{'targetInfo'} || {};
        _debug("attached: ".($info->{'type'} // '')." ".($info->{'url'} // '')." id=".($info->{'targetId'} // ''));
        return if $sid eq $session;
        if(($info->{'type'} // '') eq 'page' && $info->{'targetId'} ne $main_target) {
            # a further page (popup) is held before it runs: it must not see the session cookie.
            # It has to be resumed, closing it here would block the page which opened it.
            _remove_cookie("further page opened");
            _quiet(sub { call('Runtime.runIfWaitingForDebugger', {}, $sid, 10) });
            return;
        }
        # frames and workers in other processes: watch their responses and their own children, then let them run
        my @ids = (
            _send('Network.enable', {}, $sid),
            _send('Target.setAutoAttach', { autoAttach => $T, waitForDebuggerOnStart => $T, flatten => $T }, $sid),
            _send('Runtime.runIfWaitingForDebugger', {}, $sid),
        );
        my $deadline = time() + 10;
        for my $id (@ids) {
            _quiet(sub { _wait_reply($id, $deadline) });
        }
    }
    elsif($m eq 'Inspector.targetCrashed') {
        _fail(2, "browser page crashed");
    }
    return;
}

###########################################################
# create the page and watch everything it loads
sub _setup_page {
    my($width, $height) = @_;
    # the attach event arrives before the reply, so the id has to be known first
    $main_target = call('Target.createTarget', { url => 'about:blank' })->{'targetId'};
    $session     = call('Target.attachToTarget', { targetId => $main_target, flatten => $T })->{'sessionId'};
    for my $method (qw/Page.enable Network.enable Runtime.enable/) {
        call($method, {}, $session);
    }
    call('Target.setAutoAttach', { autoAttach => $T, waitForDebuggerOnStart => $T, flatten => $T }, $session);
    call('Target.setAutoAttach', { autoAttach => $T, waitForDebuggerOnStart => $T, flatten => $T });
    $main_frame = call('Page.getFrameTree', {}, $session)->{'frameTree'}->{'frame'}->{'id'};
    call('Emulation.setDeviceMetricsOverride', { width => $width+0, height => $height+0, deviceScaleFactor => 1, mobile => $F }, $session);
    return;
}

###########################################################
# only send the session cookie to the local server or hosts within the configured cookie auth domain.
# The browser itself says which host the url points to, there is no second url parser which could disagree.
sub _set_cookie {
    my($url, $sessionid) = @_;
    return unless(defined $sessionid && $sessionid ne '');
    my $loc = eval { $json_text->decode(_evaluate('(function() { try { var u = new URL('.$json_text->encode($url).'); return JSON.stringify([u.protocol, u.hostname, u.origin]); } catch(e) { return "[]"; } })()')) };
    die($@) if ref $@;
    my($proto, $host, $origin) = @{$loc || []};
    return unless(defined $origin && ($proto eq 'http:' || $proto eq 'https:'));
    $host = lc($host);
    $host =~ s/^\[|\]$//gmx;
    my $domain = lc($ENV{'THRUK_COOKIE_AUTH_DOMAIN'} || '');
    $domain =~ s/^\.//mx;
    return unless($host eq 'localhost' || $host eq '127.0.0.1' || $host eq '::1'
                  || ($domain ne '' && ($host eq $domain || $host =~ m/\.\Q$domain\E$/mx)));

    # host only cookie (no domain attribute), valid for all paths
    call('Network.setCookie', { name => 'thruk_auth', value => $sessionid, url => $origin.'/', path => '/', sameSite => 'Strict' }, $session);
    ($cookie_host, $cookie_url) = ($host, $origin.'/');
    # every document request is held until the cookie rule has been checked, see Fetch.requestPaused
    call('Fetch.enable', { patterns => [{ urlPattern => '*', resourceType => 'Document' }] }, $session);
    return;
}

###########################################################
# navigate and wait for the load event, returns (status, statusText) of the page
sub _goto_url {
    my($target) = @_;
    %nav = (frame => $main_frame);
    my $id       = _send('Page.navigate', { url => $target }, $session);
    my $deadline = time() + $load_timeout;
    my $nav;
    while(!$nav || !$nav{'loaded'}) {
        if(!$nav && exists $replies{$id}) {
            my $reply = delete $replies{$id};
            delete $want{$id};
            _fail(2, "fetching url ".$target." failed: ".($reply->{'error'}->{'message'} // '')) if $reply->{'error'};
            $nav = $reply->{'result'} || {};
            _fail(2, "fetching url ".$target." failed: ".$nav->{'errorText'}) if $nav->{'errorText'};
            $nav{'loader'} = $nav->{'loaderId'};
            next;
        }
        my $msg = eval { _read_msg($deadline) };
        if(!$msg) {
            _fail(2, "timeout while loading url ".$target.", giving up after ".$load_timeout."s") if(!ref $@ && $@ eq "timeout\n");
            die($@);
        }
        _dispatch($msg);
    }
    my $doc = $nav{'docs'}->{$nav{'loader'} || ''} || [0, ''];
    return(@{$doc});
}

###########################################################
sub _goto_or_fail {
    my($target) = @_;
    my($status, $text) = _goto_url($target);
    if(!($status == 0 || ($status >= 200 && $status <= 299))) {
        _fail(2, "fetching url ".$target." failed: ".$status." ".$text);
    }
    return;
}

###########################################################
sub _query_param {
    my($url, $name) = @_;
    return unless $url =~ m/[?&]\Q$name\E=([^&\#]*)/mx;
    my $v = $1;
    utf8::encode($v);
    $v =~ s/\+/ /gmx;
    $v =~ s/%([0-9a-fA-F]{2})/chr(hex($1))/gemx;
    utf8::decode($v);
    return $v;
}

###########################################################
# returns url with the panel title replaced by the panel id
sub _resolve_panel {
    my($url) = @_;
    my $panel_id = _query_param($url, 'panelId');
    return $url if(!defined $panel_id || $panel_id =~ m/^[0-9]+$/mx);

    my $set_id = sub { my($id) = @_; $url =~ s/([?&]panelId=)[^&]*/$1$id/mx; return; };
    my $hostname = _query_param($url, 'host')    // '';
    my $service  = _query_param($url, 'service') // '';
    my $random   = int(rand(100000));
    my $source_url = $url;
    $source_url =~ s%/grafana/(d|dashboard|dashboard-solo)/script/histou\.js\?%/histou/index.php?_=$random&%mx;
    $source_url =~ s/&disablePanelTitle//mx;
    if($source_url =~ m|/histou/index\.php|mx) {
        _goto_or_fail($source_url);
        my $data = _evaluate('document.documentElement.outerHTML') // '';
        $data =~ s/^[\s\S]*<br>\{/{/mx;
        $data =~ s/<br><\/pre>.*//smx;
        $data =~ s/\n//gmx;
        $data = eval { $json_text->decode($data) } or _fail(2, "cannot parse histou dashboard from ".$source_url);
        for my $row (@{$data->{'rows'} || []}) {
            for my $panel (@{$row->{'panels'} || []}) {
                my $title = $panel->{'title'} // '';
                $title =~ s/\Q$hostname\E\ -\ //mx; $title =~ s/\Q$hostname\E\ //mx;
                $title =~ s/\Q$service\E\ -\ //mx;  $title =~ s/\Q$service\E\ //mx;
                $title =~ s/^\/check_\S+[^\/]*\/\ //mx;
                $title =~ s/^check_\S+\ -\ //mx;
                $title =~ s/^check_\S+\ //mx;
                $title =~ s/^\$\{|:\w+\}//gmx;
                $set_id->($panel->{'id'}) if($panel->{'id'} eq $panel_id || $title eq $panel_id);
            }
        }
    }
    elsif($source_url =~ m%(?:d|d-solo|dashboard)/([^/]+)/%mx) {
        my $dashboard_id = $1;
        my $api_url = $source_url;
        $api_url =~ s%/grafana/.*$%/grafana/api/dashboards/uid/$dashboard_id%mx;
        _goto_or_fail($api_url);
        my $data = _evaluate('document.body.innerText') // '';
        $data = eval { $json_text->decode($data) } or _fail(2, "cannot parse dashboard from ".$api_url);
        for my $panel (@{$data->{'dashboard'}->{'panels'} || []}) {
            $set_id->($panel->{'id'}) if($panel->{'id'} eq $panel_id || ($panel->{'title'} // '') =~ m/\Q$panel_id\E/mx);
        }
    }
    return $url;
}

###########################################################
# wait till grafana shows a chart, an error or the login window
sub _wait_for_chart {
    my $wait_timeout = _seconds($ENV{'WAIT_TIMEOUT'}, 20);
    my $check = <<'EOJS';
(function() {
  var vis = function(sel) { var el = document.querySelector(sel); if(!el) { return null; }
    var st = window.getComputedStyle(el); if(st.visibility == 'hidden' || st.display == 'none' || el.getClientRects().length == 0) { return null; } return el; };
  var el;
  if(document.querySelector('#loginuser')) { return "E:login window present, export failed"; }
  if((el = vis('div.alert-error')))       { return "A:" + el.textContent; }
  if((el = vis('div[role="alert"]')))     { return "A:" + el.ariaLabel; }
  if((el = vis('DIV.markdown-html H1')))  { return "A:" + el.textContent; }
  if(document.querySelector('DIV.flot-text, p.panel-text-content, DIV.uplot')) { return "OK"; }
  return "";
})()
EOJS
    my $deadline = time() + $wait_timeout;
    my $state = "";
    while(time() < $deadline) {
        # a page busy with javascript does not answer, so the wait is bounded by what is left of WAIT_TIMEOUT
        my $left = $deadline - time();
        last if $left <= 0;
        $state = _quiet(sub { _evaluate($check, 0, $left) }) // ""; # the page may be gone during a navigation
        last if $state;
        _pump(0.1);
    }
    if($state eq 'OK')               { print "chart panel found, export OK\n"; }
    elsif($state =~ m/^A:(.*)$/smx)  { _fail(2, "alert message found, export failed\n".$1); }
    elsif($state =~ m/^E:(.*)$/smx)  { _fail(2, $1); }
    else                             { _fail(2, "timeout while waiting for chart, export failed"); }
    return;
}

###########################################################
# print the current page into a pdf file, the data is written while it arrives
sub _write_pdf {
    my($file, $is_report) = @_;
    my %pdf = (printBackground => $T, displayHeaderFooter => $F, marginTop => 0, marginBottom => 0, marginLeft => 0, marginRight => 0,
               transferMode => 'ReturnAsStream');
    if($is_report) {
        call('Emulation.setEmulatedMedia', { media => 'print' }, $session);
        %pdf = (%pdf, paperWidth => 8.27, paperHeight => 11.69, preferCSSPageSize => $T);
    } else {
        call('Emulation.setEmulatedMedia', { media => 'screen' }, $session);
        %pdf = (%pdf, paperWidth => 1600/96, paperHeight => 1200/96);
    }
    _quiet(sub { _evaluate('document.fonts.ready.then(function() { return true; })', 1, 10) });
    my $res = eval { call('Page.printToPDF', \%pdf, $session, $pdf_timeout) };
    if(!$res) {
        die($@) if ref $@;
        my $err = $@;
        chomp($err);
        _fail(2, "creating pdf failed: ".$err);
    }
    open(my $fh, '>:raw', $file) or _fail(1, "cannot write ".$file.": ".$!);
    $partial_output = $file;
    _debug("pdf stream opened");
    while(1) {
        my $chunk = call('IO.read', { handle => $res->{'stream'}, size => 1048576 }, $session, $pdf_timeout);
        _write_data($fh, $file, $chunk->{'base64Encoded'} ? decode_base64($chunk->{'data'}) : $chunk->{'data'});
        last if $chunk->{'eof'};
    }
    close($fh) or _fail(1, "cannot write ".$file.": ".$!);
    $partial_output = undef;
    _quiet(sub { call('IO.close', { handle => $res->{'stream'} }, $session, 10) });
    return;
}

###########################################################
# unbuffered, so nothing is left to flush when the run ends by a signal
sub _write_data {
    my($fh, $file, $data) = @_;
    my($off, $len) = (0, length($data));
    while($off < $len) {
        my $n = syswrite($fh, $data, $len - $off, $off);
        if(!defined $n) {
            next if $!{EINTR};
            _fail(1, "cannot write ".$file.": ".$!);
        }
        $off += $n;
    }
    return;
}

###########################################################
sub _write_png {
    my($file) = @_;
    my $res = eval { call('Page.captureScreenshot', { format => 'png' }, $session) };
    if(!$res) {
        die($@) if ref $@;
        my $err = $@;
        chomp($err);
        _fail(2, "creating screenshot failed: ".$err);
    }
    open(my $fh, '>:raw', $file) or _fail(1, "cannot write ".$file.": ".$!);
    $partial_output = $file;
    _write_data($fh, $file, decode_base64($res->{'data'}));
    close($fh) or _fail(1, "cannot write ".$file.": ".$!);
    $partial_output = undef;
    return;
}

###########################################################

=head2 render

  render($url, $output, $width, $height, $sessionid, $is_report)

loads the url and writes the pdf or png.

=cut

sub render {
    my($url, $output, $width, $height, $sessionid, $is_report) = @_;
    _setup_page($width, $height);
    _set_cookie($url, $sessionid);
    $url = _resolve_panel($url);
    _goto_or_fail($url);
    if($url =~ m/histou\.js\?/mx || $url =~ m|/grafana/|mx) {
        _wait_for_chart();
    }
    if($output =~ m/\.pdf$/mx) {
        _write_pdf($output, $is_report);
    } else {
        _write_png($output);
    }
    return;
}

###########################################################

=head2 selftest

  selftest($exe, $sandbox, $width, $height)

renders a page which creates its content by javascript into a pdf and a png
and checks both.

=cut

sub selftest {
    my($exe, $sandbox, $width, $height) = @_;
    my $version = call('Browser.getVersion')->{'product'} // '';
    print "browser: ", $exe, "\n";
    print "version: ", $version, "\n";
    print "sandbox: ", ($sandbox ? "on" : "off"), "\n";
    print "user id: ", $>, "\n";
    print "temp folder: ", $run_dir, "\n";

    my $text = "thruk rendering test";
    my $page = $run_dir."/selftest.html";
    open(my $fh, '>', $page) or _fail(1, "cannot write ".$page.": ".$!);
    print $fh '<html><head><title>selftest</title></head><body style="background: #dddddd;"><div id="out"></div>',
              '<script>document.getElementById("out").textContent = ["thruk", "rendering", "test"].join(" "); window.thruk_selftest = 1;</script>',
              '</body></html>';
    close($fh) or _fail(1, "cannot write ".$page.": ".$!);

    _setup_page($width, $height);
    _goto_or_fail("file://".$page);
    my $deadline = time() + $load_timeout;
    my $found;
    while(time() < $deadline) {
        my $left = $deadline - time();
        last if $left <= 0;
        $found = _quiet(sub { _evaluate('window.thruk_selftest === 1 && document.body.textContent.indexOf('.$json_text->encode($text).') >= 0', 0, $left) });
        last if $found;
        _pump(0.1);
    }
    _fail(1, "rendering test failed: the page did not run its javascript") unless $found;

    my($pdf, $png) = ($run_dir."/selftest.pdf", $run_dir."/selftest.png");
    _write_pdf($pdf, 1);
    my $data = _slurp($pdf);
    _fail(1, "rendering test failed: output is not a pdf") unless $data =~ m/^%PDF/mx;
    _fail(1, "rendering test failed: pdf contains no page") unless $data =~ m/\/Type\s*\/Page\b/mx;

    _write_png($png);
    $data = _slurp($png);
    _fail(1, "rendering test failed: output is not a png") unless substr($data, 0, 8) eq "\x89PNG\r\n\x1a\n";
    my($w, $h) = unpack("NN", substr($data, 16, 8));
    _fail(1, "rendering test failed: png is ".$w."x".$h." instead of ".$width."x".$height) unless($w == $width && $h == $height);

    print "rendering test OK\n";
    return;
}

###########################################################
sub _slurp {
    my($file) = @_;
    open(my $fh, '<:raw', $file) or _fail(1, "cannot read ".$file.": ".$!);
    local $/ = undef;
    my $data = <$fh> // '';
    close($fh);
    return $data;
}

1;

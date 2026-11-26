use warnings;
use strict;
use Cwd qw/abs_path/;
use File::Copy qw/copy/;
use File::Temp qw/tempdir/;
use IO::Compress::Zip qw/zip $ZipError/;
use Test::More;

# tests script/install_browser.sh without network and without a real browser:
# the installer is copied next to a fake html2pdf.sh, the tools curl, ldd and
# uname are replaced by stubs which come first in PATH.

my $installer = abs_path('script/install_browser.sh');

my($unzip) = grep { -x $_ } map { $_."/unzip" } split(/:/mx, $ENV{'PATH'} // '');
plan skip_all => 'unzip is required for this test' unless $unzip;

ok(-x $installer, "installer is executable");

my $tmp = tempdir(CLEANUP => 1);
mkdir("$tmp/$_") for qw/script stubs tools home/;
copy($installer, "$tmp/script/install_browser.sh") or die("copy failed: $!");
chmod(0755, "$tmp/script/install_browser.sh");

# does the same as the real wrapper, as far as the installer can see
_script("$tmp/script/html2pdf.sh", <<'EOT');
echo "html2pdf.sh $* THRUK_BROWSER=$THRUK_BROWSER" >> "$FAKE_LOG"
if [ "$1" = "--find-browser" ]; then
    if [ -n "$THRUK_BROWSER" ]; then
        if [ -x "$THRUK_BROWSER" ] && [ -f "$THRUK_BROWSER" ]; then echo "$THRUK_BROWSER"; exit 0; fi
        echo "THRUK_BROWSER is set to $THRUK_BROWSER but this is not an executable file"; exit 1
    fi
    if [ -n "$FAKE_SYSTEM_BROWSER" ]; then echo "$FAKE_SYSTEM_BROWSER"; exit 0; fi
    echo "no usable chromium browser found, set THRUK_BROWSER or run install_browser.sh"; exit 1
fi
if [ "$1" = "--selftest" ]; then
    if [ -n "$FAKE_SELFTEST_FAIL" ]; then echo "rendering test failed: fake failure"; exit 1; fi
    echo "browser: ${FAKE_SELFTEST_BROWSER:-$THRUK_BROWSER}"
    echo "rendering test OK"
    exit 0
fi
exit 3
EOT
_script("$tmp/stubs/curl", <<'EOT');
echo "curl $*" >> "$FAKE_LOG"
[ -n "$FAKE_CURL_FAIL" ] && { echo "curl: (22) The requested URL returned error: 404" >&2; exit 22; }
out=""
while [ $# -gt 0 ]; do
    if [ "$1" = "-o" ]; then out=$2; fi
    shift
done
cp "$FAKE_ZIP" "$out"
EOT
_script("$tmp/stubs/ldd",   'echo "ldd $*" >> "$FAKE_LOG"; echo "	libc.so.6 => /lib64/libc.so.6 (0x00007f0000000000)"; [ -n "$FAKE_LDD_MISSING" ] && echo "	$FAKE_LDD_MISSING => not found"; exit 0');
_script("$tmp/stubs/uname", 'echo "${FAKE_ARCH:-x86_64}"');

# the tools the installer needs besides bash, without unzip
for my $tool (qw/dirname mkdir mktemp rm mv grep sed head chmod cp cat/) {
    my($path) = grep { -x $_ } map { $_."/".$tool } split(/:/mx, $ENV{'PATH'});
    die("tool $tool not found") unless $path;
    symlink($path, "$tmp/tools/$tool") or die("symlink failed: $!");
}
symlink($unzip, "$tmp/stubs/unzip") or die("symlink failed: $!");

# archive with a fake browser
my $zipfile = "$tmp/browser.zip";
my $fake_browser = "#!/bin/bash\necho fake browser\n";
zip(\$fake_browser => $zipfile, Name => 'chrome-headless-shell-linux64/chrome-headless-shell', ExtAttr => 0100755 << 16)
    or die("zip failed: $ZipError");

my $default_version = '147.0.7727.117';
my $system_browser = "$tmp/system-chromium";
_script($system_browser, 'echo fake system browser');

my $log = "$tmp/calls.log";
sub _install {
    my($args, %env) = @_;
    unlink($log);
    local %ENV = (
        PATH      => "$tmp/stubs:$tmp/tools",
        HOME      => "$tmp/home",
        FAKE_LOG  => $log,
        FAKE_ZIP  => $zipfile,
        %env,
    );
    open(my $ph, '-|', "/bin/bash", "-c", 'exec "$0" "$@" 2>&1', "$tmp/script/install_browser.sh", @{$args}) or die("cannot run installer: $!");
    local $/ = undef;
    my $out = <$ph> // '';
    close($ph);
    my $rc = $? >> 8;
    my $calls = '';
    if(open(my $fh, '<', $log)) { $calls = <$fh> // ''; close($fh); }
    return($rc, $out, $calls);
}
sub _staging_left {
    my($dest) = @_;
    my @left = glob("$dest/.staging.*");
    return(scalar @left);
}

###########################################################
# a browser outside the target folder exists: nothing is downloaded
{
    my $dest = "$tmp/dest1";
    my($rc, $out, $calls) = _install([$dest], FAKE_SYSTEM_BROWSER => $system_browser);
    is($rc, 0, "system browser: exit code 0") or diag($out);
    unlike($calls, qr/^curl/mx, "system browser: nothing downloaded");
    like($calls, qr/^html2pdf\.sh\ --selftest\ THRUK_BROWSER=\Q$system_browser\E$/mx, "system browser: rendering test with this browser");
    like($out, qr/rendering\ test\ OK/mx, "system browser: rendering test shown");
    ok(!-e "$dest/chrome-headless-shell", "system browser: nothing installed");
}

###########################################################
# other architecture
{
    my $dest = "$tmp/dest2";
    my($rc, $out, $calls) = _install([$dest], FAKE_ARCH => 'aarch64');
    isnt($rc, 0, "aarch64: exit code not 0");
    unlike($calls, qr/^curl/mx, "aarch64: nothing downloaded");
    like($out, qr/aarch64/mx, "aarch64: message names the architecture");
    like($out, qr/chromium\ package/mx, "aarch64: message names the chromium package");
}

###########################################################
# download, default version, custom folder
{
    my $dest = "$tmp/dest3";
    my($rc, $out, $calls) = _install([$dest]);
    is($rc, 0, "install: exit code 0") or diag($out);
    like($calls, qr|^curl\ .*https://storage\.googleapis\.com/chrome-for-testing-public/\Q$default_version\E/linux64/chrome-headless-shell-linux64\.zip$|mx, "install: default version in url");
    ok(-x "$dest/chrome-headless-shell/chrome-headless-shell", "install: browser is in the folder");
    like($calls, qr|^ldd\ \Q$dest\E/\.staging\.\w+/chrome-headless-shell-linux64/chrome-headless-shell$|mx, "install: libraries of the downloaded browser checked");
    like($calls, qr|^html2pdf\.sh\ --selftest\ THRUK_BROWSER=\Q$dest\E/\.staging\.\w+/chrome-headless-shell-linux64/chrome-headless-shell$|mx, "install: rendering test with the downloaded browser");
    like($out, qr/^THRUK_BROWSER=\Q$dest\E\/chrome-headless-shell\/chrome-headless-shell$/mx, "install: line for thruk.env");
    like($out, qr|/etc/thruk/thruk\.env|mx, "install: names thruk.env");
    like($out, qr/successfully\ installed/mx, "install: success message");
    is(_staging_left($dest), 0, "install: staging folder removed");

    # version as argument
    ($rc, $out, $calls) = _install([$dest, '120.0.6099.109']);
    is($rc, 0, "install with version: exit code 0") or diag($out);
    like($calls, qr|^curl\ .*chrome-for-testing-public/120\.0\.6099\.109/linux64/|mx, "install with version: version in url");
    unlike($calls, qr/\Q$default_version\E/mx, "install with version: default version not used");
    ok(-x "$dest/chrome-headless-shell/chrome-headless-shell", "install with version: browser is in the folder");
    ok(!-e "$dest/chrome-headless-shell.old", "install with version: old installation removed");
    is(_staging_left($dest), 0, "install with version: staging folder removed");

    # failures leave the existing installation alone
    open(my $fh, '>', "$dest/chrome-headless-shell/marker") or die("cannot write marker: $!");
    close($fh);

    ($rc, $out, $calls) = _install([$dest], FAKE_CURL_FAIL => 1);
    isnt($rc, 0, "download fails: exit code not 0");
    like($out, qr|download\ failed:\ https://storage\.googleapis\.com/chrome-for-testing-public/\Q$default_version\E/linux64/chrome-headless-shell-linux64\.zip|mx, "download fails: url in message");
    ok(-e "$dest/chrome-headless-shell/marker", "download fails: existing installation unchanged");
    is(_staging_left($dest), 0, "download fails: staging folder removed");

    ($rc, $out, $calls) = _install([$dest], FAKE_SELFTEST_FAIL => 1);
    isnt($rc, 0, "rendering test fails: exit code not 0");
    like($out, qr/rendering\ test\ failed:\ fake\ failure/mx, "rendering test fails: output of the test shown");
    ok(-e "$dest/chrome-headless-shell/marker", "rendering test fails: existing installation unchanged");
    is(_staging_left($dest), 0, "rendering test fails: staging folder removed");

    ($rc, $out, $calls) = _install([$dest], FAKE_SELFTEST_BROWSER => $system_browser);
    isnt($rc, 0, "rendering test uses another browser: exit code not 0");
    like($out, qr/rendering\ test\ used\ \Q$system_browser\E\ instead\ of/mx, "rendering test uses another browser: message");
    like($out, qr/rc\ files/mx, "rendering test uses another browser: message names the rc files");
    ok(-e "$dest/chrome-headless-shell/marker", "rendering test uses another browser: existing installation unchanged");

    ($rc, $out, $calls) = _install([$dest], FAKE_LDD_MISSING => 'libfoo.so');
    isnt($rc, 0, "missing library: exit code not 0");
    like($out, qr/libfoo\.so\ =>\ not\ found/mx, "missing library: named");
    like($out, qr/^\s+(dnf|yum|zypper|apt-get)\ install\ \S+|package\ manager/mx, "missing library: install command");
    unlike($calls, qr/--selftest/mx, "missing library: no rendering test");
    ok(-e "$dest/chrome-headless-shell/marker", "missing library: existing installation unchanged");

    # the installed browser is found by the lookup rule now: it gets replaced
    ($rc, $out, $calls) = _install([$dest], THRUK_BROWSER => "$dest/chrome-headless-shell/chrome-headless-shell");
    is($rc, 0, "browser inside target folder: exit code 0") or diag($out);
    like($calls, qr/^curl/mx, "browser inside target folder: downloaded again");
    ok(!-e "$dest/chrome-headless-shell/marker", "browser inside target folder: installation replaced");
}

###########################################################
# unusable setting
{
    my $dest = "$tmp/dest4";
    my($rc, $out, $calls) = _install([$dest], THRUK_BROWSER => "$tmp/missing-browser");
    isnt($rc, 0, "unusable setting: exit code not 0");
    like($out, qr/THRUK_BROWSER\ is\ set\ to\ \Q$tmp\E\/missing-browser/mx, "unusable setting: message names setting and value");
    unlike($calls, qr/^curl/mx, "unusable setting: nothing downloaded");
}

###########################################################
# no unzip
{
    my $dest = "$tmp/dest5";
    unlink("$tmp/stubs/unzip");
    my($rc, $out, $calls) = _install([$dest]);
    isnt($rc, 0, "no unzip: exit code not 0");
    like($out, qr/please\ install\ the\ package:\ unzip/mx, "no unzip: message names the package");
    unlike($calls, qr/^curl/mx, "no unzip: nothing downloaded");
}

###########################################################
# no permission
SKIP: {
    skip("root can write everywhere", 2) if $> == 0;
    mkdir("$tmp/readonly");
    chmod(0555, "$tmp/readonly");
    symlink($unzip, "$tmp/stubs/unzip");
    my($rc, $out, $calls) = _install(["$tmp/readonly/browser"]);
    isnt($rc, 0, "no permission: exit code not 0");
    like($out, qr/no\ permission\ to\ write\ into\ \Q$tmp\E\/readonly\/browser/mx, "no permission: message");
    chmod(0755, "$tmp/readonly");
}

done_testing();

###########################################################
sub _script {
    my($file, $content) = @_;
    open(my $fh, '>', $file) or die("cannot write $file: $!");
    print $fh "#!/bin/bash\n", $content, "\n";
    close($fh);
    chmod(0755, $file);
    return;
}

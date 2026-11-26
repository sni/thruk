use warnings;
use strict;
use Cwd qw/abs_path/;
use File::Temp qw/tempdir/;
use Test::More;

# the browser lookup rule of script/render_url.pl. Everything it looks at is
# replaced by a temp folder, so nothing installed on this host has any influence.

my $script = abs_path('script/render_url.pl');
ok(-f $script, "renderer exists");
require $script;

my $tmp = tempdir(CLEANUP => 1);
sub _exe {
    my($file, $mode) = @_;
    my $dir = $file;
    $dir =~ s|/[^/]+$||mx;
    system("mkdir", "-p", $dir);
    open(my $fh, '>', $file) or die("cannot write $file: $!");
    print $fh "#!/bin/sh\nexit 0\n";
    close($fh);
    chmod($mode // 0755, $file);
    return $file;
}
# options which find nothing at all
sub _in {
    my(%over) = @_;
    return({
        setting   => undef,
        installed => "$tmp/none/chrome-headless-shell",
        dirs      => ["$tmp/none/bin"],
        path      => "$tmp/none/path",
        names     => [qw/chromium chromium-browser/],
        %over,
    });
}

my $setting   = _exe("$tmp/setting/mybrowser");
my $installed = _exe("$tmp/installed/chrome-headless-shell");
my $sysdir    = "$tmp/usr/bin";
my $pathdir   = "$tmp/path/bin";
_exe("$sysdir/chromium-browser");
_exe("$pathdir/chromium");
_exe("$tmp/usr/local/bin/chromium");

###########################################################
# nothing found
{
    my($exe, $err) = find_browser(_in());
    ok(!defined $exe, "nothing installed: no browser");
    like($err, qr/^no\ usable\ chromium\ browser\ found,\ set\ THRUK_BROWSER\ or\ run\ install_browser\.sh/mx, "nothing installed: message");
    ok(index($err, 'https://www.thruk.org/documentation/faq.html#chromium') > 0, "nothing installed: message names the faq");
}

###########################################################
# every step wins over the later ones
{
    my($exe, $err) = find_browser(_in(setting => $setting, installed => $installed, dirs => [$sysdir], path => $pathdir));
    is($exe, $setting, "setting wins over installer browser, system folders and PATH");
    is($err, undef, "setting: no message");

    ($exe, $err) = find_browser(_in(installed => $installed, dirs => [$sysdir], path => $pathdir));
    is($exe, $installed, "installer browser wins over system folders and PATH");

    ($exe, $err) = find_browser(_in(dirs => [$sysdir], path => $pathdir));
    is($exe, "$sysdir/chromium-browser", "system folder wins over PATH");

    ($exe, $err) = find_browser(_in(path => "$tmp/none/path:$pathdir"));
    is($exe, "$pathdir/chromium", "PATH is used last");

    ($exe, $err) = find_browser(_in(dirs => ["$tmp/none/bin", $sysdir, "$tmp/usr/local/bin"]));
    is($exe, "$sysdir/chromium-browser", "first folder with a browser wins");

    ($exe, $err) = find_browser(_in(dirs => [$sysdir], names => [qw/google-chrome chromium-browser chromium/]));
    is($exe, "$sysdir/chromium-browser", "only the given names are used");

    ($exe, $err) = find_browser(_in(setting => '', dirs => [$sysdir]));
    is($exe, "$sysdir/chromium-browser", "empty setting counts as not set");

    ($exe, $err) = find_browser(_in(path => "relative/bin::$pathdir"));
    is($exe, "$pathdir/chromium", "relative and empty PATH entries are skipped");
}

###########################################################
# unusable setting: failure which names the setting, no fallback
{
    my $noexec = _exe("$tmp/setting/noexec", 0644);
    for my $case (["$tmp/setting/missing", "missing file"], ["$tmp/setting", "directory"], ["setting/mybrowser", "relative path"], [$noexec, "file which is not executable"]) {
        my($value, $name) = @{$case};
        my($exe, $err) = find_browser(_in(setting => $value, installed => $installed, dirs => [$sysdir], path => $pathdir));
        ok(!defined $exe, "setting is a $name: no browser, no fallback");
        is($err, "THRUK_BROWSER is set to ".$value." but this is not an executable file", "setting is a $name: message names setting and value");
    }
}

###########################################################
# the variable of the old renderer has no effect
{
    my $old = uc("pup")."PETEER_EXECUTABLE_PATH"; # do not write the old name here, see the remnants test in t/092-*-remnants.t
    local $ENV{$old} = $setting;
    local $ENV{'THRUK_BROWSER'};
    delete $ENV{'THRUK_BROWSER'};
    my($exe, $err) = find_browser({ installed => "$tmp/none/x", dirs => ["$tmp/none/bin"], path => "$tmp/none/path" });
    ok(!defined $exe, "variable of the old renderer is not used");
    like($err, qr/^no\ usable\ chromium\ browser\ found/mx, "variable of the old renderer: nothing found");
}

###########################################################
# defaults come from the environment
{
    local $ENV{'THRUK_BROWSER'} = $setting;
    my($exe) = find_browser();
    is($exe, $setting, "THRUK_BROWSER is used by default");

    local $ENV{'THRUK_BROWSER'} = "$tmp/setting/missing";
    my($exe2, $err) = find_browser();
    ok(!defined $exe2, "unusable THRUK_BROWSER: no browser");
    like($err, qr/^THRUK_BROWSER\ is\ set\ to\ \Q$tmp\E\/setting\/missing\ /mx, "unusable THRUK_BROWSER: message");
}

###########################################################
# call form --find-browser
{
    local $ENV{'THRUK_BROWSER'} = $setting;
    my $out = _cmd($^X, $script, '--find-browser');
    is($out->[0], 0, "--find-browser: exit code 0");
    is($out->[1], $setting."\n", "--find-browser: prints the path");

    local $ENV{'THRUK_BROWSER'} = "$tmp/setting/missing";
    $out = _cmd($^X, $script, '--find-browser');
    is($out->[0], 1, "--find-browser with unusable setting: exit code 1");
    is($out->[1], "THRUK_BROWSER is set to $tmp/setting/missing but this is not an executable file\n", "--find-browser with unusable setting: message");
}

sub _cmd {
    my(@cmd) = @_;
    open(my $ph, '-|', @cmd) or die("cannot run ".join(" ", @cmd).": $!");
    local $/ = undef;
    my $out = <$ph> // '';
    close($ph);
    return([$? >> 8, $out]);
}

done_testing();

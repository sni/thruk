use warnings;
use strict;
use Test::More;

# housekeeping removes temp folders of the browser which are older than two
# hours, those of the current renderer and those the old renderer left behind.

BEGIN {
    plan skip_all => 'backends required' if(!-s 'thruk_local.conf' and !defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'});
    plan skip_all => 'internal test only' if defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'};
}

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

use_ok('Thruk::Utils::CLI::Maintenance');

my $c        = TestUtils::get_c();
my $tmp_path = $c->config->{'tmp_path'};
$tmp_path    =~ s|/+$||mx;
ok(-d $tmp_path, "tmp_path exists: ".$tmp_path);

# the name of the old renderer is put together here, so this file does not contain it, see the remnants test in t/092-*-remnants.t
my $old_name = "pup"."peteer";
my $id       = "t".$$;
my @old = (
    "/tmp/thruk_browser_".$id."old",
    $tmp_path."/thruk_browser_".$id."old",
    "/tmp/".$old_name."_dev_chrome_profile-".$id,
    "/tmp/org.chromium.Chromium.".$id,
    "/tmp/".$old_name.".cache.".$id,
);
my @new = (
    "/tmp/thruk_browser_".$id."new",
    $tmp_path."/thruk_browser_".$id."new",
    "/tmp/".$old_name."_dev_chrome_profile-".$id."new",
);
my @other = ("/tmp/thruk_other_".$id);
# a name with a shell command, other users can create such folders in /tmp
my $marker = "thruk_pwned_".$id;
push @old, "/tmp/thruk_browser_".$id."x;touch ".$marker;
# a symlink must not be followed, the folder it points to stays
my $target  = "/tmp/thruk_target_".$id;
my $link    = "/tmp/thruk_browser_".$id."link";
END {
    for my $dir (@old, @new, @other) {
        next unless($dir && -d $dir);
        unlink($dir."/file");
        rmdir($dir);
    }
    unlink($link, $marker);
    if(-d $target) { unlink($target."/file"); rmdir($target); }
}

my $three_hours_ago = time() - 3*3600;
for my $dir (@old, @new, @other) {
    mkdir($dir) or die("cannot create $dir: $!");
    open(my $fh, '>', $dir."/file") or die("cannot write $dir/file: $!");
    close($fh);
}
for my $dir (@old, @other) {
    utime($three_hours_ago, $three_hours_ago, $dir) or die("cannot change time of $dir: $!");
}
mkdir($target) or die("cannot create $target: $!");
open(my $tfh, '>', $target."/file") or die("cannot write $target/file: $!");
close($tfh);
utime($three_hours_ago, $three_hours_ago, $target);
symlink($target, $link) or die("cannot create $link: $!");

my($total, $removed) = Thruk::Utils::CLI::Maintenance::cleanup_browser_folders($c, 1);
ok($total   >= scalar(@old) + scalar(@new), "found at least the folders of this test (total: $total)");
ok($removed >= scalar(@old), "removed at least the old folders of this test (removed: $removed)");
for my $dir (@old) {
    ok(!-e $dir, "old folder has been removed: ".$dir);
}
for my $dir (@new) {
    ok(-d $dir, "folder younger than two hours is kept: ".$dir);
}
for my $dir (@other) {
    ok(-d $dir, "other folder is kept: ".$dir);
}
ok(!-e $marker, "shell command in a folder name is not executed");
ok(-l $link, "symlink is not removed: ".$link);
ok(-f $target."/file", "folder behind a symlink is kept: ".$target);

done_testing();

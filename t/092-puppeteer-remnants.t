use warnings;
use strict;
use Test::More;

# puppeteer has been replaced by direct control of the chromium browser. The
# name may only remain at the places listed here, so nothing in code, tests,
# packaging or documentation refers to the old renderer by accident.

plan skip_all => 'Author test. Set $ENV{TEST_AUTHOR} to a true value to run.' unless $ENV{TEST_AUTHOR};
plan skip_all => 'git repository required' unless -e '.git';

# the package installation tells where the old folder is
my $package_note = qr/^\s+\[\ !\ -d\ \/var\/lib\/thruk\/puppeteer\ \]\ \|\|\ echo\ "The\ folder\ \/var\/lib\/thruk\/puppeteer\ is\ not\ used\ anymore\ and\ can\ be\ removed\."$/mx;

# path => list of patterns, every line of that file which contains the name has to match one of them
my $allowed = {
    # the entry of the release which replaced it. Entries of earlier releases are skipped below.
    'Changes' => [
        qr/^\s+-\ replace\ puppeteer\ by\ direct\ control\ of\ the\ chromium\ browser/mx,
        qr/^\s+-\ PUPPETEER_\*\ settings\ are\ ignored,\ use\ THRUK_BROWSER/mx,
        qr/^\s+The\ folder\ \/var\/lib\/thruk\/puppeteer\ is\ not\ used\ anymore/mx,
    ],
    # housekeeping removes the temp folders of the old renderer: one comment and the folder patterns
    'lib/Thruk/Utils/CLI/Maintenance.pm' => [
        qr/^\s+\#\ folders\ left\ by\ puppeteer,/mx,
        qr/^\s+push\ \@patterns,\ "\/tmp\/puppeteer_dev_chrome_profile-\*",\ "\/tmp\/org\.chromium\.Chromium\.\*",\ "\/tmp\/puppeteer\.cache\.\*",\ \$tmp_path\."\/puppeteer\.cache";$/mx,
    ],
    # the "replaced by" entry, old links to faq.html#puppeteer keep working
    'docs/documentation/faq.md' => [
        qr/^\#\#\#\ puppeteer\ \{\#puppeteer\}$/mx,
        qr/^Puppeteer\ is\ no\ longer\ used,\ it\ has\ been\ replaced\ by\ a\ \[chromium\]\(\#chromium\)/mx,
        qr/^NodeJS\ and\ npm\ are\ not\ required\ anymore\.\ `PUPPETEER_\*`\ settings\ are\ ignored/mx,
        qr/^The\ folder\ \/var\/lib\/thruk\/puppeteer\ is\ not\ used\ anymore/mx,
    ],
    'debian/thruk-plugin-reporting.postinst' => [
        $package_note,
    ],
    'support/thruk.spec' => [
        $package_note,
    ],
    # this test and its MANIFEST entry
    't/092-puppeteer-remnants.t' => [ qr/./mx ],
    'MANIFEST' => [ qr/^t\/092-puppeteer-remnants\.t$/mx ],
};

###########################################################
# file contents
my($rc, @files) = _git('grep', '-il', 'puppeteer');
ok($rc <= 1, "git grep worked (exit code $rc)") or BAIL_OUT("git grep failed: ".join("", @files));
chomp(@files);
ok(scalar @files > 0, "git grep found the known places");
for my $file (@files) {
    next if $file =~ m|^specs/|mx; # not shipped
    my $patterns = $allowed->{$file};
    if(!$patterns) {
        fail("$file must not mention puppeteer");
        next;
    }
    open(my $fh, '<', $file) or die("cannot read $file: $!");
    my($nr, $bad, $old_releases) = (0, 0, 0);
    while(my $line = <$fh>) {
        $nr++;
        chomp($line);
        # in Changes everything below the first release header belongs to earlier releases
        $old_releases = 1 if($file eq 'Changes' && $line =~ m/^\d+\.\d+\s/mx);
        next if $old_releases;
        next unless $line =~ m/puppeteer/mxi;
        next if scalar grep { $line =~ $_ } @{$patterns};
        fail("$file:$nr mentions puppeteer: ".$line);
        $bad++;
    }
    close($fh);
    ok(!$bad, "$file mentions puppeteer only at the permitted places");
}
for my $file (sort keys %{$allowed}) {
    ok(scalar(grep { $_ eq $file } @files), "$file is still one of the permitted places");
}

###########################################################
# file names
($rc, @files) = _git('ls-files');
is($rc, 0, "git ls-files worked");
chomp(@files);
for my $file (grep { m/puppeteer/mxi } @files) {
    next if $file =~ m|^specs/|mx;
    is($file, 't/092-puppeteer-remnants.t', "file name contains puppeteer: ".$file);
}

done_testing();

###########################################################
sub _git {
    my(@args) = @_;
    # tests run as another user than the owner of the checkout (CI, OMD)
    open(my $ph, '-|', 'git', '-c', 'safe.directory=*', @args) or die("cannot run git: $!");
    my @out = <$ph>;
    close($ph);
    return($? >> 8, @out);
}

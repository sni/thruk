use warnings;
use strict;
use File::Temp qw/tempdir/;
use Test::More;

# the reports page shows its "no browser" warning exactly when the wrapper
# script/html2pdf.sh --find-browser finds none (standalone installations only).
#
# The page has to be served in-process, so the controller runs in the
# environment this test sets up.
#
# The other states of the lookup rule (nothing installed, system browser only,
# installer browser only) are states of the rule itself, see t/105-render-lookup.t.

BEGIN {
    plan skip_all => 'standalone only, the detection is not run in OMD' if $ENV{'OMD_ROOT'};
    plan skip_all => 'backends required' if(!-s 'thruk_local.conf' and !defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'});
    plan skip_all => 'internal test only' if defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'};
    if(!-e 'plugins/plugins-enabled/reports2') {
        if($ENV{'THRUK_TEST_BROWSER_REQUIRED'}) {
            plan tests => 1;
            fail('reports2 plugin is not enabled, but THRUK_TEST_BROWSER_REQUIRED is set');
            exit;
        }
        plan skip_all => 'reports2 plugin is not enabled';
    }
}

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

my $tmp = tempdir(CLEANUP => 1);
my $fake = "$tmp/fake-browser";
{
    open(my $fh, '>', $fake) or die("cannot write $fake: $!");
    print $fh "#!/bin/sh\nexit 0\n";
    close($fh);
    chmod(0755, $fake);
}
my $missing = "$tmp/missing-browser";
for my $name (qw/home_ok home_missing home_empty/) {
    mkdir("$tmp/$name");
}
_write("$tmp/home_ok/.thruk",      "THRUK_BROWSER=$fake\n");
_write("$tmp/home_missing/.thruk", "THRUK_BROWSER=$missing\n");

my $c = TestUtils::get_c();
# folder of the old renderer, it must not count as a browser. The name is put
# together here, so this file does not contain it, see the remnants test in t/092-*-remnants.t
my $leftover = $c->config->{'var_path'}."/pup"."peteer";
my $created_leftover = 0;
END {
    rmdir($leftover) if $created_leftover;
}

my $warning = 'No browser for PDF creation found, no pdfs can be generated';
my $link    = 'href="https://www.thruk.org/documentation/faq.html\#chromium"';

my @states = (
    # name                                       environment                                             browser expected
    ['setting points to an executable',          { THRUK_BROWSER => $fake,    HOME => "$tmp/home_empty" },   1],
    ['setting points to a missing file',         { THRUK_BROWSER => $missing, HOME => "$tmp/home_empty" },   0],
    ['rc file sets an executable',               { THRUK_BROWSER => undef,    HOME => "$tmp/home_ok" },      1],
    ['rc file sets a missing file',              { THRUK_BROWSER => undef,    HOME => "$tmp/home_missing" }, 0],
    ['leftovers of the old renderer only',       { THRUK_BROWSER => $missing, HOME => "$tmp/home_empty" },   0, 'leftover'],
);

for my $state (@states) {
    my($name, $env, $expected, $leftovers) = @{$state};
    if($leftovers && !-d $leftover) {
        mkdir($leftover) or die("cannot create $leftover: $!");
        $created_leftover = 1;
    }

    # wrapper and page see the same environment
    local %ENV = %ENV;
    for my $key (sort keys %{$env}) {
        if(defined $env->{$key}) { $ENV{$key} = $env->{$key}; } else { delete $ENV{$key}; }
    }

    my $rc = system('./script/html2pdf.sh --find-browser >/dev/null 2>&1') >> 8;
    is($rc == 0 ? 1 : 0, $expected, "$name: wrapper ".($expected ? "finds a browser" : "finds no browser"));

    # must be the normal reports list, a login or error page would not show the warning either
    my $page = TestUtils::test_page(
        url  => '/thruk/cgi-bin/reports2.cgi',
        code => 200,
        like => ['create\ new\ report', 'id="reportsTable"'],
    );
    my $content = $page->{'content'} // '';
    my $has_warning = scalar($content =~ m/\Q$warning\E/mx) ? 1 : 0;
    my $has_link    = scalar($content =~ m/$link/mx) ? 1 : 0;
    if($rc != 0) {
        is($has_warning, 1, "$name: wrapper found no browser, page shows the warning");
        is($has_link, 1, "$name: warning links to the faq");
    } else {
        is($has_warning, 0, "$name: wrapper found a browser, page shows no warning");
        is($has_link, 0, "$name: no link to the faq section");
    }
}

done_testing();

###########################################################
sub _write {
    my($file, $content) = @_;
    open(my $fh, '>', $file) or die("cannot write $file: $!");
    print $fh $content;
    close($fh);
    return;
}

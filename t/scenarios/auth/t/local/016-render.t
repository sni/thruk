use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

# rendering with the browser of the OMD package against the real Thruk and Grafana

###########################################################
# verify that we use the correct thruk binary
TestUtils::test_command({
    cmd  => '/bin/bash -c "type thruk"',
    like => ['/\/thruk\/script\/thruk/'],
}) or BAIL_OUT("wrong thruk path");

###########################################################
# rendering test as site user
TestUtils::test_command({
    cmd  => '/thruk/script/html2pdf.sh --selftest',
    like => ['/browser: \//', '/sandbox: (on|off)/', '/rendering test OK/'],
});

use lib 'share/thruk/lib/';

my $c = TestUtils->get_c();
$c->authenticate('username' => 'omdadmin', 'auth_src' => 'test');
require Thruk::Utils;
my($sessionid) = Thruk::Utils::get_fake_session($c, undef, "omdadmin");
ok($sessionid, "got session id");

###########################################################
# pdf from a thruk url with session, http and https with the untrusted site certificate
# without user namespaces (ex.: el7) the renderer says once per run that it retried without sandbox
my $no_sandbox_note = '(browser did not start with sandbox .*, sandbox is off for this run\n)?';
for my $base ('http://127.0.0.1/demo', 'https://127.0.0.1/demo') {
    unlink('tmp/tac.pdf');
    TestUtils::test_command({
        cmd  => '/thruk/script/html2pdf.sh "'.$base.'/thruk/cgi-bin/tac.cgi" tmp/tac.pdf',
        like => ['/^'.$no_sandbox_note.'$/'],
        env  => { 'THRUK_SESSION_ID' => $sessionid },
    });
    TestUtils::test_command({
        cmd  => '/usr/bin/env pdfinfo tmp/tac.pdf',
        like => ['/Page size:\s+1200 x 900 pts/'],
    });
    TestUtils::test_command({
        cmd    => '/usr/bin/env pdftotext tmp/tac.pdf -',
        like   => ['/Tactical Monitoring Overview/', '/omdadmin/'],
        unlike => ['/Login/'],
    });
}

###########################################################
# grafana panel by id and by title
my $start = time() - 1800;
my $end   = time();
for my $panel ('1', 'pl') {
    unlink('tmp/panel.png');
    TestUtils::test_command({
        cmd     => '/usr/bin/env /thruk/script/grafana_export.sh 800 400 '.$start.' '.$end.' "http://127.0.0.1/demo/grafana/dashboard-solo/script/histou.js?host=test&service=Ping&panelId='.$panel.'" tmp/panel.png',
        like    => ['/chart panel found/'],
        env     => { 'THRUK_SESSION_ID' => $sessionid },
        waitfor => 'chart\ panel\ found',
        maxwait => 120,
    });
    TestUtils::test_command({
        cmd  => '/usr/bin/env file tmp/panel.png',
        # older chrome (121 on el7) writes an alpha channel
        like => ['/PNG image data, 800 x 400, 8-bit\/color RGBA?, non-interlaced/'],
    });
}

###########################################################
# reports page: under OMD the browser comes with the package, no warning
TestUtils::test_command({
    cmd    => '/usr/bin/env thruk "reports2.cgi"',
    like   => ['/create new report/'],
    unlike => ['/No browser for PDF creation found/'],
});

done_testing();

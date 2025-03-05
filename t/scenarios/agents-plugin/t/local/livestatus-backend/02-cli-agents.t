use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

$ENV{'THRUK_TEST_AUTH'}               = 'omdadmin:omd';
$ENV{'PLACK_TEST_EXTERNALSERVER_URI'} = 'http://127.0.0.1/demo';
plan tests => 147;

use_ok("Thruk::Utils::IO");

###########################################################
# test thruks script path
TestUtils::test_command({
    cmd  => '/bin/bash -c "type thruk"',
    like => ['/\/thruk\/script\/thruk/'],
}) or BAIL_OUT("wrong thruk path");

###########################################################
TestUtils::test_command({ cmd => '/usr/bin/env thruk agents -I host-ls --ip=127.0.0.1 --section=testsection', like => ['/agent inventory/', '/new\ \->\ on\ |\ agent\ version/'] });
TestUtils::test_command({ cmd => '/usr/bin/env thruk agents -I host-ls', like => ['/no\ new\ checks\ found\ for\ host\ host-ls/'] });
TestUtils::test_command({ cmd => '/usr/bin/env thruk agents -S host-ls', like => ['/agent inventory/'], errlike => ['/host\ host-ls\ has\ not\ yet\ been\ activated/'] });
TestUtils::test_command({ cmd => '/usr/bin/env omd check core', errlike => ['/Things\ look\ okay/'] });
TestUtils::test_command({ cmd => '/usr/bin/env thruk agents -R', like => ['/Reloading\ naemon\ configuration/'] });
TestUtils::test_command({ cmd => '/usr/bin/env thruk agents -l', like => ['/host-ls/', '/testsection/'], waitfor => 'testsection', diag => \&_diag });
TestUtils::test_command({ cmd => '/usr/bin/env thruk agents -I host-ls', like => ['/no\ new\ checks\ found\ for\ host\ host-ls/'] });
TestUtils::test_page( url => '/thruk/cgi-bin/status.cgi', like => ['agent inventory', 'agent version', 'net eth0'] );
TestUtils::test_page( url => '/thruk/cgi-bin/agents.cgi', like => ['host-ls'], follow => 1 );
TestUtils::test_command({ cmd => '/usr/bin/env thruk agents -l', like => ['/host-ls/'] });
TestUtils::test_command({ cmd => '/usr/bin/env grep -r testpattern123 etc/naemon/conf.d/agents/', like => ['/check_command/', '/host-ls/'] });

###########################################################
# clean up again
TestUtils::test_command({ cmd => '/usr/bin/env thruk agents -yD host-ls', like => ['/host\ host-ls\ removed\ successsfully/'] });
TestUtils::test_command({ cmd => '/usr/bin/env thruk agents -R', like => ['/Reloading\ naemon\ configuration/'] });
TestUtils::test_command({ cmd => '/usr/bin/env thruk agents -l', like => ['/no agents found/'], waitfor => 'no\ agents\ found', diag => \&_diag });
TestUtils::test_page( url => '/thruk/cgi-bin/agents.cgi', unlike => ['host-ls'] );

###########################################################
# add host
TestUtils::test_command({ cmd => '/usr/bin/env thruk agents -I localhost', like => ['/agent inventory/', '/new\ \->\ on\ |\ agent\ version/'] });
TestUtils::test_command({ cmd => '/usr/bin/env omd check core', errlike => ['/Things\ look\ okay/'] });
TestUtils::test_command({ cmd => '/usr/bin/env thruk agents -R', like => ['/Reloading\ naemon\ configuration/'] });
TestUtils::test_command({ cmd => '/usr/bin/env thruk agents -II ALL -n', like => ['/localhost:\ no\ changes\ made/'] });
TestUtils::test_command({ cmd => '/usr/bin/env thruk agents -II ALL', like => ['/localhost:\ no\ changes\ made/'] });
ok(Thruk::Utils::IO::write("etc/thruk/thruk_local.d/agents_extra.cfg", &_extra_config()), "wrote extra config");
TestUtils::test_command({ cmd => '/usr/bin/env thruk agents -II ALL -n', like => ['/^localhost:/', '/updated.*cpu/', '/updated.*memory/', '/dry\ run/'] });
TestUtils::test_command({ cmd => '/usr/bin/env thruk agents -II ALL -n -v',
    errlike => [
        '/\ localhost:/',
        '/updated.*cpu/',
        '/updated.*memory/',
        '/dry\ run/',
        '/\-\s+use\s+srv-pnp/',
        '/\+\s+use\s+srv-pnp,generic-thruk-agent-service,srv-perf/',
        '/\+\s+use\s+generic/',
        '/\+\s+first_notification_delay/',
    ],
    unlike => [
        '/disk\ \/test/',      # excluded by disable drivesize
        '/zombie\ processes/', # excluded by exclude block
    ],
    });
TestUtils::test_command({ cmd => '/usr/bin/env thruk agents -II ALL', like => ['/^localhost/', '/updated.*cpu/', '/to activate changes/'] });
ok(unlink("etc/thruk/thruk_local.d/agents_extra.cfg", "removed extra config"));
TestUtils::test_command({ cmd => '/usr/bin/env thruk agents -yD localhost', like => ['/host\ localhost\ removed\ successsfully/'] });
TestUtils::test_command({ cmd => '/usr/bin/env thruk agents -R', like => ['/Reloading\ naemon\ configuration/'] });

###########################################################

sub _diag {
    my($test) = @_;
    diag(`ls -la etc/naemon/conf.d/`);
    diag(`ls -la etc/naemon/conf.d/agents`);
    diag(`cat etc/naemon/conf.d/agents/testsection/*.cfg`);
    diag(`/usr/bin/env omd status`);
    diag(`ps -efl`);
    diag(`tail -200 var/log/naemon.log`);
}

###########################################################

sub _extra_config {
    my $cfg = <<EOT;
<Component Thruk::Agents>
  <snclient>
    <extra_service_opts>
        service = cpu
        use     = +srv-perf
    </extra_service_opts>

    <extra_service_opts>
        service = memory
        use     = !srv-pnp
        first_notification_delay = 30
    </extra_service_opts>
  </snclient>
</Component>
EOT
    return($cfg);
}

###########################################################

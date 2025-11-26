use warnings;
use strict;
use Cpanel::JSON::XS qw/decode_json/;
use Test::More;

use Thruk::Config 'noautoload';

BEGIN {
    plan skip_all => 'test skipped' if defined $ENV{'NO_DISABLED_PLUGINS_TEST'};

    plan tests => 22;
}

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

###########################################################
# test modules
if(defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'}) {
    unshift @INC, 'plugins/plugins-available/agents/lib';
}

use_ok 'Thruk::Base';
use_ok 'Thruk::Config';
use_ok 'Thruk::Controller::agents';
use_ok 'Thruk::Agents::SNClient';

###########################################################
my $c = TestUtils::get_c();
my $hostname = "localhost";
my $hostobj  = undef;
my $password = "password";
my $cli_opts = {};
my $section  = "testing";
my $mode     = "http";
my $options  = {};
my $tags     = ["prod", "test"];

###########################################################
# service check
{
    my $conf = <<EOT;
<Component Thruk::Agents>
  <snclient>
    <service>
      service  = snclient
      host     = ANY
      section  ~ test
      tags     = prod
    </service>
  </snclient>
</Component>
EOT

my $inv = <<EOT;
{ "inventory" : {
    "service" : [{
      "active" : "active",
      "age" : "55550",
      "cpu" : "3.2",
      "created" : "1741410012",
      "desc" : "SNClient+ Agent",
      "name" : "snclient",
      "pid" : "2393244",
      "preset" : "enabled",
      "rss" : "21319680",
      "service" : "snclient",
      "state" : "running",
      "tasks" : "28",
      "vms" : "1276743680"
    }]
  }
}
EOT

    my $xtr = Thruk::Config::parse_config_from_text($conf);
    $c->config->{'Thruk::Agents'} = $xtr->{'Thruk::Agents'};
    undef $Thruk::Agents::SNClient::conf;
    local $cli_opts->{'cached'} = decode_json($inv);
    my $checks = Thruk::Agents::SNClient::get_services_checks(undef, $c, $hostname, $hostobj, $password, $cli_opts, $section, $mode, $options, $tags);
    $checks = Thruk::Base::array2hash($checks, "id");
    is_deeply([sort keys %{$checks}], [
        '_host',
        'inventory',
        'svc',
        'svc.snclient',
        'version'
    ], "process checks found");
    is($checks->{'inventory'}->{'svc_conf'}->{'_WORKER'}, "local", "local inventory");

    ok($checks->{'svc.snclient'}, "service check found");
    is($checks->{'svc.snclient'}->{'name'},   "service snclient", "service: name");
    is($checks->{'svc.snclient'}->{'svc_conf'}->{'check_command'}, 'check_thruk_agent!$USER1$/check_nsc_web -t 35  -p \'$_HOSTAGENT_PASSWORD$\' -u \'http://$HOSTADDRESS$:$_HOSTAGENT_PORT$\' \'check_service\' service=\'snclient\'', "service: check_command");
}

###########################################################
# service multiple checks
{
    my $conf = <<EOT;
<Component Thruk::Agents>
  <snclient>
    <service>
      name     = service %s
      service  = s*
    </service>
  </snclient>
</Component>
EOT

my $inv = <<EOT;
{ "inventory" : {
    "service" : [{
      "active" : "active",
      "age" : "55550",
      "cpu" : "3.2",
      "created" : "1741410012",
      "desc" : "SNClient+ Agent",
      "name" : "snclient",
      "pid" : "2393244",
      "preset" : "enabled",
      "rss" : "21319680",
      "service" : "snclient",
      "state" : "running",
      "tasks" : "28",
      "vms" : "1276743680"
    },{
      "active" : "active",
      "age" : "55550",
      "cpu" : "3.2",
      "created" : "1741410012",
      "desc" : "some test services",
      "name" : "someservice",
      "pid" : "2393244",
      "preset" : "enabled",
      "rss" : "21319680",
      "service" : "someservice",
      "state" : "running",
      "tasks" : "28",
      "vms" : "1276743680"
    }]
  }
}
EOT

    my $xtr = Thruk::Config::parse_config_from_text($conf);
    $c->config->{'Thruk::Agents'} = $xtr->{'Thruk::Agents'};
    undef $Thruk::Agents::SNClient::conf;
    local $cli_opts->{'cached'} = decode_json($inv);
    my $checks = Thruk::Agents::SNClient::get_services_checks(undef, $c, $hostname, $hostobj, $password, $cli_opts, $section, $mode, $options, $tags);
    $checks = Thruk::Base::array2hash($checks, "id");
    is_deeply([sort keys %{$checks}], [
        '_host',
        'inventory',
        'svc',
        'svc.snclient',
        'svc.someservice',
        'version'
    ], "process checks found");
    is($checks->{'inventory'}->{'svc_conf'}->{'_WORKER'}, "local", "local inventory");

    ok($checks->{'svc.snclient'}, "service check found");
    is($checks->{'svc.snclient'}->{'name'}, "service snclient", "service: name");
    is($checks->{'svc.snclient'}->{'svc_conf'}->{'check_command'}, 'check_thruk_agent!$USER1$/check_nsc_web -t 35  -p \'$_HOSTAGENT_PASSWORD$\' -u \'http://$HOSTADDRESS$:$_HOSTAGENT_PORT$\' \'check_service\' service=\'snclient\'', "service: check_command");

    ok($checks->{'svc.someservice'}, "service check found");
    is($checks->{'svc.someservice'}->{'name'}, "service someservice", "service: name");
    is($checks->{'svc.someservice'}->{'svc_conf'}->{'check_command'}, 'check_thruk_agent!$USER1$/check_nsc_web -t 35  -p \'$_HOSTAGENT_PASSWORD$\' -u \'http://$HOSTADDRESS$:$_HOSTAGENT_PORT$\' \'check_service\' service=\'someservice\'', "service: check_command");
}

###########################################################
# service multiple combined checks
{
    my $conf = <<EOT;
<Component Thruk::Agents>
  <snclient>
    <service>
      name       = extra services
      service    = s*
      all_in_one = 1
    </service>
  </snclient>
</Component>
EOT

my $inv = <<EOT;
{ "inventory" : {
    "service" : [{
      "active" : "active",
      "age" : "55550",
      "cpu" : "3.2",
      "created" : "1741410012",
      "desc" : "SNClient+ Agent",
      "name" : "snclient",
      "pid" : "2393244",
      "preset" : "enabled",
      "rss" : "21319680",
      "service" : "snclient",
      "state" : "running",
      "tasks" : "28",
      "vms" : "1276743680"
    },{
      "active" : "active",
      "age" : "55550",
      "cpu" : "3.2",
      "created" : "1741410012",
      "desc" : "some test services",
      "name" : "someservice",
      "pid" : "2393244",
      "preset" : "enabled",
      "rss" : "21319680",
      "service" : "someservice",
      "state" : "running",
      "tasks" : "28",
      "vms" : "1276743680"
    }]
  }
}
EOT

    my $xtr = Thruk::Config::parse_config_from_text($conf);
    $c->config->{'Thruk::Agents'} = $xtr->{'Thruk::Agents'};
    undef $Thruk::Agents::SNClient::conf;
    local $cli_opts->{'cached'} = decode_json($inv);
    my $checks = Thruk::Agents::SNClient::get_services_checks(undef, $c, $hostname, $hostobj, $password, $cli_opts, $section, $mode, $options, $tags);
    $checks = Thruk::Base::array2hash($checks, "id");
    is_deeply([sort keys %{$checks}], [
        '_host',
        'inventory',
        'svc',
        'svc.extra_services',
        'version'
    ], "process checks found");
    is($checks->{'inventory'}->{'svc_conf'}->{'_WORKER'}, "local", "local inventory");

    ok($checks->{'svc.extra_services'}, "service check found");
    is($checks->{'svc.extra_services'}->{'name'}, "extra services", "service: name");
    is($checks->{'svc.extra_services'}->{'svc_conf'}->{'check_command'}, 'check_thruk_agent!$USER1$/check_nsc_web -t 35  -p \'$_HOSTAGENT_PASSWORD$\' -u \'http://$HOSTADDRESS$:$_HOSTAGENT_PORT$\' \'check_service\' "filter=name = \'s*\'"', "service: check_command");
}

###########################################################

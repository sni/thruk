use warnings;
use strict;
use Test::More;

use Thruk::Config 'noautoload';

BEGIN {
    plan skip_all => 'test skipped' if defined $ENV{'NO_DISABLED_PLUGINS_TEST'};

    plan tests => 14;
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

use_ok 'Thruk::Config';
use_ok 'Thruk::Controller::agents';
use_ok 'Thruk::Agents::SNClient';

###########################################################
my $c = TestUtils::get_c();

###########################################################
# ANY
{
    my $conf = <<EOT;
<Component Thruk::Agents>
  <snclient>
    <extra_host_opts>
      host    = ANY
      service = ANY
      section = ANY
      tags    = ANY
      first_notification_delay = 30
    </extra_host_opts>
  </snclient>
</Component>
EOT

    my $xtr = Thruk::Config::parse_config_from_text($conf);
    $c->config->{'Thruk::Agents'} = $xtr->{'Thruk::Agents'};

    my $opts = Thruk::Agents::SNClient::_get_extra_opts_hst($c, "localhost", "test", ["tag1"]);
    ok($opts->[0]->{'first_notification_delay'} == 30, "default extra opts parsed");

    $opts = Thruk::Agents::SNClient::_get_extra_opts_hst($c, "localhost", "", []);
    ok($opts->[0]->{'first_notification_delay'} == 30, "default extra opts parsed");
}

###########################################################
# string match
{
    my $conf = <<EOT;
<Component Thruk::Agents>
  <snclient>
    <extra_host_opts>
      host    = localhost
      service = ANY
      section = ANY
      tags    = ANY
      first_notification_delay = 30
    </extra_host_opts>
  </snclient>
</Component>
EOT

    my $xtr = Thruk::Config::parse_config_from_text($conf);
    $c->config->{'Thruk::Agents'} = $xtr->{'Thruk::Agents'};

    my $opts = Thruk::Agents::SNClient::_get_extra_opts_hst($c, "localhost", "test", ["tag1"]);
    ok($opts->[0]->{'first_notification_delay'} == 30, "string match");

    $opts = Thruk::Agents::SNClient::_get_extra_opts_hst($c, "localhos", "test", ["tag1"]);
    ok(scalar @{$opts} == 0, "string match II");

    $opts = Thruk::Agents::SNClient::_get_extra_opts_hst($c, "localhost2", "test", ["tag1"]);
    ok(scalar @{$opts} == 0, "string match III");
}

###########################################################
# wildcard match
{
    my $conf = <<EOT;
<Component Thruk::Agents>
  <snclient>
    <extra_host_opts>
      host    = local*
      service = ANY
      section = ANY
      tags    = ANY
      first_notification_delay = 30
    </extra_host_opts>
  </snclient>
</Component>
EOT

    my $xtr = Thruk::Config::parse_config_from_text($conf);
    $c->config->{'Thruk::Agents'} = $xtr->{'Thruk::Agents'};

    my $opts = Thruk::Agents::SNClient::_get_extra_opts_hst($c, "localhost", "test", ["tag1"]);
    ok($opts->[0]->{'first_notification_delay'} == 30, "wildcard match");

    $opts = Thruk::Agents::SNClient::_get_extra_opts_hst($c, "loca", "test", ["tag1"]);
    ok(scalar @{$opts} == 0, "wildcard match II");

    $opts = Thruk::Agents::SNClient::_get_extra_opts_hst($c, "localhost2", "test", ["tag1"]);
    ok($opts->[0]->{'first_notification_delay'} == 30, "wildcard match");
}

###########################################################
# wildcard match
{
    my $conf = <<EOT;
<Component Thruk::Agents>
  <snclient>
    <extra_host_opts>
      host    ~ ^local.*
      service = ANY
      section = ANY
      tags    = ANY
      first_notification_delay = 30
    </extra_host_opts>
  </snclient>
</Component>
EOT

    my $xtr = Thruk::Config::parse_config_from_text($conf);
    $c->config->{'Thruk::Agents'} = $xtr->{'Thruk::Agents'};

    my $opts = Thruk::Agents::SNClient::_get_extra_opts_hst($c, "localhost", "test", ["tag1"]);
    ok($opts->[0]->{'first_notification_delay'} == 30, "regexp match");

    $opts = Thruk::Agents::SNClient::_get_extra_opts_hst($c, "loca", "test", ["tag1"]);
    ok(scalar @{$opts} == 0, "regexp match II");

    $opts = Thruk::Agents::SNClient::_get_extra_opts_hst($c, "localhost2", "test", ["tag1"]);
    ok($opts->[0]->{'first_notification_delay'} == 30, "regexp match");
}

###########################################################

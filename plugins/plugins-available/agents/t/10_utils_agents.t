use warnings;
use strict;
use Test::More;
use Text::ParseWords qw/shellwords/;

use Thruk::Config 'noautoload';
use Thruk::Utils::IO ();

BEGIN {
    plan skip_all => 'test skipped' if defined $ENV{'NO_DISABLED_PLUGINS_TEST'};

    plan tests => 26;
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
subtest 'inventory values remain literal shell arguments' => sub {
    local $c->config->{'Thruk::Agents'} = {
        snclient => {
            service     => [{ service => '*' }],
            default_opt => [{ drivesize => q{show-all freespace-ignore-reserved=false "warn=used > 80"} }],
        },
    };
    local $Thruk::Agents::SNClient::conf;
    my $value = q{sample';printf token;# $(printf token) `printf token` " \ path!};
    my $quoted = q{'sample'\'';printf token;# $(printf token) `printf token` " \ path!'};
    is(Thruk::Agents::SNClient::_quote_shell_arg($value), $quoted, 'escape embedded single quote');
    for my $plain ('', 'eth0', 'two words', 'C:\\', q{a''b}, $value) {
        # shellwords misparses a trailing backslash inside single quotes.
        my($rc, $out) = Thruk::Utils::IO::cmd("printf '%s\\0' ".Thruk::Agents::SNClient::_quote_shell_arg($plain), {});
        is_deeply([$rc, $out], [0, $plain."\0"], 'shell quoting round trip');
    }
    for my $invalid ("a\0b", "a\rb", "a\nb") {
        eval { Thruk::Agents::SNClient::_quote_shell_arg($invalid); };
        like($@, qr/invalid control character/, 'reject configuration line breaks and NUL');
    }

    my $cached = { inventory => {
        scripts      => [$value],
        network      => [{ name => $value }],
        mount        => [{ mount => $value, options => $value, fstype => $value }],
        drive_io     => [{ drive => $value }],
        drivesize    => [{ drive => $value, drive_or_id => $value, fstype => 'ext4', mounted => 1, size_bytes => 1024 }],
        omd          => [{ site => $value, autostart => 1 }],
        temperature  => [{ name => $value }],
        service      => [{ name => $value }],
        kernel_stats => [{ name => $value, label => 'dummy' }],
        connections  => [{ inet => $value }],
        pagefile     => [{ name => $value }],
    }};
    my $checks = Thruk::Agents::SNClient::get_services_checks(
        undef, $c, 'dummy', undef, '', { cached => $cached }, '', 'https', {}, [],
    );
    my %expected = (
        $value              => [$value],
        check_network       => ["device=".$value],
        check_mount         => [map { $_.'='.$value } qw/fstype mount options/],
        check_drive_io      => ["drive=".$value],
        check_drivesize     => ["drive=".$value, 'show-all', 'freespace-ignore-reserved=false', 'warn=used > 80'],
        check_omd           => ["site=".$value],
        check_temperature   => ["sensor=".$value],
        check_service       => ["service=".$value],
        check_kernel_stats  => ["type=".$value],
        check_connections   => ["inet=".$value],
        check_pagefile      => ["filter=name='".$value."'"],
    );
    for my $chk (@{$checks}) {
        next if $chk->{'id'} eq 'svc'; # generic service check has no inventory argument
        next unless $chk->{'check'} && $expected{$chk->{'check'}};
        my $command = $chk->{'svc_conf'}->{'check_command'};
        my @words = shellwords($command);
        for my $arg (@{delete $expected{$chk->{'check'}}}) {
            ok(grep($_ eq $arg, @words), 'inventory argument preserved for '.$chk->{'id'});
        }
    }
    is_deeply(\%expected, {}, 'all affected inventory check types covered');
};

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
    undef $Thruk::Agents::SNClient::conf;

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
    undef $Thruk::Agents::SNClient::conf;

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
    undef $Thruk::Agents::SNClient::conf;

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
    undef $Thruk::Agents::SNClient::conf;

    my $opts = Thruk::Agents::SNClient::_get_extra_opts_hst($c, "localhost", "test", ["tag1"]);
    ok($opts->[0]->{'first_notification_delay'} == 30, "regexp match");

    $opts = Thruk::Agents::SNClient::_get_extra_opts_hst($c, "loca", "test", ["tag1"]);
    ok(scalar @{$opts} == 0, "regexp match II");

    $opts = Thruk::Agents::SNClient::_get_extra_opts_hst($c, "localhost2", "test", ["tag1"]);
    ok($opts->[0]->{'first_notification_delay'} == 30, "regexp match");
}

###########################################################
# excludes
{
    my $conf = <<EOT;
<Component Thruk::Agents>
  <snclient>
    <extra_host_opts>
      host    = ANY
      host    = !localhost
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
    undef $Thruk::Agents::SNClient::conf;

    my $opts = Thruk::Agents::SNClient::_get_extra_opts_hst($c, "localhost", "", []);
    ok(scalar @{$opts} == 0, "excludes match");

    $opts = Thruk::Agents::SNClient::_get_extra_opts_hst($c, "local", "", []);
    ok($opts->[0]->{'first_notification_delay'} == 30, "excludes match II");
}

###########################################################
# combined matches
{
    my $conf = <<EOT;
<Component Thruk::Agents>
  <snclient>
    <extra_host_opts>
      host    = ANY
      service = ANY
      section = ANY
      tags    = tag1 && tag2
      first_notification_delay = 30
    </extra_host_opts>
  </snclient>
</Component>
EOT

    my $xtr = Thruk::Config::parse_config_from_text($conf);
    $c->config->{'Thruk::Agents'} = $xtr->{'Thruk::Agents'};
    undef $Thruk::Agents::SNClient::conf;

    my $opts = Thruk::Agents::SNClient::_get_extra_opts_hst($c, "localhost", "", []);
    ok(scalar @{$opts} == 0, "combined match");

    $opts = Thruk::Agents::SNClient::_get_extra_opts_hst($c, "localhost", "", ["tag1"]);
    ok(scalar @{$opts} == 0, "combined match II");

    $opts = Thruk::Agents::SNClient::_get_extra_opts_hst($c, "localhost", "", ["tag2"]);
    ok(scalar @{$opts} == 0, "combined match III");

    $opts = Thruk::Agents::SNClient::_get_extra_opts_hst($c, "localhost", "", ["tag1", "tag2", "tag3"]);
    ok($opts->[0]->{'first_notification_delay'} == 30, "combined match IV");
}

###########################################################
# combined exclude matches
{
    my $conf = <<EOT;
<Component Thruk::Agents>
  <snclient>
    <extra_host_opts>
      host    = ANY
      service = ANY
      section = ANY
      tags    = tag1 && !tag2
      first_notification_delay = 30
    </extra_host_opts>
  </snclient>
</Component>
EOT

    my $xtr = Thruk::Config::parse_config_from_text($conf);
    $c->config->{'Thruk::Agents'} = $xtr->{'Thruk::Agents'};
    undef $Thruk::Agents::SNClient::conf;

    my $opts = Thruk::Agents::SNClient::_get_extra_opts_hst($c, "localhost", "", []);
    ok(scalar @{$opts} == 0, "combined exclude match");

    $opts = Thruk::Agents::SNClient::_get_extra_opts_hst($c, "localhost", "", ["tag1"]);
    ok($opts->[0]->{'first_notification_delay'} == 30, "combined exclude match II");

    $opts = Thruk::Agents::SNClient::_get_extra_opts_hst($c, "localhost", "", ["tag2"]);
    ok(scalar @{$opts} == 0, "combined exclude match III");

    $opts = Thruk::Agents::SNClient::_get_extra_opts_hst($c, "localhost", "", ["tag1", "tag2", "tag3"]);
    ok(scalar @{$opts} == 0, "combined exclude match IV");
}

###########################################################
# match with equals
{
    my $conf = <<EOT;
<Component Thruk::Agents>
  <snclient>
    <proc>
      name     = ssh controlmaster %u
      match    ~ /usr/bin/ssh.*ControlMaster=yes
      user     = mon
    </proc>
  </snclient>
</Component>
EOT

    my $expect = {
        '_FILE' => '<inline>',
        '_LINE' => 2,
        'proc'  => {
                    '_FILE' => '<inline>',
                    '_LINE' => 3,
                    'match' => '~ /usr/bin/ssh.*ControlMaster=yes',
                    'name' => 'ssh controlmaster %u',
                    'user' => 'mon'
        },
    };

    my $xtr = Thruk::Config::parse_config_from_text($conf);
    is_deeply($xtr->{'Thruk::Agents'}->{'snclient'}, $expect, "parsed config correctly");
}

###########################################################

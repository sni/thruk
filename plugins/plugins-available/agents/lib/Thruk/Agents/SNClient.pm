package Thruk::Agents::SNClient;

use warnings;
use strict;
use Carp qw/confess/;
use Cpanel::JSON::XS qw/decode_json/;
use Storable ();

use Monitoring::Config::Object ();
use Thruk::Utils ();
use Thruk::Utils::Agents ();
use Thruk::Utils::Log qw/:all/;

=head1 NAME

Thruk::Agents::SNClient - implements snclient based agent configuration

=cut

my $global_settings = {
    'type'          => 'snclient',
    'icon'          => 'snclient.png',
    'icon_dark'     => 'snclient_dark.png',
    'default_port'  => 8443,
    'default_mode'  => 'https',
};

my $config_defaults = {
    'check_nsc_web_extra_options' => '-t 35',
    'default_backend'             => 'LOCAL',
    'default_password'            => '',
    'default_port'                => $global_settings->{'default_port'},
    'check_interval'              => 1,
    'retry_interval'              => 0.5,
    'max_check_attempts'          => 3,
    'inventory_interval'          => 60,
    'os_updates_interval'         => 60,
    'default_contacts'            => [],
    'default_contactgroups'       => [],
    'perf_template'               => "auto",
    'host_perf_template'          => "auto",
    'host_check'                  => "\$USER1\$/check_icmp -H \$HOSTADDRESS\$ -w 3000.0,80% -c 5000.0,100% -p 5",
    'default_opt'                 => [],
    'disable'                     => {},
    'exclude'                     => [],
    'service'                     => [],
    'proc'                        => [],
    'extra_service_opts'          => [],
    'extra_host_opts'             => [],
    'extra_service_checks'        => [],
};

my $no_object_keys = [qw/host match service section tag tags host_name args check _FILE _LINE/];

=head1 METHODS

=cut

##########################################################

=head2 new

    new($c, $host)

returns agent object from livestatus host

=cut
sub new {
    my($class, $host) = @_;
    my $self = {};
    bless $self, $class;
    return($self);
}

##########################################################

=head2 settings

    settings()

returns global module settings

=cut
sub settings {
    return($global_settings);
}

##########################################################

=head2 config

    config()

returns config for this agent

=cut
sub config {
    our $conf;
    return($conf) if $conf;

    my $c = $Thruk::Globals::c || die("uninitialized");
    $conf = $c->config->{'Thruk::Agents'}->{'snclient'};
    $conf = Thruk::Config::apply_defaults_and_normalize($conf, $config_defaults);

    return($conf);
}

##########################################################

=head2 get_config_objects

    get_config_objects($c, $data, $checks_config, $cli_opts)

returns list of Monitoring::Objects for the host / services along with list of objects to remove

=cut
sub get_config_objects {
    my($self, $c, $data, $checks_config, $cli_opts) = @_;

    my $backend  = $data->{'backend'}  || die("missing backend");
    my $hostname = $data->{'hostname'} || die("missing hostname");
    my $ip       = $data->{'ip'}       // '';
    my $section  = $data->{'section'}  // '';
    my $password = $data->{'password'} // '';
    my $port     = $data->{'port'}     || settings()->{'default_port'};
    my $mode     = $data->{'mode'}     || 'https';
    my $tags     = Thruk::Base::comma_separated_list($data->{'tags'} // '');

    $section =~ s|^\/*||gmx if $section;
    $section =~ s|\/*$||gmx if $section;
    $section =~ s|\/+|/|gmx if $section;
    my $filename = $section ? sprintf('agents/%s/%s.cfg', $section, $hostname) : sprintf('agents/%s.cfg', $hostname);
    my $objects  = $c->{'obj_db'}->get_objects_by_name('host', $hostname);
    my $hostobj;
    if(!$objects || scalar @{$objects} == 0) {
        # create new one
        $hostobj = Monitoring::Config::Object->new( type    => 'host',
                                                   coretype => $c->{'obj_db'}->{'coretype'},
                                                );
        $hostobj->{'conf'}->{'host_name'} = $hostname;
        $hostobj->{'conf'}->{'alias'}     = $hostname;
        $hostobj->{'conf'}->{'address'}   = $ip || $hostname;
    } else {
        $hostobj = $objects->[0];
        $hostobj->{'_prev_conf'} = Thruk::Utils::dclone($hostobj->{'conf'});
        $password = $password || $hostobj->{'conf'}->{'_AGENT_PASSWORD'};
    }
    $hostobj->{'_filename'} = $filename;
    $hostobj->{'conf'}->{'address'} = $ip if $ip;

    my $perf_template      = 'srv-pnp';
    my $host_perf_template = 'host-pnp';
    if($ENV{'CONFIG_GRAFANA'} && $ENV{'CONFIG_GRAFANA'} eq 'on') {
        $perf_template      = 'srv-perf';
        $host_perf_template = 'host-perf';
    }
    my $config = &config();
    $perf_template      = $config->{'perf_template'}      eq 'auto' ? $perf_template      : $config->{'perf_template'};
    $host_perf_template = $config->{'host_perf_template'} eq 'auto' ? $host_perf_template : $config->{'host_perf_template'};

    $hostobj->{'conf'}->{'use'} = [$host_perf_template, ($section ? _make_section_template("host", $section) : 'generic-thruk-agent-host')];

    my @list = ($hostobj);
    my @remove;

    my $hostdata = $hostobj->{'conf'} // {};

    my $services       = Thruk::Utils::Agents::get_host_agent_services($c, $hostobj);
    my $services_by_id = Thruk::Utils::Agents::get_host_agent_services_by_id($services);

    my $settings = $hostdata->{'_AGENT_CONFIG'} ? decode_json($hostdata->{'_AGENT_CONFIG'}) : {};
    for my $key (sort keys %{$checks_config}) {
        if($key =~ /^options\.(.*)$/mx) {
            my $opt_name = $1;
            if($checks_config->{$key} ne '') {
                $settings->{'options'}->{$opt_name} = $checks_config->{$key};
            } else {
                delete $settings->{'options'}->{$opt_name};
            }
        }
    }

    # save services
    my $checks = Thruk::Utils::Agents::get_services_checks($c, $backend, $hostname, $hostobj, "snclient", $password, $cli_opts, $section, $mode, $settings->{'options'}, $tags);
    my $checks_hash = Thruk::Base::array2hash($checks, "id");

    if(!$checks || scalar @{$checks} == 0) {
        return;
    }

    confess("missing host config") unless $checks_hash->{'_host'};
    for my $key (sort keys %{$checks_hash->{'_host'}->{'conf'}}) {
        $hostdata->{$key} = $checks_hash->{'_host'}->{'conf'}->{$key};
    }
    my $section_changed = (!defined $hostdata->{'_AGENT_SECTION'} || $hostdata->{'_AGENT_SECTION'} ne $section);
    $hostdata->{'_AGENT_SECTION'}  = $section;
    $hostdata->{'_AGENT_PORT'}     = $port;
    delete $hostdata->{'_AGENT_MODE'};
    if($mode && $mode ne 'https') {
        $hostdata->{'_AGENT_MODE'} = $mode;
    }
    delete $hostdata->{'_AGENT_TAGS'};
    if(scalar @{$tags} > 0) {
        $hostdata->{'_AGENT_TAGS'} = join(", ", @{$tags});
    }

    my $template = $section ? _make_section_template("service", $section) : 'generic-thruk-agent-service';

    my $skip_keys = Thruk::Base::array2hash($no_object_keys);

    for my $id (sort keys %{$checks_hash}) {
        next if $id eq '_host';
        my $type = $checks_config->{'check.'.$id} // 'off';
        my $args = $checks_config->{'args.'.$id}  // '';
        my $chk  = $checks_hash->{$id};
        confess("no name") unless $chk->{'name'};
        my $svc = $services_by_id->{$chk->{'id'}} // $services->{$chk->{'name'}};
        if(!$svc && $type eq 'keep') {
            $type = 'on';
            $checks_config->{'check.'.$id} = 'on';
        }
        if(!$svc && $type eq 'on') {
            # create new one
            $svc = Monitoring::Config::Object->new( type     => 'service',
                                                    coretype => $c->{'obj_db'}->{'coretype'},
                                                    );
        }

        if($type eq 'new') {
            $settings->{'disabled'} = Thruk::Base::array_remove($settings->{'disabled'}, $id);
            push @remove, $svc if $svc;
            next;
        }

        if($type eq 'off') {
            push @remove, $svc if $svc;
            # only save disabled information if it was disabled manually, not when disabled by config
            # and only if it wasn't orphanded
            if(!$chk->{'disabled'} && $chk->{'exists'} ne 'obsolete') {
                push @{$settings->{'disabled'}}, $id if (!defined $chk->{'exclude_reason'} || $chk->{'exclude_reason'} eq 'manually');
            }
            next;
        }
        $svc->{'_filename'} = $filename;
        $svc->{'_prev_conf'} = Thruk::Utils::dclone($svc->{'conf'});
        my @templates = ($template);
        unshift @templates, $perf_template unless $chk->{'noperf'};

        if($cli_opts->{'fresh'} || $type eq 'on' || ($chk->{'svc_conf'}->{'_AGENT_ARGS'}//'') ne ($args//'')) {
            if(!defined $chk->{'svc_conf'}->{'service_description'}) {
                # these are obsolete services, just keep them as is
                next;
            }
            $settings->{'disabled'} = Thruk::Base::array_remove($settings->{'disabled'}, $id);
            $svc->{'conf'} = $chk->{'svc_conf'};
            $svc->{'conf'}->{'use'} = \@templates;
            delete $chk->{'svc_conf'}->{'_AGENT_ARGS'};
            my $extra = _get_extra_opts_svc($c, $svc->{'conf'}->{'service_description'}, $hostname, $section, $tags);
            unshift @{$extra}, $chk->{'extra'} if $chk->{'extra'};
            if($args) { # user supplied manual overrides
                $chk->{'svc_conf'}->{'_AGENT_ARGS'}    = $args;
                $chk->{'svc_conf'}->{'check_command'} .= " ".$args;
            } else {
                my $args;
                for my $ex (@{$extra}) {
                    for my $key (sort keys %{$ex}) {
                        $args = $ex->{$key} if $key eq 'args';
                    }
                }
                $chk->{'svc_conf'}->{'check_command'} .= " ".$args if $args;
            }

            # escape exclamation marks in check command (except the first one)
            my($cmd, $args) = split(/\!/mx, $chk->{'svc_conf'}->{'check_command'}, 2);
            $args =~ s/\\\!/!/gmx;
            $args =~ s/\!/\\!/gmx;
            $chk->{'svc_conf'}->{'check_command'} = sprintf("%s!%s", $cmd, $args);

            $svc->{'comments'} = ["# autogenerated check: ".$svc->{'conf'}->{'service_description'} ];

            # set extra service options
            for my $ex (@{$extra}) {
                for my $key (sort keys %{$ex}) {
                    next if $skip_keys->{$key};
                    _apply_extra_obj_attr($chk->{'svc_conf'}, $key, $ex->{$key});
                }
            }

            push @list, $svc;
            next;
        }
        if($section_changed && $svc->{'conf'}) {
            $svc->{'conf'}->{'use'} = \@templates;
            push @list, $svc;
            next;
        }
    }

    my $json = Cpanel::JSON::XS->new->canonical;
    if($settings->{'disabled'}) {
        $settings->{'disabled'} = Thruk::Base::array_uniq($settings->{'disabled'});
        if(scalar @{$settings->{'disabled'}} == 0) {
            delete $settings->{'disabled'};
        }
    }
    my $settings_str = $json->encode($settings);
    if($settings_str ne ($hostdata->{'_AGENT_CONFIG'}//"")) {
        $hostdata->{'_AGENT_CONFIG'} = $settings_str;
    }

    # set extra host options
    my $extra = _get_extra_opts_hst($c, $hostname, $section, $tags);
    my $host_check;
    for my $ex (@{$extra}) {
        for my $key (sort keys %{$ex}) {
            next if $skip_keys->{$key};
            _apply_extra_obj_attr($hostdata, $key, $ex->{$key});
            $host_check = $ex->{$key} if $key eq 'check_command';
        }
    }

    my $proxy_cmd = _check_proxy_command($c, $settings->{'options'});
    # if there is a proxy command, we have to set a check_command for hosts
    if($proxy_cmd) {
        $hostdata->{'check_command'} = $host_check || $config->{'host_check'};
        $hostdata->{'check_command'} =
            sprintf("check_thruk_agent!%s%s",
                $proxy_cmd,
                $hostdata->{'check_command'},
            );
    }
    $hostobj->{'conf'} = $hostdata;

    _add_templates($c, \@list, $section);

    return(\@list, \@remove);
}

##########################################################
sub _add_templates {
    my($c, $list, $section) = @_;

    return unless $section;

    my @paths = split(/\//mx, $section);
    my $cur = "";
    my $parent_svc = "generic-thruk-agent-service";
    my $parent_hst = "generic-thruk-agent-host";
    while(scalar @paths > 0) {
        my $p = shift @paths;
        $cur = ($cur ? $cur."/" : "").$p;
        my $svc = Monitoring::Config::Object->new( type  => 'service',
                                                coretype => $c->{'obj_db'}->{'coretype'},
                                                );
        $svc->{'_filename'} = sprintf('agents/%s/templates.cfg', $cur);
        my $name = _make_section_template("service", $cur);
        $svc->{'conf'} = {
            "name"      => $name,
            "use"       => [$parent_svc],
            "register"  => 0,
        };
        my $objects = $c->{'obj_db'}->get_objects_by_name("service", $name);
        if(!$objects || scalar @{$objects} == 0) {
            push @{$list}, $svc;
        }
        $parent_svc = $name;

        $name = _make_section_template("host", $cur);
        my $hst = Monitoring::Config::Object->new( type  => 'host',
                                                coretype => $c->{'obj_db'}->{'coretype'},
                                                );
        $hst->{'_filename'} = sprintf('agents/%s/templates.cfg', $cur);
        $hst->{'conf'} = {
            "name"      => $name,
            "use"       => [$parent_hst],
            "register"  => 0,
        };
        $objects = $c->{'obj_db'}->get_objects_by_name("host", $name);
        if(!$objects || scalar @{$objects} == 0) {
            push @{$list}, $hst;
        }
        $parent_hst = $name;
    }

    return;
}

##########################################################

=head2 get_services_checks

    get_services_checks($c, $hostname, $hostobj, $password, $cli_opts, $section, $mode, $options, $tags)

returns list of Monitoring::Objects for the host / services

=cut
sub get_services_checks {
    my($self, $c, $hostname, $hostobj, $password, $cli_opts, $section, $mode, $options, $tags) = @_;
    my $datafile = $c->config->{'var_path'}.'/agents/hosts/'.$hostname.'.json';

    my $data;
    if($cli_opts->{'cached'} && ref $cli_opts->{'cached'} eq 'HASH') {
        $data = $cli_opts->{'cached'};
    } elsif($cli_opts->{'cached'}) {
        $datafile = $cli_opts->{'cached'};
        _debug("using %s as inventory file", $datafile);
    }
    if(!$data) {
        if(!-r $datafile) {
            return([]);
        }
        $data = Thruk::Utils::IO::json_lock_retrieve($datafile);
    }

    my $checks   = [];
    my $settings = {};
    if($hostobj && $hostobj->{'conf'}->{'_AGENT_CONFIG'}) {
        $settings = decode_json($hostobj->{'conf'}->{'_AGENT_CONFIG'});
    }
    $checks = _extract_checks(
                    $c,
                    $data->{'inventory'},
                    $hostname,
                    $password,
                    $cli_opts,
                    $section,
                    $mode,
                    $options // $settings->{'options'} // {},
                    $tags,
                ) if $data->{'inventory'};

    return($checks);
}

##########################################################

=head2 get_inventory

    get_inventory($c, $c, $address, $hostname, $password, $port, $mode)

returns json structure from inventory api call.

=cut
sub get_inventory {
    my($self, $c, $address, $hostname, $password, $port, $mode) = @_;

    $port = $port || settings()->{'default_port'};
    my $proto = "https";
    $proto = "http" if($mode && $mode eq 'http');
    die("no password supplied") unless $password;
    my $command  = "check_snclient";
    my $args     = sprintf("%s -p '%s' -r -u '%s://%s:%d/api/v1/inventory'",
        _check_nsc_web_extra_options($c, $mode),
        $password,
        $proto,
        ($address || $hostname),
        $port,
    );

    my $cmd = {
        command_name => 'check_snclient',
        command_line => '$USER1$/check_nsc_web $ARG1$',
    };

    my $extra_templates = [];
    push @{$extra_templates}, {
        type => 'host',
        name => 'generic-thruk-agent-host',
        file => 'agents/templates.cfg',
        conf => {
            'name'  => 'generic-thruk-agent-host',
            'use'   => ['generic-host'],
        },
    };
    push @{$extra_templates}, {
        type => 'service',
        name => 'generic-thruk-agent-service',
        file => 'agents/templates.cfg',
        conf => {
            'name'  => 'generic-thruk-agent-service',
            'use'   => ['generic-service'],
        },
    };

    Thruk::Utils::Agents::check_for_check_commands($c, [$cmd], $extra_templates);

    _debug("scan command: %s!%s", $command, $args);
    my $output = $c->{'obj_db'}->get_plugin_preview($c,
                                        $command,
                                        $args,
                                        $hostname,
                                        '',
                                    );
    $output = Thruk::Base::trim_whitespace($output) if $output;
    if($output =~ m/^\{/mx) {
        my $data;
        eval {
            $data = decode_json($output);
        };
        my $err = $@;
        if($err) {
            die($err);
        }
        return $data;
    }
    die($output || 'no output from inventory scan command');
}

##########################################################
sub _extract_checks {
    my($c, $inventory, $hostname, $password, $cli_opts, $section, $mode, $options, $tags) = @_;
    my $checks = [];

    # get available modules
    my $modules = Thruk::Utils::find_modules('Thruk/Agents/SNClient/Checks/*.pm');
    for my $mod (@{$modules}) {
        require $mod;
        $mod =~ s/\//::/gmx;
        $mod =~ s/\.pm$//gmx;
        $mod->import;
        my $add = $mod->get_checks($c, $inventory, $hostname, $password, $section);
        push @{$checks}, @{$add} if $add;
    }

    my $proxy_cmd = _check_proxy_command($c, $options);

    # compute host configuration
    my $hostdata = {};
    $hostdata->{'_AGENT'} = 'snclient';
    $password = '' unless defined $password;
    $hostdata->{'_AGENT_PASSWORD'} = $password if($password ne ''); # only if changed
    push @{$checks}, {
        'id'       => '_host',
        'conf'     => $hostdata,
    };

    # append extra service checks
    my $extra = _get_extra_service_checks($c, $hostname, $section, $tags);
    push @{$checks}, @{$extra};

    my $config = &config();

    # compute service configuration
    for my $chk (@{$checks}) {
        next if $chk->{'id'} eq '_host';
        my $svc_password = '$_HOSTAGENT_PASSWORD$';
        if($password ne '' && $password =~ m/^\$.*\$$/mx) {
            $svc_password = $password;
        }
        my $proto = "https";
        $proto = "http" if($mode && $mode eq 'http');
        my $command = $chk->{'check_command'} // sprintf(
                "check_thruk_agent!%s\$USER1\$/check_nsc_web %s %s -p '%s' -u '%s://%s:%s' '%s'",
                $proxy_cmd,
                _check_nsc_web_extra_options($c, $mode),
                ($chk->{'nscweb'} // ''),
                $svc_password,
                $proto,
                '$HOSTADDRESS$',
                '$_HOSTAGENT_PORT$',
                $chk->{'check'},
        );
        my $current_args = [];
        my $interval = $config->{'check_interval'};
        if($chk->{'check'}) {
            if($chk->{'check'} eq 'inventory') {
                my $thruk = '$USER4$/bin/thruk';
                if(-x $c->config->{'home'}."/script/thruk") {
                    # use path to local script if this is a git installation
                    $thruk = $c->config->{'home'}."/script/thruk";
                }
                $command  = 'check_thruk_agent!'.$proxy_cmd.$thruk.' agents check inventory \'$HOSTNAME$\'';
                $interval = $config->{'inventory_interval'};
            }
            if($chk->{'check'} eq 'check_os_updates') {
                $interval = $config->{'os_updates_interval'};
            }
            if($chk->{'args'}) {
                if(ref $chk->{'args'} eq 'ARRAY') {
                    for my $arg (@{$chk->{'args'}}) {
                        next unless defined $arg;
                        $command .= sprintf(" %s", $arg);
                        push @{$current_args}, $arg;
                    }
                } else {
                    for my $arg (sort keys %{$chk->{'args'}}) {
                        my $a = sprintf("%s='%s'", $arg, $chk->{'args'}->{$arg});
                        $command .= " ".$a;
                        push @{$current_args}, $a;
                    }
                }
            }
        }

        $chk->{'name'} =~ s|[`~!\$%^&*\|'"<>?,()=]*||gmx; # remove nasty chars from object name
        $chk->{'name'} =~ s|\\$||gmx; # remove trailing slashes from service names, ex.: in windows drives
        $chk->{'current_args'} = $current_args;

        $chk->{'svc_conf'} = {
            'host_name'           => $hostname,
            'service_description' => $chk->{'name'},
            'check_interval'      => $interval,
            'retry_interval'      => $config->{'retry_interval'},
            'max_check_attempts'  => $config->{'max_check_attempts'},
            'check_command'       => $command,
            '_AGENT_AUTO_CHECK'   => $chk->{'id'},
        };
        $chk->{'svc_conf'}->{'parents'} = $chk->{'parent'} if $chk->{'parent'};
        $chk->{'svc_conf'}->{'_GRAPH_SOURCE'} = $chk->{'_GRAPH_SOURCE'} if $chk->{'_GRAPH_SOURCE'};
        $chk->{'svc_conf'}->{'_WORKER'}       = $chk->{'_WORKER'}       if $chk->{'_WORKER'};
        $chk->{'args'} = "";

        for my $attr (qw/contacts contactgroups/) {
            my $data = Thruk::Base::list($config->{'default_'.$attr});
            $data    = Thruk::Base::comma_separated_list(join(",", @{$data}));
            if(scalar @{$data} > 0) {
                $chk->{'svc_conf'}->{$attr} = join(",", @{$data});
            }
        }

        # get list of applied rules
        $chk->{'rules'} = _get_extra_opts_svc($c, $chk->{'name'}, $hostname, $section, $tags);
    }

    return $checks;
}

##########################################################

=head2 make_name

    make_name($template, $macros)

returns check name based on template

=cut
sub make_name {
    my($tmpl, $macros) = @_;
    my $name = $tmpl;
    if($macros) {
        for my $key (sort keys %{$macros}) {
            my $val = $macros->{$key};
            $name =~ s|$key|$val|gmx;
        }
    }
    $name =~ s/\s*$//gmx;
    $name =~ s/^\s*//gmx;
    return($name);
}

##########################################################

=head2 make_filter

    make_filter($name, $attr, $expr)

returns filter based on matching expression

=cut
sub make_filter {
    my($name, $attr, $expr, $substringmatch) = @_;

    my $op  = "=";
    my $val = $expr;

    if($expr =~ m/^([\!=~]+)\s+(.*)$/mx) {
        $op  = $1;
        $val = $2;
    }

    my $rawval = $val;
    if($op eq '~') {
        $val = "/".$val."/";
        $op  = "~~";
    } else {
        $val = "'".$val."'";
    }

    if($op eq '=' && $substringmatch) {
        $op = "like";
    }

    my $filter = sprintf('%s="%s %s %s"', $name, $attr, $op, $val);

    return($filter, $rawval);
}

##########################################################

=head2 get_disabled_config

    get_disabled_config($c, $key, $default)

returns disabled config for this key with a fallback

=cut
sub get_disabled_config {
    my($c, $key, $fallback) = @_;

    my $config = &config;
    if($config->{'disable'}) {
        # merge blocks
        my $blocks = [];
        for my $dis (@{Thruk::Base::list($config->{'disable'})}) {
            if($dis->{$key}) {
                push @{$blocks}, @{Thruk::Base::list($dis->{$key})};
            }
        }
        return({ $key => $blocks }) if scalar @{$blocks} > 0;
    }

    # no matches, return fallback
    return({ $key => $fallback });
}

##########################################################

=head2 default_opt

    default_opt($c, $check_type)

returns default options for this check

=cut
sub default_opt {
    my($c, $check) = @_;

    my $config = &config;
    my $opts   = Thruk::Base::list($config->{'default_opt'});
    my $res;
    for my $opt (@{$opts}) {
        next unless defined $opt->{$check};
        $res = $opt->{$check};
    }

    return($res);
}

##########################################################
sub _check_nsc_web_extra_options {
    my($c, $mode) = @_;
    my $config  = &config;
    my $options = $config->{'check_nsc_web_extra_options'};
    $options = $options." -k " if($mode && $mode eq 'insecure');
    return($options);
}

##########################################################
sub _check_proxy_command {
    my($c, $options) = @_;
    my $proxy = "";
    if($options->{'offline'}) {
        $proxy = sprintf("\$USER4\$/share/thruk/script/maybe_offline -H '\$HOSTNAME\$' -s '\$SERVICEDESC\$' -o '%s' -- ", $options->{'offline'});
    }
    return $proxy;
}

##########################################################
sub _make_section_template {
    my($type, $section) = @_;
    return("agent-".$type."-".$section);
}

##########################################################
sub _get_extra_opts_hst {
    my($c, $hostname, $section, $tags) = @_;
    my $config = &config;
    my $opts   = Thruk::Base::list($config->{'extra_host_opts'});
    my $res    = [];
    for my $opt (@{$opts}) {
        next unless Thruk::Utils::Agents::check_wildcard_match($hostname, ($opt->{'match'} // 'ANY'));
        next unless Thruk::Utils::Agents::check_wildcard_match($hostname, ($opt->{'host'} // 'ANY'));
        next unless Thruk::Utils::Agents::check_wildcard_match($section, ($opt->{'section'} // 'ANY'));
        next unless Thruk::Utils::Agents::check_wildcard_match($tags, ($opt->{'tags'} // $opt->{'tag'} // 'ANY'));
        push @{$res}, $opt;
    }

    return $res;
}

##########################################################
sub _get_extra_opts_svc {
    my($c, $name, $hostname, $section, $tags) = @_;
    my $config = &config;
    my $opts   = Thruk::Base::list($config->{'extra_service_opts'});
    my $res    = [];
    for my $opt (@{$opts}) {
        next unless Thruk::Utils::Agents::check_wildcard_match($name, ($opt->{'match'} // 'ANY'));
        next unless Thruk::Utils::Agents::check_wildcard_match($name, ($opt->{'service'} // 'ANY'));
        next unless Thruk::Utils::Agents::check_wildcard_match($hostname, ($opt->{'host'} // 'ANY'));
        next unless Thruk::Utils::Agents::check_wildcard_match($section, ($opt->{'section'} // 'ANY'));
        next unless Thruk::Utils::Agents::check_wildcard_match($tags, ($opt->{'tags'} // $opt->{'tag'} // 'ANY'));
        push @{$res}, $opt;
    }

    return $res;
}

##########################################################
sub _get_extra_service_checks {
    my($c, $hostname, $section, $tags) = @_;
    my $config    = &config;
    my $checks    = Thruk::Base::list($config->{'extra_service_checks'});
    my $res       = {};
    my $skip_keys = Thruk::Base::array2hash($no_object_keys);
    for my $chk (@{$checks}) {
        next unless Thruk::Utils::Agents::check_wildcard_match($hostname, ($chk->{'host'} // 'ANY'));
        next unless Thruk::Utils::Agents::check_wildcard_match($section, ($chk->{'section'} // 'ANY'));
        next unless Thruk::Utils::Agents::check_wildcard_match($tags, ($chk->{'tags'} // $chk->{'tag'} // 'ANY'));

        # create a copy, because it will be changed in the process of creating checks
        my $svc = Storable::dclone($chk);

        # args should be a list
        $svc->{'args'} = Thruk::Base::list($svc->{'args'}) if($svc->{'args'});

        # derive id from name
        $svc->{'id'} = "extra.".Thruk::Utils::Filter::name2id($svc->{'name'});

        my $extra = {};
        for my $key (keys %{$svc}) {
            next if $skip_keys->{$key};
            next if $key eq 'extra';
            next if $key eq 'id';
            next if $key eq 'name';

            $extra->{$key} = $svc->{$key};
        }

        if($svc->{'_FILE'}) {
            $svc->{'extra_src'} = $svc->{'_FILE'}.":".$svc->{'_LINE'};
            my $root = $ENV{'OMD_ROOT'};
            $svc->{'extra_src'} =~ s=^$root/==gmx if $root;
            $svc->{'extra_src'} = '<extra_service_checks> from '.$svc->{'extra_src'};
        }

        # everything else is a custom attribute
        $svc->{'extra'} = $extra;

        $res->{$svc->{'id'}} = $svc;
    }

    return([values %{$res}]);
}

##########################################################
sub _apply_extra_obj_attr {
    my($conf, $key, $extra) = @_;

    for my $ex (@{Thruk::Base::list($extra)}) {
        if($ex =~ m/^\!/mx) {
            # remove this entry
            my $val = $extra;
            $val =~ s/^\!//gmx;
            my $cur = Thruk::Base::comma_separated_list($conf->{$key}//'');
            $cur = Thruk::Base::array_remove($cur, $val);
            $cur = Thruk::Base::array_uniq($cur);
            $conf->{$key} = join(",", @{$cur});
        }
        elsif($ex =~ m/^\+/mx) {
            # add this entry
            my $val = $extra;
            $val =~ s/^\+//gmx;
            my $cur = Thruk::Base::comma_separated_list($conf->{$key}//'');
            push @{$cur}, @{Thruk::Base::comma_separated_list($val//'')};
            $cur = Thruk::Base::array_uniq($cur);
            $conf->{$key} = join(",", @{$cur});
        } else {
            # replace this entry
            $conf->{$key} = $ex;
        }
    }

    return;
}

##########################################################

1;

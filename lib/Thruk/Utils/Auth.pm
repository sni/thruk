package Thruk::Utils::Auth;

=head1 NAME

Thruk::Utils::Auth - Authorization Utilities for Thruk

=head1 DESCRIPTION

Authorization Utilities Collection for Thruk

=cut

use warnings;
use strict;
use Carp;

use Monitoring::Livestatus::Class::Lite ();
use Thruk::Utils ();
use Thruk::Utils::Log qw/:all/;
use Thruk::Utils::Status ();

##############################################
=head1 METHODS

=cut

##############################################

=head2 get_auth_filter

  my $filter_string = get_auth_filter('hosts');

returns a filter which can be used for authorization

=cut
sub get_auth_filter {
    my($c, $type, $strict, $cmd_permissions) = @_;
    $strict = 0 unless defined $strict;

    return if $type eq 'status';

    confess("no backend!") unless defined $c->db();

    # if authentication is completely disabled
    if($c->config->{'use_authentication'} == 0 and $c->config->{'use_ssl_authentication'} == 0) {
        return;
    }

    # no user at all, for example when used by cli
    unless ($c->user_exists) {
        return;
    }

    if($strict and $type ne 'hosts' and $type ne 'services') {
        croak("strict authorization not implemented for: ".$type);
    }

    # host authorization
    if($type eq 'hosts') {
        if(!$strict && $c->check_user_roles('authorized_for_all_hosts')) {
            return();
        }
        return(Thruk::Utils::combine_filter(
            '-or', [
                {'contacts' => { '>=' => $c->user->get('username') }},
                @{_permission_filter($c, 'hosts', $cmd_permissions)},
            ],
        ));
    }

    # hostgroups authorization
    elsif($type eq 'hostgroups') {
        return();
    }

    # service authorization
    elsif($type eq 'services') {
        if(!$strict && $c->check_user_roles('authorized_for_all_services')) {
            return();
        }
        if($c->config->{'use_strict_host_authorization'}) {
            return(Thruk::Utils::combine_filter(
                '-or', [
                    {'contacts' => { '>=' => $c->user->get('username') }},
                    @{_permission_filter($c, 'services', $cmd_permissions)},
                ],
            ));
        } else {
            return(Thruk::Utils::combine_filter(
                '-or', [
                    {'contacts' => { '>=' => $c->user->get('username') }},
                    {'host_contacts' => { '>=' => $c->user->get('username') } },
                    @{_permission_filter($c, 'services', $cmd_permissions)},
                ],
            ));
        }
    }

    # servicegroups authorization
    elsif($type eq 'servicegroups') {
        return();
    }

    # servicegroups authorization
    elsif($type eq 'timeperiods') {
        return();
    }

    # contactgroups authorization
    elsif($type eq 'contactgroups') {
        return();
    }

    # commands authorization
    elsif($type eq 'commands') {
        return();
    }

    elsif($type eq 'columns') {
        return();
    }

    # contacts authorization
    elsif($type eq 'contacts') {
        return('name' => $c->user->get('username'));
    }

    # comments / downtimes authorization
    elsif($type eq 'comments' or $type eq 'downtimes') {
        my @filter;

        if(    $c->check_user_roles('authorized_for_all_services')
           and $c->check_user_roles('authorized_for_all_hosts')) {
            return;
        }

        if($c->check_user_roles('authorized_for_all_services')) {
            push @filter, { 'service_description' => { '!=' => undef } };
        } else {
            push @filter, '-and' => [ 'service_contacts'    => { '>=' => $c->user->get('username') },
                                      'service_description' => { '!=' => undef },
                                    ];
        }

        if($c->check_user_roles('authorized_for_all_hosts')) {
            push @filter, { 'service_description' => undef };
        } else {
            if(Thruk::Base->config->{'use_strict_host_authorization'}) {
                push @filter, '-and ' => [ 'host_contacts'       => { '>=' => $c->user->get('username') },
                                           'service_description' => undef,
                                         ];
            } else {
                push @filter, { 'host_contacts' => { '>=' => $c->user->get('username') }};
            }
        }
        return Thruk::Utils::combine_filter('-or', \@filter);
    }

    # logfile authorization
    elsif($type eq 'log') {
        my @filter;
        my $log_filter = { filter => undef };

        if(    $c->check_user_roles('authorized_for_all_services')
           and $c->check_user_roles('authorized_for_all_hosts')
           and $c->check_user_roles('authorized_for_system_information')) {
            return({ auth_filter => $log_filter}) if $c->config->{'logcache'};
            return;
        }

        $log_filter->{'username'} = $c->user->get('username');

        # service log entries
        if($c->check_user_roles('authorized_for_all_services')) {
            $log_filter->{'authorized_for_all_services'} = 1;
            # allowed for all services related log entries
            push @filter, { 'service_description' => { '!=' => undef } };
        }
        else {
            push @filter, { '-and' => [
                              'current_service_contacts' => { '>=' => $c->user->get('username') },
                              'service_description'      => { '!=' => undef },
                          ]}
        }

        # host log entries
        if($c->check_user_roles('authorized_for_all_hosts')) {
            $log_filter->{'authorized_for_all_hosts'} = 1;
            # allowed for all host related log entries
            push @filter, { '-and' => [ 'service_description' => undef,
                                        'host_name'           => { '!=' => undef } ],
                          };
        }
        else {
            if(Thruk::Base->config->{'use_strict_host_authorization'}) {
                $log_filter->{'strict'} = 1;
                # only allowed for the host itself, not the services
                push @filter, { -and => [ 'current_host_contacts' => { '>=' => $c->user->get('username') }, { 'service_description' => undef }]};
            } else {
                # allowed for all hosts and its services
                push @filter, { 'current_host_contacts' => { '>=' => $c->user->get('username') } };
            }
        }

        # other log entries
        if($c->check_user_roles('authorized_for_system_information')) {
            $log_filter->{'authorized_for_system_information'} = 1;
            # everything not related to a specific host or service
            push @filter, { '-and' => [ 'service_description' => undef, 'host_name' => undef ]};
        }

        # combine all filter by OR
        $log_filter->{'filter'} = {'-or' => \@filter};
        return({ auth_filter => $log_filter}) if $c->config->{'logcache'};
        return($log_filter->{'filter'});
    }
    elsif($type eq 'contact') {
        if($c->check_user_roles('authorized_for_configuration_information')) {
            return();
        }
        return('name' => $c->user->get('username'));
    }

    else {
        confess("type $type not supported");
    }

    confess("cannot authorize query");
}

##############################################
sub _permission_filter {
    my($c, $type, $cmd_permissions) = @_;

    die("unknown type") if($type ne 'hosts' && $type ne 'services');

    my $permissions = $c->user->{'permissions'};

    # filter matching permissions
    my @matched;
    for my $p (@{$permissions}) {
        next if $type eq 'services' && !$p->{'with_services'};
        if($type eq 'hosts') {
            next if ($cmd_permissions && !$p->{'hst_commands'});
        } else {
            next if ($cmd_permissions && !$p->{'svc_commands'});
        }

        push @matched, $p;
    }

    return([]) unless scalar @matched > 0;

    my(@hst_filter, @svc_filter);
    for my $p (@matched) {
        if($type eq 'services') {
            for my $s (@{$p->{'services'}}) {
                my $search = {
                    text_filter => [{
                        'type'  => 'service',
                        'op'    => $p->{'services_op'} || '=',
                        'value' => $s,
                    }],
                };
                my(undef, $servicefilter) = Thruk::Utils::Status::single_search($c, $search, 1);
                push @svc_filter, $servicefilter;
                _warn($search) if $c->stash->{'has_error'};
                die("invalid auth filter") if $c->stash->{'has_error'};
            }
        }
        for my $hg (@{$p->{'hostgroups'}}) {
            my $search = {
                text_filter => [{
                    'type'  => 'hostgroup',
                    'op'    => $p->{'hostgroups_op'} || '=',
                    'value' => $hg,
                }],
            };
            my($hostfilter, $servicefilter) = Thruk::Utils::Status::single_search($c, $search, 1);
            push @hst_filter, ($type eq 'hosts' ? $hostfilter : $servicefilter);
            _warn($search) if $c->stash->{'has_error'};
            die("invalid auth filter") if $c->stash->{'has_error'};
        }
        for my $h (@{$p->{'hosts'}}) {
            my $search = {
                text_filter => [{
                    'type'  => 'host',
                    'op'    => $p->{'hosts_op'} || '=',
                    'value' => $h,
                }],
            };
            my($hostfilter, $servicefilter) = Thruk::Utils::Status::single_search($c, $search, 1);
            push @hst_filter, ($type eq 'hosts' ? $hostfilter : $servicefilter);
            _warn($search) if $c->stash->{'has_error'};
            die("invalid auth filter") if $c->stash->{'has_error'};
        }
    }

    # remove duplicates
    @hst_filter = _filter_dups(\@hst_filter);
    @svc_filter = _filter_dups(\@svc_filter);

    if($type eq 'hosts') {
        return([Thruk::Utils::Status::improve_filter(\@hst_filter)]);
    }

    return([Thruk::Utils::Status::improve_filter([Thruk::Utils::combine_filter(
        '-and', [
            Thruk::Utils::combine_filter("-or", \@hst_filter),
            Thruk::Utils::combine_filter("-or", \@svc_filter),
        ],
    )])]);
}

##############################################
# remove duplicates from filter
sub _filter_dups {
    my($filter) = @_;

    my %seen;
    my @filtered;

    for my $f (@{$filter}) {
        my $key = join("\n", @{Monitoring::Livestatus::Class::Lite::filter_statement($f, "F:")});
        next if $seen{$key}++;
        $seen{$key} = 1;
        push @filtered, $f;
    }

    return @filtered;
}

##############################################

1;

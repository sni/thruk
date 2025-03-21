package Thruk::Utils::CLI::Cron;

=head1 NAME

Thruk::Utils::CLI::Cron - Cron CLI module

=head1 DESCRIPTION

The cron command installs/uninstalls cronjobs

=head1 SYNOPSIS

  Usage: thruk [globaloptions] cron <cmd>

=head1 OPTIONS

=over 4

=item B<help>

    print help and exit

=item B<cmd>

    available commands are:

    - install       install thruks cronjobs
    - uninstall     remove thruks cronjobs

=back

=cut

use warnings;
use strict;
use Module::Load qw/load/;

use Thruk::Utils ();
use Thruk::Utils::CLI ();
use Thruk::Utils::Log qw/:all/;

##############################################
# no backends required for this command
our $skip_backends = 1;

##############################################

=head1 METHODS

=head2 cmd

    cmd([ $options ])

=cut
sub cmd {
    my($c, $action, $commandoptions) = @_;
    $c->stats->profile(begin => "_cmd_cron($action)");

    if(!$c->check_user_roles('authorized_for_admin')) {
        return("ERROR - authorized_for_admin role required", 1);
    }

    my $output;
    my $type = shift @{$commandoptions} || 'help';
    if($type eq 'install') {
        $output = _install($c);
    }
    elsif($type eq 'uninstall') {
        $output = _uninstall($c);
    } else {
        return(Thruk::Utils::CLI::get_submodule_help(__PACKAGE__));
    }

    $c->stats->profile(end => "_cmd_cron($action)");
    return($output, 0);
}

##############################################
sub _install {
    my($c) = @_;
    $c->stats->profile(begin => "_cmd_installcron()");
    Thruk::Utils::switch_realuser($c);

    $c->cluster->run_cluster("others", "cmd: cron install");
    local $ENV{'THRUK_SKIP_CLUSTER'} = 1; # skip further subsequent cluster calls

    local $ENV{'THRUK_SKIP_CRON_RELOAD'} = 1 if $ENV{'OMD_SITE'}; # skip reloading crontab multiple times

    Thruk::Utils::update_cron_file_maintenance($c);
    _debug("maintenance cron installed");

    require Thruk::Utils::Cluster;
    Thruk::Utils::Cluster::update_cron_file($c);
    _debug("cluster cron installed") if $c->cluster->is_clustered();

    require Thruk::Utils::RecurringDowntimes;
    Thruk::Utils::RecurringDowntimes::update_cron_file($c);
    _debug("downtime cron installed");

    if($c->app->{'_cron_callbacks'}) {
        for my $function (sort keys %{$c->app->{'_cron_callbacks'}}) {
            my $pkg_name     = $function;
            $pkg_name        =~ s%::[^:]+$%%mx;
            my $function_ref = \&{$function};
            load $pkg_name;
            &{$function_ref}($c);
            _debug($pkg_name." cron installed");
        }
    }

    $c->app->check_plugins_cron_file();

    # finally reload crontab
    delete local $ENV{'THRUK_SKIP_CRON_RELOAD'};
    Thruk::Utils::update_cron_file($c);

    $c->stats->profile(end => "_cmd_installcron()");
    return "updated cron entries\n";
}

##############################################
sub _uninstall {
    my($c) = @_;
    $c->stats->profile(begin => "_cmd_uninstallcron()");
    Thruk::Utils::switch_realuser($c);
    Thruk::Utils::update_cron_file($c, undef, undef, 1);
    $c->stats->profile(end => "_cmd_uninstallcron()");
    return "cron entries removed\n";
}

##############################################

=head1 EXAMPLES

Install thruks internal cronjobs

  %> thruk cron install

=cut

##############################################

1;

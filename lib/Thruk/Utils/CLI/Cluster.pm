package Thruk::Utils::CLI::Cluster;

=head1 NAME

Thruk::Utils::CLI::Cluster - Cluster CLI module

=head1 DESCRIPTION

Show information about a Thruk cluster

=head1 SYNOPSIS

  Usage: thruk [globaloptions] cluster <cmd>

=head1 OPTIONS

=over 4

=item B<help>

    print help and exit

=item B<cmd>

    available commands are:

    - status               displays status of the cluster
    - restart              restart thruk instance on each cluster node
    - ping                 send heartbeat to cluster nodes
    - maintenance [node]   set current node into maintenance mode
    - maint       [node]   alias for maintenance
    - activate    [node]   removes maintenance mode from current node
    - unmaint     [node]   alias for activate

=back

=cut

use warnings;
use strict;

use Thruk::Config 'noautoload';
use Thruk::Utils::CLI ();

our $skip_backends = 1;

##############################################

=head1 METHODS

=head2 cmd

    cmd([ $options ])

=cut
sub cmd {
    my($c, $action, $commandoptions) = @_;
    $c->stats->profile(begin => "_cmd_cluster($action)");

    if(!$c->check_user_roles('authorized_for_admin')) {
        return("ERROR - authorized_for_admin role required", 1);
    }

    if(scalar @{$commandoptions} == 0) {
        return(Thruk::Utils::CLI::get_submodule_help(__PACKAGE__));
    }
    my $mode = shift @{$commandoptions};

    if(!$c->cluster->is_clustered()) {
        return("cluster disabled - this is a single node installation and not clustered\n", 3);
    }

    $c->cluster->load_statefile();

    my($output, $rc) = ("", 0);
    if($mode eq 'status') {
        my($total, $ok) = (0, 0);
        $output .= sprintf("%-12s %-25s %-40s %-17s %-10s\n", "STATUS", "HOSTNAME", "URL", "RESPONSE TIME", "VERSION");
        $output .= ('-' x 110)."\n";
        for my $n (@{$c->cluster->{'nodes'}}) {
            $total++;
            my $status = '';
            if($c->cluster->maint($n)) {
                $status = 'MAINTENANCE';
                $ok++;
            }
            elsif($c->cluster->is_it_me($n)) {
                $status = 'OK';
                $n->{'version'} = Thruk::Config::get_thruk_version();
                $ok++;
            }
            elsif($n->{'last_contact'} <= 0) {
                $status = 'WAITING';
            } elsif(time() - $n->{'last_contact'} < $c->config->{'cluster_node_stale_timeout'}) {
                $status = 'OK';
                $ok++;
            } else {
                $status = 'DOWN';
            }
            $output .= sprintf("%-12s %-25s %-40s %-17s %-10s\n",
                $status,
                $n->{'hostname'},
                $n->{'node_url'},
                $n->{'response_time'} ? sprintf("%.2fs", $n->{'response_time'}) : '-----',
                $n->{'version'},
            );
        }
        $output .= ('-' x 110)."\n";
        $output .= sprintf("%d/%d nodes online\n", $ok, $total);
    } elsif($mode eq 'ping') {
        my $res = $c->sub_request('/r/thruk/cluster/heartbeat', 'POST', {});
        if($res && $res->{'message'}) {
            $output = $res->{'message'}."\n";
        } else {
            $output = "failed, please check logfiles and output or retry with -v\n";
            $rc     = 2;
        }
    } elsif($mode eq 'restart') {
        my $res = $c->sub_request('/r/thruk/cluster/restart', 'POST', {});
        if($res && $res->{'message'}) {
            $output = $res->{'message'}."\n";
        } else {
            $output = "failed, please check logfiles and output or retry with -v\n";
            $rc     = 2;
        }
    } elsif($mode eq 'maint' || $mode eq 'maintenance') {
        local $ENV{'THRUK_SKIP_CLUSTER'} = 0;
        my $node = _get_node($c, $commandoptions);
        $c->cluster->maint($node, time());
        $output = sprintf("OK - node %s set into maintenance mode\n", $node->{'hostname'});
    } elsif($mode eq 'activate' || $mode eq 'unmaint') {
        local $ENV{'THRUK_SKIP_CLUSTER'} = 0;
        my $node = _get_node($c, $commandoptions);
        $c->cluster->maint($node, 0);
        $output = sprintf("OK - removed maintenance mode for node %s.\n", $node->{'hostname'});
    } else {
        return(Thruk::Utils::CLI::get_submodule_help(__PACKAGE__));
    }

    $c->stats->profile(end => "_cmd_cluster($action)");
    return($output, $rc);
}

##############################################
sub _get_node {
    my($c, $commandoptions) = @_;

    my $node;
    my $find = shift @{$commandoptions};
    if($find) {
        for my $n (@{$c->cluster->{'nodes'}}) {
            if($n->{'hostname'} eq $find || $n->{'node_id'} eq $find) {
                $node = $n;
                last;
            }
        }
        if(!$node) {
            die("no node found by name: ".$find);
        }
    }

    if(!$node) {
        $node = $c->cluster->{'node'};
    }

    return($node);
}

##############################################

=head1 EXAMPLES

Show cluster status

  %> thruk cluster status

=cut

##############################################

1;

package Thruk::Controller::outages;

use warnings;
use strict;

use Thruk::Action::AddDefaults ();
use Thruk::Backend::Manager ();
use Thruk::Utils::Auth ();

=head1 NAME

Thruk::Controller::outages - Thruk Controller

=head1 DESCRIPTION

Thruk Controller.

=head1 METHODS

=cut


=head2 index

=cut

##########################################################
sub index {
    my ( $c ) = @_;

    return unless Thruk::Action::AddDefaults::add_defaults($c, Thruk::Constants::ADD_DEFAULTS);

    my $outages = $c->db->get_hosts(filter  => [ Thruk::Utils::Auth::get_auth_filter($c, 'hosts'),
                                                 state   => 1,
                                                 childs  => { '!=' => undef },
                                               ],
                                    columns => [qw/name last_state_change/],
                                   );

    if(defined $outages and scalar @{$outages} > 0) {
        my $hostcomments = {};
        my $tmp = $c->db->get_comments(filter  => [ Thruk::Utils::Auth::get_auth_filter($c, 'comments'),
                                                    { service_description => undef },
                                                  ],
                                       columns => [qw/host_name/],
                                      );
        for my $com (@{$tmp}) {
            $hostcomments->{$com->{'host_name'}} = 0 unless defined $hostcomments->{$com->{'host_name'}};
            $hostcomments->{$com->{'host_name'}}++;
        }

        my $tmp2 = $c->db->get_hosts(filter  => [ Thruk::Utils::Auth::get_auth_filter($c, 'hosts') ],
                                     columns => [qw/name childs num_services/],
                                    );
        my $all_hosts = Thruk::Base::array2hash($tmp2, 'name');

        my $count_subtree = _subtree_sizes($all_hosts);
        for my $host (@{$outages}) {

            # get number of comments
            $host->{'comment_count'} = 0;
            $host->{'comment_count'} = $hostcomments->{$host->{'name'}} if defined $hostcomments->{$host->{'name'}};

            # count number of affected hosts / services
            my($affected_hosts, $affected_services) = $count_subtree->($host->{'name'});
            $host->{'affected_hosts'}    = $affected_hosts;
            $host->{'affected_services'} = $affected_services;

            $host->{'severity'} = int($affected_hosts + $affected_services/4);
        }
    }

    # sort by severity
    my $sortedoutages = Thruk::Backend::Manager::sort_result($c, $outages, { 'DESC' => 'severity' });

    $c->stash->{outages}        = $sortedoutages;
    $c->stash->{title}          = 'Network Outages';
    $c->stash->{infoBoxTitle}   = 'Network Outages';
    $c->stash->{page}           = 'outages';
    $c->stash->{template}       = 'outages.tt';

    Thruk::Utils::ssi_include($c);

    return 1;
}

##########################################################
# returns a memoized function counting the number of affected hosts and services for a given host by walking its child tree.
sub _subtree_sizes {
    my($all_hosts) = @_;

    my %affected_hosts;
    my %affected_services;
    my %state; # 1 = currently being explored, 2 = finished

    my $count;

    # returns tuple in the tree that starts with host: affected_hosts , affected_services
    $count = sub {
        my($host) = @_;
        my $row = $all_hosts->{$host};
        return(0, 0) unless defined $row;
        return(0, 0) if $state{$host} and $state{$host} == 1;
        return($affected_hosts{$host}, $affected_services{$host}) if $state{$host} and $state{$host} == 2;

        $state{$host} = 1;
        if(defined $row->{'childs'} and ref $row->{'childs'} eq 'ARRAY') {
            for my $child (@{$row->{'childs'}}) {
                my($child_affected_hosts, $child_affected_services) = $count->($child);
                $affected_hosts{$host}    += $child_affected_hosts;
                $affected_services{$host} += $child_affected_services;
            }
        }

        # add number of directly affected hosts after exploring children
        $affected_hosts{$host}++;

        # add number of directly affected services after exploring children
        $affected_services{$host} += $row->{'num_services'} || 0;

        # mark this host as finished i.e its results can be read directly
        $state{$host} = 2;

        return($affected_hosts{$host}, $affected_services{$host});
    };

    return($count);
}

1;

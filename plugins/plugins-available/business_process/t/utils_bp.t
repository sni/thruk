use warnings;
use strict;
use Test::More;

BEGIN {
    plan skip_all => 'internal test only' if defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'};
    plan tests => 15;
}

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

use_ok('Thruk::BP::Utils');
use_ok('Thruk::BP::Components::BP');

is_deeply(Thruk::BP::Utils::clean_function_args(), [], "args 1");
is_deeply(Thruk::BP::Utils::clean_function_args("'host', 'svc'"), ["host", "svc"], "args 2");
is_deeply(Thruk::BP::Utils::clean_function_args('"host", "svc"'), ["host", "svc"], "args 3");
is_deeply(Thruk::BP::Utils::clean_function_args('"host", \'svc\''), ["host", "svc"], "args 4");
is_deeply(Thruk::BP::Utils::clean_function_args('"host"'), ["host"], "args 5");
is_deeply(Thruk::BP::Utils::clean_function_args('1, 2'), [1, 2], "args 6");
is_deeply(Thruk::BP::Utils::clean_function_args('1'), [1], "args 7");
is_deeply(Thruk::BP::Utils::clean_function_args('"1a", 5, "a2a"'), ['1a', 5, 'a2a'], "args 8");

# custom functions
my $functions = Thruk::BP::Utils::_parse_custom_functions('t/xt/business_process/data/test_cust_function.pm');
my $expected_functions = [{
            'args' => [{
                          'args' => 'text that should be echoed',
                          'name' => 'Text',
                          'type' => 'text'
                       }, {
                          'args' => [ 'no', 'yes' ],
                          'type' => 'checkbox',
                          'name' => 'Reverse'
                       }, {
                          'args' => [ 'no', 'yes' ],
                          'name' => 'Uppercase',
                          'type' => 'select'
                       }],
            'file' => 't/xt/business_process/data/test_cust_function.pm',
            'function' => 'echo_function',
            'name' => 'echo_function',
            'help' => 'echofunction:

This function just echoes the
provided text sample and optionally
reverses the text.'
}];
is_deeply($functions, $expected_functions, 'parse custom functions 1');

###########################################################
# group members must be fetched when filters are in place, even if there
# is no direct status node for them - otherwise group statistics stay empty
my $services = [{
    host_name                => 'host1',
    description              => 'svc-crit',
    state                    => 2,
    has_been_checked         => 1,
    acknowledged             => 0,
    scheduled_downtime_depth => 0,
    checks_enabled           => 1,
    check_type               => 0,
    host_state               => 0,
    groups                   => ['bp-test-sg'],
    host_groups              => [],
}];

my $db = bless {
    'calls'    => [],
    'services' => $services,
}, 'main';

sub get_hosts {
    my($self) = @_;
    push @{$self->{'calls'}}, 'get_hosts';
    return [];
}
sub get_services {
    my($self) = @_;
    push @{$self->{'calls'}}, 'get_services';
    return $self->{'services'};
}
sub get_servicegroups { die("direct servicegroup statistics must not be used with filters"); }
sub get_hostgroups    { die("direct hostgroup statistics must not be used with filters"); }

my $c = bless { 'db' => $db }, 'main';
sub db { return $_[0]->{'db'}; }

my $bp = bless {
    'name'           => 'test',
    'filter'         => ['downtime_filter'],
    'default_filter' => [],
    'nodes'          => [
        { id => 'node2', function => 'groupstatus', hostgroup => '', servicegroup => 'bp-test-sg', filter => [] },
    ],
}, 'Thruk::BP::Components::BP';

my $livedata = $bp->bulk_fetch_live_data($c);
is_deeply($db->{'calls'}, ['get_services'], 'group members are fetched for group only business processes');
my $sg = $livedata->{'servicegroups'}->{'bp-test-sg'};
is($sg->{'num_services'},        1, 'servicegroup has one service');
is($sg->{'num_services_crit'},   1, 'servicegroup has one critical service');
is($sg->{'worst_service_state'}, 2, 'servicegroup worst state is critical');

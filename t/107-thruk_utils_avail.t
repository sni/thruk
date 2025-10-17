use warnings;
use strict;
use Test::More;
use utf8;

plan tests => 12;

use_ok("Monitoring::Availability");
use_ok("Thruk::Utils::Avail");

my $host    = 'test_host';
my $service = 'service';
my $start   = 1264110000;
my $end     = 1264135000;
my $ma = Monitoring::Availability->new();

###########################################################
# simple outage
{
    my $log = '
[1264110000] SERVICE ALERT: test_host;service;OK;HARD;1;check is ok
[1264111000] SERVICE ALERT: test_host;service;UNKNOWN;SOFT;1;check is unknown
[1264112000] SERVICE ALERT: test_host;service;UNKNOWN;HARD;2;check is unknown
[1264115000] SERVICE ALERT: test_host;service;OK;HARD;1;check is ok
';
    my $expected_outages =[{
        'host'          => 'test_host',
        'service'       => 'service',
        'start'         => 1264112000,
        'end'           => 1264115000,
        'duration'      => 3000,
        'plugin_output' => 'check is unknown',
        'type'          => 'SERVICE UNKNOWN (HARD)',
        'class'         => 'unknown',
    }];
    my $ma_options = {
        'start'                        => $start,
        'end'                          => $end,
        'log_string'                   => $log,
        'services'                     => [{ 'host' => $host, 'service' => $service }],
        'assumeinitialstates'          => "yes",
    };
    my $avail_data = $ma->calculate(%{$ma_options});
    my $logs       = $ma->get_condensed_logs();
    my $outages    = Thruk::Utils::Avail::outages($logs, {'critical' => 1, 'unknown' => 1}, $start, $end, $host, $service);
    is_deeply($outages, $expected_outages, "simple outage as expected");
};

###########################################################
# soft outage
{
    my $log = '
[1264110000] SERVICE ALERT: test_host;service;OK;HARD;1;check is ok
[1264111000] SERVICE ALERT: test_host;service;UNKNOWN;SOFT;1;check is unknown
[1264112000] SERVICE ALERT: test_host;service;UNKNOWN;HARD;2;check is unknown
[1264115000] SERVICE ALERT: test_host;service;OK;HARD;1;check is ok
';
    my $expected_outages =[{
        'host'          => 'test_host',
        'service'       => 'service',
        'start'         => 1264111000,
        'end'           => 1264115000,
        'duration'      => 4000,
        'plugin_output' => 'check is unknown',
        'type'          => 'SERVICE UNKNOWN (HARD)',
        'class'         => 'unknown',
    }];
    my $ma_options = {
        'start'                        => $start,
        'end'                          => $end,
        'log_string'                   => $log,
        'services'                     => [{ 'host' => $host, 'service' => $service }],
        'assumeinitialstates'          => "yes",
        'includesoftstates'            => "yes",
    };
    my $avail_data = $ma->calculate(%{$ma_options});
    my $logs       = $ma->get_condensed_logs();
    my $outages    = Thruk::Utils::Avail::outages($logs, {'critical' => 1, 'unknown' => 1}, $start, $end, $host, $service);
    is_deeply($outages, $expected_outages, "simple outage as expected");
};

###########################################################
# multiple outages
{
    my $log = '
[1264110000] SERVICE ALERT: test_host;service;OK;HARD;1;check is ok
[1264111000] SERVICE ALERT: test_host;service;UNKNOWN;SOFT;1;check is unknown
[1264112000] SERVICE ALERT: test_host;service;UNKNOWN;HARD;2;check is unknown
[1264113000] SERVICE DOWNTIME ALERT: test_host;service;STARTED; Service has entered a period of scheduled downtime
[1264114000] SERVICE DOWNTIME ALERT: test_host;service;CANCELLED; Scheduled downtime for service has been cancelled.
[1264115000] SERVICE ALERT: test_host;service;OK;HARD;1;check is ok
[1264120000] SERVICE ALERT: test_host;service;UNKNOWN;SOFT;1;check is unknown again
[1264121000] SERVICE ALERT: test_host;service;UNKNOWN;HARD;2;check is unknown again
[1264122000] SERVICE ALERT: test_host;service;OK;HARD;1;check is ok
[1264130000] SERVICE DOWNTIME ALERT: test_host;service;STARTED; Service has entered a period of scheduled downtime
[1264131000] SERVICE ALERT: test_host;service;UNKNOWN;SOFT;1;check is unknown during downtime
[1264132000] SERVICE ALERT: test_host;service;UNKNOWN;HARD;2;check is unknown during downtime
[1264134000] SERVICE ALERT: test_host;service;OK;HARD;1;check is ok
[1264135000] SERVICE DOWNTIME ALERT: test_host;service;CANCELLED; Scheduled downtime for service has been cancelled.
';

    my $ma = Monitoring::Availability->new();
    my $ma_options = {
        'start'                        => $start,
        'end'                          => $end,
        'log_string'                   => $log,
        'services'                     => [{ 'host' => $host, 'service' => $service }],
        'assumeinitialstates'          => "yes",
    };
    my $expected_outages =[{
        'host'          => 'test_host',
        'service'       => 'service',
        'start'         => 1264121000,
        'end'           => 1264122000,
        'duration'      => 1000,
        'plugin_output' => 'check is unknown again',
        'type'          => 'SERVICE UNKNOWN (HARD)',
        'class'         => 'unknown',
    }, {
        'host'          => 'test_host',
        'service'       => 'service',
        'start'         => 1264114000,
        'end'           => 1264115000,
        'duration'      => 1000,
        'plugin_output' => 'check is unknown',
        'type'          => 'SERVICE UNKNOWN (HARD)',
        'class'         => 'unknown',
    }, {
        'host'          => 'test_host',
        'service'       => 'service',
        'start'         => 1264112000,
        'end'           => 1264113000,
        'duration'      => 1000,
        'plugin_output' => 'check is unknown',
        'type'          => 'SERVICE UNKNOWN (HARD)',
        'class'         => 'unknown',
    }];
    my $avail_data = $ma->calculate(%{$ma_options});
    my $logs       = $ma->get_condensed_logs();
    my $outages    = Thruk::Utils::Avail::outages($logs, {'critical' => 1, 'unknown' => 1}, $start, $end, $host, $service);
    is_deeply($outages, $expected_outages, "multiple outage as expected");
};

###########################################################
# timeperiod outage
{
    my $log = '
[1264110000] TIMEPERIOD TRANSITION: test;1;0
[1264110000] SERVICE ALERT: test_host;service;OK;HARD;1;check is ok
[1264111000] SERVICE ALERT: test_host;service;UNKNOWN;SOFT;1;check is unknown
[1264112000] SERVICE ALERT: test_host;service;UNKNOWN;HARD;2;check is unknown
[1264113000] TIMEPERIOD TRANSITION: test;0;1
[1264115000] SERVICE ALERT: test_host;service;OK;HARD;1;check is ok
';
    my $expected_outages =[{
        'host'          => 'test_host',
        'service'       => 'service',
        'start'         => 1264113000,
        'end'           => 1264115000,
        'duration'      => 2000,
        'plugin_output' => 'check is unknown',
        'type'          => 'SERVICE UNKNOWN (HARD)',
        'class'         => 'unknown',
    }];
    my $ma_options = {
        'start'                        => $start,
        'end'                          => $end,
        'log_string'                   => $log,
        'services'                     => [{ 'host' => $host, 'service' => $service }],
        'assumeinitialstates'          => "yes",
        'rpttimeperiod'                => "test",
    };
    my $avail_data = $ma->calculate(%{$ma_options});
    my $logs       = $ma->get_condensed_logs();
    my $outages    = Thruk::Utils::Avail::outages($logs, {'critical' => 1, 'unknown' => 1}, $start, $end, $host, $service);
    is_deeply($outages, $expected_outages, "timeperiod outage as expected");
};

###########################################################
# hard outage with soft recovery
{
    my $log = '
[1747173600] CURRENT HOST STATE: test_host;UP;HARD;1;OK...
[1747173600] CURRENT SERVICE STATE: test_host;service;OK;HARD;1;OK:
[1747225000] HOST ALERT: test_host;DOWN;SOFT;1;down...
[1747225000] SERVICE INFO: test_host;service; Service switch to hard down state due to host down.
[1747225000] SERVICE ALERT: test_host;service;CRITICAL;HARD;1;critical...
[1747225000] HOST ALERT: test_host;UP;HARD;3;up again...
[1747225100] SERVICE ALERT: test_host;service;CRITICAL;SOFT;1;critical...
[1747225500] SERVICE ALERT: test_host;service;OK;SOFT;2;ok again...
[1747226000] HOST ALERT: test_host;DOWN;SOFT;1;down...
[1747226050] SERVICE INFO: test_host;service; Service switch to hard down state due to host down.
[1747226050] SERVICE ALERT: test_host;service;CRITICAL;HARD;1;critical...
[1747226100] HOST ALERT: test_host;DOWN;SOFT;2;down...
[1747226200] HOST ALERT: test_host;UP;SOFT;3;up again...
[1747227300] SERVICE ALERT: test_host;service;OK;SOFT;1;ok again...
[1747228000] SERVICE ALERT: test_host;service;OK;HARD;1;ok again...
';
    my $start   = 1747170000;
    my $end     = 1747230000;
    my $expected_outages =[{
        'host'          => 'test_host',
        'service'       => 'service',
        'class'         => 'critical',
        'start'         => 1747226050,
        'end'           => 1747227300,
        'duration'      => 1250,
        'plugin_output' => 'critical...',
        'type'          => 'SERVICE CRITICAL (HARD)',
        },
        {
        'host'          => 'test_host',
        'service'       => 'service',
        'class'         => 'critical',
        'start'         => 1747225000,
        'end'           => 1747225500,
        'duration'      => 500,
        'plugin_output' => 'critical...',
        'type'          => 'SERVICE CRITICAL (HARD)',
    }];
    my $ma_options = {
        'start'                        => $start,
        'end'                          => $end,
        'log_string'                   => $log,
        'services'                     => [{ 'host' => $host, 'service' => $service }],
        'assumeinitialstates'          => "yes",
    };
    my $expected_availability = {
        'hosts' => {},
        'services' => {
            'test_host' => {
                'service' => {
                                'scheduled_time_critical'               => 0,
                                'scheduled_time_indeterminate'          => 0,
                                'scheduled_time_ok'                     => 0,
                                'scheduled_time_unknown'                => 0,
                                'scheduled_time_warning'                => 0,
                                'time_critical'                         => 1750,
                                'time_indeterminate_nodata'             => 3600,
                                'time_indeterminate_notrunning'         => 0,
                                'time_indeterminate_outside_timeperiod' => 0,
                                'time_ok'                               => 54650,
                                'time_unknown'                          => 0,
                                'time_warning'                          => 0,
                },
            },
        },
        'total' => {
            'start'     => 1747170000,
            'end'       => 1747230000,
            'duration'  => 60000,
            'time_indeterminate_outside_timeperiod' => 0,
        },
    };
    my $avail_data = $ma->calculate(%{$ma_options});
    is_deeply($avail_data, $expected_availability, "host downtimes in between availability as expected");
    my $logs       = $ma->get_condensed_logs();
    my $outages    = Thruk::Utils::Avail::outages($logs, {'critical' => 1, 'unknown' => 1}, $start, $end, $host, $service);
    is_deeply($outages, $expected_outages, "soft recovery outage as expected");
};

###########################################################
# service outage with host downtime in between
{
    my $log = '
[1747173600] CURRENT HOST STATE: test_host;UP;HARD;1;OK...
[1747173600] CURRENT SERVICE STATE: test_host;service;OK;HARD;1;OK:
[1747224000] HOST DOWNTIME ALERT: test_host;STARTED; Host has entered a period of scheduled downtime
[1747225000] SERVICE ALERT: test_host;service;CRITICAL;HARD;1;critical...
[1747227000] HOST DOWNTIME ALERT: test_host;CANCELLED; Scheduled downtime for host has been cancelled.
[1747227500] SERVICE ALERT: test_host;service;OK;HARD;1;ok again...
';
    my $start   = 1747223000;
    my $end     = 1747228000;
    my $expected_outages =[{
        'host'          => 'test_host',
        'service'       => 'service',
        'class'         => 'critical',
        'start'         => 1747227000,
        'end'           => 1747227500,
        'duration'      => 500,
        'plugin_output' => 'critical...',
        'type'          => 'SERVICE CRITICAL (HARD)',
    }];
    my $ma_options = {
        'start'                        => $start,
        'end'                          => $end,
        'log_string'                   => $log,
        'services'                     => [{ 'host' => $host, 'service' => $service }],
        'assumeinitialstates'          => "yes",
    };
    my $expected_availability = {
        'hosts' => {},
        'services' => {
            'test_host' => {
                'service' => {
                    'scheduled_time_critical'               => 2000,
                    'scheduled_time_indeterminate'          => 0,
                    'scheduled_time_ok'                     => 1000,
                    'scheduled_time_unknown'                => 0,
                    'scheduled_time_warning'                => 0,
                    'time_critical'                         => 2500,
                    'time_indeterminate_nodata'             => 0,
                    'time_indeterminate_notrunning'         => 0,
                    'time_indeterminate_outside_timeperiod' => 0,
                    'time_ok'                               => 2500,
                    'time_unknown'                          => 0,
                    'time_warning'                          => 0
                }
            }
        },
        'total' => {
            'start'    => 1747223000,
            'end'      => 1747228000,
            'duration' => 5000,
            'time_indeterminate_outside_timeperiod' => 0,
        },
    };
    my $avail_data = $ma->calculate(%{$ma_options});
    is_deeply($avail_data, $expected_availability, "host downtimes in between availability as expected");
    my $logs       = $ma->get_condensed_logs();
    my $outages    = Thruk::Utils::Avail::outages($logs, {'critical' => 1, 'unknown' => 1}, $start, $end, $host, $service);
    is_deeply($outages, $expected_outages, "host downtimes in between outage as expected");
};

###########################################################
# service outage with downtime in the middle
{
    my $log = '
[1747173600] CURRENT HOST STATE: test_host;UP;HARD;1;OK...
[1747173600] CURRENT SERVICE STATE: test_host;service;OK;HARD;1;OK:
[1747223000] SERVICE ALERT: test_host;service;CRITICAL;HARD;1;critical...
[1747224000] HOST DOWNTIME ALERT: test_host;STARTED; Host has entered a period of scheduled downtime
[1747224500] SERVICE ALERT: test_host;service;CRITICAL;HARD;1;still critical...
[1747225000] SERVICE DOWNTIME ALERT: test_host;service;STARTED; Service has entered a period of scheduled downtime
[1747227000] HOST DOWNTIME ALERT: test_host;CANCELLED; Scheduled downtime for host has been cancelled.
[1747227200] SERVICE DOWNTIME ALERT: test_host;service;CANCELLED; Scheduled downtime for service has been cancelled.
[1747227500] SERVICE ALERT: test_host;service;OK;HARD;1;ok again...
';
    my $start   = 1747223000;
    my $end     = 1747228000;
    my $expected_outages =[{
        'host'          => 'test_host',
        'service'       => 'service',
        'class'         => 'critical',
        'start'         => 1747227200,
        'end'           => 1747227500,
        'duration'      => 300,
        'plugin_output' => 'still critical...',
        'type'          => 'SERVICE CRITICAL (HARD)',
    }, {
        'host'          => 'test_host',
        'service'       => 'service',
        'class'         => 'critical',
        'start'         => 1747223000,
        'end'           => 1747224000,
        'duration'      => 1000,
        'plugin_output' => 'critical...',
        'type'          => 'SERVICE CRITICAL (HARD)',
    }];
    my $ma_options = {
        'start'                        => $start,
        'end'                          => $end,
        'log_string'                   => $log,
        'services'                     => [{ 'host' => $host, 'service' => $service }],
        'assumeinitialstates'          => "yes",
    };
    my $expected_availability = {
        'hosts'    => {},
        'services' => {
            'test_host' => {
                'service' => {
                    'time_indeterminate_notrunning'         => 0,
                    'time_indeterminate_nodata'             => 0,
                    'scheduled_time_unknown'                => 0,
                    'scheduled_time_warning'                => 0,
                    'time_ok'                               => 500,
                    'time_warning'                          => 0,
                    'time_critical'                         => 4500,
                    'time_unknown'                          => 0,
                    'scheduled_time_indeterminate'          => 0,
                    'scheduled_time_critical'               => 3200,
                    'time_indeterminate_outside_timeperiod' => 0,
                    'scheduled_time_ok'                     => 0,
                },
            },
        },
        'total' => {
            'start'    => 1747223000,
            'end'      => 1747228000,
            'duration' => 5000,
            'time_indeterminate_outside_timeperiod' => 0,
        },
    };

    my $avail_data = $ma->calculate(%{$ma_options});
    is_deeply($avail_data, $expected_availability, "host downtimes in the middle availability as expected");
    my $logs       = $ma->get_condensed_logs();
    my $outages    = Thruk::Utils::Avail::outages($logs, {'critical' => 1, 'unknown' => 1}, $start, $end, $host, $service);
    is_deeply($outages, $expected_outages, "host downtimes in the middle outage as expected");
};

###########################################################

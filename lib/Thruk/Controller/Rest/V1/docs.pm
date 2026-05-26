package Thruk::Controller::Rest::V1::docs;

use warnings;
use strict;
use Cpanel::JSON::XS qw/decode_json/;

=head1 NAME

Thruk::Controller::Rest::V1::docs - Contains attributes for all endpoints

=head1 DESCRIPTION

Thruk Controller

=head1 METHODS

=head2 keys

    keys()

returns raw attributes for all rest endpoints

=cut

##########################################################
sub keys {
    our $doc_data;
    if(!$doc_data) {
        my $data = "";
        while(<DATA>) {
            my $line = $_;
            next if $line =~ m/^\s*\#/mx;
            next if $line =~ m/^\s*$/mx;
            $data .= $line;
        }
        $doc_data = decode_json($data);
    }
    return($doc_data);
}

##########################################################

1;

__DATA__
{
 "/checks/stats": {
  "GET": {
   "columns": [
    {
     "description": "percent of active hosts during the last 15 minutes",
     "name": "hosts_active_15_perc",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "amount of active hosts during the last 15 minutes",
     "name": "hosts_active_15_sum",
     "type": "number",
     "unit": ""
    },
    {
     "description": "same for last minute",
     "name": "hosts_active_1_perc",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "same for last minute",
     "name": "hosts_active_1_sum",
     "type": "number",
     "unit": ""
    },
    {
     "description": "same for last 5 minutes",
     "name": "hosts_active_5_perc",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "same for last 5 minutes",
     "name": "hosts_active_5_sum",
     "type": "number",
     "unit": ""
    },
    {
     "description": "same for last 60 minutes",
     "name": "hosts_active_60_perc",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "same for last 60 minutes",
     "name": "hosts_active_60_sum",
     "type": "number",
     "unit": ""
    },
    {
     "description": "percent of total active hosts",
     "name": "hosts_active_all_perc",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "amount of total active hosts",
     "name": "hosts_active_all_sum",
     "type": "number",
     "unit": ""
    },
    {
     "description": "average percent state change",
     "name": "hosts_active_state_change_avg",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "maximum state change over all active hosts",
     "name": "hosts_active_state_change_max",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "minimum state change over all active hosts",
     "name": "hosts_active_state_change_min",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "sum state change over all hosts",
     "name": "hosts_active_state_change_sum",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "number of active hosts",
     "name": "hosts_active_sum",
     "type": "number",
     "unit": ""
    },
    {
     "description": "average execution time over all hosts",
     "name": "hosts_execution_time_avg",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "maximum execution time over all hosts",
     "name": "hosts_execution_time_max",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "minimum execution time over all hosts",
     "name": "hosts_execution_time_min",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "sum execution time over all hosts",
     "name": "hosts_execution_time_sum",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "host latency average",
     "name": "hosts_latency_avg",
     "type": "number",
     "unit": ""
    },
    {
     "description": "minimum host latency",
     "name": "hosts_latency_max",
     "type": "number",
     "unit": ""
    },
    {
     "description": "minimum host latency",
     "name": "hosts_latency_min",
     "type": "number",
     "unit": ""
    },
    {
     "description": "sum latency over all hosts",
     "name": "hosts_latency_sum",
     "type": "number",
     "unit": ""
    },
    {
     "description": "percent of passive hosts during the last 15 minutes",
     "name": "hosts_passive_15_perc",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "amount of passive hosts during the last 15 minutes",
     "name": "hosts_passive_15_sum",
     "type": "number",
     "unit": ""
    },
    {
     "description": "same for last minute",
     "name": "hosts_passive_1_perc",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "same for last minute",
     "name": "hosts_passive_1_sum",
     "type": "number",
     "unit": ""
    },
    {
     "description": "same for last 5 minutes",
     "name": "hosts_passive_5_perc",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "same for last 5 minutes",
     "name": "hosts_passive_5_sum",
     "type": "number",
     "unit": ""
    },
    {
     "description": "same for last 60 minutes",
     "name": "hosts_passive_60_perc",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "same for last 60 minutes",
     "name": "hosts_passive_60_sum",
     "type": "number",
     "unit": ""
    },
    {
     "description": "percent of total passive hosts",
     "name": "hosts_passive_all_perc",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "amount of total passive hosts",
     "name": "hosts_passive_all_sum",
     "type": "number",
     "unit": ""
    },
    {
     "description": "average percent state change for passive hosts",
     "name": "hosts_passive_state_change_avg",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "maximum state change over all passive hosts",
     "name": "hosts_passive_state_change_max",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "minimum state change over all passive hosts",
     "name": "hosts_passive_state_change_min",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "sum state change over all passive hosts",
     "name": "hosts_passive_state_change_sum",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "number of passive hosts",
     "name": "hosts_passive_sum",
     "type": "number",
     "unit": ""
    },
    {
     "description": "percent of active services during the last 15 minutes",
     "name": "services_active_15_perc",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "amount of active services during the last 15 minutes",
     "name": "services_active_15_sum",
     "type": "number",
     "unit": ""
    },
    {
     "description": "same for last minute",
     "name": "services_active_1_perc",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "same for last minute",
     "name": "services_active_1_sum",
     "type": "number",
     "unit": ""
    },
    {
     "description": "same for last 5 minutes",
     "name": "services_active_5_perc",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "same for last 5 minutes",
     "name": "services_active_5_sum",
     "type": "number",
     "unit": ""
    },
    {
     "description": "same for last 60 minutes",
     "name": "services_active_60_perc",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "same for last 60 minutes",
     "name": "services_active_60_sum",
     "type": "number",
     "unit": ""
    },
    {
     "description": "percent of total active services",
     "name": "services_active_all_perc",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "amount of total active services",
     "name": "services_active_all_sum",
     "type": "number",
     "unit": ""
    },
    {
     "description": "average percent state change",
     "name": "services_active_state_change_avg",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "maximum state change over all active services",
     "name": "services_active_state_change_max",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "minimum state change over all active services",
     "name": "services_active_state_change_min",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "sum state change over all services",
     "name": "services_active_state_change_sum",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "number of active services",
     "name": "services_active_sum",
     "type": "number",
     "unit": ""
    },
    {
     "description": "average execution time over all services",
     "name": "services_execution_time_avg",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "maximum execution time over all services",
     "name": "services_execution_time_max",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "minimum execution time over all services",
     "name": "services_execution_time_min",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "sum execution time over all services",
     "name": "services_execution_time_sum",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "services latency average",
     "name": "services_latency_avg",
     "type": "number",
     "unit": ""
    },
    {
     "description": "minimum services latency",
     "name": "services_latency_max",
     "type": "number",
     "unit": ""
    },
    {
     "description": "minimum services latency",
     "name": "services_latency_min",
     "type": "number",
     "unit": ""
    },
    {
     "description": "sum latency over all services",
     "name": "services_latency_sum",
     "type": "number",
     "unit": ""
    },
    {
     "description": "percent of passive services during the last 15 minutes",
     "name": "services_passive_15_perc",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "amount of passive services during the last 15 minutes",
     "name": "services_passive_15_sum",
     "type": "number",
     "unit": ""
    },
    {
     "description": "same for last minute",
     "name": "services_passive_1_perc",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "same for last minute",
     "name": "services_passive_1_sum",
     "type": "number",
     "unit": ""
    },
    {
     "description": "same for last 5 minutes",
     "name": "services_passive_5_perc",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "same for last 5 minutes",
     "name": "services_passive_5_sum",
     "type": "number",
     "unit": ""
    },
    {
     "description": "same for last 60 minutes",
     "name": "services_passive_60_perc",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "same for last 60 minutes",
     "name": "services_passive_60_sum",
     "type": "number",
     "unit": ""
    },
    {
     "description": "percent of total passive services",
     "name": "services_passive_all_perc",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "amount of total passive services",
     "name": "services_passive_all_sum",
     "type": "number",
     "unit": ""
    },
    {
     "description": "average percent state change for passive services",
     "name": "services_passive_state_change_avg",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "maximum state change over all passive services",
     "name": "services_passive_state_change_max",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "minimum state change over all passive services",
     "name": "services_passive_state_change_min",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "sum state change over all passive services",
     "name": "services_passive_state_change_sum",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "number of passive services",
     "name": "services_passive_sum",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/config/diff": {
  "GET": {
   "columns": [
    {
     "description": "file name of changed file",
     "name": "file",
     "type": "string",
     "unit": ""
    },
    {
     "description": "diff output",
     "name": "output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "id as defined in Thruk::Backend component configuration",
     "name": "peer_key",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/config/files": {
  "GET": {
   "columns": [
    {
     "description": "raw file content",
     "name": "content",
     "type": "string",
     "unit": ""
    },
    {
     "description": "hex sum for this file",
     "name": "hex",
     "type": "string",
     "unit": ""
    },
    {
     "description": "unix timestamp of last modification",
     "name": "mtime",
     "type": "time",
     "unit": ""
    },
    {
     "description": "filesystem path",
     "name": "path",
     "type": "string",
     "unit": ""
    },
    {
     "description": "id as defined in Thruk::Backend component configuration",
     "name": "peer_key",
     "type": "string",
     "unit": ""
    },
    {
     "description": "readonly flag",
     "name": "readonly",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/config/fullobjects": {
  "GET": {
   "columns": [
    {
     "description": "object attributes like defined in the source config files",
     "name": "...",
     "type": "string",
     "unit": ""
    },
    {
     "description": "filename and line number",
     "name": ":FILE",
     "type": "string",
     "unit": ""
    },
    {
     "description": "internal uniq id",
     "name": ":ID",
     "type": "string",
     "unit": ""
    },
    {
     "description": "id of remote site",
     "name": ":PEER_KEY",
     "type": "string",
     "unit": ""
    },
    {
     "description": "name of remote site",
     "name": ":PEER_NAME",
     "type": "string",
     "unit": ""
    },
    {
     "description": "flag whether file is readonly",
     "name": ":READONLY",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "list of used template",
     "name": ":TEMPLATES",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "object type, ex.: host",
     "name": ":TYPE",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/config/objects": {
  "GET": {
   "columns": [
    {
     "description": "object attributes like defined in the source config files",
     "name": "...",
     "type": "string",
     "unit": ""
    },
    {
     "description": "filename and line number",
     "name": ":FILE",
     "type": "string",
     "unit": ""
    },
    {
     "description": "internal uniq id",
     "name": ":ID",
     "type": "",
     "unit": ""
    },
    {
     "description": "id of remote site",
     "name": ":PEER_KEY",
     "type": "string",
     "unit": ""
    },
    {
     "description": "name of remote site",
     "name": ":PEER_NAME",
     "type": "string",
     "unit": ""
    },
    {
     "description": "flag whether file is readonly",
     "name": ":READONLY",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "object type, ex.: host",
     "name": ":TYPE",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/config/precheck": {
  "GET": {
   "columns": [
    {
     "description": "list of errors encountered",
     "name": "errors",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "boolean flag whether configuration check has failed or not",
     "name": "failed",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "id as defined in Thruk::Backend component configuration",
     "name": "peer_key",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/contacts/totals": {
  "GET": {
   "columns": [
    {
     "description": "total number of contacts",
     "name": "total",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/hostgroups/<name>/availability": {
  "GET": {
   "columns": [
    {
     "description": "host name",
     "name": "host",
     "type": "string",
     "unit": ""
    },
    {
     "description": "total seconds in state down (during downtimes)",
     "name": "scheduled_time_down",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time down in percent of total time (during downtimes)",
     "name": "scheduled_time_down_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds unknown (during downtimes)",
     "name": "scheduled_time_indeterminate",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time unknown in percent of total time (during downtimes)",
     "name": "scheduled_time_indeterminate_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state unreachable (during downtimes)",
     "name": "scheduled_time_unreachable",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time unreachable in percent of total time (during downtimes)",
     "name": "scheduled_time_unreachable_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state up (during downtimes)",
     "name": "scheduled_time_up",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time up in percent of total time (during downtimes)",
     "name": "scheduled_time_up_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state down",
     "name": "time_down",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time down in percent of total time",
     "name": "time_down_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds without any data",
     "name": "time_indeterminate_nodata",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time without any data in percent of total time",
     "name": "time_indeterminate_nodata_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds during core not running",
     "name": "time_indeterminate_notrunning",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time during core not running in percent of total time",
     "name": "time_indeterminate_notrunning_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds outside the given timeperiod",
     "name": "time_indeterminate_outside_timeperiod",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time outside the given timeperiod in percent of total time",
     "name": "time_indeterminate_outside_timeperiod_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state unreachable",
     "name": "time_unreachable",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time unreachable in percent of total time",
     "name": "time_unreachable_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state up",
     "name": "time_up",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time up in percent of total time",
     "name": "time_up_percent",
     "type": "number",
     "unit": "%"
    }
   ]
  }
 },
 "/hostgroups/<name>/outages": {
  "GET": {
   "columns": [
    {
     "description": "host/service status",
     "name": "class",
     "type": "string",
     "unit": ""
    },
    {
     "description": "outage duration in seconds",
     "name": "duration",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "unix timestamp of outage end",
     "name": "end",
     "type": "time",
     "unit": ""
    },
    {
     "description": "host name",
     "name": "host",
     "type": "string",
     "unit": ""
    },
    {
     "description": "last plugin output during outage",
     "name": "plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "service description (only for service outages)",
     "name": "service",
     "type": "string",
     "unit": ""
    },
    {
     "description": "unix timestamp of outage start",
     "name": "start",
     "type": "time",
     "unit": ""
    },
    {
     "description": "log entry type",
     "name": "type",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/hosts/<name>/availability": {
  "GET": {
   "columns": [
    {
     "description": "total seconds in state down (during downtimes)",
     "name": "scheduled_time_down",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time down in percent of total time (during downtimes)",
     "name": "scheduled_time_down_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds unknown (during downtimes)",
     "name": "scheduled_time_indeterminate",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time unknown in percent of total time (during downtimes)",
     "name": "scheduled_time_indeterminate_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state unreachable (during downtimes)",
     "name": "scheduled_time_unreachable",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time unreachable in percent of total time (during downtimes)",
     "name": "scheduled_time_unreachable_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state up (during downtimes)",
     "name": "scheduled_time_up",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time up in percent of total time (during downtimes)",
     "name": "scheduled_time_up_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state down",
     "name": "time_down",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time down in percent of total time",
     "name": "time_down_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds without any data",
     "name": "time_indeterminate_nodata",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time without any data in percent of total time",
     "name": "time_indeterminate_nodata_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds during core not running",
     "name": "time_indeterminate_notrunning",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time during core not running in percent of total time",
     "name": "time_indeterminate_notrunning_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds outside the given timeperiod",
     "name": "time_indeterminate_outside_timeperiod",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time outside the given timeperiod in percent of total time",
     "name": "time_indeterminate_outside_timeperiod_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state unreachable",
     "name": "time_unreachable",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time unreachable in percent of total time",
     "name": "time_unreachable_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state up",
     "name": "time_up",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time up in percent of total time",
     "name": "time_up_percent",
     "type": "number",
     "unit": "%"
    }
   ]
  }
 },
 "/hosts/<name>/commandline": {
  "GET": {
   "columns": [
    {
     "description": "name of the check_command including arguments",
     "name": "check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "full expanded command line (if possible)",
     "name": "command_line",
     "type": "string",
     "unit": ""
    },
    {
     "description": "contains the error if expanding failed for some reason",
     "name": "error",
     "type": "string",
     "unit": ""
    },
    {
     "description": "host name",
     "name": "host_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "id as defined in Thruk::Backend component configuration",
     "name": "peer_key",
     "type": "string",
     "unit": ""
    },
    {
     "description": "name as defined in Thruk::Backend component configuration",
     "name": "peer_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "section as defined in Thruk::Backend component configuration",
     "name": "peer_section",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/hosts/<name>/outages": {
  "GET": {
   "columns": [
    {
     "description": "host/service status",
     "name": "class",
     "type": "string",
     "unit": ""
    },
    {
     "description": "outage duration in seconds",
     "name": "duration",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "unix timestamp of outage end",
     "name": "end",
     "type": "time",
     "unit": ""
    },
    {
     "description": "host name",
     "name": "host",
     "type": "string",
     "unit": ""
    },
    {
     "description": "last plugin output during outage",
     "name": "plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "unix timestamp of outage start",
     "name": "start",
     "type": "time",
     "unit": ""
    },
    {
     "description": "log entry type",
     "name": "type",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/hosts/availability": {
  "GET": {
   "columns": [
    {
     "description": "host name",
     "name": "host",
     "type": "string",
     "unit": ""
    },
    {
     "description": "total seconds in state down (during downtimes)",
     "name": "scheduled_time_down",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time down in percent of total time (during downtimes)",
     "name": "scheduled_time_down_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds unknown (during downtimes)",
     "name": "scheduled_time_indeterminate",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time unknown in percent of total time (during downtimes)",
     "name": "scheduled_time_indeterminate_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state unreachable (during downtimes)",
     "name": "scheduled_time_unreachable",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time unreachable in percent of total time (during downtimes)",
     "name": "scheduled_time_unreachable_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state up (during downtimes)",
     "name": "scheduled_time_up",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time up in percent of total time (during downtimes)",
     "name": "scheduled_time_up_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state down",
     "name": "time_down",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time down in percent of total time",
     "name": "time_down_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds without any data",
     "name": "time_indeterminate_nodata",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time without any data in percent of total time",
     "name": "time_indeterminate_nodata_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds during core not running",
     "name": "time_indeterminate_notrunning",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time during core not running in percent of total time",
     "name": "time_indeterminate_notrunning_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds outside the given timeperiod",
     "name": "time_indeterminate_outside_timeperiod",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time outside the given timeperiod in percent of total time",
     "name": "time_indeterminate_outside_timeperiod_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state unreachable",
     "name": "time_unreachable",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time unreachable in percent of total time",
     "name": "time_unreachable_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state up",
     "name": "time_up",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time up in percent of total time",
     "name": "time_up_percent",
     "type": "number",
     "unit": "%"
    }
   ]
  }
 },
 "/hosts/outages": {
  "GET": {
   "columns": [
    {
     "description": "host/service status",
     "name": "class",
     "type": "",
     "unit": ""
    },
    {
     "description": "outage duration in seconds",
     "name": "duration",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "unix timestamp of outage end",
     "name": "end",
     "type": "time",
     "unit": ""
    },
    {
     "description": "host name",
     "name": "host",
     "type": "string",
     "unit": ""
    },
    {
     "description": "last plugin output during outage",
     "name": "plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "unix timestamp of outage start",
     "name": "start",
     "type": "time",
     "unit": ""
    },
    {
     "description": "log entry type",
     "name": "type",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/hosts/stats": {
  "GET": {
   "columns": [
    {
     "description": "number of active hosts which have active checks disabled",
     "name": "active_checks_disabled_active",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of passive hosts which have active checks disabled",
     "name": "active_checks_disabled_passive",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of down hosts",
     "name": "down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of down hosts which are acknowledged",
     "name": "down_and_ack",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of active down hosts which have active checks disabled",
     "name": "down_and_disabled_active",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of passive down hosts which have active checks disabled",
     "name": "down_and_disabled_passive",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of down hosts which are in a scheduled downtime",
     "name": "down_and_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unhandled down hosts",
     "name": "down_and_unhandled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of hard down hosts",
     "name": "down_hard",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unhandled hard down hosts",
     "name": "down_hard_unhandled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of soft down hosts",
     "name": "down_soft",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of hosts with eventhandlers disabled",
     "name": "eventhandler_disabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of flapping hosts",
     "name": "flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of hosts with flapping detection disabled",
     "name": "flapping_disabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of hosts in hard state",
     "name": "hard",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of hosts with notifications disabled",
     "name": "notifications_disabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of network outages",
     "name": "outages",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of hosts which do not accept passive check results",
     "name": "passive_checks_disabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of pending hosts",
     "name": "pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of pending hosts with active checks disabled",
     "name": "pending_and_disabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of pending hosts which are in a scheduled downtime",
     "name": "pending_and_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of down hosts which are not acknowleded or in a downtime",
     "name": "plain_down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of pending hosts which are not acknowleded or in a downtime",
     "name": "plain_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unreachable hosts which are not acknowleded or in a downtime",
     "name": "plain_unreachable",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of up hosts which are not acknowleded or in a downtime",
     "name": "plain_up",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of hosts in soft state",
     "name": "soft",
     "type": "number",
     "unit": ""
    },
    {
     "description": "total number of hosts",
     "name": "total",
     "type": "number",
     "unit": ""
    },
    {
     "description": "total number of active hosts",
     "name": "total_active",
     "type": "number",
     "unit": ""
    },
    {
     "description": "total number of passive hosts",
     "name": "total_passive",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unreachable hosts",
     "name": "unreachable",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unreachable hosts which are acknowledged",
     "name": "unreachable_and_ack",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of active unreachable hosts which have active checks disabled",
     "name": "unreachable_and_disabled_active",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of passive unreachable hosts which have active checks disabled",
     "name": "unreachable_and_disabled_passive",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unreachable hosts which are in a scheduled downtime",
     "name": "unreachable_and_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unhandled unreachable hosts",
     "name": "unreachable_and_unhandled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unreachable hosts in hard state",
     "name": "unreachable_hard",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unhandled unreachable hosts in hard state",
     "name": "unreachable_hard_unhandled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unreachable hosts in soft state",
     "name": "unreachable_soft",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of up hosts",
     "name": "up",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of active up hosts which have active checks disabled",
     "name": "up_and_disabled_active",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of passive up hosts which have active checks disabled",
     "name": "up_and_disabled_passive",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of up hosts which are in a scheduled downtime",
     "name": "up_and_scheduled",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/hosts/totals": {
  "GET": {
   "columns": [
    {
     "description": "number of down hosts",
     "name": "down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of down hosts which are neither acknowledged nor in scheduled downtime",
     "name": "down_and_unhandled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of pending hosts",
     "name": "pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "total number of hosts",
     "name": "total",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unreachable hosts",
     "name": "unreachable",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unreachable hosts which are neither acknowledged nor in scheduled downtime",
     "name": "unreachable_and_unhandled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of up hosts",
     "name": "up",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/index": {
  "GET": {
   "columns": [
    {
     "description": "description of the url",
     "name": "description",
     "type": "number",
     "unit": ""
    },
    {
     "description": "protocol to use for this url",
     "name": "protocol",
     "type": "number",
     "unit": ""
    },
    {
     "description": "the rest url",
     "name": "url",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/lmd/sites": {
  "GET": {
   "columns": [
    {
     "description": "address of the remote site",
     "name": "addr",
     "type": "string",
     "unit": ""
    },
    {
     "description": "total bytes received from this site",
     "name": "bytes_received",
     "type": "number",
     "unit": "bytes"
    },
    {
     "description": "total bytes send to this site",
     "name": "bytes_send",
     "type": "number",
     "unit": "bytes"
    },
    {
     "description": "contains the real address if using federation",
     "name": "federation_addr",
     "type": "string",
     "unit": ""
    },
    {
     "description": "contains the real peer key if using federation",
     "name": "federation_key",
     "type": "string",
     "unit": ""
    },
    {
     "description": "contains the real name if using federation",
     "name": "federation_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "contains the real backend type if using federation",
     "name": "federation_type",
     "type": "string",
     "unit": ""
    },
    {
     "description": "contains the real backend version if using federation",
     "name": "federation_version",
     "type": "string",
     "unit": ""
    },
    {
     "description": "flag if the connection is in idle mode",
     "name": "idling",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "primary id of this site",
     "name": "key",
     "type": "string",
     "unit": ""
    },
    {
     "description": "last error message",
     "name": "last_error",
     "type": "time",
     "unit": ""
    },
    {
     "description": "timestamp when the site was last time online",
     "name": "last_online",
     "type": "time",
     "unit": ""
    },
    {
     "description": "timestamp of the last received query for this site",
     "name": "last_query",
     "type": "time",
     "unit": ""
    },
    {
     "description": "timestamp of the last update",
     "name": "last_update",
     "type": "time",
     "unit": ""
    },
    {
     "description": "same as last_update",
     "name": "lmd_last_cache_update",
     "type": "time",
     "unit": ""
    },
    {
     "description": "name of the site",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "parent id for lmd federation setups",
     "name": "parent",
     "type": "string",
     "unit": ""
    },
    {
     "description": "id as defined in Thruk::Backend component configuration",
     "name": "peer_key",
     "type": "string",
     "unit": ""
    },
    {
     "description": "name as defined in Thruk::Backend component configuration",
     "name": "peer_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "number of queries received",
     "name": "queries",
     "type": "number",
     "unit": ""
    },
    {
     "description": "response time in seconds",
     "name": "response_time",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "thruks section",
     "name": "section",
     "type": "",
     "unit": ""
    },
    {
     "description": "connection status of this site",
     "name": "status",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/servicegroups/<name>/availability": {
  "GET": {
   "columns": [
    {
     "description": "host name",
     "name": "host",
     "type": "string",
     "unit": ""
    },
    {
     "description": "total seconds in state critical (during downtimes)",
     "name": "scheduled_time_critical",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time critical in percent of total time (during downtimes)",
     "name": "scheduled_time_critical_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds unknown (during downtimes)",
     "name": "scheduled_time_indeterminate",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time unknown in percent of total time (during downtimes)",
     "name": "scheduled_time_indeterminate_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state ok (during downtimes)",
     "name": "scheduled_time_ok",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time ok in percent of total time (during downtimes)",
     "name": "scheduled_time_ok_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state unknown (during downtimes)",
     "name": "scheduled_time_unknown",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time unknown in percent of total time (during downtimes)",
     "name": "scheduled_time_unknown_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state warning (during downtimes)",
     "name": "scheduled_time_warning",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time warning in percent of total time (during downtimes)",
     "name": "scheduled_time_warning_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "service description",
     "name": "service",
     "type": "string",
     "unit": ""
    },
    {
     "description": "total seconds in state critical",
     "name": "time_critical",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time critical in percent of total time",
     "name": "time_critical_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds without any data",
     "name": "time_indeterminate_nodata",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time without any data in percent of total time (during downtimes)",
     "name": "time_indeterminate_nodata_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds during core not running",
     "name": "time_indeterminate_notrunning",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time during core not running in percent of total time",
     "name": "time_indeterminate_notrunning_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds outside the given timeperiod",
     "name": "time_indeterminate_outside_timeperiod",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time outside the given timeperiod in percent of total time",
     "name": "time_indeterminate_outside_timeperiod_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state ok",
     "name": "time_ok",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time ok in percent of total time",
     "name": "time_ok_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state unknown",
     "name": "time_unknown",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time unknown in percent of total time",
     "name": "time_unknown_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state warning",
     "name": "time_warning",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time warning in percent of total time",
     "name": "time_warning_percent",
     "type": "number",
     "unit": "%"
    }
   ]
  }
 },
 "/servicegroups/<name>/outages": {
  "GET": {
   "columns": [
    {
     "description": "host/service status",
     "name": "class",
     "type": "string",
     "unit": ""
    },
    {
     "description": "outage duration in seconds",
     "name": "duration",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "unix timestamp of outage end",
     "name": "end",
     "type": "time",
     "unit": ""
    },
    {
     "description": "host name",
     "name": "host",
     "type": "string",
     "unit": ""
    },
    {
     "description": "last plugin output during outage",
     "name": "plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "service description (only for service outages)",
     "name": "service",
     "type": "string",
     "unit": ""
    },
    {
     "description": "unix timestamp of outage start",
     "name": "start",
     "type": "time",
     "unit": ""
    },
    {
     "description": "log entry type",
     "name": "type",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/services/<host>/<service>/availability": {
  "GET": {
   "columns": [
    {
     "description": "total seconds in state critical (during downtimes)",
     "name": "scheduled_time_critical",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time critical in percent of total time (during downtimes)",
     "name": "scheduled_time_critical_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds unknown (during downtimes)",
     "name": "scheduled_time_indeterminate",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time unknown in percent of total time (during downtimes)",
     "name": "scheduled_time_indeterminate_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state ok (during downtimes)",
     "name": "scheduled_time_ok",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time ok in percent of total time (during downtimes)",
     "name": "scheduled_time_ok_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state unknown (during downtimes)",
     "name": "scheduled_time_unknown",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time unknown in percent of total time (during downtimes)",
     "name": "scheduled_time_unknown_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state warning (during downtimes)",
     "name": "scheduled_time_warning",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time warning in percent of total time (during downtimes)",
     "name": "scheduled_time_warning_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state critical",
     "name": "time_critical",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time critical in percent of total time",
     "name": "time_critical_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds without any data",
     "name": "time_indeterminate_nodata",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time without any data in percent of total time (during downtimes)",
     "name": "time_indeterminate_nodata_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds during core not running",
     "name": "time_indeterminate_notrunning",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time during core not running in percent of total time",
     "name": "time_indeterminate_notrunning_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds outside the given timeperiod",
     "name": "time_indeterminate_outside_timeperiod",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time outside the given timeperiod in percent of total time",
     "name": "time_indeterminate_outside_timeperiod_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state ok",
     "name": "time_ok",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time ok in percent of total time",
     "name": "time_ok_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state unknown",
     "name": "time_unknown",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time unknown in percent of total time",
     "name": "time_unknown_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state warning",
     "name": "time_warning",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time warning in percent of total time",
     "name": "time_warning_percent",
     "type": "number",
     "unit": "%"
    }
   ]
  }
 },
 "/services/<host>/<service>/commandline": {
  "GET": {
   "columns": [
    {
     "description": "name of the check_command including arguments",
     "name": "check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "full expanded command line (if possible)",
     "name": "command_line",
     "type": "string",
     "unit": ""
    },
    {
     "description": "contains the error if expanding failed for some reason",
     "name": "error",
     "type": "string",
     "unit": ""
    },
    {
     "description": "host name",
     "name": "host_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "id as defined in Thruk::Backend component configuration",
     "name": "peer_key",
     "type": "string",
     "unit": ""
    },
    {
     "description": "name as defined in Thruk::Backend component configuration",
     "name": "peer_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "section as defined in Thruk::Backend component configuration",
     "name": "peer_section",
     "type": "string",
     "unit": ""
    },
    {
     "description": "service name",
     "name": "service_description",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/services/<host>/<service>/outages": {
  "GET": {
   "columns": [
    {
     "description": "host/service status",
     "name": "class",
     "type": "string",
     "unit": ""
    },
    {
     "description": "outage duration in seconds",
     "name": "duration",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "unix timestamp of outage end",
     "name": "end",
     "type": "time",
     "unit": ""
    },
    {
     "description": "host name",
     "name": "host",
     "type": "string",
     "unit": ""
    },
    {
     "description": "last plugin output during outage",
     "name": "plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "service description (only for service outages)",
     "name": "service",
     "type": "string",
     "unit": ""
    },
    {
     "description": "unix timestamp of outage start",
     "name": "start",
     "type": "time",
     "unit": ""
    },
    {
     "description": "log entry type",
     "name": "type",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/services/availability": {
  "GET": {
   "columns": [
    {
     "description": "host name",
     "name": "host",
     "type": "string",
     "unit": ""
    },
    {
     "description": "total seconds in state critical (during downtimes)",
     "name": "scheduled_time_critical",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time critical in percent of total time (during downtimes)",
     "name": "scheduled_time_critical_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds unknown (during downtimes)",
     "name": "scheduled_time_indeterminate",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time unknown in percent of total time (during downtimes)",
     "name": "scheduled_time_indeterminate_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state ok (during downtimes)",
     "name": "scheduled_time_ok",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time ok in percent of total time (during downtimes)",
     "name": "scheduled_time_ok_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state unknown (during downtimes)",
     "name": "scheduled_time_unknown",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time unknown in percent of total time (during downtimes)",
     "name": "scheduled_time_unknown_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state warning (during downtimes)",
     "name": "scheduled_time_warning",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time warning in percent of total time (during downtimes)",
     "name": "scheduled_time_warning_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "service description",
     "name": "service",
     "type": "string",
     "unit": ""
    },
    {
     "description": "total seconds in state critical",
     "name": "time_critical",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time critical in percent of total time",
     "name": "time_critical_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds without any data",
     "name": "time_indeterminate_nodata",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time without any data in percent of total time (during downtimes)",
     "name": "time_indeterminate_nodata_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds during core not running",
     "name": "time_indeterminate_notrunning",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time during core not running in percent of total time",
     "name": "time_indeterminate_notrunning_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds outside the given timeperiod",
     "name": "time_indeterminate_outside_timeperiod",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time outside the given timeperiod in percent of total time",
     "name": "time_indeterminate_outside_timeperiod_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state ok",
     "name": "time_ok",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time ok in percent of total time",
     "name": "time_ok_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state unknown",
     "name": "time_unknown",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time unknown in percent of total time",
     "name": "time_unknown_percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "total seconds in state warning",
     "name": "time_warning",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "time warning in percent of total time",
     "name": "time_warning_percent",
     "type": "number",
     "unit": "%"
    }
   ]
  }
 },
 "/services/outages": {
  "GET": {
   "columns": [
    {
     "description": "host/service status",
     "name": "class",
     "type": "string",
     "unit": ""
    },
    {
     "description": "outage duration in seconds",
     "name": "duration",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "unix timestamp of outage end",
     "name": "end",
     "type": "time",
     "unit": ""
    },
    {
     "description": "host name",
     "name": "host",
     "type": "string",
     "unit": ""
    },
    {
     "description": "last plugin output during outage",
     "name": "plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "service description (only for service outages)",
     "name": "service",
     "type": "string",
     "unit": ""
    },
    {
     "description": "unix timestamp of outage start",
     "name": "start",
     "type": "time",
     "unit": ""
    },
    {
     "description": "log entry type",
     "name": "type",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/services/stats": {
  "GET": {
   "columns": [
    {
     "description": "number of active services which have active checks disabled",
     "name": "active_checks_disabled_active",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of passive services which have active checks disabled",
     "name": "active_checks_disabled_passive",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of critical services",
     "name": "critical",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of critical services which are acknowledged",
     "name": "critical_and_ack",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of active critical services which have active checks disabled",
     "name": "critical_and_disabled_active",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of passive critical services which have active checks disabled",
     "name": "critical_and_disabled_passive",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of critical services which are in a scheduled downtime",
     "name": "critical_and_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unhandled critical services",
     "name": "critical_and_unhandled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of critical services in hard state",
     "name": "critical_hard",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unhandled critical services in hard state",
     "name": "critical_hard_unhandled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unhandled critical services on down hosts",
     "name": "critical_on_down_host",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of critical services in soft state",
     "name": "critical_soft",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services with eventhandlers disabled",
     "name": "eventhandler_disabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of flapping services",
     "name": "flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services with flapping detection disabled",
     "name": "flapping_disabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services in hard state",
     "name": "hard",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services with notifications disabled",
     "name": "notifications_disabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of ok services",
     "name": "ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of active ok services which have active checks disabled",
     "name": "ok_and_disabled_active",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of passive ok services which have active checks disabled",
     "name": "ok_and_disabled_passive",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of ok services which are in a scheduled downtime",
     "name": "ok_and_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services which do not accept passive check results",
     "name": "passive_checks_disabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of pending services",
     "name": "pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of pending services with active checks disabled",
     "name": "pending_and_disabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of pending services which are in a scheduled downtime",
     "name": "pending_and_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of critical services which are not acknowleded or in a downtime",
     "name": "plain_critical",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of ok services which are not acknowleded or in a downtime",
     "name": "plain_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of pending services which are not acknowleded or in a downtime",
     "name": "plain_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unknown services which are not acknowleded or in a downtime",
     "name": "plain_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of warning services which are not acknowleded or in a downtime",
     "name": "plain_warning",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services in soft state",
     "name": "soft",
     "type": "number",
     "unit": ""
    },
    {
     "description": "total number of services",
     "name": "total",
     "type": "number",
     "unit": ""
    },
    {
     "description": "total number of active services",
     "name": "total_active",
     "type": "number",
     "unit": ""
    },
    {
     "description": "total number of passive services",
     "name": "total_passive",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unknown services",
     "name": "unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unknown services which are acknowledged",
     "name": "unknown_and_ack",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of active unknown services which have active checks disabled",
     "name": "unknown_and_disabled_active",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of passive unknown services which have active checks disabled",
     "name": "unknown_and_disabled_passive",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unknown services which are in a scheduled downtime",
     "name": "unknown_and_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unhandled unknown services",
     "name": "unknown_and_unhandled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unknown services in hard state",
     "name": "unknown_hard",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unhandled unknown services in hard state",
     "name": "unknown_hard_unhandled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unhandled unknown services on down hosts",
     "name": "unknown_on_down_host",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unknown services in soft state",
     "name": "unknown_soft",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of warning services",
     "name": "warning",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of warning services which are acknowledged",
     "name": "warning_and_ack",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of active warning services which have active checks disabled",
     "name": "warning_and_disabled_active",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of passive warning services which have active checks disabled",
     "name": "warning_and_disabled_passive",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of warning services which are in a scheduled downtime",
     "name": "warning_and_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unhandled warning services",
     "name": "warning_and_unhandled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of warning services in hard state",
     "name": "warning_hard",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unhandled warning services in hard state",
     "name": "warning_hard_unhandled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unhandled warning services on down hosts",
     "name": "warning_on_down_host",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of warning services in soft state",
     "name": "warning_soft",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/services/totals": {
  "GET": {
   "columns": [
    {
     "description": "number of critical services",
     "name": "critical",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of critical services which are neither acknowledged nor in scheduled downtime",
     "name": "critical_and_unhandled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of ok services",
     "name": "ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of pending services",
     "name": "pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "total number of services",
     "name": "total",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unknown services",
     "name": "unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of unknown services which are neither acknowledged nor in scheduled downtime",
     "name": "unknown_and_unhandled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of warning services",
     "name": "warning",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of warning services which are neither acknowledged nor in scheduled downtime",
     "name": "warning_and_unhandled",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/sites": {
  "GET": {
   "columns": [
    {
     "description": "address for this connection",
     "name": "addr",
     "type": "string",
     "unit": ""
    },
    {
     "description": "flag whether sites is connected (1) or not (0)",
     "name": "connected",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "contains the real address if using federation",
     "name": "federation_addr",
     "type": "string",
     "unit": ""
    },
    {
     "description": "contains the real peer key if using federation",
     "name": "federation_key",
     "type": "string",
     "unit": ""
    },
    {
     "description": "contains the real name if using federation",
     "name": "federation_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "contains the real backend type if using federation",
     "name": "federation_type",
     "type": "string",
     "unit": ""
    },
    {
     "description": "contains the real backend version if using federation",
     "name": "federation_version",
     "type": "string",
     "unit": ""
    },
    {
     "description": "id for this backend",
     "name": "id",
     "type": "string",
     "unit": ""
    },
    {
     "description": "error message if backend is not connected",
     "name": "last_error",
     "type": "time",
     "unit": ""
    },
    {
     "description": "current local unix timestamp of thruk host",
     "name": "localtime",
     "type": "time",
     "unit": ""
    },
    {
     "description": "name of the backend",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "section name",
     "name": "section",
     "type": "string",
     "unit": ""
    },
    {
     "description": "0 (OK), 1 (DOWN)",
     "name": "status",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "type of the backend",
     "name": "type",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/thruk": {
  "GET": {
   "columns": [
    {
     "description": "rest api version",
     "name": "rest_version",
     "type": "string",
     "unit": ""
    },
    {
     "description": "thruk version",
     "name": "thruk_version",
     "type": "string",
     "unit": ""
    },
    {
     "description": "thruk release date",
     "name": "thruk_release_date",
     "type": "string",
     "unit": ""
    },
    {
     "description": "current server unix timestamp / epoch",
     "name": "localtime",
     "type": "time",
     "unit": ""
    },
    {
     "description": "thruk root folder",
     "name": "project_root",
     "type": "string",
     "unit": ""
    },
    {
     "description": "configuration folder",
     "name": "etc_path",
     "type": "string",
     "unit": ""
    },
    {
     "description": "variable data folder",
     "name": "var_path",
     "type": "string",
     "unit": ""
    },
    {
     "description": "might contain omd version",
     "name": "extra_version",
     "type": "string",
     "unit": ""
    },
    {
     "description": "contains link from extra_versions product",
     "name": "extra_link",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/thruk/api_keys": {
  "GET": {
   "columns": [
    {
     "description": "comment of this api key",
     "name": "comment",
     "type": "string",
     "unit": ""
    },
    {
     "description": "unixtimestamp of when the key was created",
     "name": "created",
     "type": "time",
     "unit": ""
    },
    {
     "description": "used hash algorithm",
     "name": "digest",
     "type": "string",
     "unit": ""
    },
    {
     "description": "path to stored file",
     "name": "file",
     "type": "string",
     "unit": ""
    },
    {
     "description": "super user keys can enforce a specific user",
     "name": "force_user",
     "type": "string",
     "unit": ""
    },
    {
     "description": "hashed private key",
     "name": "hashed_key",
     "type": "string",
     "unit": ""
    },
    {
     "description": "ip address of last usage",
     "name": "last_from",
     "type": "time",
     "unit": ""
    },
    {
     "description": "unixtimestamp of last usage",
     "name": "last_used",
     "type": "time",
     "unit": ""
    },
    {
     "description": "list of roles this key is limited too",
     "name": "roles",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "flag whether this a global superuser key and not bound to a specific user",
     "name": "superuser",
     "type": "string",
     "unit": ""
    },
    {
     "description": "username of key owner",
     "name": "user",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/thruk/bp": {
  "GET": {
   "columns": [
    {
     "description": "list of backend ids used for the last calculation",
     "name": "affected_peers",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "id of backend which hosts the business process",
     "name": "bp_backend",
     "type": "string",
     "unit": ""
    },
    {
     "description": "0 - do no create a host object, 1 - create naemon host object",
     "name": "create_host_object",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "flag whether this is a draft only",
     "name": "draft",
     "type": "string",
     "unit": ""
    },
    {
     "description": "list of enabled filters",
     "name": "filter",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "primary id",
     "name": "id",
     "type": "string",
     "unit": ""
    },
    {
     "description": "timestamp of last check result submited",
     "name": "last_check",
     "type": "time",
     "unit": ""
    },
    {
     "description": "timestamp of last state change",
     "name": "last_state_change",
     "type": "time",
     "unit": ""
    },
    {
     "description": "name of this business proces",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "all nodes of this business process",
     "name": "nodes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "flag wheter this business process is horizontal or vertical",
     "name": "rankDir",
     "type": "string",
     "unit": ""
    },
    {
     "description": "flag if this business process uses hard or soft state types",
     "name": "state_type",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "current status",
     "name": "status",
     "type": "number",
     "unit": ""
    },
    {
     "description": "current status text",
     "name": "status_text",
     "type": "string",
     "unit": ""
    },
    {
     "description": "naemon template used for the generated object",
     "name": "template",
     "type": "string",
     "unit": ""
    },
    {
     "description": "calculation duration",
     "name": "time",
     "type": "number",
     "unit": "s"
    }
   ]
  }
 },
 "/thruk/broadcasts": {
  "GET": {
   "columns": [
    {
     "description": "annotation icon for this broadcast",
     "name": "annotation",
     "type": "string",
     "unit": ""
    },
    {
     "description": "author of the broadcast",
     "name": "author",
     "type": "string",
     "unit": ""
    },
    {
     "description": "authors E-Mail address, mainly used as macro",
     "name": "authoremail",
     "type": "string",
     "unit": ""
    },
    {
     "description": "list of contactgroups if broadcast should be limited to specific groups",
     "name": "contactgroups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "list of contacts if broadcast should be limited to specific contacts",
     "name": "contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "expire date after which the broadcast won't be displayed anymore",
     "name": "expires",
     "type": "string",
     "unit": ""
    },
    {
     "description": "expire data as unix timestamp",
     "name": "expires_ts",
     "type": "time",
     "unit": ""
    },
    {
     "description": "filename",
     "name": "file",
     "type": "string",
     "unit": ""
    },
    {
     "description": "hash list of extraceted frontmatter variables",
     "name": "frontmatter",
     "type": "string",
     "unit": ""
    },
    {
     "description": "do not show broadcast before this date",
     "name": "hide_before",
     "type": "string",
     "unit": ""
    },
    {
     "description": "hide_before as unix timestamp",
     "name": "hide_before_ts",
     "type": "time",
     "unit": ""
    },
    {
     "description": "flag whether broadcast should be displayed on the loginpage as well",
     "name": "loginpage",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "hash list of macros",
     "name": "macros",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "name of this broadcast, mostly used for templates",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "flag whether broadcast should be displayed on panorama dashboards",
     "name": "panorama",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "raw broadcast text",
     "name": "raw_text",
     "type": "string",
     "unit": ""
    },
    {
     "description": "flag whether this broadcast is a template",
     "name": "template",
     "type": "string",
     "unit": ""
    },
    {
     "description": "processed broadcast message",
     "name": "text",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/thruk/cluster": {
  "GET": {
   "columns": [
    {
     "description": "host name of the cluster node",
     "name": "hostname",
     "type": "string",
     "unit": ""
    },
    {
     "description": "timestamp of last successful contact",
     "name": "last_contact",
     "type": "time",
     "unit": ""
    },
    {
     "description": "text of last error message",
     "name": "last_error",
     "type": "time",
     "unit": ""
    },
    {
     "description": "Flag whether this node is in maintenance mode",
     "name": "maintenance",
     "type": "",
     "unit": ""
    },
    {
     "description": "internal id for this node",
     "name": "node_id",
     "type": "string",
     "unit": ""
    },
    {
     "description": "url to access this node directly",
     "name": "node_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "list of current process ids of this node",
     "name": "pids",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "response time in seconds",
     "name": "response_time",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "version information of this node",
     "name": "version",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/thruk/jobs": {
  "GET": {
   "columns": [
    {
     "description": "the executed command line or perl code",
     "name": "cmd",
     "type": "string",
     "unit": ""
    },
    {
     "description": "timestamp when the job finished",
     "name": "end",
     "type": "time",
     "unit": ""
    },
    {
     "description": "url to forward when the job is done",
     "name": "forward",
     "type": "string",
     "unit": ""
    },
    {
     "description": "thruk node id this job is run on",
     "name": "host_id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "hostname of the node",
     "name": "host_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "job id",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "flag whether the job is still running",
     "name": "is_running",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "current status text",
     "name": "message",
     "type": "string",
     "unit": ""
    },
    {
     "description": "percent of completion",
     "name": "percent",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "contains the perl result in case this was a perl job",
     "name": "perl_res",
     "type": "string",
     "unit": ""
    },
    {
     "description": "process id",
     "name": "pid",
     "type": "number",
     "unit": ""
    },
    {
     "description": "return code",
     "name": "rc",
     "type": "number",
     "unit": ""
    },
    {
     "description": "remaining seconds for the job to complete",
     "name": "remaining",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "flag whether output console will be displayed",
     "name": "show_output",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "timestamp when the job started",
     "name": "start",
     "type": "time",
     "unit": ""
    },
    {
     "description": "stderr output",
     "name": "stderr",
     "type": "string",
     "unit": ""
    },
    {
     "description": "stdout output",
     "name": "stdout",
     "type": "string",
     "unit": ""
    },
    {
     "description": "duration in seconds",
     "name": "time",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "username of the owner",
     "name": "user",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/thruk/logcache/stats": {
  "GET": {
   "columns": [
    {
     "description": "db schema version",
     "name": "cache_version",
     "type": "string",
     "unit": ""
    },
    {
     "description": "duration of last compact run in seconds",
     "name": "compact_duration",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "timestamp marker where last compact run finished",
     "name": "compact_till",
     "type": "time",
     "unit": ""
    },
    {
     "description": "used size of data in bytes",
     "name": "data_size",
     "type": "number",
     "unit": "bytes"
    },
    {
     "description": "flag whether logcache is enabled for this backend or not",
     "name": "enabled",
     "type": "string",
     "unit": ""
    },
    {
     "description": "used size of index in bytes",
     "name": "index_size",
     "type": "number",
     "unit": "bytes"
    },
    {
     "description": "number of items/rows",
     "name": "items",
     "type": "string",
     "unit": ""
    },
    {
     "description": "peer key",
     "name": "key",
     "type": "string",
     "unit": ""
    },
    {
     "description": "timestamp of last compact run",
     "name": "last_compact",
     "type": "time",
     "unit": ""
    },
    {
     "description": "timestamp of last log entry",
     "name": "last_entry",
     "type": "time",
     "unit": ""
    },
    {
     "description": "timestamp of last optimize run",
     "name": "last_reorder",
     "type": "time",
     "unit": ""
    },
    {
     "description": "timestamp of last update run",
     "name": "last_update",
     "type": "time",
     "unit": ""
    },
    {
     "description": "current lock mode",
     "name": "mode",
     "type": "string",
     "unit": ""
    },
    {
     "description": "peer name",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "duration of last reorder run in seconds",
     "name": "reorder_duration",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "human readable status",
     "name": "status",
     "type": "string",
     "unit": ""
    },
    {
     "description": "duration of last update run in seconds",
     "name": "update_duration",
     "type": "number",
     "unit": "s"
    }
   ]
  }
 },
 "/thruk/node-control/nodes": {
  "GET": {
   "columns": [
    {
     "description": "full qualified domain from ansible facts",
     "name": "ansible_fqdn",
     "type": "string",
     "unit": ""
    },
    {
     "description": "flag 1/0 if the nodes is running cleanup right now",
     "name": "cleaning",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "flag 1/0 whether last cleanup job failed",
     "name": "cleaning_failed",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "number of cpu cores",
     "name": "cpu_cores",
     "type": "number",
     "unit": ""
    },
    {
     "description": "current cpu usage in percent",
     "name": "cpu_perc",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "ansible facts as nested data structure",
     "name": "facts",
     "type": "string",
     "unit": ""
    },
    {
     "description": "flag 1/0 if node is gathering facts right now",
     "name": "gathering",
     "type": "number",
     "unit": ""
    },
    {
     "description": "nodes host name",
     "name": "host_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "flag 1/0 if node is installing omd right now",
     "name": "installing",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "flag 1/0 if last install failed",
     "name": "installing_failed",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "text of last job error",
     "name": "last_error",
     "type": "string",
     "unit": ""
    },
    {
     "description": "timestamp of last error",
     "name": "last_error_ts",
     "type": "time",
     "unit": ""
    },
    {
     "description": "duration of last facts gathering job",
     "name": "last_gather_runtime",
     "type": "time",
     "unit": ""
    },
    {
     "description": "last job id",
     "name": "last_job",
     "type": "nummer",
     "unit": ""
    },
    {
     "description": "nested list of available log files",
     "name": "logs",
     "type": "",
     "unit": ""
    },
    {
     "description": "machine type from ansible",
     "name": "machine_type",
     "type": "string",
     "unit": ""
    },
    {
     "description": "free memory in MB",
     "name": "memfree",
     "type": "number",
     "unit": ""
    },
    {
     "description": "total memory in MB",
     "name": "memtotal",
     "type": "number",
     "unit": ""
    },
    {
     "description": "list of available omd versions",
     "name": "omd_available_versions",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "list of unused omd versions",
     "name": "omd_cleanable",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "free disk space in bytes",
     "name": "omd_disk_free",
     "type": "number",
     "unit": "bytes"
    },
    {
     "description": "total disk space in bytes",
     "name": "omd_disk_total",
     "type": "number",
     "unit": "bytes"
    },
    {
     "description": "omd site name",
     "name": "omd_site",
     "type": "string",
     "unit": ""
    },
    {
     "description": "nested structure of omd services with their states",
     "name": "omd_status",
     "type": "string",
     "unit": ""
    },
    {
     "description": "current used omd version",
     "name": "omd_version",
     "type": "string",
     "unit": ""
    },
    {
     "description": "available omd versions",
     "name": "omd_versions",
     "type": "string",
     "unit": ""
    },
    {
     "description": "operating systems name",
     "name": "os_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "flag 1/0 if security updates are beeing installed right now",
     "name": "os_sec_updating",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "list of available security updates",
     "name": "os_security",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "list of available os updates",
     "name": "os_updates",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "flag 1/0 if os updates are beeing installed right now",
     "name": "os_updating",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "version number of operating system",
     "name": "os_version",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "id as defined in Thruk::Backend component configuration",
     "name": "peer_key",
     "type": "string",
     "unit": ""
    },
    {
     "description": "name as defined in Thruk::Backend component configuration",
     "name": "peer_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "peer connection type",
     "name": "peer_type",
     "type": "string",
     "unit": ""
    },
    {
     "description": "flag 0/1 if install/update/cleanup is running right now",
     "name": "run_all",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "peer backend section",
     "name": "section",
     "type": "string",
     "unit": ""
    },
    {
     "description": "flag 0/1 if update is running right now",
     "name": "updating",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "flag 0/1 if last update failed",
     "name": "updating_failed",
     "type": "boolean",
     "unit": ""
    }
   ]
  }
 },
 "/thruk/panorama": {
  "GET": {
   "columns": [
    {
     "description": "filename of the dashboard",
     "name": "file",
     "type": "string",
     "unit": ""
    },
    {
     "description": "version of dashboard format",
     "name": "file_version",
     "type": "string",
     "unit": ""
    },
    {
     "description": "internal id",
     "name": "id",
     "type": "",
     "unit": ""
    },
    {
     "description": "maintenance reason (only if in maintenance mode)",
     "name": "maintenance",
     "type": "string",
     "unit": ""
    },
    {
     "description": "number of the dashboard",
     "name": "nr",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of objects",
     "name": "objects",
     "type": "number",
     "unit": ""
    },
    {
     "description": "panlet definition",
     "name": "panlet_<nr>",
     "type": "string",
     "unit": ""
    },
    {
     "description": "flag whether this dashboard is read-only",
     "name": "readonly",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "flag whether this is a scripted dashboard",
     "name": "scripted",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "structure of global dashboard settings",
     "name": "tab",
     "type": "string",
     "unit": ""
    },
    {
     "description": "timestamp of last modification",
     "name": "ts",
     "type": "time",
     "unit": ""
    },
    {
     "description": "owner of this dashboard",
     "name": "user",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/thruk/recurring_downtimes": {
  "GET": {
   "columns": [
    {
     "description": "list of backends this downtime is used for",
     "name": "backends",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "flag used for the downtime command",
     "name": "childoptions",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "comment used for the downtime command",
     "name": "comment",
     "type": "string",
     "unit": ""
    },
    {
     "description": "username who created this downtime",
     "name": "created_by",
     "type": "string",
     "unit": ""
    },
    {
     "description": "duration in minutes",
     "name": "duration",
     "type": "number",
     "unit": "minutes"
    },
    {
     "description": "username who last edited this downtime",
     "name": "edited_by",
     "type": "string",
     "unit": ""
    },
    {
     "description": "contains the error message if something got wrong with this downtime",
     "name": "error",
     "type": "string",
     "unit": ""
    },
    {
     "description": "file number",
     "name": "file",
     "type": "number",
     "unit": ""
    },
    {
     "description": "flag whether this should create a fixed downtime",
     "name": "fixed",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "range in minutes for flexible downtimes",
     "name": "flex_range",
     "type": "number",
     "unit": "minutes"
    },
    {
     "description": "list of hostnames",
     "name": "host",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "list of hostgroups",
     "name": "hostgroup",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "unix timestamp of last change",
     "name": "last_changed",
     "type": "time",
     "unit": ""
    },
    {
     "description": "list of schedules",
     "name": "schedule",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "list of services",
     "name": "service",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "list of servicegroups",
     "name": "servicegroup",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "sets the type of the downtime, ex. host or hostgroup",
     "name": "target",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/thruk/reports": {
  "GET": {
   "columns": [
    {
     "description": "list of backends used in this report",
     "name": "backends",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "email cc address if this report is send by mail",
     "name": "cc",
     "type": "string",
     "unit": ""
    },
    {
     "description": "report description",
     "name": "desc",
     "type": "string",
     "unit": ""
    },
    {
     "description": "contains error messages (optional)",
     "name": "error",
     "type": "string",
     "unit": ""
    },
    {
     "description": "flag wheter the report failed to generate last time",
     "name": "failed",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "flag wheter the report is public or not",
     "name": "is_public",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "name of the report",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "number of the report",
     "name": "nr",
     "type": "number",
     "unit": ""
    },
    {
     "description": "reporting parameters",
     "name": "params",
     "type": "string",
     "unit": ""
    },
    {
     "description": "user/group permission",
     "name": "permissions",
     "type": "string",
     "unit": ""
    },
    {
     "description": "flag whether the report is read-only",
     "name": "readonly",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "list of cron entries",
     "name": "send_types",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "template of the report",
     "name": "template",
     "type": "string",
     "unit": ""
    },
    {
     "description": "email to address if this report is send by mail",
     "name": "to",
     "type": "string",
     "unit": ""
    },
    {
     "description": "owner",
     "name": "user",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/thruk/reports/<nr>": {
  "GET": {
   "columns": [
    {
     "description": "list of selected backends.",
     "name": "backends",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "carbon-copy for report email.",
     "name": "cc",
     "type": "string",
     "unit": ""
    },
    {
     "description": "description.",
     "name": "desc",
     "type": "string",
     "unit": ""
    },
    {
     "description": "contains error messages (optional)",
     "name": "error",
     "type": "string",
     "unit": ""
    },
    {
     "description": "failed flag.",
     "name": "failed",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "flag for public reports.",
     "name": "is_public",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "name of the report.",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "primary id.",
     "name": "nr",
     "type": "string",
     "unit": ""
    },
    {
     "description": "report parameters.",
     "name": "params",
     "type": "string",
     "unit": ""
    },
    {
     "description": "user/group permission",
     "name": "permissions",
     "type": "string",
     "unit": ""
    },
    {
     "description": "readonly flag.",
     "name": "readonly",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "list of crontab entries.",
     "name": "send_types",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "report template.",
     "name": "template",
     "type": "string",
     "unit": ""
    },
    {
     "description": "email address the report email.",
     "name": "to",
     "type": "string",
     "unit": ""
    },
    {
     "description": "owner of the report.",
     "name": "user",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/thruk/sessions": {
  "GET": {
   "columns": [
    {
     "description": "timestamp when session was last time used",
     "name": "active",
     "type": "time",
     "unit": ""
    },
    {
     "description": "remote address of user",
     "name": "address",
     "type": "string",
     "unit": ""
    },
    {
     "description": "used hash algorithm",
     "name": "digest",
     "type": "string",
     "unit": ""
    },
    {
     "description": "flag whether this is a fake session or not",
     "name": "fake",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "file name the session data file",
     "name": "file",
     "type": "string",
     "unit": ""
    },
    {
     "description": "hashed session id",
     "name": "hashed_key",
     "type": "string",
     "unit": ""
    },
    {
     "description": "groups/roles as provided by the oauth server",
     "name": "oauth_groups",
     "type": "",
     "unit": ""
    },
    {
     "description": "extra session roles",
     "name": "roles",
     "type": "",
     "unit": ""
    },
    {
     "description": "username of this session",
     "name": "username",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/thruk/stats": {
  "GET": {
   "columns": [
    {
     "description": "business process calculation duration in seconds",
     "name": "business_process_duration_seconds",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "timestamp of last business process calculation",
     "name": "business_process_last_update",
     "type": "time",
     "unit": ""
    },
    {
     "description": "total number of business processes",
     "name": "business_process_total",
     "type": "number",
     "unit": ""
    },
    {
     "description": "total number of worker processes used to calculate business processes",
     "name": "business_process_worker_total",
     "type": "number",
     "unit": ""
    },
    {
     "description": "total number of active thruk sessions (active during the last 5 minutes)",
     "name": "sessions_active_5min_total",
     "type": "number",
     "unit": ""
    },
    {
     "description": "total number of thruk sessions",
     "name": "sessions_total",
     "type": "number",
     "unit": ""
    },
    {
     "description": "total number of uniq users active during the last 5 minutes",
     "name": "sessions_uniq_user_5min_total",
     "type": "number",
     "unit": ""
    },
    {
     "description": "total number of uniq users",
     "name": "sessions_uniq_user_total",
     "type": "number",
     "unit": ""
    },
    {
     "description": "total number of locked thruk users",
     "name": "users_locked_total",
     "type": "number",
     "unit": ""
    },
    {
     "description": "total number of thruk users",
     "name": "users_total",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/thruk/metrics": {
  "GET": {
   "columns": [
    {
     "description": "business process calculation duration in seconds",
     "name": "business_process_duration_seconds",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "timestamp of last business process calculation",
     "name": "business_process_last_update",
     "type": "time",
     "unit": ""
    },
    {
     "description": "total number of business processes",
     "name": "business_process_total",
     "type": "number",
     "unit": ""
    },
    {
     "description": "total number of worker processes used to calculate business processes",
     "name": "business_process_worker_total",
     "type": "number",
     "unit": ""
    },
    {
     "description": "total number of active thruk sessions (active during the last 5 minutes)",
     "name": "sessions_active_5min_total",
     "type": "number",
     "unit": ""
    },
    {
     "description": "total number of thruk sessions",
     "name": "sessions_total",
     "type": "number",
     "unit": ""
    },
    {
     "description": "total number of uniq users active during the last 5 minutes",
     "name": "sessions_uniq_user_5min_total",
     "type": "number",
     "unit": ""
    },
    {
     "description": "total number of uniq users",
     "name": "sessions_uniq_user_total",
     "type": "number",
     "unit": ""
    },
    {
     "description": "total number of locked thruk users",
     "name": "users_locked_total",
     "type": "number",
     "unit": ""
    },
    {
     "description": "total number of thruk users",
     "name": "users_total",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/thruk/users": {
  "GET": {
   "columns": [
    {
     "description": "alias name",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "flag whether this account is allowed to submit commands",
     "name": "can_submit_commands",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "email address",
     "name": "email",
     "type": "string",
     "unit": ""
    },
    {
     "description": "list of contactgroups",
     "name": "groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "flag whether this account has a thruk profile or not",
     "name": "has_thruk_profile",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "username",
     "name": "id",
     "type": "string",
     "unit": ""
    },
    {
     "description": "timestamp of last successfull login",
     "name": "last_login",
     "type": "time",
     "unit": ""
    },
    {
     "description": "flag whether account is locked or not",
     "name": "locked",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "list of roles for this user",
     "name": "roles",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "users selected timezone",
     "name": "tz",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/thruk/whoami": {
  "GET": {
   "columns": [
    {
     "description": "alias name",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "authentication method",
     "name": "auth_src",
     "type": "string",
     "unit": ""
    },
    {
     "description": "flag whether this account is allowed to submit commands",
     "name": "can_submit_commands",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "email address",
     "name": "email",
     "type": "string",
     "unit": ""
    },
    {
     "description": "list of contactgroups",
     "name": "groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "flag whether this account has a thruk profile or not",
     "name": "has_thruk_profile",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "username",
     "name": "id",
     "type": "string",
     "unit": ""
    },
    {
     "description": "timestamp of last successfull login",
     "name": "last_login",
     "type": "time",
     "unit": ""
    },
    {
     "description": "flag whether account is locked or not",
     "name": "locked",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "original username",
     "name": "original_username",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "list of roles for this user",
     "name": "roles",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "users selected timezone",
     "name": "tz",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/contacts": {
  "GET": {
   "columns": [
    {
     "description": "",
     "name": "in_host_notification_period",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "",
     "name": "in_service_notification_period",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "modified_attributes_list",
     "name": "peer_section",
     "type": "array_of_strings",
     "unit": ""
    }
   ]
  }
 }
}

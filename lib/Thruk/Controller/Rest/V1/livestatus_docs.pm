package Thruk::Controller::Rest::V1::livestatus_docs;

use warnings;
use strict;
use Cpanel::JSON::XS qw/decode_json/;

=head1 NAME

Thruk::Controller::Rest::V1::livestatus_docs - Livestatus table column metadata

=head1 DESCRIPTION

Contains column attributes for Livestatus table endpoints.

=head1 METHODS

=head2 keys

    keys()

returns raw attributes for livestatus rest endpoints

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
 "/hosts": {
  "GET": {
   "columns": [
    {
     "description": "host name",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "display name, defaults to host_name",
     "name": "display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "longer name or description used to identify the host",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "IP address or FQDN of the host",
     "name": "address",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of parent host names",
     "name": "parents",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of hostgroup names",
     "name": "hostgroups",
     "type": "string",
     "unit": ""
    },
    {
     "description": "check command name and arguments",
     "name": "check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "expanded check command with macros resolved",
     "name": "check_command_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "number of time units between regularly scheduled checks",
     "name": "check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of time units to wait before re-checking the host after a non-UP state",
     "name": "retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of times to retry the host check before generating an alert",
     "name": "max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "timeout in seconds for the host check command",
     "name": "check_timeout",
     "type": "number",
     "unit": ""
    },
    {
     "description": "time period during which active checks of this host can be made",
     "name": "check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of contact names notified about host problems",
     "name": "contacts",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of contact group names notified about host problems",
     "name": "contact_groups",
     "type": "string",
     "unit": ""
    },
    {
     "description": "number of time units to wait before re-notifying about a still-down host",
     "name": "notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of time units to wait before sending the first problem notification",
     "name": "first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "time period during which notifications can be sent for this host",
     "name": "notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "host notification options (d,u,r,f,s)",
     "name": "notification_options",
     "type": "string",
     "unit": ""
    },
    {
     "description": "current state: 0=UP, 1=DOWN, 2=UNREACHABLE",
     "name": "state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "whether the host has been checked at least once",
     "name": "has_been_checked",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "timestamp of the last host check",
     "name": "last_check",
     "type": "time",
     "unit": ""
    },
    {
     "description": "timestamp of the next scheduled host check",
     "name": "next_check",
     "type": "time",
     "unit": ""
    },
    {
     "description": "timestamp of the last state change",
     "name": "last_state_change",
     "type": "time",
     "unit": ""
    },
    {
     "description": "timestamp of the last hard state change",
     "name": "last_hard_state_change",
     "type": "time",
     "unit": ""
    },
    {
     "description": "last hard state",
     "name": "last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "output from the check plugin (first line)",
     "name": "plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "long output from the check plugin",
     "name": "long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "performance data from the check plugin",
     "name": "perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "whether the host problem has been acknowledged",
     "name": "acknowledged",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "acknowledgement type: 0=none, 1=normal, 2=sticky",
     "name": "acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "whether active checks are enabled for this host",
     "name": "active_checks_enabled",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether passive checks are enabled for this host",
     "name": "passive_checks_enabled",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether the event handler is enabled for this host",
     "name": "event_handler_enabled",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether flap detection is enabled for this host",
     "name": "flap_detection_enabled",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether notifications are enabled for this host",
     "name": "notifications_enabled",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether performance data processing is enabled for this host",
     "name": "process_performance_data",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether obsessing over this host is enabled",
     "name": "obsess_over_host",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "check type: 0=active, 1=passive",
     "name": "check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "current check attempt number",
     "name": "current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "current notification number for this problem",
     "name": "current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "whether the host is currently flapping",
     "name": "is_flapping",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "percent state change used for flap detection",
     "name": "percent_state_change",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "number of scheduled downtimes affecting this host",
     "name": "scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services associated with this host",
     "name": "num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of pending services on this host",
     "name": "num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of OK services on this host",
     "name": "num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of WARNING services on this host",
     "name": "num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of CRITICAL services on this host",
     "name": "num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of UNKNOWN services on this host",
     "name": "num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "host freshness threshold in seconds",
     "name": "freshness_threshold",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "optional string of notes pertaining to the host",
     "name": "notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "optional URL providing more information about the host",
     "name": "notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "optional URL providing actions to perform on the host",
     "name": "action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "name of the icon image associated with this host",
     "name": "icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "alt text for the icon image",
     "name": "icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "value representing the worth of this host to the organization",
     "name": "hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "event handler command name",
     "name": "event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "low flap threshold",
     "name": "low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "high flap threshold",
     "name": "high_flap_threshold",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/hosts/<name>": {
  "GET": {
   "columns": [
    {
     "description": "host name",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "display name, defaults to host_name",
     "name": "display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "longer name or description used to identify the host",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "IP address or FQDN of the host",
     "name": "address",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of parent host names",
     "name": "parents",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of hostgroup names",
     "name": "hostgroups",
     "type": "string",
     "unit": ""
    },
    {
     "description": "check command name and arguments",
     "name": "check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "expanded check command with macros resolved",
     "name": "check_command_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "number of time units between regularly scheduled checks",
     "name": "check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of time units to wait before re-checking the host after a non-UP state",
     "name": "retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of times to retry the host check before generating an alert",
     "name": "max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "timeout in seconds for the host check command",
     "name": "check_timeout",
     "type": "number",
     "unit": ""
    },
    {
     "description": "time period during which active checks of this host can be made",
     "name": "check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of contact names notified about host problems",
     "name": "contacts",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of contact group names notified about host problems",
     "name": "contact_groups",
     "type": "string",
     "unit": ""
    },
    {
     "description": "number of time units to wait before re-notifying about a still-down host",
     "name": "notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of time units to wait before sending the first problem notification",
     "name": "first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "time period during which notifications can be sent for this host",
     "name": "notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "host notification options (d,u,r,f,s)",
     "name": "notification_options",
     "type": "string",
     "unit": ""
    },
    {
     "description": "current state: 0=UP, 1=DOWN, 2=UNREACHABLE",
     "name": "state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "whether the host has been checked at least once",
     "name": "has_been_checked",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "timestamp of the last host check",
     "name": "last_check",
     "type": "time",
     "unit": ""
    },
    {
     "description": "timestamp of the next scheduled host check",
     "name": "next_check",
     "type": "time",
     "unit": ""
    },
    {
     "description": "timestamp of the last state change",
     "name": "last_state_change",
     "type": "time",
     "unit": ""
    },
    {
     "description": "timestamp of the last hard state change",
     "name": "last_hard_state_change",
     "type": "time",
     "unit": ""
    },
    {
     "description": "last hard state",
     "name": "last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "output from the check plugin (first line)",
     "name": "plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "long output from the check plugin",
     "name": "long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "performance data from the check plugin",
     "name": "perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "whether the host problem has been acknowledged",
     "name": "acknowledged",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "acknowledgement type: 0=none, 1=normal, 2=sticky",
     "name": "acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "whether active checks are enabled for this host",
     "name": "active_checks_enabled",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether passive checks are enabled for this host",
     "name": "passive_checks_enabled",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether the event handler is enabled for this host",
     "name": "event_handler_enabled",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether flap detection is enabled for this host",
     "name": "flap_detection_enabled",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether notifications are enabled for this host",
     "name": "notifications_enabled",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether performance data processing is enabled for this host",
     "name": "process_performance_data",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether obsessing over this host is enabled",
     "name": "obsess_over_host",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "check type: 0=active, 1=passive",
     "name": "check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "current check attempt number",
     "name": "current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "current notification number for this problem",
     "name": "current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "whether the host is currently flapping",
     "name": "is_flapping",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "percent state change used for flap detection",
     "name": "percent_state_change",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "number of scheduled downtimes affecting this host",
     "name": "scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services associated with this host",
     "name": "num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of pending services on this host",
     "name": "num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of OK services on this host",
     "name": "num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of WARNING services on this host",
     "name": "num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of CRITICAL services on this host",
     "name": "num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of UNKNOWN services on this host",
     "name": "num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "host freshness threshold in seconds",
     "name": "freshness_threshold",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "optional string of notes pertaining to the host",
     "name": "notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "optional URL providing more information about the host",
     "name": "notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "optional URL providing actions to perform on the host",
     "name": "action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "name of the icon image associated with this host",
     "name": "icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "alt text for the icon image",
     "name": "icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "value representing the worth of this host to the organization",
     "name": "hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "event handler command name",
     "name": "event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "low flap threshold",
     "name": "low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "high flap threshold",
     "name": "high_flap_threshold",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/services": {
  "GET": {
   "columns": [
    {
     "description": "host name the service belongs to",
     "name": "host_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "host group name the service belongs to",
     "name": "host_groups",
     "type": "string",
     "unit": ""
    },
    {
     "description": "service description",
     "name": "description",
     "type": "string",
     "unit": ""
    },
    {
     "description": "alternative display name, defaults to service_description",
     "name": "display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of servicegroup names",
     "name": "servicegroups",
     "type": "string",
     "unit": ""
    },
    {
     "description": "check command name and arguments",
     "name": "check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "expanded check command with macros resolved",
     "name": "check_command_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "number of time units between regularly scheduled checks",
     "name": "check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of time units to wait before re-checking the service after a non-OK state",
     "name": "retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of times to retry the service check before generating an alert",
     "name": "max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "timeout in seconds for the service check command",
     "name": "check_timeout",
     "type": "number",
     "unit": ""
    },
    {
     "description": "time period during which active checks of this service can be made",
     "name": "check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of contact names notified about service problems",
     "name": "contacts",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of contact group names notified about service problems",
     "name": "contact_groups",
     "type": "string",
     "unit": ""
    },
    {
     "description": "number of time units to wait before re-notifying about a still-failing service",
     "name": "notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of time units to wait before sending the first problem notification",
     "name": "first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "time period during which notifications can be sent for this service",
     "name": "notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "service notification options (w,u,c,r,f,s)",
     "name": "notification_options",
     "type": "string",
     "unit": ""
    },
    {
     "description": "current state: 0=OK, 1=WARNING, 2=CRITICAL, 3=UNKNOWN",
     "name": "state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "whether the service has been checked at least once",
     "name": "has_been_checked",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "timestamp of the last service check",
     "name": "last_check",
     "type": "time",
     "unit": ""
    },
    {
     "description": "timestamp of the next scheduled service check",
     "name": "next_check",
     "type": "time",
     "unit": ""
    },
    {
     "description": "timestamp of the last state change",
     "name": "last_state_change",
     "type": "time",
     "unit": ""
    },
    {
     "description": "timestamp of the last hard state change",
     "name": "last_hard_state_change",
     "type": "time",
     "unit": ""
    },
    {
     "description": "last hard state",
     "name": "last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "output from the check plugin (first line)",
     "name": "plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "long output from the check plugin",
     "name": "long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "performance data from the check plugin",
     "name": "perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "whether the service problem has been acknowledged",
     "name": "acknowledged",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "acknowledgement type: 0=none, 1=normal, 2=sticky",
     "name": "acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "whether active checks are enabled for this service",
     "name": "active_checks_enabled",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether passive checks are enabled for this service",
     "name": "passive_checks_enabled",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether the event handler is enabled for this service",
     "name": "event_handler_enabled",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether flap detection is enabled for this service",
     "name": "flap_detection_enabled",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether notifications are enabled for this service",
     "name": "notifications_enabled",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether performance data processing is enabled for this service",
     "name": "process_performance_data",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether obsessing over this service is enabled",
     "name": "obsess_over_service",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether the service is volatile",
     "name": "is_volatile",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "check type: 0=active, 1=passive",
     "name": "check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "current check attempt number",
     "name": "current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "current notification number for this problem",
     "name": "current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "whether the service is currently flapping",
     "name": "is_flapping",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "percent state change used for flap detection",
     "name": "percent_state_change",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "number of scheduled downtimes affecting this service",
     "name": "scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "service freshness threshold in seconds",
     "name": "freshness_threshold",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "optional string of notes pertaining to the service",
     "name": "notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "optional URL providing more information about the service",
     "name": "notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "optional URL providing actions to perform on the service",
     "name": "action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "name of the icon image associated with this service",
     "name": "icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "alt text for the icon image",
     "name": "icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "value representing the worth of this service to the organization",
     "name": "hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "event handler command name",
     "name": "event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "low flap threshold",
     "name": "low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "high flap threshold",
     "name": "high_flap_threshold",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/services/<host>/<service>": {
  "GET": {
   "columns": [
    {
     "description": "host name the service belongs to",
     "name": "host_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "host group name the service belongs to",
     "name": "host_groups",
     "type": "string",
     "unit": ""
    },
    {
     "description": "service description",
     "name": "description",
     "type": "string",
     "unit": ""
    },
    {
     "description": "alternative display name, defaults to service_description",
     "name": "display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of servicegroup names",
     "name": "servicegroups",
     "type": "string",
     "unit": ""
    },
    {
     "description": "check command name and arguments",
     "name": "check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "expanded check command with macros resolved",
     "name": "check_command_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "number of time units between regularly scheduled checks",
     "name": "check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of time units to wait before re-checking the service after a non-OK state",
     "name": "retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of times to retry the service check before generating an alert",
     "name": "max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "timeout in seconds for the service check command",
     "name": "check_timeout",
     "type": "number",
     "unit": ""
    },
    {
     "description": "time period during which active checks of this service can be made",
     "name": "check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of contact names notified about service problems",
     "name": "contacts",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of contact group names notified about service problems",
     "name": "contact_groups",
     "type": "string",
     "unit": ""
    },
    {
     "description": "number of time units to wait before re-notifying about a still-failing service",
     "name": "notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of time units to wait before sending the first problem notification",
     "name": "first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "time period during which notifications can be sent for this service",
     "name": "notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "service notification options (w,u,c,r,f,s)",
     "name": "notification_options",
     "type": "string",
     "unit": ""
    },
    {
     "description": "current state: 0=OK, 1=WARNING, 2=CRITICAL, 3=UNKNOWN",
     "name": "state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "whether the service has been checked at least once",
     "name": "has_been_checked",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "timestamp of the last service check",
     "name": "last_check",
     "type": "time",
     "unit": ""
    },
    {
     "description": "timestamp of the next scheduled service check",
     "name": "next_check",
     "type": "time",
     "unit": ""
    },
    {
     "description": "timestamp of the last state change",
     "name": "last_state_change",
     "type": "time",
     "unit": ""
    },
    {
     "description": "timestamp of the last hard state change",
     "name": "last_hard_state_change",
     "type": "time",
     "unit": ""
    },
    {
     "description": "last hard state",
     "name": "last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "output from the check plugin (first line)",
     "name": "plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "long output from the check plugin",
     "name": "long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "performance data from the check plugin",
     "name": "perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "whether the service problem has been acknowledged",
     "name": "acknowledged",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "acknowledgement type: 0=none, 1=normal, 2=sticky",
     "name": "acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "whether active checks are enabled for this service",
     "name": "active_checks_enabled",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether passive checks are enabled for this service",
     "name": "passive_checks_enabled",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether the event handler is enabled for this service",
     "name": "event_handler_enabled",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether flap detection is enabled for this service",
     "name": "flap_detection_enabled",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether notifications are enabled for this service",
     "name": "notifications_enabled",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether performance data processing is enabled for this service",
     "name": "process_performance_data",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether obsessing over this service is enabled",
     "name": "obsess_over_service",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether the service is volatile",
     "name": "is_volatile",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "check type: 0=active, 1=passive",
     "name": "check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "current check attempt number",
     "name": "current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "current notification number for this problem",
     "name": "current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "whether the service is currently flapping",
     "name": "is_flapping",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "percent state change used for flap detection",
     "name": "percent_state_change",
     "type": "number",
     "unit": "%"
    },
    {
     "description": "number of scheduled downtimes affecting this service",
     "name": "scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "service freshness threshold in seconds",
     "name": "freshness_threshold",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "optional string of notes pertaining to the service",
     "name": "notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "optional URL providing more information about the service",
     "name": "notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "optional URL providing actions to perform on the service",
     "name": "action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "name of the icon image associated with this service",
     "name": "icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "alt text for the icon image",
     "name": "icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "value representing the worth of this service to the organization",
     "name": "hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "event handler command name",
     "name": "event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "low flap threshold",
     "name": "low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "high flap threshold",
     "name": "high_flap_threshold",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/hostgroups": {
  "GET": {
   "columns": [
    {
     "description": "short name used to identify the host group",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "longer name or description used to identify the host group",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of host names belonging to this group",
     "name": "members",
     "type": "string",
     "unit": ""
    },
    {
     "description": "optional string of notes pertaining to the host group",
     "name": "notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "optional URL providing more information about the host group",
     "name": "notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "optional URL providing actions to perform on the host group",
     "name": "action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "number of hosts in this host group",
     "name": "num_hosts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of hosts in PENDING state",
     "name": "num_hosts_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of hosts in UP state",
     "name": "num_hosts_up",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of hosts in DOWN state",
     "name": "num_hosts_down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of hosts in UNREACHABLE state",
     "name": "num_hosts_unreach",
     "type": "number",
     "unit": ""
    },
    {
     "description": "worst host state in this group (0=UP, 1=DOWN, 2=UNREACHABLE)",
     "name": "worst_host_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services in this host group",
     "name": "num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services in PENDING state",
     "name": "num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services in OK state",
     "name": "num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services in WARNING state",
     "name": "num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services in CRITICAL state",
     "name": "num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services in UNKNOWN state",
     "name": "num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "worst service state in this group (0=OK, 1=WARNING, 2=CRITICAL, 3=UNKNOWN)",
     "name": "worst_service_state",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/hostgroups/<name>": {
  "GET": {
   "columns": [
    {
     "description": "short name used to identify the host group",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "longer name or description used to identify the host group",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of host names belonging to this group",
     "name": "members",
     "type": "string",
     "unit": ""
    },
    {
     "description": "optional string of notes pertaining to the host group",
     "name": "notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "optional URL providing more information about the host group",
     "name": "notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "optional URL providing actions to perform on the host group",
     "name": "action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "number of hosts in this host group",
     "name": "num_hosts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of hosts in PENDING state",
     "name": "num_hosts_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of hosts in UP state",
     "name": "num_hosts_up",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of hosts in DOWN state",
     "name": "num_hosts_down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of hosts in UNREACHABLE state",
     "name": "num_hosts_unreach",
     "type": "number",
     "unit": ""
    },
    {
     "description": "worst host state in this group (0=UP, 1=DOWN, 2=UNREACHABLE)",
     "name": "worst_host_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services in this host group",
     "name": "num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services in PENDING state",
     "name": "num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services in OK state",
     "name": "num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services in WARNING state",
     "name": "num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services in CRITICAL state",
     "name": "num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services in UNKNOWN state",
     "name": "num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "worst service state in this group (0=OK, 1=WARNING, 2=CRITICAL, 3=UNKNOWN)",
     "name": "worst_service_state",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/servicegroups": {
  "GET": {
   "columns": [
    {
     "description": "short name used to identify the service group",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "longer name or description used to identify the service group",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of service members in host,service format",
     "name": "members",
     "type": "string",
     "unit": ""
    },
    {
     "description": "optional string of notes pertaining to the service group",
     "name": "notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "optional URL providing more information about the service group",
     "name": "notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "optional URL providing actions to perform on the service group",
     "name": "action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "number of services in this service group",
     "name": "num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services in PENDING state",
     "name": "num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services in OK state",
     "name": "num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services in WARNING state",
     "name": "num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services in CRITICAL state",
     "name": "num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services in UNKNOWN state",
     "name": "num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "worst service state in this group (0=OK, 1=WARNING, 2=CRITICAL, 3=UNKNOWN)",
     "name": "worst_service_state",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/servicegroups/<name>": {
  "GET": {
   "columns": [
    {
     "description": "short name used to identify the service group",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "longer name or description used to identify the service group",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of service members in host,service format",
     "name": "members",
     "type": "string",
     "unit": ""
    },
    {
     "description": "optional string of notes pertaining to the service group",
     "name": "notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "optional URL providing more information about the service group",
     "name": "notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "optional URL providing actions to perform on the service group",
     "name": "action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "number of services in this service group",
     "name": "num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services in PENDING state",
     "name": "num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services in OK state",
     "name": "num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services in WARNING state",
     "name": "num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services in CRITICAL state",
     "name": "num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services in UNKNOWN state",
     "name": "num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "worst service state in this group (0=OK, 1=WARNING, 2=CRITICAL, 3=UNKNOWN)",
     "name": "worst_service_state",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/contacts": {
  "GET": {
   "columns": [
    {
     "description": "short name used to identify the contact",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "longer name or description for the contact, defaults to contact_name",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "email address for the contact",
     "name": "email",
     "type": "string",
     "unit": ""
    },
    {
     "description": "pager number or pager email gateway",
     "name": "pager",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of contactgroup names",
     "name": "contactgroups",
     "type": "string",
     "unit": ""
    },
    {
     "description": "time period during which host notifications can be sent to this contact",
     "name": "host_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "time period during which service notifications can be sent to this contact",
     "name": "service_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "whether the contact receives host notifications",
     "name": "host_notifications_enabled",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether the contact receives service notifications",
     "name": "service_notifications_enabled",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether the contact can submit external commands",
     "name": "can_submit_commands",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "minimum value required before host or service notifications are sent",
     "name": "minimum_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "host notification options (d,u,r,f,s,n)",
     "name": "host_notification_options",
     "type": "string",
     "unit": ""
    },
    {
     "description": "service notification options (w,u,c,r,f,s,n)",
     "name": "service_notification_options",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of host notification command names",
     "name": "host_notification_commands",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of service notification command names",
     "name": "service_notification_commands",
     "type": "string",
     "unit": ""
    },
    {
     "description": "additional contact address (address1 through address6)",
     "name": "address1",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/contacts/<name>": {
  "GET": {
   "columns": [
    {
     "description": "short name used to identify the contact",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "longer name or description for the contact, defaults to contact_name",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "email address for the contact",
     "name": "email",
     "type": "string",
     "unit": ""
    },
    {
     "description": "pager number or pager email gateway",
     "name": "pager",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of contactgroup names",
     "name": "contactgroups",
     "type": "string",
     "unit": ""
    },
    {
     "description": "time period during which host notifications can be sent to this contact",
     "name": "host_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "time period during which service notifications can be sent to this contact",
     "name": "service_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "whether the contact receives host notifications",
     "name": "host_notifications_enabled",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether the contact receives service notifications",
     "name": "service_notifications_enabled",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether the contact can submit external commands",
     "name": "can_submit_commands",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "minimum value required before host or service notifications are sent",
     "name": "minimum_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "host notification options (d,u,r,f,s,n)",
     "name": "host_notification_options",
     "type": "string",
     "unit": ""
    },
    {
     "description": "service notification options (w,u,c,r,f,s,n)",
     "name": "service_notification_options",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of host notification command names",
     "name": "host_notification_commands",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of service notification command names",
     "name": "service_notification_commands",
     "type": "string",
     "unit": ""
    },
    {
     "description": "additional contact address (address1 through address6)",
     "name": "address1",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/contactgroups": {
  "GET": {
   "columns": [
    {
     "description": "short name used to identify the contact group",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "longer name or description used to identify the contact group",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of contact names belonging to this group",
     "name": "members",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/contactgroups/<name>": {
  "GET": {
   "columns": [
    {
     "description": "short name used to identify the contact group",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "longer name or description used to identify the contact group",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comma separated list of contact names belonging to this group",
     "name": "members",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/timeperiods": {
  "GET": {
   "columns": [
    {
     "description": "short name used to identify the time period",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "longer name or description used to identify the time period",
     "name": "alias",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/timeperiods/<name>": {
  "GET": {
   "columns": [
    {
     "description": "short name used to identify the time period",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "longer name or description used to identify the time period",
     "name": "alias",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/commands": {
  "GET": {
   "columns": [
    {
     "description": "short name used to identify the command",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "the actual command line to execute",
     "name": "line",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/commands/<name>": {
  "GET": {
   "columns": [
    {
     "description": "short name used to identify the command",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "the actual command line to execute",
     "name": "line",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/comments": {
  "GET": {
   "columns": [
    {
     "description": "host name the comment is associated with",
     "name": "host_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "service description the comment is associated with (empty for host comments)",
     "name": "service_description",
     "type": "string",
     "unit": ""
    },
    {
     "description": "author of the comment",
     "name": "author",
     "type": "string",
     "unit": ""
    },
    {
     "description": "text content of the comment",
     "name": "comment",
     "type": "string",
     "unit": ""
    },
    {
     "description": "entry type: 1=user, 2=downtime, 3=flapping, 4=acknowledgement",
     "name": "entry_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "timestamp when the comment was created",
     "name": "entry_time",
     "type": "time",
     "unit": ""
    },
    {
     "description": "unique identifier of the comment",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "whether the comment is persistent across restarts",
     "name": "persistent",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "source of the comment: 0=internal, 1=external",
     "name": "source",
     "type": "number",
     "unit": ""
    },
    {
     "description": "type of the comment: 1=host, 2=service",
     "name": "type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "whether the comment is associated with a service",
     "name": "is_service",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether the comment has an expiration time",
     "name": "expires",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "timestamp when the comment expires",
     "name": "expire_time",
     "type": "time",
     "unit": ""
    }
   ]
  }
 },
 "/comments/<id>": {
  "GET": {
   "columns": [
    {
     "description": "host name the comment is associated with",
     "name": "host_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "service description the comment is associated with (empty for host comments)",
     "name": "service_description",
     "type": "string",
     "unit": ""
    },
    {
     "description": "author of the comment",
     "name": "author",
     "type": "string",
     "unit": ""
    },
    {
     "description": "text content of the comment",
     "name": "comment",
     "type": "string",
     "unit": ""
    },
    {
     "description": "entry type: 1=user, 2=downtime, 3=flapping, 4=acknowledgement",
     "name": "entry_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "timestamp when the comment was created",
     "name": "entry_time",
     "type": "time",
     "unit": ""
    },
    {
     "description": "unique identifier of the comment",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "whether the comment is persistent across restarts",
     "name": "persistent",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "source of the comment: 0=internal, 1=external",
     "name": "source",
     "type": "number",
     "unit": ""
    },
    {
     "description": "type of the comment: 1=host, 2=service",
     "name": "type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "whether the comment is associated with a service",
     "name": "is_service",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether the comment has an expiration time",
     "name": "expires",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "timestamp when the comment expires",
     "name": "expire_time",
     "type": "time",
     "unit": ""
    }
   ]
  }
 },
 "/downtimes": {
  "GET": {
   "columns": [
    {
     "description": "host name the downtime is associated with",
     "name": "host_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "service description the downtime is associated with (empty for host downtimes)",
     "name": "service_description",
     "type": "string",
     "unit": ""
    },
    {
     "description": "author of the downtime",
     "name": "author",
     "type": "string",
     "unit": ""
    },
    {
     "description": "text comment for the downtime",
     "name": "comment",
     "type": "string",
     "unit": ""
    },
    {
     "description": "timestamp when the downtime was created",
     "name": "entry_time",
     "type": "time",
     "unit": ""
    },
    {
     "description": "timestamp when the downtime starts",
     "name": "start_time",
     "type": "time",
     "unit": ""
    },
    {
     "description": "timestamp when the downtime ends",
     "name": "end_time",
     "type": "time",
     "unit": ""
    },
    {
     "description": "whether the downtime is fixed (1) or flexible (0)",
     "name": "fixed",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "id of the downtime that triggered this one, 0 if not triggered",
     "name": "triggered_by",
     "type": "number",
     "unit": ""
    },
    {
     "description": "unique identifier of the downtime",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "duration of the downtime in seconds (for flexible downtimes)",
     "name": "duration",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "type of the downtime: 1=host, 2=service",
     "name": "type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "whether the downtime is associated with a service",
     "name": "is_service",
     "type": "boolean",
     "unit": ""
    }
   ]
  }
 },
 "/downtimes/<id>": {
  "GET": {
   "columns": [
    {
     "description": "host name the downtime is associated with",
     "name": "host_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "service description the downtime is associated with (empty for host downtimes)",
     "name": "service_description",
     "type": "string",
     "unit": ""
    },
    {
     "description": "author of the downtime",
     "name": "author",
     "type": "string",
     "unit": ""
    },
    {
     "description": "text comment for the downtime",
     "name": "comment",
     "type": "string",
     "unit": ""
    },
    {
     "description": "timestamp when the downtime was created",
     "name": "entry_time",
     "type": "time",
     "unit": ""
    },
    {
     "description": "timestamp when the downtime starts",
     "name": "start_time",
     "type": "time",
     "unit": ""
    },
    {
     "description": "timestamp when the downtime ends",
     "name": "end_time",
     "type": "time",
     "unit": ""
    },
    {
     "description": "whether the downtime is fixed (1) or flexible (0)",
     "name": "fixed",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "id of the downtime that triggered this one, 0 if not triggered",
     "name": "triggered_by",
     "type": "number",
     "unit": ""
    },
    {
     "description": "unique identifier of the downtime",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "duration of the downtime in seconds (for flexible downtimes)",
     "name": "duration",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "type of the downtime: 1=host, 2=service",
     "name": "type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "whether the downtime is associated with a service",
     "name": "is_service",
     "type": "boolean",
     "unit": ""
    }
   ]
  }
 },
 "/logs": {
  "GET": {
   "columns": [
    {
     "description": "timestamp of the log entry",
     "name": "time",
     "type": "time",
     "unit": ""
    },
    {
     "description": "type of the log entry",
     "name": "type",
     "type": "string",
     "unit": ""
    },
    {
     "description": "state type (HARD or SOFT)",
     "name": "state_type",
     "type": "string",
     "unit": ""
    },
    {
     "description": "log message text",
     "name": "message",
     "type": "string",
     "unit": ""
    },
    {
     "description": "host name associated with this log entry",
     "name": "host_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "service description associated with this log entry",
     "name": "service_description",
     "type": "string",
     "unit": ""
    },
    {
     "description": "comment text from the log entry",
     "name": "comment",
     "type": "string",
     "unit": ""
    },
    {
     "description": "plugin output from the log entry",
     "name": "plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "state of the host or service at the time of the log entry",
     "name": "state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "current attempt number when this log entry was generated",
     "name": "attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "contact name associated with this log entry",
     "name": "contact_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "command name associated with this log entry",
     "name": "command_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "line number of the log entry in the log file",
     "name": "lineno",
     "type": "number",
     "unit": ""
    },
    {
     "description": "options string from the log entry",
     "name": "options",
     "type": "string",
     "unit": ""
    }
   ]
  }
 },
 "/processinfo": {
  "GET": {
   "columns": [
    {
     "description": "current state retention interval in seconds",
     "name": "interval_length",
     "type": "number",
     "unit": "s"
    },
    {
     "description": "Naemon program version",
     "name": "program_version",
     "type": "string",
     "unit": ""
    },
    {
     "description": "timestamp when Naemon was started",
     "name": "program_start",
     "type": "time",
     "unit": ""
    },
    {
     "description": "whether external commands are accepted",
     "name": "accept_passive_host_checks",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether service passive checks are accepted",
     "name": "accept_passive_service_checks",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether host checks are being executed",
     "name": "execute_host_checks",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether service checks are being executed",
     "name": "execute_service_checks",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether notifications are enabled globally",
     "name": "enable_notifications",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether event handlers are enabled globally",
     "name": "enable_event_handlers",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether flap detection is enabled globally",
     "name": "enable_flap_detection",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether performance data processing is enabled",
     "name": "process_performance_data",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether host freshness checking is enabled",
     "name": "check_host_freshness",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "whether service freshness checking is enabled",
     "name": "check_service_freshness",
     "type": "boolean",
     "unit": ""
    },
    {
     "description": "PID of the Naemon process",
     "name": "pid",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of hosts being monitored",
     "name": "num_hosts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "number of services being monitored",
     "name": "num_services",
     "type": "number",
     "unit": ""
    }
   ]
  }
 }
}

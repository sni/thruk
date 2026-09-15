package Thruk::Controller::Rest::V1::livestatus_docs;

use warnings;
use strict;
use Cpanel::JSON::XS qw/decode_json/;

=head1 NAME

Thruk::Controller::Rest::V1::livestatus_docs - Livestatus table column metadata

=head1 DESCRIPTION

Contains column attributes for Livestatus table endpoints like /hosts and /services.
These are merged with endpoint-specific docs at runtime.

Generated from naemon.github.io livestatus.columns.json

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
 "/commands": {
  "GET": {
   "columns": [
    {
     "description": "Command id",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The shell command line",
     "name": "line",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The name of the command",
     "name": "name",
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
     "description": "Command id",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The shell command line",
     "name": "line",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The name of the command",
     "name": "name",
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
     "description": "The contact that entered the comment",
     "name": "author",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A comment text",
     "name": "comment",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The time the entry was made as UNIX timestamp",
     "name": "entry_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the comment: 1 is user, 2 is downtime, 3 is flap and 4 is acknowledgement",
     "name": "entry_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of expiry of this comment as a UNIX timestamp",
     "name": "expire_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this comment expires",
     "name": "expires",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether passive host checks are accepted (0/1)",
     "name": "host_accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current host problem has been acknowledged (0/1)",
     "name": "host_acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of acknowledgement (0: none, 1: normal, 2: stick)",
     "name": "host_acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL to custom actions or information about this host",
     "name": "host_action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as action_url, but with the most important macros expanded",
     "name": "host_action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the host (0/1)",
     "name": "host_active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "IP address",
     "name": "host_address",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alias name for the host",
     "name": "host_alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Naemon command for active host check of this host",
     "name": "host_check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether to check to send a recovery notification when flapping stops (0/1)",
     "name": "host_check_flapping_recovery_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "host_check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the host",
     "name": "host_check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0-2)",
     "name": "host_check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which this host will be checked. If empty then the host will always be checked.",
     "name": "host_check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "host_check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Type of check (0: active, 1: passive)",
     "name": "host_check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether checks of the host are enabled (0/1)",
     "name": "host_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct children of the host",
     "name": "host_childs",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the ids of all comments of this host",
     "name": "host_comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the host with id, author, comment, entry_type, expires and expire_time",
     "name": "host_comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this host is in",
     "name": "host_contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of this host, either direct or via a contact group",
     "name": "host_contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Number of the current check attempts",
     "name": "host_current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of the current notification",
     "name": "host_current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables",
     "name": "host_custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of the custom variables",
     "name": "host_custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "host_custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute",
     "name": "host_depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "host_depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify",
     "name": "host_depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "host_depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Optional display name of the host",
     "name": "host_display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of the ids of all scheduled downtimes of this host",
     "name": "host_downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the host with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "host_downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "host_event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether event handling is enabled (0/1)",
     "name": "host_event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the host check needed for execution",
     "name": "host_execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The value of the custom variable FILENAME",
     "name": "host_filename",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "host_first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled (0/1)",
     "name": "host_flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all host groups this host is in",
     "name": "host_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The effective hard state of the host (eliminates a problem in hard_state)",
     "name": "host_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host has already been checked (0/1)",
     "name": "host_has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "host_high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "host_hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image file to be used in the web pages",
     "name": "host_icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Alternative text for the icon_image",
     "name": "host_icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as icon_image, but with the most important macros expanded",
     "name": "host_icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Host id",
     "name": "host_id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its check period (0/1)",
     "name": "host_in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its notification period (0/1)",
     "name": "host_in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Initial host state",
     "name": "host_initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a host check currently running... (0/1)",
     "name": "host_is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host state is flapping (0/1)",
     "name": "host_is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last check (Unix timestamp)",
     "name": "host_last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Last hard state",
     "name": "host_last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last hard state change (Unix timestamp)",
     "name": "host_last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last notification (Unix timestamp)",
     "name": "host_last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "State before last state change",
     "name": "host_last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last state change - soft or hard (Unix timestamp)",
     "name": "host_last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was DOWN (Unix timestamp)",
     "name": "host_last_time_down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UNREACHABLE (Unix timestamp)",
     "name": "host_last_time_unreachable",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UP (Unix timestamp)",
     "name": "host_last_time_up",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this host (Unix timestamp)",
     "name": "host_last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "host_latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Complete output from check plugin",
     "name": "host_long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "host_low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Max check attempts for active host checks",
     "name": "host_max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "host_modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "host_modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Host name",
     "name": "host_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Scheduled time for the next check (Unix timestamp)",
     "name": "host_next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the next notification (Unix timestamp)",
     "name": "host_next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "host_no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes for this host",
     "name": "host_notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as notes, but with the most important macros expanded",
     "name": "host_notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL with further information about the host",
     "name": "host_notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Same as notes_url, but with the most important macros expanded",
     "name": "host_notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "host_notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which problems of this host will be notified. If empty then notification will be always",
     "name": "host_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications of the host are enabled (0/1)",
     "name": "host_notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "host_notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "host_num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state CRIT",
     "name": "host_num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state CRIT",
     "name": "host_num_services_hard_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state OK",
     "name": "host_num_services_hard_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state UNKNOWN",
     "name": "host_num_services_hard_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state WARN",
     "name": "host_num_services_hard_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state OK",
     "name": "host_num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services which have not been checked yet (pending)",
     "name": "host_num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state UNKNOWN",
     "name": "host_num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state WARN",
     "name": "host_num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "host_obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "host_obsess_over_host",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct parents of the host",
     "name": "host_parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether a flex downtime is pending (0/1)",
     "name": "host_pending_flex_downtime",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "host_percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional performance data of the last host check",
     "name": "host_perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last host check",
     "name": "host_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this host (0/1)",
     "name": "host_pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled (0/1)",
     "name": "host_process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "host_retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of downtimes this host is currently in",
     "name": "host_scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all services of the host",
     "name": "host_services",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services including detailed information about each service",
     "name": "host_services_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services of the host together with state and has_been_checked",
     "name": "host_services_with_state",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this host (0/1)",
     "name": "host_should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Staleness indicator for this host",
     "name": "host_staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the host (0: up, 1: down, 2: unreachable)",
     "name": "host_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of the current state (0: soft, 1: hard)",
     "name": "host_state_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of in image file for the status map",
     "name": "host_statusmap_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "host_total_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst hard state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "host_worst_service_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst soft state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "host_worst_service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: X",
     "name": "host_x_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Y",
     "name": "host_y_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Z",
     "name": "host_z_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The id of the comment",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "0, if this entry is for a host, 1 if it is for a service",
     "name": "is_service",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this comment is persistent (0/1)",
     "name": "persistent",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service accepts passive checks (0/1)",
     "name": "service_accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current service problem has been acknowledged (0/1)",
     "name": "service_acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the acknowledgement (0: none, 1: normal, 2: sticky)",
     "name": "service_acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL for actions or custom information about the service",
     "name": "service_action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The action_url with (the most important) macros expanded",
     "name": "service_action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the service (0/1)",
     "name": "service_active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Naemon command used for active checks",
     "name": "service_check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "service_check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the service",
     "name": "service_check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0/1)",
     "name": "service_check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the check period of the service. It this is empty, the service is always checked.",
     "name": "service_check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "service_check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The type of the last check (0: active, 1: passive)",
     "name": "service_check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the service (0/1)",
     "name": "service_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all comment ids of the service",
     "name": "service_comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the service with id, author, comment, entry_type, expires and expire_time",
     "name": "service_comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this service is in",
     "name": "service_contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of the service, either direct or via a contact group",
     "name": "service_contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The number of the current check attempt",
     "name": "service_current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the current notification",
     "name": "service_current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables of the service",
     "name": "service_custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of all custom variable of the service",
     "name": "service_custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "service_custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to execute",
     "name": "service_depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to execute including information: host_name, service_description, failure_options, dependency_period and inherits_parent",
     "name": "service_depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to notify",
     "name": "service_depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to notify including information: host_name, service_description, failure_options, dependency_period and inherits_parent",
     "name": "service_depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Description of the service (also used as key)",
     "name": "service_description",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional display name",
     "name": "service_display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all downtime ids of the service",
     "name": "service_downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the service with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "service_downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "service_event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether and event handler is activated for the service (0/1)",
     "name": "service_event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the service check needed for execution",
     "name": "service_execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "service_first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled for the service (0/1)",
     "name": "service_flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all service groups the service is in",
     "name": "service_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether the service already has been checked (0/1)",
     "name": "service_has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "service_high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "service_hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image to be used as icon in the web interface",
     "name": "service_icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alternative text for the icon_image for browsers not displaying icons",
     "name": "service_icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The icon_image with (the most important) macros expanded",
     "name": "service_icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Service id",
     "name": "service_id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is currently in its check period (0/1)",
     "name": "service_in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is currently in its notification period (0/1)",
     "name": "service_in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The initial state of the service",
     "name": "service_initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a service check currently running... (0/1)",
     "name": "service_is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is flapping (0/1)",
     "name": "service_is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last check (Unix timestamp)",
     "name": "service_last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last hard state of the service",
     "name": "service_last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last hard state change (Unix timestamp)",
     "name": "service_last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last notification (Unix timestamp)",
     "name": "service_last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last state of the service",
     "name": "service_last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last state change (Unix timestamp)",
     "name": "service_last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was CRITICAL (Unix timestamp)",
     "name": "service_last_time_critical",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was OK (Unix timestamp)",
     "name": "service_last_time_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was UNKNOWN (Unix timestamp)",
     "name": "service_last_time_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was in WARNING state (Unix timestamp)",
     "name": "service_last_time_warning",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this service (Unix timestamp)",
     "name": "service_last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "service_latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Unabbreviated output of the last check plugin",
     "name": "service_long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "service_low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The maximum number of check attempts",
     "name": "service_max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "service_modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "service_modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The scheduled time of the next check (Unix timestamp)",
     "name": "service_next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the next notification (Unix timestamp)",
     "name": "service_next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "service_no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes about the service",
     "name": "service_notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The notes with (the most important) macros expanded",
     "name": "service_notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL for additional notes about the service",
     "name": "service_notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The notes_url with (the most important) macros expanded",
     "name": "service_notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "service_notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the notification period of the service. It this is empty, service problems are always notified.",
     "name": "service_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications are enabled for the service (0/1)",
     "name": "service_notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "service_notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether 'obsess' is enabled for the service (0/1)",
     "name": "service_obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether 'obsess' is enabled for the service (0/1)",
     "name": "service_obsess_over_service",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all parent services",
     "name": "service_parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "service_percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Performance data of the last check plugin",
     "name": "service_perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last check plugin",
     "name": "service_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this service (0/1)",
     "name": "service_pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled for the service (0/1)",
     "name": "service_process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "service_retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of scheduled downtimes the service is currently in",
     "name": "service_scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this service (0/1)",
     "name": "service_should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The staleness indicator for this service",
     "name": "service_staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the service (0: OK, 1: WARN, 2: CRITICAL, 3: UNKNOWN)",
     "name": "service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the current state (0: soft, 1: hard)",
     "name": "service_state_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The source of the comment (0 is internal and 1 is external)",
     "name": "source",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the comment: 1 is host, 2 is service",
     "name": "type",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/comments/<id>": {
  "GET": {
   "columns": [
    {
     "description": "The contact that entered the comment",
     "name": "author",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A comment text",
     "name": "comment",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The time the entry was made as UNIX timestamp",
     "name": "entry_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the comment: 1 is user, 2 is downtime, 3 is flap and 4 is acknowledgement",
     "name": "entry_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of expiry of this comment as a UNIX timestamp",
     "name": "expire_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this comment expires",
     "name": "expires",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether passive host checks are accepted (0/1)",
     "name": "host_accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current host problem has been acknowledged (0/1)",
     "name": "host_acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of acknowledgement (0: none, 1: normal, 2: stick)",
     "name": "host_acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL to custom actions or information about this host",
     "name": "host_action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as action_url, but with the most important macros expanded",
     "name": "host_action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the host (0/1)",
     "name": "host_active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "IP address",
     "name": "host_address",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alias name for the host",
     "name": "host_alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Naemon command for active host check of this host",
     "name": "host_check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether to check to send a recovery notification when flapping stops (0/1)",
     "name": "host_check_flapping_recovery_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "host_check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the host",
     "name": "host_check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0-2)",
     "name": "host_check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which this host will be checked. If empty then the host will always be checked.",
     "name": "host_check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "host_check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Type of check (0: active, 1: passive)",
     "name": "host_check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether checks of the host are enabled (0/1)",
     "name": "host_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct children of the host",
     "name": "host_childs",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the ids of all comments of this host",
     "name": "host_comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the host with id, author, comment, entry_type, expires and expire_time",
     "name": "host_comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this host is in",
     "name": "host_contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of this host, either direct or via a contact group",
     "name": "host_contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Number of the current check attempts",
     "name": "host_current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of the current notification",
     "name": "host_current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables",
     "name": "host_custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of the custom variables",
     "name": "host_custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "host_custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute",
     "name": "host_depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "host_depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify",
     "name": "host_depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "host_depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Optional display name of the host",
     "name": "host_display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of the ids of all scheduled downtimes of this host",
     "name": "host_downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the host with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "host_downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "host_event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether event handling is enabled (0/1)",
     "name": "host_event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the host check needed for execution",
     "name": "host_execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The value of the custom variable FILENAME",
     "name": "host_filename",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "host_first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled (0/1)",
     "name": "host_flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all host groups this host is in",
     "name": "host_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The effective hard state of the host (eliminates a problem in hard_state)",
     "name": "host_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host has already been checked (0/1)",
     "name": "host_has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "host_high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "host_hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image file to be used in the web pages",
     "name": "host_icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Alternative text for the icon_image",
     "name": "host_icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as icon_image, but with the most important macros expanded",
     "name": "host_icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Host id",
     "name": "host_id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its check period (0/1)",
     "name": "host_in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its notification period (0/1)",
     "name": "host_in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Initial host state",
     "name": "host_initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a host check currently running... (0/1)",
     "name": "host_is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host state is flapping (0/1)",
     "name": "host_is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last check (Unix timestamp)",
     "name": "host_last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Last hard state",
     "name": "host_last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last hard state change (Unix timestamp)",
     "name": "host_last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last notification (Unix timestamp)",
     "name": "host_last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "State before last state change",
     "name": "host_last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last state change - soft or hard (Unix timestamp)",
     "name": "host_last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was DOWN (Unix timestamp)",
     "name": "host_last_time_down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UNREACHABLE (Unix timestamp)",
     "name": "host_last_time_unreachable",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UP (Unix timestamp)",
     "name": "host_last_time_up",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this host (Unix timestamp)",
     "name": "host_last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "host_latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Complete output from check plugin",
     "name": "host_long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "host_low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Max check attempts for active host checks",
     "name": "host_max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "host_modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "host_modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Host name",
     "name": "host_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Scheduled time for the next check (Unix timestamp)",
     "name": "host_next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the next notification (Unix timestamp)",
     "name": "host_next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "host_no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes for this host",
     "name": "host_notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as notes, but with the most important macros expanded",
     "name": "host_notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL with further information about the host",
     "name": "host_notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Same as notes_url, but with the most important macros expanded",
     "name": "host_notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "host_notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which problems of this host will be notified. If empty then notification will be always",
     "name": "host_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications of the host are enabled (0/1)",
     "name": "host_notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "host_notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "host_num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state CRIT",
     "name": "host_num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state CRIT",
     "name": "host_num_services_hard_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state OK",
     "name": "host_num_services_hard_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state UNKNOWN",
     "name": "host_num_services_hard_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state WARN",
     "name": "host_num_services_hard_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state OK",
     "name": "host_num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services which have not been checked yet (pending)",
     "name": "host_num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state UNKNOWN",
     "name": "host_num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state WARN",
     "name": "host_num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "host_obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "host_obsess_over_host",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct parents of the host",
     "name": "host_parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether a flex downtime is pending (0/1)",
     "name": "host_pending_flex_downtime",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "host_percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional performance data of the last host check",
     "name": "host_perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last host check",
     "name": "host_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this host (0/1)",
     "name": "host_pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled (0/1)",
     "name": "host_process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "host_retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of downtimes this host is currently in",
     "name": "host_scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all services of the host",
     "name": "host_services",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services including detailed information about each service",
     "name": "host_services_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services of the host together with state and has_been_checked",
     "name": "host_services_with_state",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this host (0/1)",
     "name": "host_should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Staleness indicator for this host",
     "name": "host_staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the host (0: up, 1: down, 2: unreachable)",
     "name": "host_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of the current state (0: soft, 1: hard)",
     "name": "host_state_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of in image file for the status map",
     "name": "host_statusmap_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "host_total_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst hard state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "host_worst_service_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst soft state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "host_worst_service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: X",
     "name": "host_x_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Y",
     "name": "host_y_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Z",
     "name": "host_z_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The id of the comment",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "0, if this entry is for a host, 1 if it is for a service",
     "name": "is_service",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this comment is persistent (0/1)",
     "name": "persistent",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service accepts passive checks (0/1)",
     "name": "service_accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current service problem has been acknowledged (0/1)",
     "name": "service_acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the acknowledgement (0: none, 1: normal, 2: sticky)",
     "name": "service_acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL for actions or custom information about the service",
     "name": "service_action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The action_url with (the most important) macros expanded",
     "name": "service_action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the service (0/1)",
     "name": "service_active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Naemon command used for active checks",
     "name": "service_check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "service_check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the service",
     "name": "service_check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0/1)",
     "name": "service_check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the check period of the service. It this is empty, the service is always checked.",
     "name": "service_check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "service_check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The type of the last check (0: active, 1: passive)",
     "name": "service_check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the service (0/1)",
     "name": "service_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all comment ids of the service",
     "name": "service_comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the service with id, author, comment, entry_type, expires and expire_time",
     "name": "service_comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this service is in",
     "name": "service_contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of the service, either direct or via a contact group",
     "name": "service_contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The number of the current check attempt",
     "name": "service_current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the current notification",
     "name": "service_current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables of the service",
     "name": "service_custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of all custom variable of the service",
     "name": "service_custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "service_custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to execute",
     "name": "service_depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to execute including information: host_name, service_description, failure_options, dependency_period and inherits_parent",
     "name": "service_depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to notify",
     "name": "service_depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to notify including information: host_name, service_description, failure_options, dependency_period and inherits_parent",
     "name": "service_depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Description of the service (also used as key)",
     "name": "service_description",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional display name",
     "name": "service_display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all downtime ids of the service",
     "name": "service_downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the service with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "service_downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "service_event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether and event handler is activated for the service (0/1)",
     "name": "service_event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the service check needed for execution",
     "name": "service_execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "service_first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled for the service (0/1)",
     "name": "service_flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all service groups the service is in",
     "name": "service_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether the service already has been checked (0/1)",
     "name": "service_has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "service_high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "service_hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image to be used as icon in the web interface",
     "name": "service_icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alternative text for the icon_image for browsers not displaying icons",
     "name": "service_icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The icon_image with (the most important) macros expanded",
     "name": "service_icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Service id",
     "name": "service_id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is currently in its check period (0/1)",
     "name": "service_in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is currently in its notification period (0/1)",
     "name": "service_in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The initial state of the service",
     "name": "service_initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a service check currently running... (0/1)",
     "name": "service_is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is flapping (0/1)",
     "name": "service_is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last check (Unix timestamp)",
     "name": "service_last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last hard state of the service",
     "name": "service_last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last hard state change (Unix timestamp)",
     "name": "service_last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last notification (Unix timestamp)",
     "name": "service_last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last state of the service",
     "name": "service_last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last state change (Unix timestamp)",
     "name": "service_last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was CRITICAL (Unix timestamp)",
     "name": "service_last_time_critical",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was OK (Unix timestamp)",
     "name": "service_last_time_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was UNKNOWN (Unix timestamp)",
     "name": "service_last_time_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was in WARNING state (Unix timestamp)",
     "name": "service_last_time_warning",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this service (Unix timestamp)",
     "name": "service_last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "service_latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Unabbreviated output of the last check plugin",
     "name": "service_long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "service_low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The maximum number of check attempts",
     "name": "service_max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "service_modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "service_modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The scheduled time of the next check (Unix timestamp)",
     "name": "service_next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the next notification (Unix timestamp)",
     "name": "service_next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "service_no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes about the service",
     "name": "service_notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The notes with (the most important) macros expanded",
     "name": "service_notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL for additional notes about the service",
     "name": "service_notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The notes_url with (the most important) macros expanded",
     "name": "service_notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "service_notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the notification period of the service. It this is empty, service problems are always notified.",
     "name": "service_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications are enabled for the service (0/1)",
     "name": "service_notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "service_notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether 'obsess' is enabled for the service (0/1)",
     "name": "service_obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether 'obsess' is enabled for the service (0/1)",
     "name": "service_obsess_over_service",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all parent services",
     "name": "service_parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "service_percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Performance data of the last check plugin",
     "name": "service_perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last check plugin",
     "name": "service_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this service (0/1)",
     "name": "service_pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled for the service (0/1)",
     "name": "service_process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "service_retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of scheduled downtimes the service is currently in",
     "name": "service_scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this service (0/1)",
     "name": "service_should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The staleness indicator for this service",
     "name": "service_staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the service (0: OK, 1: WARN, 2: CRITICAL, 3: UNKNOWN)",
     "name": "service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the current state (0: soft, 1: hard)",
     "name": "service_state_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The source of the comment (0 is internal and 1 is external)",
     "name": "source",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the comment: 1 is host, 2 is service",
     "name": "type",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/contactgroups": {
  "GET": {
   "columns": [
    {
     "description": "The alias of the contactgroup",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Contactgroup id",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all members of this contactgroup",
     "name": "members",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The name of the contactgroup",
     "name": "name",
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
     "description": "The alias of the contactgroup",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Contactgroup id",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all members of this contactgroup",
     "name": "members",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The name of the contactgroup",
     "name": "name",
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
     "description": "The additional field address1",
     "name": "address1",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The additional field address2",
     "name": "address2",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The additional field address3",
     "name": "address3",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The additional field address4",
     "name": "address4",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The additional field address5",
     "name": "address5",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The additional field address6",
     "name": "address6",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The full name of the contact",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether the contact is allowed to submit commands (0/1)",
     "name": "can_submit_commands",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all custom variables of the contact",
     "name": "custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of all custom variables of the contact",
     "name": "custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The email address of the contact",
     "name": "email",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this contact is in",
     "name": "groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all host notifications commands for this contact",
     "name": "host_notification_commands",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The time period in which the contact will be notified about host problems",
     "name": "host_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether the contact will be notified about host problems in general (0/1)",
     "name": "host_notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Contact id",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the contact is currently in his/her host notification period (0/1)",
     "name": "in_host_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the contact is currently in his/her service notification period (0/1)",
     "name": "in_service_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The login name of the contact person",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The pager address of the contact",
     "name": "pager",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all service notifications commands for this contact",
     "name": "service_notification_commands",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The time period in which the contact will be notified about service problems",
     "name": "service_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether the contact will be notified about service problems in general (0/1)",
     "name": "service_notifications_enabled",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/contacts/<name>": {
  "GET": {
   "columns": [
    {
     "description": "The additional field address1",
     "name": "address1",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The additional field address2",
     "name": "address2",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The additional field address3",
     "name": "address3",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The additional field address4",
     "name": "address4",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The additional field address5",
     "name": "address5",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The additional field address6",
     "name": "address6",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The full name of the contact",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether the contact is allowed to submit commands (0/1)",
     "name": "can_submit_commands",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all custom variables of the contact",
     "name": "custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of all custom variables of the contact",
     "name": "custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The email address of the contact",
     "name": "email",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this contact is in",
     "name": "groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all host notifications commands for this contact",
     "name": "host_notification_commands",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The time period in which the contact will be notified about host problems",
     "name": "host_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether the contact will be notified about host problems in general (0/1)",
     "name": "host_notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Contact id",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the contact is currently in his/her host notification period (0/1)",
     "name": "in_host_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the contact is currently in his/her service notification period (0/1)",
     "name": "in_service_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The login name of the contact person",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The pager address of the contact",
     "name": "pager",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all service notifications commands for this contact",
     "name": "service_notification_commands",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The time period in which the contact will be notified about service problems",
     "name": "service_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether the contact will be notified about service problems in general (0/1)",
     "name": "service_notifications_enabled",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/downtimes": {
  "GET": {
   "columns": [
    {
     "description": "The contact that scheduled the downtime",
     "name": "author",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A comment text",
     "name": "comment",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The duration of the downtime in seconds",
     "name": "duration",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The end time of the downtime as UNIX timestamp",
     "name": "end_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time the entry was made as UNIX timestamp",
     "name": "entry_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A 1 if the downtime is fixed, a 0 if it is flexible",
     "name": "fixed",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether passive host checks are accepted (0/1)",
     "name": "host_accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current host problem has been acknowledged (0/1)",
     "name": "host_acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of acknowledgement (0: none, 1: normal, 2: stick)",
     "name": "host_acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL to custom actions or information about this host",
     "name": "host_action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as action_url, but with the most important macros expanded",
     "name": "host_action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the host (0/1)",
     "name": "host_active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "IP address",
     "name": "host_address",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alias name for the host",
     "name": "host_alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Naemon command for active host check of this host",
     "name": "host_check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether to check to send a recovery notification when flapping stops (0/1)",
     "name": "host_check_flapping_recovery_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "host_check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the host",
     "name": "host_check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0-2)",
     "name": "host_check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which this host will be checked. If empty then the host will always be checked.",
     "name": "host_check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "host_check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Type of check (0: active, 1: passive)",
     "name": "host_check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether checks of the host are enabled (0/1)",
     "name": "host_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct children of the host",
     "name": "host_childs",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the ids of all comments of this host",
     "name": "host_comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the host with id, author, comment, entry_type, expires and expire_time",
     "name": "host_comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this host is in",
     "name": "host_contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of this host, either direct or via a contact group",
     "name": "host_contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Number of the current check attempts",
     "name": "host_current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of the current notification",
     "name": "host_current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables",
     "name": "host_custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of the custom variables",
     "name": "host_custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "host_custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute",
     "name": "host_depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "host_depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify",
     "name": "host_depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "host_depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Optional display name of the host",
     "name": "host_display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of the ids of all scheduled downtimes of this host",
     "name": "host_downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the host with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "host_downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "host_event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether event handling is enabled (0/1)",
     "name": "host_event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the host check needed for execution",
     "name": "host_execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The value of the custom variable FILENAME",
     "name": "host_filename",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "host_first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled (0/1)",
     "name": "host_flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all host groups this host is in",
     "name": "host_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The effective hard state of the host (eliminates a problem in hard_state)",
     "name": "host_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host has already been checked (0/1)",
     "name": "host_has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "host_high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "host_hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image file to be used in the web pages",
     "name": "host_icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Alternative text for the icon_image",
     "name": "host_icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as icon_image, but with the most important macros expanded",
     "name": "host_icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Host id",
     "name": "host_id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its check period (0/1)",
     "name": "host_in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its notification period (0/1)",
     "name": "host_in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Initial host state",
     "name": "host_initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a host check currently running... (0/1)",
     "name": "host_is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host state is flapping (0/1)",
     "name": "host_is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last check (Unix timestamp)",
     "name": "host_last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Last hard state",
     "name": "host_last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last hard state change (Unix timestamp)",
     "name": "host_last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last notification (Unix timestamp)",
     "name": "host_last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "State before last state change",
     "name": "host_last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last state change - soft or hard (Unix timestamp)",
     "name": "host_last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was DOWN (Unix timestamp)",
     "name": "host_last_time_down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UNREACHABLE (Unix timestamp)",
     "name": "host_last_time_unreachable",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UP (Unix timestamp)",
     "name": "host_last_time_up",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this host (Unix timestamp)",
     "name": "host_last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "host_latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Complete output from check plugin",
     "name": "host_long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "host_low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Max check attempts for active host checks",
     "name": "host_max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "host_modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "host_modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Host name",
     "name": "host_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Scheduled time for the next check (Unix timestamp)",
     "name": "host_next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the next notification (Unix timestamp)",
     "name": "host_next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "host_no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes for this host",
     "name": "host_notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as notes, but with the most important macros expanded",
     "name": "host_notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL with further information about the host",
     "name": "host_notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Same as notes_url, but with the most important macros expanded",
     "name": "host_notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "host_notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which problems of this host will be notified. If empty then notification will be always",
     "name": "host_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications of the host are enabled (0/1)",
     "name": "host_notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "host_notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "host_num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state CRIT",
     "name": "host_num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state CRIT",
     "name": "host_num_services_hard_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state OK",
     "name": "host_num_services_hard_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state UNKNOWN",
     "name": "host_num_services_hard_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state WARN",
     "name": "host_num_services_hard_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state OK",
     "name": "host_num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services which have not been checked yet (pending)",
     "name": "host_num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state UNKNOWN",
     "name": "host_num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state WARN",
     "name": "host_num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "host_obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "host_obsess_over_host",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct parents of the host",
     "name": "host_parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether a flex downtime is pending (0/1)",
     "name": "host_pending_flex_downtime",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "host_percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional performance data of the last host check",
     "name": "host_perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last host check",
     "name": "host_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this host (0/1)",
     "name": "host_pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled (0/1)",
     "name": "host_process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "host_retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of downtimes this host is currently in",
     "name": "host_scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all services of the host",
     "name": "host_services",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services including detailed information about each service",
     "name": "host_services_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services of the host together with state and has_been_checked",
     "name": "host_services_with_state",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this host (0/1)",
     "name": "host_should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Staleness indicator for this host",
     "name": "host_staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the host (0: up, 1: down, 2: unreachable)",
     "name": "host_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of the current state (0: soft, 1: hard)",
     "name": "host_state_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of in image file for the status map",
     "name": "host_statusmap_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "host_total_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst hard state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "host_worst_service_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst soft state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "host_worst_service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: X",
     "name": "host_x_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Y",
     "name": "host_y_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Z",
     "name": "host_z_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The id of the downtime",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "0, if this entry is for a host, 1 if it is for a service",
     "name": "is_service",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service accepts passive checks (0/1)",
     "name": "service_accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current service problem has been acknowledged (0/1)",
     "name": "service_acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the acknowledgement (0: none, 1: normal, 2: sticky)",
     "name": "service_acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL for actions or custom information about the service",
     "name": "service_action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The action_url with (the most important) macros expanded",
     "name": "service_action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the service (0/1)",
     "name": "service_active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Naemon command used for active checks",
     "name": "service_check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "service_check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the service",
     "name": "service_check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0/1)",
     "name": "service_check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the check period of the service. It this is empty, the service is always checked.",
     "name": "service_check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "service_check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The type of the last check (0: active, 1: passive)",
     "name": "service_check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the service (0/1)",
     "name": "service_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all comment ids of the service",
     "name": "service_comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the service with id, author, comment, entry_type, expires and expire_time",
     "name": "service_comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this service is in",
     "name": "service_contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of the service, either direct or via a contact group",
     "name": "service_contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The number of the current check attempt",
     "name": "service_current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the current notification",
     "name": "service_current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables of the service",
     "name": "service_custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of all custom variable of the service",
     "name": "service_custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "service_custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to execute",
     "name": "service_depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to execute including information: host_name, service_description, failure_options, dependency_period and inherits_parent",
     "name": "service_depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to notify",
     "name": "service_depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to notify including information: host_name, service_description, failure_options, dependency_period and inherits_parent",
     "name": "service_depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Description of the service (also used as key)",
     "name": "service_description",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional display name",
     "name": "service_display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all downtime ids of the service",
     "name": "service_downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the service with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "service_downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "service_event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether and event handler is activated for the service (0/1)",
     "name": "service_event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the service check needed for execution",
     "name": "service_execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "service_first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled for the service (0/1)",
     "name": "service_flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all service groups the service is in",
     "name": "service_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether the service already has been checked (0/1)",
     "name": "service_has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "service_high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "service_hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image to be used as icon in the web interface",
     "name": "service_icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alternative text for the icon_image for browsers not displaying icons",
     "name": "service_icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The icon_image with (the most important) macros expanded",
     "name": "service_icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Service id",
     "name": "service_id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is currently in its check period (0/1)",
     "name": "service_in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is currently in its notification period (0/1)",
     "name": "service_in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The initial state of the service",
     "name": "service_initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a service check currently running... (0/1)",
     "name": "service_is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is flapping (0/1)",
     "name": "service_is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last check (Unix timestamp)",
     "name": "service_last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last hard state of the service",
     "name": "service_last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last hard state change (Unix timestamp)",
     "name": "service_last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last notification (Unix timestamp)",
     "name": "service_last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last state of the service",
     "name": "service_last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last state change (Unix timestamp)",
     "name": "service_last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was CRITICAL (Unix timestamp)",
     "name": "service_last_time_critical",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was OK (Unix timestamp)",
     "name": "service_last_time_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was UNKNOWN (Unix timestamp)",
     "name": "service_last_time_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was in WARNING state (Unix timestamp)",
     "name": "service_last_time_warning",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this service (Unix timestamp)",
     "name": "service_last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "service_latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Unabbreviated output of the last check plugin",
     "name": "service_long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "service_low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The maximum number of check attempts",
     "name": "service_max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "service_modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "service_modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The scheduled time of the next check (Unix timestamp)",
     "name": "service_next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the next notification (Unix timestamp)",
     "name": "service_next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "service_no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes about the service",
     "name": "service_notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The notes with (the most important) macros expanded",
     "name": "service_notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL for additional notes about the service",
     "name": "service_notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The notes_url with (the most important) macros expanded",
     "name": "service_notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "service_notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the notification period of the service. It this is empty, service problems are always notified.",
     "name": "service_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications are enabled for the service (0/1)",
     "name": "service_notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "service_notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether 'obsess' is enabled for the service (0/1)",
     "name": "service_obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether 'obsess' is enabled for the service (0/1)",
     "name": "service_obsess_over_service",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all parent services",
     "name": "service_parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "service_percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Performance data of the last check plugin",
     "name": "service_perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last check plugin",
     "name": "service_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this service (0/1)",
     "name": "service_pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled for the service (0/1)",
     "name": "service_process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "service_retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of scheduled downtimes the service is currently in",
     "name": "service_scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this service (0/1)",
     "name": "service_should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The staleness indicator for this service",
     "name": "service_staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the service (0: OK, 1: WARN, 2: CRITICAL, 3: UNKNOWN)",
     "name": "service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the current state (0: soft, 1: hard)",
     "name": "service_state_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The start time of the downtime as UNIX timestamp",
     "name": "start_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The id of the downtime this downtime was triggered by or 0 if it was not triggered by another downtime",
     "name": "triggered_by",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the downtime: 0 if it is active, 1 if it is pending",
     "name": "type",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/downtimes/<id>": {
  "GET": {
   "columns": [
    {
     "description": "The contact that scheduled the downtime",
     "name": "author",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A comment text",
     "name": "comment",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The duration of the downtime in seconds",
     "name": "duration",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The end time of the downtime as UNIX timestamp",
     "name": "end_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time the entry was made as UNIX timestamp",
     "name": "entry_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A 1 if the downtime is fixed, a 0 if it is flexible",
     "name": "fixed",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether passive host checks are accepted (0/1)",
     "name": "host_accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current host problem has been acknowledged (0/1)",
     "name": "host_acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of acknowledgement (0: none, 1: normal, 2: stick)",
     "name": "host_acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL to custom actions or information about this host",
     "name": "host_action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as action_url, but with the most important macros expanded",
     "name": "host_action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the host (0/1)",
     "name": "host_active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "IP address",
     "name": "host_address",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alias name for the host",
     "name": "host_alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Naemon command for active host check of this host",
     "name": "host_check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether to check to send a recovery notification when flapping stops (0/1)",
     "name": "host_check_flapping_recovery_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "host_check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the host",
     "name": "host_check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0-2)",
     "name": "host_check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which this host will be checked. If empty then the host will always be checked.",
     "name": "host_check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "host_check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Type of check (0: active, 1: passive)",
     "name": "host_check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether checks of the host are enabled (0/1)",
     "name": "host_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct children of the host",
     "name": "host_childs",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the ids of all comments of this host",
     "name": "host_comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the host with id, author, comment, entry_type, expires and expire_time",
     "name": "host_comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this host is in",
     "name": "host_contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of this host, either direct or via a contact group",
     "name": "host_contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Number of the current check attempts",
     "name": "host_current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of the current notification",
     "name": "host_current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables",
     "name": "host_custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of the custom variables",
     "name": "host_custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "host_custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute",
     "name": "host_depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "host_depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify",
     "name": "host_depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "host_depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Optional display name of the host",
     "name": "host_display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of the ids of all scheduled downtimes of this host",
     "name": "host_downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the host with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "host_downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "host_event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether event handling is enabled (0/1)",
     "name": "host_event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the host check needed for execution",
     "name": "host_execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The value of the custom variable FILENAME",
     "name": "host_filename",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "host_first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled (0/1)",
     "name": "host_flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all host groups this host is in",
     "name": "host_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The effective hard state of the host (eliminates a problem in hard_state)",
     "name": "host_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host has already been checked (0/1)",
     "name": "host_has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "host_high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "host_hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image file to be used in the web pages",
     "name": "host_icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Alternative text for the icon_image",
     "name": "host_icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as icon_image, but with the most important macros expanded",
     "name": "host_icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Host id",
     "name": "host_id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its check period (0/1)",
     "name": "host_in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its notification period (0/1)",
     "name": "host_in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Initial host state",
     "name": "host_initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a host check currently running... (0/1)",
     "name": "host_is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host state is flapping (0/1)",
     "name": "host_is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last check (Unix timestamp)",
     "name": "host_last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Last hard state",
     "name": "host_last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last hard state change (Unix timestamp)",
     "name": "host_last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last notification (Unix timestamp)",
     "name": "host_last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "State before last state change",
     "name": "host_last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last state change - soft or hard (Unix timestamp)",
     "name": "host_last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was DOWN (Unix timestamp)",
     "name": "host_last_time_down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UNREACHABLE (Unix timestamp)",
     "name": "host_last_time_unreachable",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UP (Unix timestamp)",
     "name": "host_last_time_up",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this host (Unix timestamp)",
     "name": "host_last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "host_latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Complete output from check plugin",
     "name": "host_long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "host_low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Max check attempts for active host checks",
     "name": "host_max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "host_modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "host_modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Host name",
     "name": "host_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Scheduled time for the next check (Unix timestamp)",
     "name": "host_next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the next notification (Unix timestamp)",
     "name": "host_next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "host_no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes for this host",
     "name": "host_notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as notes, but with the most important macros expanded",
     "name": "host_notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL with further information about the host",
     "name": "host_notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Same as notes_url, but with the most important macros expanded",
     "name": "host_notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "host_notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which problems of this host will be notified. If empty then notification will be always",
     "name": "host_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications of the host are enabled (0/1)",
     "name": "host_notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "host_notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "host_num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state CRIT",
     "name": "host_num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state CRIT",
     "name": "host_num_services_hard_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state OK",
     "name": "host_num_services_hard_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state UNKNOWN",
     "name": "host_num_services_hard_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state WARN",
     "name": "host_num_services_hard_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state OK",
     "name": "host_num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services which have not been checked yet (pending)",
     "name": "host_num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state UNKNOWN",
     "name": "host_num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state WARN",
     "name": "host_num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "host_obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "host_obsess_over_host",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct parents of the host",
     "name": "host_parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether a flex downtime is pending (0/1)",
     "name": "host_pending_flex_downtime",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "host_percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional performance data of the last host check",
     "name": "host_perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last host check",
     "name": "host_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this host (0/1)",
     "name": "host_pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled (0/1)",
     "name": "host_process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "host_retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of downtimes this host is currently in",
     "name": "host_scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all services of the host",
     "name": "host_services",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services including detailed information about each service",
     "name": "host_services_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services of the host together with state and has_been_checked",
     "name": "host_services_with_state",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this host (0/1)",
     "name": "host_should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Staleness indicator for this host",
     "name": "host_staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the host (0: up, 1: down, 2: unreachable)",
     "name": "host_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of the current state (0: soft, 1: hard)",
     "name": "host_state_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of in image file for the status map",
     "name": "host_statusmap_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "host_total_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst hard state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "host_worst_service_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst soft state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "host_worst_service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: X",
     "name": "host_x_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Y",
     "name": "host_y_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Z",
     "name": "host_z_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The id of the downtime",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "0, if this entry is for a host, 1 if it is for a service",
     "name": "is_service",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service accepts passive checks (0/1)",
     "name": "service_accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current service problem has been acknowledged (0/1)",
     "name": "service_acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the acknowledgement (0: none, 1: normal, 2: sticky)",
     "name": "service_acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL for actions or custom information about the service",
     "name": "service_action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The action_url with (the most important) macros expanded",
     "name": "service_action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the service (0/1)",
     "name": "service_active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Naemon command used for active checks",
     "name": "service_check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "service_check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the service",
     "name": "service_check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0/1)",
     "name": "service_check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the check period of the service. It this is empty, the service is always checked.",
     "name": "service_check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "service_check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The type of the last check (0: active, 1: passive)",
     "name": "service_check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the service (0/1)",
     "name": "service_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all comment ids of the service",
     "name": "service_comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the service with id, author, comment, entry_type, expires and expire_time",
     "name": "service_comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this service is in",
     "name": "service_contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of the service, either direct or via a contact group",
     "name": "service_contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The number of the current check attempt",
     "name": "service_current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the current notification",
     "name": "service_current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables of the service",
     "name": "service_custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of all custom variable of the service",
     "name": "service_custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "service_custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to execute",
     "name": "service_depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to execute including information: host_name, service_description, failure_options, dependency_period and inherits_parent",
     "name": "service_depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to notify",
     "name": "service_depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to notify including information: host_name, service_description, failure_options, dependency_period and inherits_parent",
     "name": "service_depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Description of the service (also used as key)",
     "name": "service_description",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional display name",
     "name": "service_display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all downtime ids of the service",
     "name": "service_downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the service with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "service_downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "service_event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether and event handler is activated for the service (0/1)",
     "name": "service_event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the service check needed for execution",
     "name": "service_execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "service_first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled for the service (0/1)",
     "name": "service_flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all service groups the service is in",
     "name": "service_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether the service already has been checked (0/1)",
     "name": "service_has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "service_high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "service_hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image to be used as icon in the web interface",
     "name": "service_icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alternative text for the icon_image for browsers not displaying icons",
     "name": "service_icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The icon_image with (the most important) macros expanded",
     "name": "service_icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Service id",
     "name": "service_id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is currently in its check period (0/1)",
     "name": "service_in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is currently in its notification period (0/1)",
     "name": "service_in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The initial state of the service",
     "name": "service_initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a service check currently running... (0/1)",
     "name": "service_is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is flapping (0/1)",
     "name": "service_is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last check (Unix timestamp)",
     "name": "service_last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last hard state of the service",
     "name": "service_last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last hard state change (Unix timestamp)",
     "name": "service_last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last notification (Unix timestamp)",
     "name": "service_last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last state of the service",
     "name": "service_last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last state change (Unix timestamp)",
     "name": "service_last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was CRITICAL (Unix timestamp)",
     "name": "service_last_time_critical",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was OK (Unix timestamp)",
     "name": "service_last_time_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was UNKNOWN (Unix timestamp)",
     "name": "service_last_time_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was in WARNING state (Unix timestamp)",
     "name": "service_last_time_warning",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this service (Unix timestamp)",
     "name": "service_last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "service_latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Unabbreviated output of the last check plugin",
     "name": "service_long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "service_low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The maximum number of check attempts",
     "name": "service_max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "service_modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "service_modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The scheduled time of the next check (Unix timestamp)",
     "name": "service_next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the next notification (Unix timestamp)",
     "name": "service_next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "service_no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes about the service",
     "name": "service_notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The notes with (the most important) macros expanded",
     "name": "service_notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL for additional notes about the service",
     "name": "service_notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The notes_url with (the most important) macros expanded",
     "name": "service_notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "service_notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the notification period of the service. It this is empty, service problems are always notified.",
     "name": "service_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications are enabled for the service (0/1)",
     "name": "service_notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "service_notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether 'obsess' is enabled for the service (0/1)",
     "name": "service_obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether 'obsess' is enabled for the service (0/1)",
     "name": "service_obsess_over_service",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all parent services",
     "name": "service_parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "service_percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Performance data of the last check plugin",
     "name": "service_perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last check plugin",
     "name": "service_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this service (0/1)",
     "name": "service_pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled for the service (0/1)",
     "name": "service_process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "service_retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of scheduled downtimes the service is currently in",
     "name": "service_scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this service (0/1)",
     "name": "service_should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The staleness indicator for this service",
     "name": "service_staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the service (0: OK, 1: WARN, 2: CRITICAL, 3: UNKNOWN)",
     "name": "service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the current state (0: soft, 1: hard)",
     "name": "service_state_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The start time of the downtime as UNIX timestamp",
     "name": "start_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The id of the downtime this downtime was triggered by or 0 if it was not triggered by another downtime",
     "name": "triggered_by",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the downtime: 0 if it is active, 1 if it is pending",
     "name": "type",
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
     "description": "An optional URL to custom actions or information about the hostgroup",
     "name": "action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alias of the hostgroup",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Hostgroup id",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all host names that are members of the hostgroup",
     "name": "members",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all host names that are members of the hostgroup together with state and has_been_checked",
     "name": "members_with_state",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Name of the hostgroup",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Optional notes to the hostgroup",
     "name": "notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL with further information about the hostgroup",
     "name": "notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The total number of hosts in the group",
     "name": "num_hosts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of hosts in the group that are down",
     "name": "num_hosts_down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of hosts in the group that are pending",
     "name": "num_hosts_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of hosts in the group that are unreachable",
     "name": "num_hosts_unreach",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of hosts in the group that are up",
     "name": "num_hosts_up",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services of hosts in this group",
     "name": "num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state CRIT of hosts in this group",
     "name": "num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state CRIT of hosts in this group",
     "name": "num_services_hard_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state OK of hosts in this group",
     "name": "num_services_hard_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state UNKNOWN of hosts in this group",
     "name": "num_services_hard_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state WARN of hosts in this group",
     "name": "num_services_hard_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state OK of hosts in this group",
     "name": "num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state Pending of hosts in this group",
     "name": "num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state UNKNOWN of hosts in this group",
     "name": "num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state WARN of hosts in this group",
     "name": "num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst state of all of the groups' hosts (UP <= UNREACHABLE <= DOWN)",
     "name": "worst_host_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst state of all services that belong to a host of this group (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "worst_service_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst state of all services that belong to a host of this group (OK <= WARN <= UNKNOWN <= CRIT)",
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
     "description": "An optional URL to custom actions or information about the hostgroup",
     "name": "action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alias of the hostgroup",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Hostgroup id",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all host names that are members of the hostgroup",
     "name": "members",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all host names that are members of the hostgroup together with state and has_been_checked",
     "name": "members_with_state",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Name of the hostgroup",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Optional notes to the hostgroup",
     "name": "notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL with further information about the hostgroup",
     "name": "notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The total number of hosts in the group",
     "name": "num_hosts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of hosts in the group that are down",
     "name": "num_hosts_down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of hosts in the group that are pending",
     "name": "num_hosts_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of hosts in the group that are unreachable",
     "name": "num_hosts_unreach",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of hosts in the group that are up",
     "name": "num_hosts_up",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services of hosts in this group",
     "name": "num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state CRIT of hosts in this group",
     "name": "num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state CRIT of hosts in this group",
     "name": "num_services_hard_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state OK of hosts in this group",
     "name": "num_services_hard_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state UNKNOWN of hosts in this group",
     "name": "num_services_hard_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state WARN of hosts in this group",
     "name": "num_services_hard_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state OK of hosts in this group",
     "name": "num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state Pending of hosts in this group",
     "name": "num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state UNKNOWN of hosts in this group",
     "name": "num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state WARN of hosts in this group",
     "name": "num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst state of all of the groups' hosts (UP <= UNREACHABLE <= DOWN)",
     "name": "worst_host_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst state of all services that belong to a host of this group (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "worst_service_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst state of all services that belong to a host of this group (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "worst_service_state",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/hosts": {
  "GET": {
   "columns": [
    {
     "description": "Whether passive host checks are accepted (0/1)",
     "name": "accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current host problem has been acknowledged (0/1)",
     "name": "acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of acknowledgement (0: none, 1: normal, 2: stick)",
     "name": "acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL to custom actions or information about this host",
     "name": "action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as action_url, but with the most important macros expanded",
     "name": "action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the host (0/1)",
     "name": "active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "IP address",
     "name": "address",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alias name for the host",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Naemon command for active host check of this host",
     "name": "check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether to check to send a recovery notification when flapping stops (0/1)",
     "name": "check_flapping_recovery_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the host",
     "name": "check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0-2)",
     "name": "check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which this host will be checked. If empty then the host will always be checked.",
     "name": "check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Type of check (0: active, 1: passive)",
     "name": "check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether checks of the host are enabled (0/1)",
     "name": "checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct children of the host",
     "name": "childs",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the ids of all comments of this host",
     "name": "comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the host with id, author, comment, entry_type, expires and expire_time",
     "name": "comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this host is in",
     "name": "contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of this host, either direct or via a contact group",
     "name": "contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Number of the current check attempts",
     "name": "current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of the current notification",
     "name": "current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables",
     "name": "custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of the custom variables",
     "name": "custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute",
     "name": "depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify",
     "name": "depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Optional display name of the host",
     "name": "display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of the ids of all scheduled downtimes of this host",
     "name": "downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the host with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether event handling is enabled (0/1)",
     "name": "event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the host check needed for execution",
     "name": "execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The value of the custom variable FILENAME",
     "name": "filename",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled (0/1)",
     "name": "flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all host groups this host is in",
     "name": "groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The effective hard state of the host (eliminates a problem in hard_state)",
     "name": "hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host has already been checked (0/1)",
     "name": "has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image file to be used in the web pages",
     "name": "icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Alternative text for the icon_image",
     "name": "icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as icon_image, but with the most important macros expanded",
     "name": "icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Host id",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its check period (0/1)",
     "name": "in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its notification period (0/1)",
     "name": "in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Initial host state",
     "name": "initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a host check currently running... (0/1)",
     "name": "is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host state is flapping (0/1)",
     "name": "is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last check (Unix timestamp)",
     "name": "last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Last hard state",
     "name": "last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last hard state change (Unix timestamp)",
     "name": "last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last notification (Unix timestamp)",
     "name": "last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "State before last state change",
     "name": "last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last state change - soft or hard (Unix timestamp)",
     "name": "last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was DOWN (Unix timestamp)",
     "name": "last_time_down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UNREACHABLE (Unix timestamp)",
     "name": "last_time_unreachable",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UP (Unix timestamp)",
     "name": "last_time_up",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this host (Unix timestamp)",
     "name": "last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Complete output from check plugin",
     "name": "long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Max check attempts for active host checks",
     "name": "max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Host name",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Scheduled time for the next check (Unix timestamp)",
     "name": "next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the next notification (Unix timestamp)",
     "name": "next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes for this host",
     "name": "notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as notes, but with the most important macros expanded",
     "name": "notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL with further information about the host",
     "name": "notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Same as notes_url, but with the most important macros expanded",
     "name": "notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which problems of this host will be notified. If empty then notification will be always",
     "name": "notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications of the host are enabled (0/1)",
     "name": "notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state CRIT",
     "name": "num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state CRIT",
     "name": "num_services_hard_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state OK",
     "name": "num_services_hard_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state UNKNOWN",
     "name": "num_services_hard_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state WARN",
     "name": "num_services_hard_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state OK",
     "name": "num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services which have not been checked yet (pending)",
     "name": "num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state UNKNOWN",
     "name": "num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state WARN",
     "name": "num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "obsess_over_host",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct parents of the host",
     "name": "parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether a flex downtime is pending (0/1)",
     "name": "pending_flex_downtime",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional performance data of the last host check",
     "name": "perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last host check",
     "name": "plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this host (0/1)",
     "name": "pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled (0/1)",
     "name": "process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of downtimes this host is currently in",
     "name": "scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all services of the host",
     "name": "services",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services including detailed information about each service",
     "name": "services_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services of the host together with state and has_been_checked",
     "name": "services_with_state",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this host (0/1)",
     "name": "should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Staleness indicator for this host",
     "name": "staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the host (0: up, 1: down, 2: unreachable)",
     "name": "state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of the current state (0: soft, 1: hard)",
     "name": "state_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of in image file for the status map",
     "name": "statusmap_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "total_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst hard state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "worst_service_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst soft state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "worst_service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: X",
     "name": "x_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Y",
     "name": "y_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Z",
     "name": "z_3d",
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
     "description": "Whether passive host checks are accepted (0/1)",
     "name": "accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current host problem has been acknowledged (0/1)",
     "name": "acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of acknowledgement (0: none, 1: normal, 2: stick)",
     "name": "acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL to custom actions or information about this host",
     "name": "action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as action_url, but with the most important macros expanded",
     "name": "action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the host (0/1)",
     "name": "active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "IP address",
     "name": "address",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alias name for the host",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Naemon command for active host check of this host",
     "name": "check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether to check to send a recovery notification when flapping stops (0/1)",
     "name": "check_flapping_recovery_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the host",
     "name": "check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0-2)",
     "name": "check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which this host will be checked. If empty then the host will always be checked.",
     "name": "check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Type of check (0: active, 1: passive)",
     "name": "check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether checks of the host are enabled (0/1)",
     "name": "checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct children of the host",
     "name": "childs",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the ids of all comments of this host",
     "name": "comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the host with id, author, comment, entry_type, expires and expire_time",
     "name": "comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this host is in",
     "name": "contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of this host, either direct or via a contact group",
     "name": "contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Number of the current check attempts",
     "name": "current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of the current notification",
     "name": "current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables",
     "name": "custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of the custom variables",
     "name": "custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute",
     "name": "depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify",
     "name": "depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Optional display name of the host",
     "name": "display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of the ids of all scheduled downtimes of this host",
     "name": "downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the host with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether event handling is enabled (0/1)",
     "name": "event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the host check needed for execution",
     "name": "execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The value of the custom variable FILENAME",
     "name": "filename",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled (0/1)",
     "name": "flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all host groups this host is in",
     "name": "groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The effective hard state of the host (eliminates a problem in hard_state)",
     "name": "hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host has already been checked (0/1)",
     "name": "has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image file to be used in the web pages",
     "name": "icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Alternative text for the icon_image",
     "name": "icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as icon_image, but with the most important macros expanded",
     "name": "icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Host id",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its check period (0/1)",
     "name": "in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its notification period (0/1)",
     "name": "in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Initial host state",
     "name": "initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a host check currently running... (0/1)",
     "name": "is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host state is flapping (0/1)",
     "name": "is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last check (Unix timestamp)",
     "name": "last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Last hard state",
     "name": "last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last hard state change (Unix timestamp)",
     "name": "last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last notification (Unix timestamp)",
     "name": "last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "State before last state change",
     "name": "last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last state change - soft or hard (Unix timestamp)",
     "name": "last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was DOWN (Unix timestamp)",
     "name": "last_time_down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UNREACHABLE (Unix timestamp)",
     "name": "last_time_unreachable",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UP (Unix timestamp)",
     "name": "last_time_up",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this host (Unix timestamp)",
     "name": "last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Complete output from check plugin",
     "name": "long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Max check attempts for active host checks",
     "name": "max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Host name",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Scheduled time for the next check (Unix timestamp)",
     "name": "next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the next notification (Unix timestamp)",
     "name": "next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes for this host",
     "name": "notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as notes, but with the most important macros expanded",
     "name": "notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL with further information about the host",
     "name": "notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Same as notes_url, but with the most important macros expanded",
     "name": "notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which problems of this host will be notified. If empty then notification will be always",
     "name": "notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications of the host are enabled (0/1)",
     "name": "notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state CRIT",
     "name": "num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state CRIT",
     "name": "num_services_hard_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state OK",
     "name": "num_services_hard_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state UNKNOWN",
     "name": "num_services_hard_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state WARN",
     "name": "num_services_hard_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state OK",
     "name": "num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services which have not been checked yet (pending)",
     "name": "num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state UNKNOWN",
     "name": "num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state WARN",
     "name": "num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "obsess_over_host",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct parents of the host",
     "name": "parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether a flex downtime is pending (0/1)",
     "name": "pending_flex_downtime",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional performance data of the last host check",
     "name": "perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last host check",
     "name": "plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this host (0/1)",
     "name": "pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled (0/1)",
     "name": "process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of downtimes this host is currently in",
     "name": "scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all services of the host",
     "name": "services",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services including detailed information about each service",
     "name": "services_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services of the host together with state and has_been_checked",
     "name": "services_with_state",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this host (0/1)",
     "name": "should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Staleness indicator for this host",
     "name": "staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the host (0: up, 1: down, 2: unreachable)",
     "name": "state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of the current state (0: soft, 1: hard)",
     "name": "state_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of in image file for the status map",
     "name": "statusmap_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "total_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst hard state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "worst_service_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst soft state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "worst_service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: X",
     "name": "x_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Y",
     "name": "y_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Z",
     "name": "z_3d",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/hostsbygroup": {
  "GET": {
   "columns": [
    {
     "description": "Whether passive host checks are accepted (0/1)",
     "name": "accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current host problem has been acknowledged (0/1)",
     "name": "acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of acknowledgement (0: none, 1: normal, 2: stick)",
     "name": "acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL to custom actions or information about this host",
     "name": "action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as action_url, but with the most important macros expanded",
     "name": "action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the host (0/1)",
     "name": "active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "IP address",
     "name": "address",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alias name for the host",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Naemon command for active host check of this host",
     "name": "check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether to check to send a recovery notification when flapping stops (0/1)",
     "name": "check_flapping_recovery_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the host",
     "name": "check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0-2)",
     "name": "check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which this host will be checked. If empty then the host will always be checked.",
     "name": "check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Type of check (0: active, 1: passive)",
     "name": "check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether checks of the host are enabled (0/1)",
     "name": "checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct children of the host",
     "name": "childs",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the ids of all comments of this host",
     "name": "comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the host with id, author, comment, entry_type, expires and expire_time",
     "name": "comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this host is in",
     "name": "contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of this host, either direct or via a contact group",
     "name": "contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Number of the current check attempts",
     "name": "current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of the current notification",
     "name": "current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables",
     "name": "custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of the custom variables",
     "name": "custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute",
     "name": "depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify",
     "name": "depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Optional display name of the host",
     "name": "display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of the ids of all scheduled downtimes of this host",
     "name": "downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the host with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether event handling is enabled (0/1)",
     "name": "event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the host check needed for execution",
     "name": "execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The value of the custom variable FILENAME",
     "name": "filename",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled (0/1)",
     "name": "flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all host groups this host is in",
     "name": "groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The effective hard state of the host (eliminates a problem in hard_state)",
     "name": "hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host has already been checked (0/1)",
     "name": "has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL to custom actions or information about the hostgroup",
     "name": "hostgroup_action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alias of the hostgroup",
     "name": "hostgroup_alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Hostgroup id",
     "name": "hostgroup_id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all host names that are members of the hostgroup",
     "name": "hostgroup_members",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all host names that are members of the hostgroup together with state and has_been_checked",
     "name": "hostgroup_members_with_state",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Name of the hostgroup",
     "name": "hostgroup_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Optional notes to the hostgroup",
     "name": "hostgroup_notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL with further information about the hostgroup",
     "name": "hostgroup_notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The total number of hosts in the group",
     "name": "hostgroup_num_hosts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of hosts in the group that are down",
     "name": "hostgroup_num_hosts_down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of hosts in the group that are pending",
     "name": "hostgroup_num_hosts_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of hosts in the group that are unreachable",
     "name": "hostgroup_num_hosts_unreach",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of hosts in the group that are up",
     "name": "hostgroup_num_hosts_up",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services of hosts in this group",
     "name": "hostgroup_num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state CRIT of hosts in this group",
     "name": "hostgroup_num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state CRIT of hosts in this group",
     "name": "hostgroup_num_services_hard_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state OK of hosts in this group",
     "name": "hostgroup_num_services_hard_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state UNKNOWN of hosts in this group",
     "name": "hostgroup_num_services_hard_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state WARN of hosts in this group",
     "name": "hostgroup_num_services_hard_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state OK of hosts in this group",
     "name": "hostgroup_num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state Pending of hosts in this group",
     "name": "hostgroup_num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state UNKNOWN of hosts in this group",
     "name": "hostgroup_num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state WARN of hosts in this group",
     "name": "hostgroup_num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst state of all of the groups' hosts (UP <= UNREACHABLE <= DOWN)",
     "name": "hostgroup_worst_host_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst state of all services that belong to a host of this group (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "hostgroup_worst_service_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst state of all services that belong to a host of this group (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "hostgroup_worst_service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image file to be used in the web pages",
     "name": "icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Alternative text for the icon_image",
     "name": "icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as icon_image, but with the most important macros expanded",
     "name": "icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Host id",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its check period (0/1)",
     "name": "in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its notification period (0/1)",
     "name": "in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Initial host state",
     "name": "initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a host check currently running... (0/1)",
     "name": "is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host state is flapping (0/1)",
     "name": "is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last check (Unix timestamp)",
     "name": "last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Last hard state",
     "name": "last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last hard state change (Unix timestamp)",
     "name": "last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last notification (Unix timestamp)",
     "name": "last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "State before last state change",
     "name": "last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last state change - soft or hard (Unix timestamp)",
     "name": "last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was DOWN (Unix timestamp)",
     "name": "last_time_down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UNREACHABLE (Unix timestamp)",
     "name": "last_time_unreachable",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UP (Unix timestamp)",
     "name": "last_time_up",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this host (Unix timestamp)",
     "name": "last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Complete output from check plugin",
     "name": "long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Max check attempts for active host checks",
     "name": "max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Host name",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Scheduled time for the next check (Unix timestamp)",
     "name": "next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the next notification (Unix timestamp)",
     "name": "next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes for this host",
     "name": "notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as notes, but with the most important macros expanded",
     "name": "notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL with further information about the host",
     "name": "notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Same as notes_url, but with the most important macros expanded",
     "name": "notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which problems of this host will be notified. If empty then notification will be always",
     "name": "notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications of the host are enabled (0/1)",
     "name": "notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state CRIT",
     "name": "num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state CRIT",
     "name": "num_services_hard_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state OK",
     "name": "num_services_hard_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state UNKNOWN",
     "name": "num_services_hard_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state WARN",
     "name": "num_services_hard_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state OK",
     "name": "num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services which have not been checked yet (pending)",
     "name": "num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state UNKNOWN",
     "name": "num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state WARN",
     "name": "num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "obsess_over_host",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct parents of the host",
     "name": "parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether a flex downtime is pending (0/1)",
     "name": "pending_flex_downtime",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional performance data of the last host check",
     "name": "perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last host check",
     "name": "plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this host (0/1)",
     "name": "pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled (0/1)",
     "name": "process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of downtimes this host is currently in",
     "name": "scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all services of the host",
     "name": "services",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services including detailed information about each service",
     "name": "services_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services of the host together with state and has_been_checked",
     "name": "services_with_state",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this host (0/1)",
     "name": "should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Staleness indicator for this host",
     "name": "staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the host (0: up, 1: down, 2: unreachable)",
     "name": "state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of the current state (0: soft, 1: hard)",
     "name": "state_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of in image file for the status map",
     "name": "statusmap_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "total_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst hard state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "worst_service_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst soft state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "worst_service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: X",
     "name": "x_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Y",
     "name": "y_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Z",
     "name": "z_3d",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/hostsbygroup/<hostgroup>": {
  "GET": {
   "columns": [
    {
     "description": "Whether passive host checks are accepted (0/1)",
     "name": "accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current host problem has been acknowledged (0/1)",
     "name": "acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of acknowledgement (0: none, 1: normal, 2: stick)",
     "name": "acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL to custom actions or information about this host",
     "name": "action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as action_url, but with the most important macros expanded",
     "name": "action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the host (0/1)",
     "name": "active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "IP address",
     "name": "address",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alias name for the host",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Naemon command for active host check of this host",
     "name": "check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether to check to send a recovery notification when flapping stops (0/1)",
     "name": "check_flapping_recovery_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the host",
     "name": "check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0-2)",
     "name": "check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which this host will be checked. If empty then the host will always be checked.",
     "name": "check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Type of check (0: active, 1: passive)",
     "name": "check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether checks of the host are enabled (0/1)",
     "name": "checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct children of the host",
     "name": "childs",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the ids of all comments of this host",
     "name": "comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the host with id, author, comment, entry_type, expires and expire_time",
     "name": "comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this host is in",
     "name": "contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of this host, either direct or via a contact group",
     "name": "contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Number of the current check attempts",
     "name": "current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of the current notification",
     "name": "current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables",
     "name": "custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of the custom variables",
     "name": "custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute",
     "name": "depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify",
     "name": "depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Optional display name of the host",
     "name": "display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of the ids of all scheduled downtimes of this host",
     "name": "downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the host with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether event handling is enabled (0/1)",
     "name": "event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the host check needed for execution",
     "name": "execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The value of the custom variable FILENAME",
     "name": "filename",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled (0/1)",
     "name": "flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all host groups this host is in",
     "name": "groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The effective hard state of the host (eliminates a problem in hard_state)",
     "name": "hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host has already been checked (0/1)",
     "name": "has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL to custom actions or information about the hostgroup",
     "name": "hostgroup_action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alias of the hostgroup",
     "name": "hostgroup_alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Hostgroup id",
     "name": "hostgroup_id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all host names that are members of the hostgroup",
     "name": "hostgroup_members",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all host names that are members of the hostgroup together with state and has_been_checked",
     "name": "hostgroup_members_with_state",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Name of the hostgroup",
     "name": "hostgroup_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Optional notes to the hostgroup",
     "name": "hostgroup_notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL with further information about the hostgroup",
     "name": "hostgroup_notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The total number of hosts in the group",
     "name": "hostgroup_num_hosts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of hosts in the group that are down",
     "name": "hostgroup_num_hosts_down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of hosts in the group that are pending",
     "name": "hostgroup_num_hosts_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of hosts in the group that are unreachable",
     "name": "hostgroup_num_hosts_unreach",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of hosts in the group that are up",
     "name": "hostgroup_num_hosts_up",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services of hosts in this group",
     "name": "hostgroup_num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state CRIT of hosts in this group",
     "name": "hostgroup_num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state CRIT of hosts in this group",
     "name": "hostgroup_num_services_hard_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state OK of hosts in this group",
     "name": "hostgroup_num_services_hard_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state UNKNOWN of hosts in this group",
     "name": "hostgroup_num_services_hard_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state WARN of hosts in this group",
     "name": "hostgroup_num_services_hard_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state OK of hosts in this group",
     "name": "hostgroup_num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state Pending of hosts in this group",
     "name": "hostgroup_num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state UNKNOWN of hosts in this group",
     "name": "hostgroup_num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state WARN of hosts in this group",
     "name": "hostgroup_num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst state of all of the groups' hosts (UP <= UNREACHABLE <= DOWN)",
     "name": "hostgroup_worst_host_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst state of all services that belong to a host of this group (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "hostgroup_worst_service_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst state of all services that belong to a host of this group (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "hostgroup_worst_service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image file to be used in the web pages",
     "name": "icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Alternative text for the icon_image",
     "name": "icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as icon_image, but with the most important macros expanded",
     "name": "icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Host id",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its check period (0/1)",
     "name": "in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its notification period (0/1)",
     "name": "in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Initial host state",
     "name": "initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a host check currently running... (0/1)",
     "name": "is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host state is flapping (0/1)",
     "name": "is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last check (Unix timestamp)",
     "name": "last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Last hard state",
     "name": "last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last hard state change (Unix timestamp)",
     "name": "last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last notification (Unix timestamp)",
     "name": "last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "State before last state change",
     "name": "last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last state change - soft or hard (Unix timestamp)",
     "name": "last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was DOWN (Unix timestamp)",
     "name": "last_time_down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UNREACHABLE (Unix timestamp)",
     "name": "last_time_unreachable",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UP (Unix timestamp)",
     "name": "last_time_up",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this host (Unix timestamp)",
     "name": "last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Complete output from check plugin",
     "name": "long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Max check attempts for active host checks",
     "name": "max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Host name",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Scheduled time for the next check (Unix timestamp)",
     "name": "next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the next notification (Unix timestamp)",
     "name": "next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes for this host",
     "name": "notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as notes, but with the most important macros expanded",
     "name": "notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL with further information about the host",
     "name": "notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Same as notes_url, but with the most important macros expanded",
     "name": "notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which problems of this host will be notified. If empty then notification will be always",
     "name": "notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications of the host are enabled (0/1)",
     "name": "notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state CRIT",
     "name": "num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state CRIT",
     "name": "num_services_hard_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state OK",
     "name": "num_services_hard_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state UNKNOWN",
     "name": "num_services_hard_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state WARN",
     "name": "num_services_hard_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state OK",
     "name": "num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services which have not been checked yet (pending)",
     "name": "num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state UNKNOWN",
     "name": "num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state WARN",
     "name": "num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "obsess_over_host",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct parents of the host",
     "name": "parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether a flex downtime is pending (0/1)",
     "name": "pending_flex_downtime",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional performance data of the last host check",
     "name": "perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last host check",
     "name": "plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this host (0/1)",
     "name": "pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled (0/1)",
     "name": "process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of downtimes this host is currently in",
     "name": "scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all services of the host",
     "name": "services",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services including detailed information about each service",
     "name": "services_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services of the host together with state and has_been_checked",
     "name": "services_with_state",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this host (0/1)",
     "name": "should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Staleness indicator for this host",
     "name": "staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the host (0: up, 1: down, 2: unreachable)",
     "name": "state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of the current state (0: soft, 1: hard)",
     "name": "state_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of in image file for the status map",
     "name": "statusmap_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "total_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst hard state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "worst_service_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst soft state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "worst_service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: X",
     "name": "x_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Y",
     "name": "y_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Z",
     "name": "z_3d",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/logs": {
  "GET": {
   "columns": [
    {
     "description": "The number of the check attempt",
     "name": "attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The class of the message as integer (0:info, 1:state, 2:program, 3:notification, 4:passive, 5:command)",
     "name": "class",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the command of the log entry (e.g. for notifications)",
     "name": "command_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A comment field used in various message types",
     "name": "comment",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The name of the contact the log entry is about (might be empty)",
     "name": "contact_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Command id",
     "name": "current_command_id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The shell command line",
     "name": "current_command_line",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The name of the command",
     "name": "current_command_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The additional field address1",
     "name": "current_contact_address1",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The additional field address2",
     "name": "current_contact_address2",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The additional field address3",
     "name": "current_contact_address3",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The additional field address4",
     "name": "current_contact_address4",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The additional field address5",
     "name": "current_contact_address5",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The additional field address6",
     "name": "current_contact_address6",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The full name of the contact",
     "name": "current_contact_alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether the contact is allowed to submit commands (0/1)",
     "name": "current_contact_can_submit_commands",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all custom variables of the contact",
     "name": "current_contact_custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of all custom variables of the contact",
     "name": "current_contact_custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "current_contact_custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The email address of the contact",
     "name": "current_contact_email",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this contact is in",
     "name": "current_contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all host notifications commands for this contact",
     "name": "current_contact_host_notification_commands",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The time period in which the contact will be notified about host problems",
     "name": "current_contact_host_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether the contact will be notified about host problems in general (0/1)",
     "name": "current_contact_host_notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Contact id",
     "name": "current_contact_id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the contact is currently in his/her host notification period (0/1)",
     "name": "current_contact_in_host_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the contact is currently in his/her service notification period (0/1)",
     "name": "current_contact_in_service_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "current_contact_modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "current_contact_modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The login name of the contact person",
     "name": "current_contact_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The pager address of the contact",
     "name": "current_contact_pager",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all service notifications commands for this contact",
     "name": "current_contact_service_notification_commands",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The time period in which the contact will be notified about service problems",
     "name": "current_contact_service_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether the contact will be notified about service problems in general (0/1)",
     "name": "current_contact_service_notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether passive host checks are accepted (0/1)",
     "name": "current_host_accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current host problem has been acknowledged (0/1)",
     "name": "current_host_acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of acknowledgement (0: none, 1: normal, 2: stick)",
     "name": "current_host_acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL to custom actions or information about this host",
     "name": "current_host_action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as action_url, but with the most important macros expanded",
     "name": "current_host_action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the host (0/1)",
     "name": "current_host_active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "IP address",
     "name": "current_host_address",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alias name for the host",
     "name": "current_host_alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Naemon command for active host check of this host",
     "name": "current_host_check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether to check to send a recovery notification when flapping stops (0/1)",
     "name": "current_host_check_flapping_recovery_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "current_host_check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the host",
     "name": "current_host_check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0-2)",
     "name": "current_host_check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which this host will be checked. If empty then the host will always be checked.",
     "name": "current_host_check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "current_host_check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Type of check (0: active, 1: passive)",
     "name": "current_host_check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether checks of the host are enabled (0/1)",
     "name": "current_host_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct children of the host",
     "name": "current_host_childs",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the ids of all comments of this host",
     "name": "current_host_comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the host with id, author, comment, entry_type, expires and expire_time",
     "name": "current_host_comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this host is in",
     "name": "current_host_contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of this host, either direct or via a contact group",
     "name": "current_host_contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Number of the current check attempts",
     "name": "current_host_current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of the current notification",
     "name": "current_host_current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables",
     "name": "current_host_custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of the custom variables",
     "name": "current_host_custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "current_host_custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute",
     "name": "current_host_depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "current_host_depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify",
     "name": "current_host_depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "current_host_depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Optional display name of the host",
     "name": "current_host_display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of the ids of all scheduled downtimes of this host",
     "name": "current_host_downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the host with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "current_host_downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "current_host_event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether event handling is enabled (0/1)",
     "name": "current_host_event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the host check needed for execution",
     "name": "current_host_execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The value of the custom variable FILENAME",
     "name": "current_host_filename",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "current_host_first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled (0/1)",
     "name": "current_host_flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all host groups this host is in",
     "name": "current_host_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The effective hard state of the host (eliminates a problem in hard_state)",
     "name": "current_host_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host has already been checked (0/1)",
     "name": "current_host_has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "current_host_high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "current_host_hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image file to be used in the web pages",
     "name": "current_host_icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Alternative text for the icon_image",
     "name": "current_host_icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as icon_image, but with the most important macros expanded",
     "name": "current_host_icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Host id",
     "name": "current_host_id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its check period (0/1)",
     "name": "current_host_in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its notification period (0/1)",
     "name": "current_host_in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Initial host state",
     "name": "current_host_initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a host check currently running... (0/1)",
     "name": "current_host_is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host state is flapping (0/1)",
     "name": "current_host_is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last check (Unix timestamp)",
     "name": "current_host_last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Last hard state",
     "name": "current_host_last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last hard state change (Unix timestamp)",
     "name": "current_host_last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last notification (Unix timestamp)",
     "name": "current_host_last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "State before last state change",
     "name": "current_host_last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last state change - soft or hard (Unix timestamp)",
     "name": "current_host_last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was DOWN (Unix timestamp)",
     "name": "current_host_last_time_down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UNREACHABLE (Unix timestamp)",
     "name": "current_host_last_time_unreachable",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UP (Unix timestamp)",
     "name": "current_host_last_time_up",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this host (Unix timestamp)",
     "name": "current_host_last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "current_host_latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Complete output from check plugin",
     "name": "current_host_long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "current_host_low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Max check attempts for active host checks",
     "name": "current_host_max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "current_host_modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "current_host_modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Host name",
     "name": "current_host_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Scheduled time for the next check (Unix timestamp)",
     "name": "current_host_next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the next notification (Unix timestamp)",
     "name": "current_host_next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "current_host_no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes for this host",
     "name": "current_host_notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as notes, but with the most important macros expanded",
     "name": "current_host_notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL with further information about the host",
     "name": "current_host_notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Same as notes_url, but with the most important macros expanded",
     "name": "current_host_notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "current_host_notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which problems of this host will be notified. If empty then notification will be always",
     "name": "current_host_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications of the host are enabled (0/1)",
     "name": "current_host_notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "current_host_notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "current_host_num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state CRIT",
     "name": "current_host_num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state CRIT",
     "name": "current_host_num_services_hard_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state OK",
     "name": "current_host_num_services_hard_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state UNKNOWN",
     "name": "current_host_num_services_hard_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state WARN",
     "name": "current_host_num_services_hard_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state OK",
     "name": "current_host_num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services which have not been checked yet (pending)",
     "name": "current_host_num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state UNKNOWN",
     "name": "current_host_num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state WARN",
     "name": "current_host_num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "current_host_obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "current_host_obsess_over_host",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct parents of the host",
     "name": "current_host_parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether a flex downtime is pending (0/1)",
     "name": "current_host_pending_flex_downtime",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "current_host_percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional performance data of the last host check",
     "name": "current_host_perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last host check",
     "name": "current_host_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this host (0/1)",
     "name": "current_host_pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled (0/1)",
     "name": "current_host_process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "current_host_retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of downtimes this host is currently in",
     "name": "current_host_scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all services of the host",
     "name": "current_host_services",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services including detailed information about each service",
     "name": "current_host_services_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services of the host together with state and has_been_checked",
     "name": "current_host_services_with_state",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this host (0/1)",
     "name": "current_host_should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Staleness indicator for this host",
     "name": "current_host_staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the host (0: up, 1: down, 2: unreachable)",
     "name": "current_host_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of the current state (0: soft, 1: hard)",
     "name": "current_host_state_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of in image file for the status map",
     "name": "current_host_statusmap_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "current_host_total_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst hard state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "current_host_worst_service_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst soft state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "current_host_worst_service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: X",
     "name": "current_host_x_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Y",
     "name": "current_host_y_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Z",
     "name": "current_host_z_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service accepts passive checks (0/1)",
     "name": "current_service_accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current service problem has been acknowledged (0/1)",
     "name": "current_service_acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the acknowledgement (0: none, 1: normal, 2: sticky)",
     "name": "current_service_acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL for actions or custom information about the service",
     "name": "current_service_action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The action_url with (the most important) macros expanded",
     "name": "current_service_action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the service (0/1)",
     "name": "current_service_active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Naemon command used for active checks",
     "name": "current_service_check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "current_service_check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the service",
     "name": "current_service_check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0/1)",
     "name": "current_service_check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the check period of the service. It this is empty, the service is always checked.",
     "name": "current_service_check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "current_service_check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The type of the last check (0: active, 1: passive)",
     "name": "current_service_check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the service (0/1)",
     "name": "current_service_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all comment ids of the service",
     "name": "current_service_comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the service with id, author, comment, entry_type, expires and expire_time",
     "name": "current_service_comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this service is in",
     "name": "current_service_contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of the service, either direct or via a contact group",
     "name": "current_service_contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The number of the current check attempt",
     "name": "current_service_current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the current notification",
     "name": "current_service_current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables of the service",
     "name": "current_service_custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of all custom variable of the service",
     "name": "current_service_custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "current_service_custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to execute",
     "name": "current_service_depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to execute including information: host_name, service_description, failure_options, dependency_period and inherits_parent",
     "name": "current_service_depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to notify",
     "name": "current_service_depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to notify including information: host_name, service_description, failure_options, dependency_period and inherits_parent",
     "name": "current_service_depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Description of the service (also used as key)",
     "name": "current_service_description",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional display name",
     "name": "current_service_display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all downtime ids of the service",
     "name": "current_service_downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the service with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "current_service_downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "current_service_event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether and event handler is activated for the service (0/1)",
     "name": "current_service_event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the service check needed for execution",
     "name": "current_service_execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "current_service_first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled for the service (0/1)",
     "name": "current_service_flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all service groups the service is in",
     "name": "current_service_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether the service already has been checked (0/1)",
     "name": "current_service_has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "current_service_high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "current_service_hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image to be used as icon in the web interface",
     "name": "current_service_icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alternative text for the icon_image for browsers not displaying icons",
     "name": "current_service_icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The icon_image with (the most important) macros expanded",
     "name": "current_service_icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Service id",
     "name": "current_service_id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is currently in its check period (0/1)",
     "name": "current_service_in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is currently in its notification period (0/1)",
     "name": "current_service_in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The initial state of the service",
     "name": "current_service_initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a service check currently running... (0/1)",
     "name": "current_service_is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is flapping (0/1)",
     "name": "current_service_is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last check (Unix timestamp)",
     "name": "current_service_last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last hard state of the service",
     "name": "current_service_last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last hard state change (Unix timestamp)",
     "name": "current_service_last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last notification (Unix timestamp)",
     "name": "current_service_last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last state of the service",
     "name": "current_service_last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last state change (Unix timestamp)",
     "name": "current_service_last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was CRITICAL (Unix timestamp)",
     "name": "current_service_last_time_critical",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was OK (Unix timestamp)",
     "name": "current_service_last_time_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was UNKNOWN (Unix timestamp)",
     "name": "current_service_last_time_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was in WARNING state (Unix timestamp)",
     "name": "current_service_last_time_warning",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this service (Unix timestamp)",
     "name": "current_service_last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "current_service_latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Unabbreviated output of the last check plugin",
     "name": "current_service_long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "current_service_low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The maximum number of check attempts",
     "name": "current_service_max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "current_service_modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "current_service_modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The scheduled time of the next check (Unix timestamp)",
     "name": "current_service_next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the next notification (Unix timestamp)",
     "name": "current_service_next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "current_service_no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes about the service",
     "name": "current_service_notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The notes with (the most important) macros expanded",
     "name": "current_service_notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL for additional notes about the service",
     "name": "current_service_notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The notes_url with (the most important) macros expanded",
     "name": "current_service_notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "current_service_notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the notification period of the service. It this is empty, service problems are always notified.",
     "name": "current_service_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications are enabled for the service (0/1)",
     "name": "current_service_notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "current_service_notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether 'obsess' is enabled for the service (0/1)",
     "name": "current_service_obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether 'obsess' is enabled for the service (0/1)",
     "name": "current_service_obsess_over_service",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all parent services",
     "name": "current_service_parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "current_service_percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Performance data of the last check plugin",
     "name": "current_service_perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last check plugin",
     "name": "current_service_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this service (0/1)",
     "name": "current_service_pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled for the service (0/1)",
     "name": "current_service_process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "current_service_retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of scheduled downtimes the service is currently in",
     "name": "current_service_scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this service (0/1)",
     "name": "current_service_should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The staleness indicator for this service",
     "name": "current_service_staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the service (0: OK, 1: WARN, 2: CRITICAL, 3: UNKNOWN)",
     "name": "current_service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the current state (0: soft, 1: hard)",
     "name": "current_service_state_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the host the log entry is about (might be empty)",
     "name": "host_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The number of the line in the log file",
     "name": "lineno",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The complete message line including the timestamp",
     "name": "message",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The part of the message after the ':'",
     "name": "options",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The output of the check, if any is associated with the message",
     "name": "plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The description of the service log entry is about (might be empty)",
     "name": "service_description",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The state of the host or service in question",
     "name": "state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the state (varies on different log classes)",
     "name": "state_type",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Time of the log event (UNIX timestamp)",
     "name": "time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the message (text before the colon), the message itself for info messages",
     "name": "type",
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
     "description": "Whether passive host checks are accepted in general (0/1)",
     "name": "accept_passive_host_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether passive service checks are activated in general (0/1)",
     "name": "accept_passive_service_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current number of log messages Naemon Livestatus keeps in memory",
     "name": "cached_log_messages",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether Naemon checks for external commands at its command pipe (0/1)",
     "name": "check_external_commands",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether host freshness checking is activated in general (0/1)",
     "name": "check_host_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether service freshness checking is activated in general (0/1)",
     "name": "check_service_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of client connections to Livestatus since program start",
     "name": "connections",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The averaged number of new client connections to Livestatus per second",
     "name": "connections_rate",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether event handlers are activated in general (0/1)",
     "name": "enable_event_handlers",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is activated in general (0/1)",
     "name": "enable_flap_detection",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether notifications are enabled in general (0/1)",
     "name": "enable_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether host checks are executed in general (0/1)",
     "name": "execute_host_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether active service checks are activated in general (0/1)",
     "name": "execute_service_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of process creations since program start",
     "name": "forks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "the averaged number of forks checks per second",
     "name": "forks_rate",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of host checks since program start",
     "name": "host_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "the averaged number of host checks per second",
     "name": "host_checks_rate",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The default interval length from naemon.cfg",
     "name": "interval_length",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last check for a command as UNIX timestamp (deprecated)",
     "name": "last_command_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time time of the last log file rotation",
     "name": "last_log_rotation",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of times a check could not be executed because now livecheck helper was free",
     "name": "livecheck_overflows",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of livecheck overflows per second",
     "name": "livecheck_overflows_rate",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of checks executed via livecheck",
     "name": "livechecks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The averaged number of livechecks executed per second",
     "name": "livechecks_rate",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The version of the Naemon Livestatus module",
     "name": "livestatus_version",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The number of new log messages since program start",
     "name": "log_messages",
     "type": "number",
     "unit": ""
    },
    {
     "description": "the averaged number of new log messages per second",
     "name": "log_messages_rate",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The process ID of the Naemon main process",
     "name": "nagios_pid",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of NEB call backs since program start",
     "name": "neb_callbacks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The averaged number of NEB call backs per second",
     "name": "neb_callbacks_rate",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of hosts",
     "name": "num_hosts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services",
     "name": "num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether Naemon will obsess over host checks (0/1)",
     "name": "obsess_over_hosts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether Naemon will obsess over service checks and run the ocsp_command (0/1)",
     "name": "obsess_over_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is activated in general (0/1)",
     "name": "process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last program start as UNIX timestamp",
     "name": "program_start",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The version of the monitoring daemon",
     "name": "program_version",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The number of requests to Livestatus since program start",
     "name": "requests",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The averaged number of request to Livestatus per second",
     "name": "requests_rate",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of completed service checks since program start",
     "name": "service_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The averaged number of service checks per second",
     "name": "service_checks_rate",
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
     "description": "An optional URL to custom notes or actions on the service group",
     "name": "action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alias of the service group",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Servicegroup id",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all members of the service group as host/service pairs",
     "name": "members",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all members of the service group with state and has_been_checked",
     "name": "members_with_state",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The name of the service group",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Optional additional notes about the service group",
     "name": "notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL to further notes on the service group",
     "name": "notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The total number of services in the group",
     "name": "num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are CRIT",
     "name": "num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are CRIT",
     "name": "num_services_hard_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are OK",
     "name": "num_services_hard_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are UNKNOWN",
     "name": "num_services_hard_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are WARN",
     "name": "num_services_hard_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are OK",
     "name": "num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are PENDING",
     "name": "num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are UNKNOWN",
     "name": "num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are WARN",
     "name": "num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst soft state of all of the groups services (OK <= WARN <= UNKNOWN <= CRIT)",
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
     "description": "An optional URL to custom notes or actions on the service group",
     "name": "action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alias of the service group",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Servicegroup id",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all members of the service group as host/service pairs",
     "name": "members",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all members of the service group with state and has_been_checked",
     "name": "members_with_state",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The name of the service group",
     "name": "name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Optional additional notes about the service group",
     "name": "notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL to further notes on the service group",
     "name": "notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The total number of services in the group",
     "name": "num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are CRIT",
     "name": "num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are CRIT",
     "name": "num_services_hard_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are OK",
     "name": "num_services_hard_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are UNKNOWN",
     "name": "num_services_hard_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are WARN",
     "name": "num_services_hard_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are OK",
     "name": "num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are PENDING",
     "name": "num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are UNKNOWN",
     "name": "num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are WARN",
     "name": "num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst soft state of all of the groups services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "worst_service_state",
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
     "description": "Whether the service accepts passive checks (0/1)",
     "name": "accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current service problem has been acknowledged (0/1)",
     "name": "acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the acknowledgement (0: none, 1: normal, 2: sticky)",
     "name": "acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL for actions or custom information about the service",
     "name": "action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The action_url with (the most important) macros expanded",
     "name": "action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the service (0/1)",
     "name": "active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Naemon command used for active checks",
     "name": "check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the service",
     "name": "check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0/1)",
     "name": "check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the check period of the service. It this is empty, the service is always checked.",
     "name": "check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The type of the last check (0: active, 1: passive)",
     "name": "check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the service (0/1)",
     "name": "checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all comment ids of the service",
     "name": "comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the service with id, author, comment, entry_type, expires and expire_time",
     "name": "comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this service is in",
     "name": "contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of the service, either direct or via a contact group",
     "name": "contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The number of the current check attempt",
     "name": "current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the current notification",
     "name": "current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables of the service",
     "name": "custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of all custom variable of the service",
     "name": "custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to execute",
     "name": "depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to execute including information: host_name, service_description, failure_options, dependency_period and inherits_parent",
     "name": "depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to notify",
     "name": "depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to notify including information: host_name, service_description, failure_options, dependency_period and inherits_parent",
     "name": "depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Description of the service (also used as key)",
     "name": "description",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional display name",
     "name": "display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all downtime ids of the service",
     "name": "downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the service with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether and event handler is activated for the service (0/1)",
     "name": "event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the service check needed for execution",
     "name": "execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled for the service (0/1)",
     "name": "flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all service groups the service is in",
     "name": "groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether the service already has been checked (0/1)",
     "name": "has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether passive host checks are accepted (0/1)",
     "name": "host_accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current host problem has been acknowledged (0/1)",
     "name": "host_acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of acknowledgement (0: none, 1: normal, 2: stick)",
     "name": "host_acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL to custom actions or information about this host",
     "name": "host_action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as action_url, but with the most important macros expanded",
     "name": "host_action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the host (0/1)",
     "name": "host_active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "IP address",
     "name": "host_address",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alias name for the host",
     "name": "host_alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Naemon command for active host check of this host",
     "name": "host_check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether to check to send a recovery notification when flapping stops (0/1)",
     "name": "host_check_flapping_recovery_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "host_check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the host",
     "name": "host_check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0-2)",
     "name": "host_check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which this host will be checked. If empty then the host will always be checked.",
     "name": "host_check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "host_check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Type of check (0: active, 1: passive)",
     "name": "host_check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether checks of the host are enabled (0/1)",
     "name": "host_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct children of the host",
     "name": "host_childs",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the ids of all comments of this host",
     "name": "host_comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the host with id, author, comment, entry_type, expires and expire_time",
     "name": "host_comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this host is in",
     "name": "host_contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of this host, either direct or via a contact group",
     "name": "host_contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Number of the current check attempts",
     "name": "host_current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of the current notification",
     "name": "host_current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables",
     "name": "host_custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of the custom variables",
     "name": "host_custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "host_custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute",
     "name": "host_depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "host_depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify",
     "name": "host_depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "host_depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Optional display name of the host",
     "name": "host_display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of the ids of all scheduled downtimes of this host",
     "name": "host_downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the host with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "host_downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "host_event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether event handling is enabled (0/1)",
     "name": "host_event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the host check needed for execution",
     "name": "host_execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The value of the custom variable FILENAME",
     "name": "host_filename",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "host_first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled (0/1)",
     "name": "host_flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all host groups this host is in",
     "name": "host_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The effective hard state of the host (eliminates a problem in hard_state)",
     "name": "host_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host has already been checked (0/1)",
     "name": "host_has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "host_high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "host_hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image file to be used in the web pages",
     "name": "host_icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Alternative text for the icon_image",
     "name": "host_icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as icon_image, but with the most important macros expanded",
     "name": "host_icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Host id",
     "name": "host_id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its check period (0/1)",
     "name": "host_in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its notification period (0/1)",
     "name": "host_in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Initial host state",
     "name": "host_initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a host check currently running... (0/1)",
     "name": "host_is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host state is flapping (0/1)",
     "name": "host_is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last check (Unix timestamp)",
     "name": "host_last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Last hard state",
     "name": "host_last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last hard state change (Unix timestamp)",
     "name": "host_last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last notification (Unix timestamp)",
     "name": "host_last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "State before last state change",
     "name": "host_last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last state change - soft or hard (Unix timestamp)",
     "name": "host_last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was DOWN (Unix timestamp)",
     "name": "host_last_time_down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UNREACHABLE (Unix timestamp)",
     "name": "host_last_time_unreachable",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UP (Unix timestamp)",
     "name": "host_last_time_up",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this host (Unix timestamp)",
     "name": "host_last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "host_latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Complete output from check plugin",
     "name": "host_long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "host_low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Max check attempts for active host checks",
     "name": "host_max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "host_modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "host_modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Host name",
     "name": "host_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Scheduled time for the next check (Unix timestamp)",
     "name": "host_next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the next notification (Unix timestamp)",
     "name": "host_next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "host_no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes for this host",
     "name": "host_notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as notes, but with the most important macros expanded",
     "name": "host_notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL with further information about the host",
     "name": "host_notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Same as notes_url, but with the most important macros expanded",
     "name": "host_notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "host_notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which problems of this host will be notified. If empty then notification will be always",
     "name": "host_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications of the host are enabled (0/1)",
     "name": "host_notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "host_notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "host_num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state CRIT",
     "name": "host_num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state CRIT",
     "name": "host_num_services_hard_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state OK",
     "name": "host_num_services_hard_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state UNKNOWN",
     "name": "host_num_services_hard_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state WARN",
     "name": "host_num_services_hard_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state OK",
     "name": "host_num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services which have not been checked yet (pending)",
     "name": "host_num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state UNKNOWN",
     "name": "host_num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state WARN",
     "name": "host_num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "host_obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "host_obsess_over_host",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct parents of the host",
     "name": "host_parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether a flex downtime is pending (0/1)",
     "name": "host_pending_flex_downtime",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "host_percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional performance data of the last host check",
     "name": "host_perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last host check",
     "name": "host_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this host (0/1)",
     "name": "host_pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled (0/1)",
     "name": "host_process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "host_retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of downtimes this host is currently in",
     "name": "host_scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all services of the host",
     "name": "host_services",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services including detailed information about each service",
     "name": "host_services_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services of the host together with state and has_been_checked",
     "name": "host_services_with_state",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this host (0/1)",
     "name": "host_should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Staleness indicator for this host",
     "name": "host_staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the host (0: up, 1: down, 2: unreachable)",
     "name": "host_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of the current state (0: soft, 1: hard)",
     "name": "host_state_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of in image file for the status map",
     "name": "host_statusmap_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "host_total_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst hard state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "host_worst_service_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst soft state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "host_worst_service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: X",
     "name": "host_x_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Y",
     "name": "host_y_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Z",
     "name": "host_z_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image to be used as icon in the web interface",
     "name": "icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alternative text for the icon_image for browsers not displaying icons",
     "name": "icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The icon_image with (the most important) macros expanded",
     "name": "icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Service id",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is currently in its check period (0/1)",
     "name": "in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is currently in its notification period (0/1)",
     "name": "in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The initial state of the service",
     "name": "initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a service check currently running... (0/1)",
     "name": "is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is flapping (0/1)",
     "name": "is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last check (Unix timestamp)",
     "name": "last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last hard state of the service",
     "name": "last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last hard state change (Unix timestamp)",
     "name": "last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last notification (Unix timestamp)",
     "name": "last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last state of the service",
     "name": "last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last state change (Unix timestamp)",
     "name": "last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was CRITICAL (Unix timestamp)",
     "name": "last_time_critical",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was OK (Unix timestamp)",
     "name": "last_time_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was UNKNOWN (Unix timestamp)",
     "name": "last_time_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was in WARNING state (Unix timestamp)",
     "name": "last_time_warning",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this service (Unix timestamp)",
     "name": "last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Unabbreviated output of the last check plugin",
     "name": "long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The maximum number of check attempts",
     "name": "max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The scheduled time of the next check (Unix timestamp)",
     "name": "next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the next notification (Unix timestamp)",
     "name": "next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes about the service",
     "name": "notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The notes with (the most important) macros expanded",
     "name": "notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL for additional notes about the service",
     "name": "notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The notes_url with (the most important) macros expanded",
     "name": "notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the notification period of the service. It this is empty, service problems are always notified.",
     "name": "notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications are enabled for the service (0/1)",
     "name": "notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether 'obsess' is enabled for the service (0/1)",
     "name": "obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether 'obsess' is enabled for the service (0/1)",
     "name": "obsess_over_service",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all parent services",
     "name": "parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Performance data of the last check plugin",
     "name": "perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last check plugin",
     "name": "plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this service (0/1)",
     "name": "pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled for the service (0/1)",
     "name": "process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of scheduled downtimes the service is currently in",
     "name": "scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this service (0/1)",
     "name": "should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The staleness indicator for this service",
     "name": "staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the service (0: OK, 1: WARN, 2: CRITICAL, 3: UNKNOWN)",
     "name": "state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the current state (0: soft, 1: hard)",
     "name": "state_type",
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
     "description": "Whether the service accepts passive checks (0/1)",
     "name": "accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current service problem has been acknowledged (0/1)",
     "name": "acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the acknowledgement (0: none, 1: normal, 2: sticky)",
     "name": "acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL for actions or custom information about the service",
     "name": "action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The action_url with (the most important) macros expanded",
     "name": "action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the service (0/1)",
     "name": "active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Naemon command used for active checks",
     "name": "check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the service",
     "name": "check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0/1)",
     "name": "check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the check period of the service. It this is empty, the service is always checked.",
     "name": "check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The type of the last check (0: active, 1: passive)",
     "name": "check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the service (0/1)",
     "name": "checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all comment ids of the service",
     "name": "comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the service with id, author, comment, entry_type, expires and expire_time",
     "name": "comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this service is in",
     "name": "contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of the service, either direct or via a contact group",
     "name": "contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The number of the current check attempt",
     "name": "current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the current notification",
     "name": "current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables of the service",
     "name": "custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of all custom variable of the service",
     "name": "custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to execute",
     "name": "depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to execute including information: host_name, service_description, failure_options, dependency_period and inherits_parent",
     "name": "depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to notify",
     "name": "depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to notify including information: host_name, service_description, failure_options, dependency_period and inherits_parent",
     "name": "depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Description of the service (also used as key)",
     "name": "description",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional display name",
     "name": "display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all downtime ids of the service",
     "name": "downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the service with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether and event handler is activated for the service (0/1)",
     "name": "event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the service check needed for execution",
     "name": "execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled for the service (0/1)",
     "name": "flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all service groups the service is in",
     "name": "groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether the service already has been checked (0/1)",
     "name": "has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether passive host checks are accepted (0/1)",
     "name": "host_accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current host problem has been acknowledged (0/1)",
     "name": "host_acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of acknowledgement (0: none, 1: normal, 2: stick)",
     "name": "host_acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL to custom actions or information about this host",
     "name": "host_action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as action_url, but with the most important macros expanded",
     "name": "host_action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the host (0/1)",
     "name": "host_active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "IP address",
     "name": "host_address",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alias name for the host",
     "name": "host_alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Naemon command for active host check of this host",
     "name": "host_check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether to check to send a recovery notification when flapping stops (0/1)",
     "name": "host_check_flapping_recovery_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "host_check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the host",
     "name": "host_check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0-2)",
     "name": "host_check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which this host will be checked. If empty then the host will always be checked.",
     "name": "host_check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "host_check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Type of check (0: active, 1: passive)",
     "name": "host_check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether checks of the host are enabled (0/1)",
     "name": "host_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct children of the host",
     "name": "host_childs",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the ids of all comments of this host",
     "name": "host_comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the host with id, author, comment, entry_type, expires and expire_time",
     "name": "host_comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this host is in",
     "name": "host_contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of this host, either direct or via a contact group",
     "name": "host_contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Number of the current check attempts",
     "name": "host_current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of the current notification",
     "name": "host_current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables",
     "name": "host_custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of the custom variables",
     "name": "host_custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "host_custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute",
     "name": "host_depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "host_depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify",
     "name": "host_depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "host_depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Optional display name of the host",
     "name": "host_display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of the ids of all scheduled downtimes of this host",
     "name": "host_downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the host with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "host_downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "host_event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether event handling is enabled (0/1)",
     "name": "host_event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the host check needed for execution",
     "name": "host_execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The value of the custom variable FILENAME",
     "name": "host_filename",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "host_first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled (0/1)",
     "name": "host_flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all host groups this host is in",
     "name": "host_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The effective hard state of the host (eliminates a problem in hard_state)",
     "name": "host_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host has already been checked (0/1)",
     "name": "host_has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "host_high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "host_hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image file to be used in the web pages",
     "name": "host_icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Alternative text for the icon_image",
     "name": "host_icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as icon_image, but with the most important macros expanded",
     "name": "host_icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Host id",
     "name": "host_id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its check period (0/1)",
     "name": "host_in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its notification period (0/1)",
     "name": "host_in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Initial host state",
     "name": "host_initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a host check currently running... (0/1)",
     "name": "host_is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host state is flapping (0/1)",
     "name": "host_is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last check (Unix timestamp)",
     "name": "host_last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Last hard state",
     "name": "host_last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last hard state change (Unix timestamp)",
     "name": "host_last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last notification (Unix timestamp)",
     "name": "host_last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "State before last state change",
     "name": "host_last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last state change - soft or hard (Unix timestamp)",
     "name": "host_last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was DOWN (Unix timestamp)",
     "name": "host_last_time_down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UNREACHABLE (Unix timestamp)",
     "name": "host_last_time_unreachable",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UP (Unix timestamp)",
     "name": "host_last_time_up",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this host (Unix timestamp)",
     "name": "host_last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "host_latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Complete output from check plugin",
     "name": "host_long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "host_low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Max check attempts for active host checks",
     "name": "host_max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "host_modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "host_modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Host name",
     "name": "host_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Scheduled time for the next check (Unix timestamp)",
     "name": "host_next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the next notification (Unix timestamp)",
     "name": "host_next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "host_no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes for this host",
     "name": "host_notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as notes, but with the most important macros expanded",
     "name": "host_notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL with further information about the host",
     "name": "host_notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Same as notes_url, but with the most important macros expanded",
     "name": "host_notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "host_notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which problems of this host will be notified. If empty then notification will be always",
     "name": "host_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications of the host are enabled (0/1)",
     "name": "host_notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "host_notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "host_num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state CRIT",
     "name": "host_num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state CRIT",
     "name": "host_num_services_hard_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state OK",
     "name": "host_num_services_hard_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state UNKNOWN",
     "name": "host_num_services_hard_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state WARN",
     "name": "host_num_services_hard_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state OK",
     "name": "host_num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services which have not been checked yet (pending)",
     "name": "host_num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state UNKNOWN",
     "name": "host_num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state WARN",
     "name": "host_num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "host_obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "host_obsess_over_host",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct parents of the host",
     "name": "host_parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether a flex downtime is pending (0/1)",
     "name": "host_pending_flex_downtime",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "host_percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional performance data of the last host check",
     "name": "host_perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last host check",
     "name": "host_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this host (0/1)",
     "name": "host_pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled (0/1)",
     "name": "host_process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "host_retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of downtimes this host is currently in",
     "name": "host_scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all services of the host",
     "name": "host_services",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services including detailed information about each service",
     "name": "host_services_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services of the host together with state and has_been_checked",
     "name": "host_services_with_state",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this host (0/1)",
     "name": "host_should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Staleness indicator for this host",
     "name": "host_staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the host (0: up, 1: down, 2: unreachable)",
     "name": "host_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of the current state (0: soft, 1: hard)",
     "name": "host_state_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of in image file for the status map",
     "name": "host_statusmap_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "host_total_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst hard state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "host_worst_service_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst soft state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "host_worst_service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: X",
     "name": "host_x_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Y",
     "name": "host_y_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Z",
     "name": "host_z_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image to be used as icon in the web interface",
     "name": "icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alternative text for the icon_image for browsers not displaying icons",
     "name": "icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The icon_image with (the most important) macros expanded",
     "name": "icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Service id",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is currently in its check period (0/1)",
     "name": "in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is currently in its notification period (0/1)",
     "name": "in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The initial state of the service",
     "name": "initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a service check currently running... (0/1)",
     "name": "is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is flapping (0/1)",
     "name": "is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last check (Unix timestamp)",
     "name": "last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last hard state of the service",
     "name": "last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last hard state change (Unix timestamp)",
     "name": "last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last notification (Unix timestamp)",
     "name": "last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last state of the service",
     "name": "last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last state change (Unix timestamp)",
     "name": "last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was CRITICAL (Unix timestamp)",
     "name": "last_time_critical",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was OK (Unix timestamp)",
     "name": "last_time_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was UNKNOWN (Unix timestamp)",
     "name": "last_time_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was in WARNING state (Unix timestamp)",
     "name": "last_time_warning",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this service (Unix timestamp)",
     "name": "last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Unabbreviated output of the last check plugin",
     "name": "long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The maximum number of check attempts",
     "name": "max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The scheduled time of the next check (Unix timestamp)",
     "name": "next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the next notification (Unix timestamp)",
     "name": "next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes about the service",
     "name": "notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The notes with (the most important) macros expanded",
     "name": "notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL for additional notes about the service",
     "name": "notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The notes_url with (the most important) macros expanded",
     "name": "notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the notification period of the service. It this is empty, service problems are always notified.",
     "name": "notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications are enabled for the service (0/1)",
     "name": "notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether 'obsess' is enabled for the service (0/1)",
     "name": "obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether 'obsess' is enabled for the service (0/1)",
     "name": "obsess_over_service",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all parent services",
     "name": "parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Performance data of the last check plugin",
     "name": "perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last check plugin",
     "name": "plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this service (0/1)",
     "name": "pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled for the service (0/1)",
     "name": "process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of scheduled downtimes the service is currently in",
     "name": "scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this service (0/1)",
     "name": "should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The staleness indicator for this service",
     "name": "staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the service (0: OK, 1: WARN, 2: CRITICAL, 3: UNKNOWN)",
     "name": "state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the current state (0: soft, 1: hard)",
     "name": "state_type",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/servicesbygroup": {
  "GET": {
   "columns": [
    {
     "description": "Whether the service accepts passive checks (0/1)",
     "name": "accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current service problem has been acknowledged (0/1)",
     "name": "acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the acknowledgement (0: none, 1: normal, 2: sticky)",
     "name": "acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL for actions or custom information about the service",
     "name": "action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The action_url with (the most important) macros expanded",
     "name": "action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the service (0/1)",
     "name": "active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Naemon command used for active checks",
     "name": "check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the service",
     "name": "check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0/1)",
     "name": "check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the check period of the service. It this is empty, the service is always checked.",
     "name": "check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The type of the last check (0: active, 1: passive)",
     "name": "check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the service (0/1)",
     "name": "checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all comment ids of the service",
     "name": "comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the service with id, author, comment, entry_type, expires and expire_time",
     "name": "comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this service is in",
     "name": "contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of the service, either direct or via a contact group",
     "name": "contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The number of the current check attempt",
     "name": "current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the current notification",
     "name": "current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables of the service",
     "name": "custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of all custom variable of the service",
     "name": "custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to execute",
     "name": "depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to execute including information: host_name, service_description, failure_options, dependency_period and inherits_parent",
     "name": "depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to notify",
     "name": "depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to notify including information: host_name, service_description, failure_options, dependency_period and inherits_parent",
     "name": "depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Description of the service (also used as key)",
     "name": "description",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional display name",
     "name": "display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all downtime ids of the service",
     "name": "downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the service with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether and event handler is activated for the service (0/1)",
     "name": "event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the service check needed for execution",
     "name": "execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled for the service (0/1)",
     "name": "flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all service groups the service is in",
     "name": "groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether the service already has been checked (0/1)",
     "name": "has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether passive host checks are accepted (0/1)",
     "name": "host_accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current host problem has been acknowledged (0/1)",
     "name": "host_acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of acknowledgement (0: none, 1: normal, 2: stick)",
     "name": "host_acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL to custom actions or information about this host",
     "name": "host_action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as action_url, but with the most important macros expanded",
     "name": "host_action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the host (0/1)",
     "name": "host_active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "IP address",
     "name": "host_address",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alias name for the host",
     "name": "host_alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Naemon command for active host check of this host",
     "name": "host_check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether to check to send a recovery notification when flapping stops (0/1)",
     "name": "host_check_flapping_recovery_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "host_check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the host",
     "name": "host_check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0-2)",
     "name": "host_check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which this host will be checked. If empty then the host will always be checked.",
     "name": "host_check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "host_check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Type of check (0: active, 1: passive)",
     "name": "host_check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether checks of the host are enabled (0/1)",
     "name": "host_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct children of the host",
     "name": "host_childs",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the ids of all comments of this host",
     "name": "host_comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the host with id, author, comment, entry_type, expires and expire_time",
     "name": "host_comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this host is in",
     "name": "host_contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of this host, either direct or via a contact group",
     "name": "host_contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Number of the current check attempts",
     "name": "host_current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of the current notification",
     "name": "host_current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables",
     "name": "host_custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of the custom variables",
     "name": "host_custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "host_custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute",
     "name": "host_depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "host_depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify",
     "name": "host_depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "host_depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Optional display name of the host",
     "name": "host_display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of the ids of all scheduled downtimes of this host",
     "name": "host_downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the host with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "host_downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "host_event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether event handling is enabled (0/1)",
     "name": "host_event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the host check needed for execution",
     "name": "host_execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The value of the custom variable FILENAME",
     "name": "host_filename",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "host_first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled (0/1)",
     "name": "host_flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all host groups this host is in",
     "name": "host_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The effective hard state of the host (eliminates a problem in hard_state)",
     "name": "host_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host has already been checked (0/1)",
     "name": "host_has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "host_high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "host_hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image file to be used in the web pages",
     "name": "host_icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Alternative text for the icon_image",
     "name": "host_icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as icon_image, but with the most important macros expanded",
     "name": "host_icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Host id",
     "name": "host_id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its check period (0/1)",
     "name": "host_in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its notification period (0/1)",
     "name": "host_in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Initial host state",
     "name": "host_initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a host check currently running... (0/1)",
     "name": "host_is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host state is flapping (0/1)",
     "name": "host_is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last check (Unix timestamp)",
     "name": "host_last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Last hard state",
     "name": "host_last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last hard state change (Unix timestamp)",
     "name": "host_last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last notification (Unix timestamp)",
     "name": "host_last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "State before last state change",
     "name": "host_last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last state change - soft or hard (Unix timestamp)",
     "name": "host_last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was DOWN (Unix timestamp)",
     "name": "host_last_time_down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UNREACHABLE (Unix timestamp)",
     "name": "host_last_time_unreachable",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UP (Unix timestamp)",
     "name": "host_last_time_up",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this host (Unix timestamp)",
     "name": "host_last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "host_latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Complete output from check plugin",
     "name": "host_long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "host_low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Max check attempts for active host checks",
     "name": "host_max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "host_modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "host_modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Host name",
     "name": "host_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Scheduled time for the next check (Unix timestamp)",
     "name": "host_next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the next notification (Unix timestamp)",
     "name": "host_next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "host_no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes for this host",
     "name": "host_notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as notes, but with the most important macros expanded",
     "name": "host_notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL with further information about the host",
     "name": "host_notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Same as notes_url, but with the most important macros expanded",
     "name": "host_notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "host_notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which problems of this host will be notified. If empty then notification will be always",
     "name": "host_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications of the host are enabled (0/1)",
     "name": "host_notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "host_notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "host_num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state CRIT",
     "name": "host_num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state CRIT",
     "name": "host_num_services_hard_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state OK",
     "name": "host_num_services_hard_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state UNKNOWN",
     "name": "host_num_services_hard_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state WARN",
     "name": "host_num_services_hard_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state OK",
     "name": "host_num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services which have not been checked yet (pending)",
     "name": "host_num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state UNKNOWN",
     "name": "host_num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state WARN",
     "name": "host_num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "host_obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "host_obsess_over_host",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct parents of the host",
     "name": "host_parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether a flex downtime is pending (0/1)",
     "name": "host_pending_flex_downtime",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "host_percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional performance data of the last host check",
     "name": "host_perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last host check",
     "name": "host_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this host (0/1)",
     "name": "host_pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled (0/1)",
     "name": "host_process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "host_retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of downtimes this host is currently in",
     "name": "host_scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all services of the host",
     "name": "host_services",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services including detailed information about each service",
     "name": "host_services_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services of the host together with state and has_been_checked",
     "name": "host_services_with_state",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this host (0/1)",
     "name": "host_should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Staleness indicator for this host",
     "name": "host_staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the host (0: up, 1: down, 2: unreachable)",
     "name": "host_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of the current state (0: soft, 1: hard)",
     "name": "host_state_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of in image file for the status map",
     "name": "host_statusmap_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "host_total_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst hard state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "host_worst_service_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst soft state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "host_worst_service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: X",
     "name": "host_x_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Y",
     "name": "host_y_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Z",
     "name": "host_z_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image to be used as icon in the web interface",
     "name": "icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alternative text for the icon_image for browsers not displaying icons",
     "name": "icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The icon_image with (the most important) macros expanded",
     "name": "icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Service id",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is currently in its check period (0/1)",
     "name": "in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is currently in its notification period (0/1)",
     "name": "in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The initial state of the service",
     "name": "initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a service check currently running... (0/1)",
     "name": "is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is flapping (0/1)",
     "name": "is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last check (Unix timestamp)",
     "name": "last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last hard state of the service",
     "name": "last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last hard state change (Unix timestamp)",
     "name": "last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last notification (Unix timestamp)",
     "name": "last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last state of the service",
     "name": "last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last state change (Unix timestamp)",
     "name": "last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was CRITICAL (Unix timestamp)",
     "name": "last_time_critical",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was OK (Unix timestamp)",
     "name": "last_time_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was UNKNOWN (Unix timestamp)",
     "name": "last_time_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was in WARNING state (Unix timestamp)",
     "name": "last_time_warning",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this service (Unix timestamp)",
     "name": "last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Unabbreviated output of the last check plugin",
     "name": "long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The maximum number of check attempts",
     "name": "max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The scheduled time of the next check (Unix timestamp)",
     "name": "next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the next notification (Unix timestamp)",
     "name": "next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes about the service",
     "name": "notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The notes with (the most important) macros expanded",
     "name": "notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL for additional notes about the service",
     "name": "notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The notes_url with (the most important) macros expanded",
     "name": "notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the notification period of the service. It this is empty, service problems are always notified.",
     "name": "notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications are enabled for the service (0/1)",
     "name": "notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether 'obsess' is enabled for the service (0/1)",
     "name": "obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether 'obsess' is enabled for the service (0/1)",
     "name": "obsess_over_service",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all parent services",
     "name": "parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Performance data of the last check plugin",
     "name": "perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last check plugin",
     "name": "plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this service (0/1)",
     "name": "pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled for the service (0/1)",
     "name": "process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of scheduled downtimes the service is currently in",
     "name": "scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL to custom notes or actions on the service group",
     "name": "servicegroup_action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alias of the service group",
     "name": "servicegroup_alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Servicegroup id",
     "name": "servicegroup_id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all members of the service group as host/service pairs",
     "name": "servicegroup_members",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all members of the service group with state and has_been_checked",
     "name": "servicegroup_members_with_state",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The name of the service group",
     "name": "servicegroup_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Optional additional notes about the service group",
     "name": "servicegroup_notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL to further notes on the service group",
     "name": "servicegroup_notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The total number of services in the group",
     "name": "servicegroup_num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are CRIT",
     "name": "servicegroup_num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are CRIT",
     "name": "servicegroup_num_services_hard_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are OK",
     "name": "servicegroup_num_services_hard_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are UNKNOWN",
     "name": "servicegroup_num_services_hard_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are WARN",
     "name": "servicegroup_num_services_hard_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are OK",
     "name": "servicegroup_num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are PENDING",
     "name": "servicegroup_num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are UNKNOWN",
     "name": "servicegroup_num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are WARN",
     "name": "servicegroup_num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst soft state of all of the groups services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "servicegroup_worst_service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this service (0/1)",
     "name": "should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The staleness indicator for this service",
     "name": "staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the service (0: OK, 1: WARN, 2: CRITICAL, 3: UNKNOWN)",
     "name": "state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the current state (0: soft, 1: hard)",
     "name": "state_type",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/servicesbygroup/<servicegroup>": {
  "GET": {
   "columns": [
    {
     "description": "Whether the service accepts passive checks (0/1)",
     "name": "accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current service problem has been acknowledged (0/1)",
     "name": "acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the acknowledgement (0: none, 1: normal, 2: sticky)",
     "name": "acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL for actions or custom information about the service",
     "name": "action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The action_url with (the most important) macros expanded",
     "name": "action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the service (0/1)",
     "name": "active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Naemon command used for active checks",
     "name": "check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the service",
     "name": "check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0/1)",
     "name": "check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the check period of the service. It this is empty, the service is always checked.",
     "name": "check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The type of the last check (0: active, 1: passive)",
     "name": "check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the service (0/1)",
     "name": "checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all comment ids of the service",
     "name": "comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the service with id, author, comment, entry_type, expires and expire_time",
     "name": "comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this service is in",
     "name": "contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of the service, either direct or via a contact group",
     "name": "contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The number of the current check attempt",
     "name": "current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the current notification",
     "name": "current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables of the service",
     "name": "custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of all custom variable of the service",
     "name": "custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to execute",
     "name": "depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to execute including information: host_name, service_description, failure_options, dependency_period and inherits_parent",
     "name": "depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to notify",
     "name": "depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to notify including information: host_name, service_description, failure_options, dependency_period and inherits_parent",
     "name": "depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Description of the service (also used as key)",
     "name": "description",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional display name",
     "name": "display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all downtime ids of the service",
     "name": "downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the service with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether and event handler is activated for the service (0/1)",
     "name": "event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the service check needed for execution",
     "name": "execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled for the service (0/1)",
     "name": "flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all service groups the service is in",
     "name": "groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether the service already has been checked (0/1)",
     "name": "has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether passive host checks are accepted (0/1)",
     "name": "host_accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current host problem has been acknowledged (0/1)",
     "name": "host_acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of acknowledgement (0: none, 1: normal, 2: stick)",
     "name": "host_acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL to custom actions or information about this host",
     "name": "host_action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as action_url, but with the most important macros expanded",
     "name": "host_action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the host (0/1)",
     "name": "host_active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "IP address",
     "name": "host_address",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alias name for the host",
     "name": "host_alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Naemon command for active host check of this host",
     "name": "host_check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether to check to send a recovery notification when flapping stops (0/1)",
     "name": "host_check_flapping_recovery_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "host_check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the host",
     "name": "host_check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0-2)",
     "name": "host_check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which this host will be checked. If empty then the host will always be checked.",
     "name": "host_check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "host_check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Type of check (0: active, 1: passive)",
     "name": "host_check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether checks of the host are enabled (0/1)",
     "name": "host_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct children of the host",
     "name": "host_childs",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the ids of all comments of this host",
     "name": "host_comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the host with id, author, comment, entry_type, expires and expire_time",
     "name": "host_comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this host is in",
     "name": "host_contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of this host, either direct or via a contact group",
     "name": "host_contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Number of the current check attempts",
     "name": "host_current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of the current notification",
     "name": "host_current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables",
     "name": "host_custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of the custom variables",
     "name": "host_custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "host_custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute",
     "name": "host_depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "host_depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify",
     "name": "host_depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "host_depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Optional display name of the host",
     "name": "host_display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of the ids of all scheduled downtimes of this host",
     "name": "host_downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the host with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "host_downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "host_event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether event handling is enabled (0/1)",
     "name": "host_event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the host check needed for execution",
     "name": "host_execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The value of the custom variable FILENAME",
     "name": "host_filename",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "host_first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled (0/1)",
     "name": "host_flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all host groups this host is in",
     "name": "host_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The effective hard state of the host (eliminates a problem in hard_state)",
     "name": "host_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host has already been checked (0/1)",
     "name": "host_has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "host_high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "host_hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image file to be used in the web pages",
     "name": "host_icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Alternative text for the icon_image",
     "name": "host_icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as icon_image, but with the most important macros expanded",
     "name": "host_icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Host id",
     "name": "host_id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its check period (0/1)",
     "name": "host_in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its notification period (0/1)",
     "name": "host_in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Initial host state",
     "name": "host_initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a host check currently running... (0/1)",
     "name": "host_is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host state is flapping (0/1)",
     "name": "host_is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last check (Unix timestamp)",
     "name": "host_last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Last hard state",
     "name": "host_last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last hard state change (Unix timestamp)",
     "name": "host_last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last notification (Unix timestamp)",
     "name": "host_last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "State before last state change",
     "name": "host_last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last state change - soft or hard (Unix timestamp)",
     "name": "host_last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was DOWN (Unix timestamp)",
     "name": "host_last_time_down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UNREACHABLE (Unix timestamp)",
     "name": "host_last_time_unreachable",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UP (Unix timestamp)",
     "name": "host_last_time_up",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this host (Unix timestamp)",
     "name": "host_last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "host_latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Complete output from check plugin",
     "name": "host_long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "host_low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Max check attempts for active host checks",
     "name": "host_max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "host_modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "host_modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Host name",
     "name": "host_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Scheduled time for the next check (Unix timestamp)",
     "name": "host_next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the next notification (Unix timestamp)",
     "name": "host_next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "host_no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes for this host",
     "name": "host_notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as notes, but with the most important macros expanded",
     "name": "host_notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL with further information about the host",
     "name": "host_notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Same as notes_url, but with the most important macros expanded",
     "name": "host_notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "host_notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which problems of this host will be notified. If empty then notification will be always",
     "name": "host_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications of the host are enabled (0/1)",
     "name": "host_notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "host_notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "host_num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state CRIT",
     "name": "host_num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state CRIT",
     "name": "host_num_services_hard_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state OK",
     "name": "host_num_services_hard_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state UNKNOWN",
     "name": "host_num_services_hard_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state WARN",
     "name": "host_num_services_hard_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state OK",
     "name": "host_num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services which have not been checked yet (pending)",
     "name": "host_num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state UNKNOWN",
     "name": "host_num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state WARN",
     "name": "host_num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "host_obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "host_obsess_over_host",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct parents of the host",
     "name": "host_parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether a flex downtime is pending (0/1)",
     "name": "host_pending_flex_downtime",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "host_percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional performance data of the last host check",
     "name": "host_perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last host check",
     "name": "host_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this host (0/1)",
     "name": "host_pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled (0/1)",
     "name": "host_process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "host_retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of downtimes this host is currently in",
     "name": "host_scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all services of the host",
     "name": "host_services",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services including detailed information about each service",
     "name": "host_services_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services of the host together with state and has_been_checked",
     "name": "host_services_with_state",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this host (0/1)",
     "name": "host_should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Staleness indicator for this host",
     "name": "host_staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the host (0: up, 1: down, 2: unreachable)",
     "name": "host_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of the current state (0: soft, 1: hard)",
     "name": "host_state_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of in image file for the status map",
     "name": "host_statusmap_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "host_total_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst hard state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "host_worst_service_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst soft state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "host_worst_service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: X",
     "name": "host_x_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Y",
     "name": "host_y_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Z",
     "name": "host_z_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image to be used as icon in the web interface",
     "name": "icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alternative text for the icon_image for browsers not displaying icons",
     "name": "icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The icon_image with (the most important) macros expanded",
     "name": "icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Service id",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is currently in its check period (0/1)",
     "name": "in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is currently in its notification period (0/1)",
     "name": "in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The initial state of the service",
     "name": "initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a service check currently running... (0/1)",
     "name": "is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is flapping (0/1)",
     "name": "is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last check (Unix timestamp)",
     "name": "last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last hard state of the service",
     "name": "last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last hard state change (Unix timestamp)",
     "name": "last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last notification (Unix timestamp)",
     "name": "last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last state of the service",
     "name": "last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last state change (Unix timestamp)",
     "name": "last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was CRITICAL (Unix timestamp)",
     "name": "last_time_critical",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was OK (Unix timestamp)",
     "name": "last_time_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was UNKNOWN (Unix timestamp)",
     "name": "last_time_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was in WARNING state (Unix timestamp)",
     "name": "last_time_warning",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this service (Unix timestamp)",
     "name": "last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Unabbreviated output of the last check plugin",
     "name": "long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The maximum number of check attempts",
     "name": "max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The scheduled time of the next check (Unix timestamp)",
     "name": "next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the next notification (Unix timestamp)",
     "name": "next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes about the service",
     "name": "notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The notes with (the most important) macros expanded",
     "name": "notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL for additional notes about the service",
     "name": "notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The notes_url with (the most important) macros expanded",
     "name": "notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the notification period of the service. It this is empty, service problems are always notified.",
     "name": "notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications are enabled for the service (0/1)",
     "name": "notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether 'obsess' is enabled for the service (0/1)",
     "name": "obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether 'obsess' is enabled for the service (0/1)",
     "name": "obsess_over_service",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all parent services",
     "name": "parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Performance data of the last check plugin",
     "name": "perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last check plugin",
     "name": "plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this service (0/1)",
     "name": "pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled for the service (0/1)",
     "name": "process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of scheduled downtimes the service is currently in",
     "name": "scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL to custom notes or actions on the service group",
     "name": "servicegroup_action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alias of the service group",
     "name": "servicegroup_alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Servicegroup id",
     "name": "servicegroup_id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all members of the service group as host/service pairs",
     "name": "servicegroup_members",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all members of the service group with state and has_been_checked",
     "name": "servicegroup_members_with_state",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The name of the service group",
     "name": "servicegroup_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Optional additional notes about the service group",
     "name": "servicegroup_notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL to further notes on the service group",
     "name": "servicegroup_notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The total number of services in the group",
     "name": "servicegroup_num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are CRIT",
     "name": "servicegroup_num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are CRIT",
     "name": "servicegroup_num_services_hard_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are OK",
     "name": "servicegroup_num_services_hard_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are UNKNOWN",
     "name": "servicegroup_num_services_hard_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are WARN",
     "name": "servicegroup_num_services_hard_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are OK",
     "name": "servicegroup_num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are PENDING",
     "name": "servicegroup_num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are UNKNOWN",
     "name": "servicegroup_num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of services in the group that are WARN",
     "name": "servicegroup_num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst soft state of all of the groups services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "servicegroup_worst_service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this service (0/1)",
     "name": "should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The staleness indicator for this service",
     "name": "staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the service (0: OK, 1: WARN, 2: CRITICAL, 3: UNKNOWN)",
     "name": "state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the current state (0: soft, 1: hard)",
     "name": "state_type",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/servicesbyhostgroup": {
  "GET": {
   "columns": [
    {
     "description": "Whether the service accepts passive checks (0/1)",
     "name": "accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current service problem has been acknowledged (0/1)",
     "name": "acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the acknowledgement (0: none, 1: normal, 2: sticky)",
     "name": "acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL for actions or custom information about the service",
     "name": "action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The action_url with (the most important) macros expanded",
     "name": "action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the service (0/1)",
     "name": "active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Naemon command used for active checks",
     "name": "check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the service",
     "name": "check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0/1)",
     "name": "check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the check period of the service. It this is empty, the service is always checked.",
     "name": "check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The type of the last check (0: active, 1: passive)",
     "name": "check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the service (0/1)",
     "name": "checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all comment ids of the service",
     "name": "comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the service with id, author, comment, entry_type, expires and expire_time",
     "name": "comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this service is in",
     "name": "contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of the service, either direct or via a contact group",
     "name": "contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The number of the current check attempt",
     "name": "current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the current notification",
     "name": "current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables of the service",
     "name": "custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of all custom variable of the service",
     "name": "custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to execute",
     "name": "depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to execute including information: host_name, service_description, failure_options, dependency_period and inherits_parent",
     "name": "depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to notify",
     "name": "depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to notify including information: host_name, service_description, failure_options, dependency_period and inherits_parent",
     "name": "depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Description of the service (also used as key)",
     "name": "description",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional display name",
     "name": "display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all downtime ids of the service",
     "name": "downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the service with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether and event handler is activated for the service (0/1)",
     "name": "event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the service check needed for execution",
     "name": "execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled for the service (0/1)",
     "name": "flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all service groups the service is in",
     "name": "groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether the service already has been checked (0/1)",
     "name": "has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether passive host checks are accepted (0/1)",
     "name": "host_accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current host problem has been acknowledged (0/1)",
     "name": "host_acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of acknowledgement (0: none, 1: normal, 2: stick)",
     "name": "host_acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL to custom actions or information about this host",
     "name": "host_action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as action_url, but with the most important macros expanded",
     "name": "host_action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the host (0/1)",
     "name": "host_active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "IP address",
     "name": "host_address",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alias name for the host",
     "name": "host_alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Naemon command for active host check of this host",
     "name": "host_check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether to check to send a recovery notification when flapping stops (0/1)",
     "name": "host_check_flapping_recovery_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "host_check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the host",
     "name": "host_check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0-2)",
     "name": "host_check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which this host will be checked. If empty then the host will always be checked.",
     "name": "host_check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "host_check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Type of check (0: active, 1: passive)",
     "name": "host_check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether checks of the host are enabled (0/1)",
     "name": "host_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct children of the host",
     "name": "host_childs",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the ids of all comments of this host",
     "name": "host_comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the host with id, author, comment, entry_type, expires and expire_time",
     "name": "host_comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this host is in",
     "name": "host_contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of this host, either direct or via a contact group",
     "name": "host_contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Number of the current check attempts",
     "name": "host_current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of the current notification",
     "name": "host_current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables",
     "name": "host_custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of the custom variables",
     "name": "host_custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "host_custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute",
     "name": "host_depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "host_depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify",
     "name": "host_depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "host_depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Optional display name of the host",
     "name": "host_display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of the ids of all scheduled downtimes of this host",
     "name": "host_downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the host with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "host_downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "host_event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether event handling is enabled (0/1)",
     "name": "host_event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the host check needed for execution",
     "name": "host_execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The value of the custom variable FILENAME",
     "name": "host_filename",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "host_first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled (0/1)",
     "name": "host_flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all host groups this host is in",
     "name": "host_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The effective hard state of the host (eliminates a problem in hard_state)",
     "name": "host_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host has already been checked (0/1)",
     "name": "host_has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "host_high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "host_hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image file to be used in the web pages",
     "name": "host_icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Alternative text for the icon_image",
     "name": "host_icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as icon_image, but with the most important macros expanded",
     "name": "host_icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Host id",
     "name": "host_id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its check period (0/1)",
     "name": "host_in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its notification period (0/1)",
     "name": "host_in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Initial host state",
     "name": "host_initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a host check currently running... (0/1)",
     "name": "host_is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host state is flapping (0/1)",
     "name": "host_is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last check (Unix timestamp)",
     "name": "host_last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Last hard state",
     "name": "host_last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last hard state change (Unix timestamp)",
     "name": "host_last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last notification (Unix timestamp)",
     "name": "host_last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "State before last state change",
     "name": "host_last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last state change - soft or hard (Unix timestamp)",
     "name": "host_last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was DOWN (Unix timestamp)",
     "name": "host_last_time_down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UNREACHABLE (Unix timestamp)",
     "name": "host_last_time_unreachable",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UP (Unix timestamp)",
     "name": "host_last_time_up",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this host (Unix timestamp)",
     "name": "host_last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "host_latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Complete output from check plugin",
     "name": "host_long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "host_low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Max check attempts for active host checks",
     "name": "host_max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "host_modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "host_modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Host name",
     "name": "host_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Scheduled time for the next check (Unix timestamp)",
     "name": "host_next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the next notification (Unix timestamp)",
     "name": "host_next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "host_no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes for this host",
     "name": "host_notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as notes, but with the most important macros expanded",
     "name": "host_notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL with further information about the host",
     "name": "host_notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Same as notes_url, but with the most important macros expanded",
     "name": "host_notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "host_notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which problems of this host will be notified. If empty then notification will be always",
     "name": "host_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications of the host are enabled (0/1)",
     "name": "host_notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "host_notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "host_num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state CRIT",
     "name": "host_num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state CRIT",
     "name": "host_num_services_hard_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state OK",
     "name": "host_num_services_hard_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state UNKNOWN",
     "name": "host_num_services_hard_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state WARN",
     "name": "host_num_services_hard_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state OK",
     "name": "host_num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services which have not been checked yet (pending)",
     "name": "host_num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state UNKNOWN",
     "name": "host_num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state WARN",
     "name": "host_num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "host_obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "host_obsess_over_host",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct parents of the host",
     "name": "host_parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether a flex downtime is pending (0/1)",
     "name": "host_pending_flex_downtime",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "host_percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional performance data of the last host check",
     "name": "host_perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last host check",
     "name": "host_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this host (0/1)",
     "name": "host_pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled (0/1)",
     "name": "host_process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "host_retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of downtimes this host is currently in",
     "name": "host_scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all services of the host",
     "name": "host_services",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services including detailed information about each service",
     "name": "host_services_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services of the host together with state and has_been_checked",
     "name": "host_services_with_state",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this host (0/1)",
     "name": "host_should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Staleness indicator for this host",
     "name": "host_staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the host (0: up, 1: down, 2: unreachable)",
     "name": "host_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of the current state (0: soft, 1: hard)",
     "name": "host_state_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of in image file for the status map",
     "name": "host_statusmap_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "host_total_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst hard state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "host_worst_service_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst soft state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "host_worst_service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: X",
     "name": "host_x_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Y",
     "name": "host_y_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Z",
     "name": "host_z_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL to custom actions or information about the hostgroup",
     "name": "hostgroup_action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alias of the hostgroup",
     "name": "hostgroup_alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Hostgroup id",
     "name": "hostgroup_id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all host names that are members of the hostgroup",
     "name": "hostgroup_members",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all host names that are members of the hostgroup together with state and has_been_checked",
     "name": "hostgroup_members_with_state",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Name of the hostgroup",
     "name": "hostgroup_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Optional notes to the hostgroup",
     "name": "hostgroup_notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL with further information about the hostgroup",
     "name": "hostgroup_notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The total number of hosts in the group",
     "name": "hostgroup_num_hosts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of hosts in the group that are down",
     "name": "hostgroup_num_hosts_down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of hosts in the group that are pending",
     "name": "hostgroup_num_hosts_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of hosts in the group that are unreachable",
     "name": "hostgroup_num_hosts_unreach",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of hosts in the group that are up",
     "name": "hostgroup_num_hosts_up",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services of hosts in this group",
     "name": "hostgroup_num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state CRIT of hosts in this group",
     "name": "hostgroup_num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state CRIT of hosts in this group",
     "name": "hostgroup_num_services_hard_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state OK of hosts in this group",
     "name": "hostgroup_num_services_hard_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state UNKNOWN of hosts in this group",
     "name": "hostgroup_num_services_hard_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state WARN of hosts in this group",
     "name": "hostgroup_num_services_hard_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state OK of hosts in this group",
     "name": "hostgroup_num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state Pending of hosts in this group",
     "name": "hostgroup_num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state UNKNOWN of hosts in this group",
     "name": "hostgroup_num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state WARN of hosts in this group",
     "name": "hostgroup_num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst state of all of the groups' hosts (UP <= UNREACHABLE <= DOWN)",
     "name": "hostgroup_worst_host_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst state of all services that belong to a host of this group (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "hostgroup_worst_service_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst state of all services that belong to a host of this group (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "hostgroup_worst_service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image to be used as icon in the web interface",
     "name": "icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alternative text for the icon_image for browsers not displaying icons",
     "name": "icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The icon_image with (the most important) macros expanded",
     "name": "icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Service id",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is currently in its check period (0/1)",
     "name": "in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is currently in its notification period (0/1)",
     "name": "in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The initial state of the service",
     "name": "initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a service check currently running... (0/1)",
     "name": "is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is flapping (0/1)",
     "name": "is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last check (Unix timestamp)",
     "name": "last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last hard state of the service",
     "name": "last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last hard state change (Unix timestamp)",
     "name": "last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last notification (Unix timestamp)",
     "name": "last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last state of the service",
     "name": "last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last state change (Unix timestamp)",
     "name": "last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was CRITICAL (Unix timestamp)",
     "name": "last_time_critical",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was OK (Unix timestamp)",
     "name": "last_time_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was UNKNOWN (Unix timestamp)",
     "name": "last_time_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was in WARNING state (Unix timestamp)",
     "name": "last_time_warning",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this service (Unix timestamp)",
     "name": "last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Unabbreviated output of the last check plugin",
     "name": "long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The maximum number of check attempts",
     "name": "max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The scheduled time of the next check (Unix timestamp)",
     "name": "next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the next notification (Unix timestamp)",
     "name": "next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes about the service",
     "name": "notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The notes with (the most important) macros expanded",
     "name": "notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL for additional notes about the service",
     "name": "notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The notes_url with (the most important) macros expanded",
     "name": "notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the notification period of the service. It this is empty, service problems are always notified.",
     "name": "notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications are enabled for the service (0/1)",
     "name": "notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether 'obsess' is enabled for the service (0/1)",
     "name": "obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether 'obsess' is enabled for the service (0/1)",
     "name": "obsess_over_service",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all parent services",
     "name": "parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Performance data of the last check plugin",
     "name": "perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last check plugin",
     "name": "plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this service (0/1)",
     "name": "pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled for the service (0/1)",
     "name": "process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of scheduled downtimes the service is currently in",
     "name": "scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this service (0/1)",
     "name": "should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The staleness indicator for this service",
     "name": "staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the service (0: OK, 1: WARN, 2: CRITICAL, 3: UNKNOWN)",
     "name": "state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the current state (0: soft, 1: hard)",
     "name": "state_type",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/servicesbyhostgroup/<hostgroup>": {
  "GET": {
   "columns": [
    {
     "description": "Whether the service accepts passive checks (0/1)",
     "name": "accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current service problem has been acknowledged (0/1)",
     "name": "acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the acknowledgement (0: none, 1: normal, 2: sticky)",
     "name": "acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL for actions or custom information about the service",
     "name": "action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The action_url with (the most important) macros expanded",
     "name": "action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the service (0/1)",
     "name": "active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Naemon command used for active checks",
     "name": "check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the service",
     "name": "check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0/1)",
     "name": "check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the check period of the service. It this is empty, the service is always checked.",
     "name": "check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The type of the last check (0: active, 1: passive)",
     "name": "check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the service (0/1)",
     "name": "checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all comment ids of the service",
     "name": "comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the service with id, author, comment, entry_type, expires and expire_time",
     "name": "comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this service is in",
     "name": "contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of the service, either direct or via a contact group",
     "name": "contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The number of the current check attempt",
     "name": "current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the current notification",
     "name": "current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables of the service",
     "name": "custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of all custom variable of the service",
     "name": "custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to execute",
     "name": "depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to execute including information: host_name, service_description, failure_options, dependency_period and inherits_parent",
     "name": "depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to notify",
     "name": "depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services this service depends on to notify including information: host_name, service_description, failure_options, dependency_period and inherits_parent",
     "name": "depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Description of the service (also used as key)",
     "name": "description",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional display name",
     "name": "display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all downtime ids of the service",
     "name": "downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the service with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether and event handler is activated for the service (0/1)",
     "name": "event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the service check needed for execution",
     "name": "execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled for the service (0/1)",
     "name": "flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all service groups the service is in",
     "name": "groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether the service already has been checked (0/1)",
     "name": "has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether passive host checks are accepted (0/1)",
     "name": "host_accept_passive_checks",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the current host problem has been acknowledged (0/1)",
     "name": "host_acknowledged",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of acknowledgement (0: none, 1: normal, 2: stick)",
     "name": "host_acknowledgement_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL to custom actions or information about this host",
     "name": "host_action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as action_url, but with the most important macros expanded",
     "name": "host_action_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether active checks are enabled for the host (0/1)",
     "name": "host_active_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "IP address",
     "name": "host_address",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alias name for the host",
     "name": "host_alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Naemon command for active host check of this host",
     "name": "host_check_command",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether to check to send a recovery notification when flapping stops (0/1)",
     "name": "host_check_flapping_recovery_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether freshness checks are activated (0/1)",
     "name": "host_check_freshness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between two scheduled checks of the host",
     "name": "host_check_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current check option, forced, normal, freshness... (0-2)",
     "name": "host_check_options",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which this host will be checked. If empty then the host will always be checked.",
     "name": "host_check_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The source of the check",
     "name": "host_check_source",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Type of check (0: active, 1: passive)",
     "name": "host_check_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether checks of the host are enabled (0/1)",
     "name": "host_checks_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct children of the host",
     "name": "host_childs",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the ids of all comments of this host",
     "name": "host_comments",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all comments of the host with id, author, comment, entry_type, expires and expire_time",
     "name": "host_comments_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contact groups this host is in",
     "name": "host_contact_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all contacts of this host, either direct or via a contact group",
     "name": "host_contacts",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Number of the current check attempts",
     "name": "host_current_attempt",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of the current notification",
     "name": "host_current_notification_number",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of the names of all custom variables",
     "name": "host_custom_variable_names",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of the values of the custom variables",
     "name": "host_custom_variable_values",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A dictionary of the custom variables",
     "name": "host_custom_variables",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute",
     "name": "host_depends_exec",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to execute including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "host_depends_exec_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify",
     "name": "host_depends_notify",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all hosts this hosts depends on to notify including information: host_name, failure_options, dependency_period and inherits_parent",
     "name": "host_depends_notify_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Optional display name of the host",
     "name": "host_display_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "A list of the ids of all scheduled downtimes of this host",
     "name": "host_downtimes",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all downtimes of the host with id, author, comment, start_time, end_time, fixed, duration and triggered_by",
     "name": "host_downtimes_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Naemon command used as event handler",
     "name": "host_event_handler",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether event handling is enabled (0/1)",
     "name": "host_event_handler_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time the host check needed for execution",
     "name": "host_execution_time",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The value of the custom variable FILENAME",
     "name": "host_filename",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Delay before the first notification",
     "name": "host_first_notification_delay",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether flap detection is enabled (0/1)",
     "name": "host_flap_detection_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all host groups this host is in",
     "name": "host_groups",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The effective hard state of the host (eliminates a problem in hard_state)",
     "name": "host_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host has already been checked (0/1)",
     "name": "host_has_been_checked",
     "type": "number",
     "unit": ""
    },
    {
     "description": "High threshold of flap detection",
     "name": "host_high_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "host_hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image file to be used in the web pages",
     "name": "host_icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Alternative text for the icon_image",
     "name": "host_icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as icon_image, but with the most important macros expanded",
     "name": "host_icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Host id",
     "name": "host_id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its check period (0/1)",
     "name": "host_in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether this host is currently in its notification period (0/1)",
     "name": "host_in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Initial host state",
     "name": "host_initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a host check currently running... (0/1)",
     "name": "host_is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the host state is flapping (0/1)",
     "name": "host_is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last check (Unix timestamp)",
     "name": "host_last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Last hard state",
     "name": "host_last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last hard state change (Unix timestamp)",
     "name": "host_last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last notification (Unix timestamp)",
     "name": "host_last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "State before last state change",
     "name": "host_last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last state change - soft or hard (Unix timestamp)",
     "name": "host_last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was DOWN (Unix timestamp)",
     "name": "host_last_time_down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UNREACHABLE (Unix timestamp)",
     "name": "host_last_time_unreachable",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the host was UP (Unix timestamp)",
     "name": "host_last_time_up",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this host (Unix timestamp)",
     "name": "host_last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "host_latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Complete output from check plugin",
     "name": "host_long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "host_low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Max check attempts for active host checks",
     "name": "host_max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "host_modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "host_modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Host name",
     "name": "host_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Scheduled time for the next check (Unix timestamp)",
     "name": "host_next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the next notification (Unix timestamp)",
     "name": "host_next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "host_no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes for this host",
     "name": "host_notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The same as notes, but with the most important macros expanded",
     "name": "host_notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL with further information about the host",
     "name": "host_notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Same as notes_url, but with the most important macros expanded",
     "name": "host_notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "host_notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time period in which problems of this host will be notified. If empty then notification will be always",
     "name": "host_notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications of the host are enabled (0/1)",
     "name": "host_notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "host_notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "host_num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state CRIT",
     "name": "host_num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state CRIT",
     "name": "host_num_services_hard_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state OK",
     "name": "host_num_services_hard_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state UNKNOWN",
     "name": "host_num_services_hard_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the hard state WARN",
     "name": "host_num_services_hard_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state OK",
     "name": "host_num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services which have not been checked yet (pending)",
     "name": "host_num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state UNKNOWN",
     "name": "host_num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of the host's services with the soft state WARN",
     "name": "host_num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "host_obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current obsess setting... (0/1)",
     "name": "host_obsess_over_host",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all direct parents of the host",
     "name": "host_parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether a flex downtime is pending (0/1)",
     "name": "host_pending_flex_downtime",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "host_percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional performance data of the last host check",
     "name": "host_perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last host check",
     "name": "host_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this host (0/1)",
     "name": "host_pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled (0/1)",
     "name": "host_process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "host_retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of downtimes this host is currently in",
     "name": "host_scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all services of the host",
     "name": "host_services",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services including detailed information about each service",
     "name": "host_services_with_info",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all services of the host together with state and has_been_checked",
     "name": "host_services_with_state",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this host (0/1)",
     "name": "host_should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Staleness indicator for this host",
     "name": "host_staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the host (0: up, 1: down, 2: unreachable)",
     "name": "host_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Type of the current state (0: soft, 1: hard)",
     "name": "host_state_type",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of in image file for the status map",
     "name": "host_statusmap_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The total number of services of the host",
     "name": "host_total_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst hard state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "host_worst_service_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst soft state of all of the host's services (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "host_worst_service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: X",
     "name": "host_x_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Y",
     "name": "host_y_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "3D-Coordinates: Z",
     "name": "host_z_3d",
     "type": "number",
     "unit": ""
    },
    {
     "description": "An optional URL to custom actions or information about the hostgroup",
     "name": "hostgroup_action_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alias of the hostgroup",
     "name": "hostgroup_alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Hostgroup id",
     "name": "hostgroup_id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all host names that are members of the hostgroup",
     "name": "hostgroup_members",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "A list of all host names that are members of the hostgroup together with state and has_been_checked",
     "name": "hostgroup_members_with_state",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Name of the hostgroup",
     "name": "hostgroup_name",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Optional notes to the hostgroup",
     "name": "hostgroup_notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL with further information about the hostgroup",
     "name": "hostgroup_notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The total number of hosts in the group",
     "name": "hostgroup_num_hosts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of hosts in the group that are down",
     "name": "hostgroup_num_hosts_down",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of hosts in the group that are pending",
     "name": "hostgroup_num_hosts_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of hosts in the group that are unreachable",
     "name": "hostgroup_num_hosts_unreach",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of hosts in the group that are up",
     "name": "hostgroup_num_hosts_up",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services of hosts in this group",
     "name": "hostgroup_num_services",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state CRIT of hosts in this group",
     "name": "hostgroup_num_services_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state CRIT of hosts in this group",
     "name": "hostgroup_num_services_hard_crit",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state OK of hosts in this group",
     "name": "hostgroup_num_services_hard_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state UNKNOWN of hosts in this group",
     "name": "hostgroup_num_services_hard_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state WARN of hosts in this group",
     "name": "hostgroup_num_services_hard_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state OK of hosts in this group",
     "name": "hostgroup_num_services_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state Pending of hosts in this group",
     "name": "hostgroup_num_services_pending",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state UNKNOWN of hosts in this group",
     "name": "hostgroup_num_services_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The total number of services with the state WARN of hosts in this group",
     "name": "hostgroup_num_services_warn",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst state of all of the groups' hosts (UP <= UNREACHABLE <= DOWN)",
     "name": "hostgroup_worst_host_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst state of all services that belong to a host of this group (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "hostgroup_worst_service_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The worst state of all services that belong to a host of this group (OK <= WARN <= UNKNOWN <= CRIT)",
     "name": "hostgroup_worst_service_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Hourly Value",
     "name": "hourly_value",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of an image to be used as icon in the web interface",
     "name": "icon_image",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An alternative text for the icon_image for browsers not displaying icons",
     "name": "icon_image_alt",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The icon_image with (the most important) macros expanded",
     "name": "icon_image_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Service id",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is currently in its check period (0/1)",
     "name": "in_check_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is currently in its notification period (0/1)",
     "name": "in_notification_period",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The initial state of the service",
     "name": "initial_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "is there a service check currently running... (0/1)",
     "name": "is_executing",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether the service is flapping (0/1)",
     "name": "is_flapping",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last check (Unix timestamp)",
     "name": "last_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last hard state of the service",
     "name": "last_hard_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last hard state change (Unix timestamp)",
     "name": "last_hard_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last notification (Unix timestamp)",
     "name": "last_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last state of the service",
     "name": "last_state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the last state change (Unix timestamp)",
     "name": "last_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was CRITICAL (Unix timestamp)",
     "name": "last_time_critical",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was OK (Unix timestamp)",
     "name": "last_time_ok",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was UNKNOWN (Unix timestamp)",
     "name": "last_time_unknown",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The last time the service was in WARNING state (Unix timestamp)",
     "name": "last_time_warning",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time of the last update of this service (Unix timestamp)",
     "name": "last_update",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Time difference between scheduled check time and actual check time",
     "name": "latency",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Unabbreviated output of the last check plugin",
     "name": "long_plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Low threshold of flap detection",
     "name": "low_flap_threshold",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The maximum number of check attempts",
     "name": "max_check_attempts",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A bitmask specifying which attributes have been modified",
     "name": "modified_attributes",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all modified attributes",
     "name": "modified_attributes_list",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "The scheduled time of the next check (Unix timestamp)",
     "name": "next_check",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The time of the next notification (Unix timestamp)",
     "name": "next_notification",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether to stop sending notifications (0/1)",
     "name": "no_more_notifications",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Optional notes about the service",
     "name": "notes",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The notes with (the most important) macros expanded",
     "name": "notes_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "An optional URL for additional notes about the service",
     "name": "notes_url",
     "type": "string",
     "unit": ""
    },
    {
     "description": "The notes_url with (the most important) macros expanded",
     "name": "notes_url_expanded",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Interval of periodic notification or 0 if its off",
     "name": "notification_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the notification period of the service. It this is empty, service problems are always notified.",
     "name": "notification_period",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether notifications are enabled for the service (0/1)",
     "name": "notifications_enabled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Flags determining which states have been notified on",
     "name": "notified_on",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether 'obsess' is enabled for the service (0/1)",
     "name": "obsess",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether 'obsess' is enabled for the service (0/1)",
     "name": "obsess_over_service",
     "type": "number",
     "unit": ""
    },
    {
     "description": "A list of all parent services",
     "name": "parents",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Percent state change",
     "name": "percent_state_change",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Performance data of the last check plugin",
     "name": "perf_data",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Output of the last check plugin",
     "name": "plugin_output",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Whether there is a PNP4Nagios graph present for this service (0/1)",
     "name": "pnpgraph_present",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether processing of performance data is enabled for the service (0/1)",
     "name": "process_performance_data",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Number of basic interval lengths between checks when retrying after a soft error",
     "name": "retry_interval",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The number of scheduled downtimes the service is currently in",
     "name": "scheduled_downtime_depth",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether naemon still tries to run checks on this service (0/1)",
     "name": "should_be_scheduled",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The staleness indicator for this service",
     "name": "staleness",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The current state of the service (0: OK, 1: WARN, 2: CRITICAL, 3: UNKNOWN)",
     "name": "state",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The type of the current state (0: soft, 1: hard)",
     "name": "state_type",
     "type": "number",
     "unit": ""
    }
   ]
  }
 },
 "/timeperiods": {
  "GET": {
   "columns": [
    {
     "description": "The alias of the timeperiod",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Time per days, as 7 lists (sun-sat) of a list of even number of elements, representing start,stop,start,stop... in seconds since midnight",
     "name": "days",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "List of objects representing exceptions for DATERANGE_CALENDAR_DATE. For time ranges, see \"days\" column.",
     "name": "exceptions_calendar_dates",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "List of objects representing exceptions for DATERANGE_MONTH_DATE. For time ranges, see \"days\" column.",
     "name": "exceptions_month_date",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "List of objects representing exceptions for DATERANGE_MONTH_DAY. For time ranges, see \"days\" column.",
     "name": "exceptions_month_day",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "List of objects representing exceptions for DATERANGE_MONTH_WEEK_DAY. For time ranges, see \"days\" column.",
     "name": "exceptions_month_week_day",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "List of objects representing exceptions for DATERANGE_WEEK_DAY. For time ranges, see \"days\" column.",
     "name": "exceptions_week_day",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Exclusions for this timeperiod",
     "name": "exclusions",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Timeperiod id",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether we are currently in this period (0/1)",
     "name": "in",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the timeperiod",
     "name": "name",
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
     "description": "The alias of the timeperiod",
     "name": "alias",
     "type": "string",
     "unit": ""
    },
    {
     "description": "Time per days, as 7 lists (sun-sat) of a list of even number of elements, representing start,stop,start,stop... in seconds since midnight",
     "name": "days",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "List of objects representing exceptions for DATERANGE_CALENDAR_DATE. For time ranges, see \"days\" column.",
     "name": "exceptions_calendar_dates",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "List of objects representing exceptions for DATERANGE_MONTH_DATE. For time ranges, see \"days\" column.",
     "name": "exceptions_month_date",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "List of objects representing exceptions for DATERANGE_MONTH_DAY. For time ranges, see \"days\" column.",
     "name": "exceptions_month_day",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "List of objects representing exceptions for DATERANGE_MONTH_WEEK_DAY. For time ranges, see \"days\" column.",
     "name": "exceptions_month_week_day",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "List of objects representing exceptions for DATERANGE_WEEK_DAY. For time ranges, see \"days\" column.",
     "name": "exceptions_week_day",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Exclusions for this timeperiod",
     "name": "exclusions",
     "type": "array_of_strings",
     "unit": ""
    },
    {
     "description": "Timeperiod id",
     "name": "id",
     "type": "number",
     "unit": ""
    },
    {
     "description": "Whether we are currently in this period (0/1)",
     "name": "in",
     "type": "number",
     "unit": ""
    },
    {
     "description": "The name of the timeperiod",
     "name": "name",
     "type": "string",
     "unit": ""
    }
   ]
  }
 }
}

---
title: REST API Endpoints
---

# REST API Endpoints

The Thruk REST API provides access to Thruk and Livestatus information.

For API details, see [REST API](rest.html).

<rest-filter></rest-filter>

<!--GENERATED-ENDPOINTS-->
### `GET /` {#get}

lists all available rest urls.
alias for `/index`

### `GET /alerts` {#get-alerts}

lists alerts based on logfiles.
alias for `/logs?type[~]=^(HOST|SERVICE) ALERT`

### `GET /checks/stats` {#get-checksstats}

lists host / service check statistics.

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `hosts_active_15_perc` | number | % | percent of active hosts during the last 15 minutes |
| `hosts_active_15_sum` | number |  | amount of active hosts during the last 15 minutes |
| `hosts_active_1_perc` | number | % | same for last minute |
| `hosts_active_1_sum` | number |  | same for last minute |
| `hosts_active_5_perc` | number | % | same for last 5 minutes |
| `hosts_active_5_sum` | number |  | same for last 5 minutes |
| `hosts_active_60_perc` | number | % | same for last 60 minutes |
| `hosts_active_60_sum` | number |  | same for last 60 minutes |
| `hosts_active_all_perc` | number | % | percent of total active hosts |
| `hosts_active_all_sum` | number |  | amount of total active hosts |
| `hosts_active_state_change_avg` | number | % | average percent state change |
| `hosts_active_state_change_max` | number | % | maximum state change over all active hosts |
| `hosts_active_state_change_min` | number | % | minimum state change over all active hosts |
| `hosts_active_state_change_sum` | number | % | sum state change over all hosts |
| `hosts_active_sum` | number |  | number of active hosts |
| `hosts_execution_time_avg` | number | s | average execution time over all hosts |
| `hosts_execution_time_max` | number | s | maximum execution time over all hosts |
| `hosts_execution_time_min` | number | s | minimum execution time over all hosts |
| `hosts_execution_time_sum` | number | s | sum execution time over all hosts |
| `hosts_latency_avg` | number |  | host latency average |
| `hosts_latency_max` | number |  | minimum host latency |
| `hosts_latency_min` | number |  | minimum host latency |
| `hosts_latency_sum` | number |  | sum latency over all hosts |
| `hosts_passive_15_perc` | number | % | percent of passive hosts during the last 15 minutes |
| `hosts_passive_15_sum` | number |  | amount of passive hosts during the last 15 minutes |
| `hosts_passive_1_perc` | number | % | same for last minute |
| `hosts_passive_1_sum` | number |  | same for last minute |
| `hosts_passive_5_perc` | number | % | same for last 5 minutes |
| `hosts_passive_5_sum` | number |  | same for last 5 minutes |
| `hosts_passive_60_perc` | number | % | same for last 60 minutes |
| `hosts_passive_60_sum` | number |  | same for last 60 minutes |
| `hosts_passive_all_perc` | number | % | percent of total passive hosts |
| `hosts_passive_all_sum` | number |  | amount of total passive hosts |
| `hosts_passive_state_change_avg` | number | % | average percent state change for passive hosts |
| `hosts_passive_state_change_max` | number | % | maximum state change over all passive hosts |
| `hosts_passive_state_change_min` | number | % | minimum state change over all passive hosts |
| `hosts_passive_state_change_sum` | number | % | sum state change over all passive hosts |
| `hosts_passive_sum` | number |  | number of passive hosts |
| `services_active_15_perc` | number | % | percent of active services during the last 15 minutes |
| `services_active_15_sum` | number |  | amount of active services during the last 15 minutes |
| `services_active_1_perc` | number | % | same for last minute |
| `services_active_1_sum` | number |  | same for last minute |
| `services_active_5_perc` | number | % | same for last 5 minutes |
| `services_active_5_sum` | number |  | same for last 5 minutes |
| `services_active_60_perc` | number | % | same for last 60 minutes |
| `services_active_60_sum` | number |  | same for last 60 minutes |
| `services_active_all_perc` | number | % | percent of total active services |
| `services_active_all_sum` | number |  | amount of total active services |
| `services_active_state_change_avg` | number | % | average percent state change |
| `services_active_state_change_max` | number | % | maximum state change over all active services |
| `services_active_state_change_min` | number | % | minimum state change over all active services |
| `services_active_state_change_sum` | number | % | sum state change over all services |
| `services_active_sum` | number |  | number of active services |
| `services_execution_time_avg` | number | s | average execution time over all services |
| `services_execution_time_max` | number | s | maximum execution time over all services |
| `services_execution_time_min` | number | s | minimum execution time over all services |
| `services_execution_time_sum` | number | s | sum execution time over all services |
| `services_latency_avg` | number |  | services latency average |
| `services_latency_max` | number |  | minimum services latency |
| `services_latency_min` | number |  | minimum services latency |
| `services_latency_sum` | number |  | sum latency over all services |
| `services_passive_15_perc` | number | % | percent of passive services during the last 15 minutes |
| `services_passive_15_sum` | number |  | amount of passive services during the last 15 minutes |
| `services_passive_1_perc` | number | % | same for last minute |
| `services_passive_1_sum` | number |  | same for last minute |
| `services_passive_5_perc` | number | % | same for last 5 minutes |
| `services_passive_5_sum` | number |  | same for last 5 minutes |
| `services_passive_60_perc` | number | % | same for last 60 minutes |
| `services_passive_60_sum` | number |  | same for last 60 minutes |
| `services_passive_all_perc` | number | % | percent of total passive services |
| `services_passive_all_sum` | number |  | amount of total passive services |
| `services_passive_state_change_avg` | number | % | average percent state change for passive services |
| `services_passive_state_change_max` | number | % | maximum state change over all passive services |
| `services_passive_state_change_min` | number | % | minimum state change over all passive services |
| `services_passive_state_change_sum` | number | % | sum state change over all passive services |
| `services_passive_sum` | number |  | number of passive services |

### `POST /cmd` {#post-cmd}

Sends any command.

Required arguments:

  * cmd

Optional arguments:

  * host
  * hostgroup
  * service
  * servicegroup
  * contact
  * contactgroup

### `GET /commands` {#get-commands}

lists livestatus commands.
see https://www.naemon.io/documentation/usersguide/livestatus.html#commands for details.

### `GET /commands/<name>` {#get-commandsname}

lists commands for given name.
alias for `/commands?name=<name>`

### `GET /commands/<name>/config` {#get-commandsnameconfig}

Returns configuration for given command.
You will find available attributes here: https://www.naemon.io/documentation/usersguide/objectdefinitions.html#command

### `POST /commands/<name>/config` {#post-commandsnameconfig}

Replace command configuration completely, use PATCH to only update specific attributes.

### `PATCH /commands/<name>/config` {#patch-commandsnameconfig}

Update command configuration partially.

### `DELETE /commands/<name>/config` {#delete-commandsnameconfig}

Deletes given command from configuration.

### `GET /comments` {#get-comments}

lists livestatus comments.
see https://www.naemon.io/documentation/usersguide/livestatus.html#comments for details.

### `GET /comments/<id>` {#get-commentsid}

lists comments for given id.
alias for `/comments?id=<id>`

### `POST /config/check` {#post-configcheck}

Returns result from config check. This check does require changes to be saved to disk before running the check.

### `GET /config/diff` {#get-configdiff}


Optional arguments:

  * ignore_whitespace

Returns differences between filesystem and stashed config changes.

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `file` | string |  | file name of changed file |
| `output` | string |  | diff output |
| `peer_key` | string |  | id as defined in Thruk::Backend component configuration |

### `POST /config/discard` {#post-configdiscard}

Reverts stashed configuration changes.
Alias for /config/revert

### `GET /config/files` {#get-configfiles}

returns all config files

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `content` | string |  | raw file content |
| `hex` | string |  | hex sum for this file |
| `mtime` | time |  | unix timestamp of last modification |
| `path` | string |  | filesystem path |
| `peer_key` | string |  | id as defined in Thruk::Backend component configuration |
| `readonly` | boolean |  | readonly flag |

### `GET /config/fullobjects` {#get-configfullobjects}

Returns list of all objects with templates expanded.
Used templates are saved to the :TEMPLATES attribute

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `...` | string |  | object attributes like defined in the source config files |
| `:FILE` | string |  | filename and line number |
| `:ID` | string |  | internal uniq id |
| `:PEER_KEY` | string |  | id of remote site |
| `:PEER_NAME` | string |  | name of remote site |
| `:READONLY` | boolean |  | flag whether file is readonly |
| `:TEMPLATES` | array_of_strings |  | list of used template |
| `:TYPE` | string |  | object type, ex.: host |

### `GET /config/objects` {#get-configobjects}

Returns list of all objects with their raw config.
Use /config/fullobjects to get the full expanded config.

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `...` | string |  | object attributes like defined in the source config files |
| `:FILE` | string |  | filename and line number |
| `:ID` |  |  | internal uniq id |
| `:PEER_KEY` | string |  | id of remote site |
| `:PEER_NAME` | string |  | name of remote site |
| `:READONLY` | boolean |  | flag whether file is readonly |
| `:TYPE` | string |  | object type, ex.: host |

### `POST /config/objects` {#post-configobjects}

Create a new object. Besides the actual object configuration, this requires
2 special parameters, :FILE and :TYPE.

### `PATCH /config/objects` {#patch-configobjects}

Change attributes for all matching objects.
**CAUTION** Review the filters before submitting a bulk change.
This example changes all hosts with max_check_attempts=3 to max_check_attempts=5:

```sh
  thruk r -m PATCH -d max_check_attempts=5 '/config/objects?:TYPE=host&max_check_attempts=3'
```

### `DELETE /config/objects` {#delete-configobjects}

Delete objects based on filters.
**CAUTION:** A broad filter can select all objects. Confirm the filters before deleting.
Requests without query parameters are rejected.
This example removes all contacts matching a name:

```sh
  thruk r -m DELETE '/config/objects?contact_name=test'
```

### `POST /config/objects/<id>` {#post-configobjectsid}

Replace object configuration completely.

### `PATCH /config/objects/<id>` {#patch-configobjectsid}

Update object configuration partially.

### `DELETE /config/objects/<id>` {#delete-configobjectsid}

Remove given object from configuration.

### `GET /config/precheck` {#get-configprecheck}

Returns result from Thruks config precheck. The precheck does not require changes to be saved to disk before running the check.

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `errors` | array_of_strings |  | list of errors encountered |
| `failed` | boolean |  | boolean flag whether configuration check has failed or not |
| `peer_key` | string |  | id as defined in Thruk::Backend component configuration |

### `POST /config/reload` {#post-configreload}

Reloads configuration with the configured reload command.

### `POST /config/revert` {#post-configrevert}

Reverts stashed configuration changes.

### `POST /config/save` {#post-configsave}

Saves stashed configuration changes to disk.

### `GET /contactgroups` {#get-contactgroups}

lists livestatus contactgroups.
see https://www.naemon.io/documentation/usersguide/livestatus.html#contactgroups for details.

### `GET /contactgroups/<name>` {#get-contactgroupsname}

lists contactgroups for given name.
alias for `/contactgroups?name=<name>`

### `POST /contactgroups/<name>/cmd/...` {#post-contactgroupsnamecmd}

list of supported commands:

 - [disable_contactgroup_host_notifications](#post-contactgroupsnamecmddisable_contactgroup_host_notifications)
 - [disable_contactgroup_svc_notifications](#post-contactgroupsnamecmddisable_contactgroup_svc_notifications)
 - [enable_contactgroup_host_notifications](#post-contactgroupsnamecmdenable_contactgroup_host_notifications)
 - [enable_contactgroup_svc_notifications](#post-contactgroupsnamecmdenable_contactgroup_svc_notifications)

### `POST /contactgroups/<name>/cmd/disable_contactgroup_host_notifications` {#post-contactgroupsnamecmddisable_contactgroup_host_notifications}

Disables host notifications for all contacts in a particular contactgroup.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_contactgroup_host_notifications.html for details.

### `POST /contactgroups/<name>/cmd/disable_contactgroup_svc_notifications` {#post-contactgroupsnamecmddisable_contactgroup_svc_notifications}

Disables service notifications for all contacts in a particular contactgroup.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_contactgroup_svc_notifications.html for details.

### `POST /contactgroups/<name>/cmd/enable_contactgroup_host_notifications` {#post-contactgroupsnamecmdenable_contactgroup_host_notifications}

Enables host notifications for all contacts in a particular contactgroup.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_contactgroup_host_notifications.html for details.

### `POST /contactgroups/<name>/cmd/enable_contactgroup_svc_notifications` {#post-contactgroupsnamecmdenable_contactgroup_svc_notifications}

Enables service notifications for all contacts in a particular contactgroup.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_contactgroup_svc_notifications.html for details.

### `GET /contactgroups/<name>/config` {#get-contactgroupsnameconfig}

Returns configuration for given contactgroup.
You will find available attributes here: https://www.naemon.io/documentation/usersguide/objectdefinitions.html#contactgroup

### `POST /contactgroups/<name>/config` {#post-contactgroupsnameconfig}

Replace contactgroup configuration completely, use PATCH to only update specific attributes.

### `PATCH /contactgroups/<name>/config` {#patch-contactgroupsnameconfig}

Update contactgroup configuration partially.

### `DELETE /contactgroups/<name>/config` {#delete-contactgroupsnameconfig}

Deletes given contactgroup from configuration.

### `GET /contacts` {#get-contacts}

lists livestatus contacts.
see https://www.naemon.io/documentation/usersguide/livestatus.html#contacts for details.

Additional attributes added by Thruk:

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `in_host_notification_period` | boolean |  | Whether the contact is currently in its host notification period |
| `in_service_notification_period` | boolean |  | Whether the contact is currently in its service notification period |
| `modified_attributes_list` | array_of_strings |  | A list of all modified attributes |

### `GET /contacts/<name>` {#get-contactsname}

lists contacts for given name.
alias for `/contacts?name=<name>`

### `POST /contacts/<name>/cmd/...` {#post-contactsnamecmd}

list of supported commands:

 - [change_contact_host_notification_timeperiod](#post-contactsnamecmdchange_contact_host_notification_timeperiod)
 - [change_contact_svc_notification_timeperiod](#post-contactsnamecmdchange_contact_svc_notification_timeperiod)
 - [change_custom_contact_var](#post-contactsnamecmdchange_custom_contact_var)
 - [disable_contact_host_notifications](#post-contactsnamecmddisable_contact_host_notifications)
 - [disable_contact_svc_notifications](#post-contactsnamecmddisable_contact_svc_notifications)
 - [enable_contact_host_notifications](#post-contactsnamecmdenable_contact_host_notifications)
 - [enable_contact_svc_notifications](#post-contactsnamecmdenable_contact_svc_notifications)

### `POST /contacts/<name>/cmd/change_contact_host_notification_timeperiod` {#post-contactsnamecmdchange_contact_host_notification_timeperiod}

Changes the host notification timeperiod for a particular contact to what is specified by the 'notification_timeperiod' option. The 'notification_timeperiod' option should be the short name of the timeperiod that is to be used as the contact's host notification timeperiod. The timeperiod must have been configured in Naemon before it was last (re)started.

Required arguments:

  * timeperiod

See https://www.naemon.io/documentation/developer/externalcommands/change_contact_host_notification_timeperiod.html for details.

### `POST /contacts/<name>/cmd/change_contact_svc_notification_timeperiod` {#post-contactsnamecmdchange_contact_svc_notification_timeperiod}

Changes the service notification timeperiod for a particular contact to what is specified by the 'notification_timeperiod' option. The 'notification_timeperiod' option should be the short name of the timeperiod that is to be used as the contact's service notification timeperiod. The timeperiod must have been configured in Naemon before it was last (re)started.

Required arguments:

  * timeperiod

See https://www.naemon.io/documentation/developer/externalcommands/change_contact_svc_notification_timeperiod.html for details.

### `POST /contacts/<name>/cmd/change_custom_contact_var` {#post-contactsnamecmdchange_custom_contact_var}

Changes the value of a custom contact variable.

Required arguments:

  * name
  * value

See https://www.naemon.io/documentation/developer/externalcommands/change_custom_contact_var.html for details.

### `POST /contacts/<name>/cmd/disable_contact_host_notifications` {#post-contactsnamecmddisable_contact_host_notifications}

Disables host notifications for a particular contact.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_contact_host_notifications.html for details.

### `POST /contacts/<name>/cmd/disable_contact_svc_notifications` {#post-contactsnamecmddisable_contact_svc_notifications}

Disables service notifications for a particular contact.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_contact_svc_notifications.html for details.

### `POST /contacts/<name>/cmd/enable_contact_host_notifications` {#post-contactsnamecmdenable_contact_host_notifications}

Enables host notifications for a particular contact.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_contact_host_notifications.html for details.

### `POST /contacts/<name>/cmd/enable_contact_svc_notifications` {#post-contactsnamecmdenable_contact_svc_notifications}

Enables service notifications for a particular contact.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_contact_svc_notifications.html for details.

### `GET /contacts/<name>/config` {#get-contactsnameconfig}

Returns configuration for given contact.
You will find available attributes here: https://www.naemon.io/documentation/usersguide/objectdefinitions.html#contact

### `POST /contacts/<name>/config` {#post-contactsnameconfig}

Replace contact configuration completely, use PATCH to only update specific attributes.

### `PATCH /contacts/<name>/config` {#patch-contactsnameconfig}

Update contact configuration partially.

### `DELETE /contacts/<name>/config` {#delete-contactsnameconfig}

Deletes given contact from configuration.

### `GET /contacts/totals` {#get-contactstotals}

hash of livestatus contacts totals statistics.

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `total` | number |  | total number of contacts |

### `GET /downtimes` {#get-downtimes}

lists livestatus downtimes.
see https://www.naemon.io/documentation/usersguide/livestatus.html#downtimes for details.

### `GET /downtimes/<id>` {#get-downtimesid}

lists downtimes for given id.
alias for `/downtimes?id=<id>`

### `GET /hostgroups` {#get-hostgroups}

lists livestatus hostgroups.
see https://www.naemon.io/documentation/usersguide/livestatus.html#hostgroups for details.

Additional attributes added by Thruk:

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `num_services_hard_crit` | number |  | Number of services in hard CRITICAL state |
| `num_services_hard_ok` | number |  | Number of services in hard OK state |
| `num_services_hard_unknown` | number |  | Number of services in hard UNKNOWN state |
| `num_services_hard_warn` | number |  | Number of services in hard WARNING state |

### `GET /hostgroups/<name>` {#get-hostgroupsname}

lists hostgroups for given name.
alias for `/hostgroups?name=<name>`

### `GET /hostgroups/<name>/availability` {#get-hostgroupsnameavailability}

list availability for this hostgroup.

Optional arguments:

  * type              - both | hosts | services
  * timeperiod        - last24hours | lastmonth | thismonth | ...
  * start             - unix timestamp
  * end               - unix timestamp
  * withdowntimes     - 0/1 whether downtimes should count as outages
  * includesoftstates - 0/1 whether soft states should be used as well

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `host` | string |  | host name |
| `scheduled_time_down` | number | s | total seconds in state down (during downtimes) |
| `scheduled_time_down_percent` | number | % | time down in percent of total time (during downtimes) |
| `scheduled_time_indeterminate` | number | s | total seconds unknown (during downtimes) |
| `scheduled_time_indeterminate_percent` | number | % | time unknown in percent of total time (during downtimes) |
| `scheduled_time_unreachable` | number | s | total seconds in state unreachable (during downtimes) |
| `scheduled_time_unreachable_percent` | number | % | time unreachable in percent of total time (during downtimes) |
| `scheduled_time_up` | number | s | total seconds in state up (during downtimes) |
| `scheduled_time_up_percent` | number | % | time up in percent of total time (during downtimes) |
| `time_down` | number | s | total seconds in state down |
| `time_down_percent` | number | % | time down in percent of total time |
| `time_indeterminate_nodata` | number | s | total seconds without any data |
| `time_indeterminate_nodata_percent` | number | % | time without any data in percent of total time |
| `time_indeterminate_notrunning` | number | s | total seconds during core not running |
| `time_indeterminate_notrunning_percent` | number | % | time during core not running in percent of total time |
| `time_indeterminate_outside_timeperiod` | number | s | total seconds outside the given timeperiod |
| `time_indeterminate_outside_timeperiod_percent` | number | % | time outside the given timeperiod in percent of total time |
| `time_unreachable` | number | s | total seconds in state unreachable |
| `time_unreachable_percent` | number | % | time unreachable in percent of total time |
| `time_up` | number | s | total seconds in state up |
| `time_up_percent` | number | % | time up in percent of total time |

### `POST /hostgroups/<name>/cmd/...` {#post-hostgroupsnamecmd}

list of supported commands:

 - [disable_hostgroup_host_checks](#post-hostgroupsnamecmddisable_hostgroup_host_checks)
 - [disable_hostgroup_host_notifications](#post-hostgroupsnamecmddisable_hostgroup_host_notifications)
 - [disable_hostgroup_passive_host_checks](#post-hostgroupsnamecmddisable_hostgroup_passive_host_checks)
 - [disable_hostgroup_passive_svc_checks](#post-hostgroupsnamecmddisable_hostgroup_passive_svc_checks)
 - [disable_hostgroup_svc_checks](#post-hostgroupsnamecmddisable_hostgroup_svc_checks)
 - [disable_hostgroup_svc_notifications](#post-hostgroupsnamecmddisable_hostgroup_svc_notifications)
 - [enable_hostgroup_host_checks](#post-hostgroupsnamecmdenable_hostgroup_host_checks)
 - [enable_hostgroup_host_notifications](#post-hostgroupsnamecmdenable_hostgroup_host_notifications)
 - [enable_hostgroup_passive_host_checks](#post-hostgroupsnamecmdenable_hostgroup_passive_host_checks)
 - [enable_hostgroup_passive_svc_checks](#post-hostgroupsnamecmdenable_hostgroup_passive_svc_checks)
 - [enable_hostgroup_svc_checks](#post-hostgroupsnamecmdenable_hostgroup_svc_checks)
 - [enable_hostgroup_svc_notifications](#post-hostgroupsnamecmdenable_hostgroup_svc_notifications)
 - [schedule_hostgroup_host_downtime](#post-hostgroupsnamecmdschedule_hostgroup_host_downtime)
 - [schedule_hostgroup_svc_downtime](#post-hostgroupsnamecmdschedule_hostgroup_svc_downtime)

### `POST /hostgroups/<name>/cmd/disable_hostgroup_host_checks` {#post-hostgroupsnamecmddisable_hostgroup_host_checks}

Sends the DISABLE_HOSTGROUP_HOST_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_hostgroup_host_checks.html for details.

### `POST /hostgroups/<name>/cmd/disable_hostgroup_host_notifications` {#post-hostgroupsnamecmddisable_hostgroup_host_notifications}

Sends the DISABLE_HOSTGROUP_HOST_NOTIFICATIONS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_hostgroup_host_notifications.html for details.

### `POST /hostgroups/<name>/cmd/disable_hostgroup_passive_host_checks` {#post-hostgroupsnamecmddisable_hostgroup_passive_host_checks}

Disables passive checks for all hosts in a particular hostgroup.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_hostgroup_passive_host_checks.html for details.

### `POST /hostgroups/<name>/cmd/disable_hostgroup_passive_svc_checks` {#post-hostgroupsnamecmddisable_hostgroup_passive_svc_checks}

Disables passive checks for all services associated with hosts in a particular hostgroup.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_hostgroup_passive_svc_checks.html for details.

### `POST /hostgroups/<name>/cmd/disable_hostgroup_svc_checks` {#post-hostgroupsnamecmddisable_hostgroup_svc_checks}

Sends the DISABLE_HOSTGROUP_SVC_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_hostgroup_svc_checks.html for details.

### `POST /hostgroups/<name>/cmd/disable_hostgroup_svc_notifications` {#post-hostgroupsnamecmddisable_hostgroup_svc_notifications}

Sends the DISABLE_HOSTGROUP_SVC_NOTIFICATIONS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_hostgroup_svc_notifications.html for details.

### `POST /hostgroups/<name>/cmd/enable_hostgroup_host_checks` {#post-hostgroupsnamecmdenable_hostgroup_host_checks}

Sends the ENABLE_HOSTGROUP_HOST_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_hostgroup_host_checks.html for details.

### `POST /hostgroups/<name>/cmd/enable_hostgroup_host_notifications` {#post-hostgroupsnamecmdenable_hostgroup_host_notifications}

Sends the ENABLE_HOSTGROUP_HOST_NOTIFICATIONS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_hostgroup_host_notifications.html for details.

### `POST /hostgroups/<name>/cmd/enable_hostgroup_passive_host_checks` {#post-hostgroupsnamecmdenable_hostgroup_passive_host_checks}

Enables passive checks for all hosts in a particular hostgroup.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_hostgroup_passive_host_checks.html for details.

### `POST /hostgroups/<name>/cmd/enable_hostgroup_passive_svc_checks` {#post-hostgroupsnamecmdenable_hostgroup_passive_svc_checks}

Enables passive checks for all services associated with hosts in a particular hostgroup.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_hostgroup_passive_svc_checks.html for details.

### `POST /hostgroups/<name>/cmd/enable_hostgroup_svc_checks` {#post-hostgroupsnamecmdenable_hostgroup_svc_checks}

Sends the ENABLE_HOSTGROUP_SVC_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_hostgroup_svc_checks.html for details.

### `POST /hostgroups/<name>/cmd/enable_hostgroup_svc_notifications` {#post-hostgroupsnamecmdenable_hostgroup_svc_notifications}

Sends the ENABLE_HOSTGROUP_SVC_NOTIFICATIONS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_hostgroup_svc_notifications.html for details.

### `POST /hostgroups/<name>/cmd/schedule_hostgroup_host_downtime` {#post-hostgroupsnamecmdschedule_hostgroup_host_downtime}

Sends the SCHEDULE_HOSTGROUP_HOST_DOWNTIME command.

Required arguments:

  * comment_data

Optional arguments:

  * start_time
  * end_time
  * fixed
  * triggered_by
  * duration
  * comment_author

See https://www.naemon.io/documentation/developer/externalcommands/schedule_hostgroup_host_downtime.html for details.

### `POST /hostgroups/<name>/cmd/schedule_hostgroup_svc_downtime` {#post-hostgroupsnamecmdschedule_hostgroup_svc_downtime}

Sends the SCHEDULE_HOSTGROUP_SVC_DOWNTIME command.

Required arguments:

  * comment_data

Optional arguments:

  * start_time
  * end_time
  * fixed
  * triggered_by
  * duration
  * comment_author

See https://www.naemon.io/documentation/developer/externalcommands/schedule_hostgroup_svc_downtime.html for details.

### `GET /hostgroups/<name>/config` {#get-hostgroupsnameconfig}

Returns configuration for given hostgroup.
You will find available attributes here: https://www.naemon.io/documentation/usersguide/objectdefinitions.html#hostgroup

### `POST /hostgroups/<name>/config` {#post-hostgroupsnameconfig}

Replace hostgroups configuration completely, use PATCH to only update specific attributes.

### `PATCH /hostgroups/<name>/config` {#patch-hostgroupsnameconfig}

Update hostgroup configuration partially.

### `DELETE /hostgroups/<name>/config` {#delete-hostgroupsnameconfig}

Deletes given hostgroup from configuration.

### `GET /hostgroups/<name>/outages` {#get-hostgroupsnameoutages}

list of outages for this hostgroup.

Optional arguments:

  * type              - both | hosts | services
  * timeperiod        - last24hours | lastmonth | thismonth | ...
  * start             - unix timestamp
  * end               - unix timestamp
  * withdowntimes     - 0/1 whether downtimes should count as outages
  * includesoftstates - 0/1 whether soft states should be used as well

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `class` | string |  | host/service status |
| `duration` | number | s | outage duration in seconds |
| `end` | time |  | unix timestamp of outage end |
| `host` | string |  | host name |
| `plugin_output` | string |  | last plugin output during outage |
| `service` | string |  | service description (only for service outages) |
| `start` | time |  | unix timestamp of outage start |
| `type` | string |  | log entry type |

### `GET /hostgroups/<name>/stats` {#get-hostgroupsnamestats}

hash of livestatus hostgroup statistics.
alias for `/hosts/stats?groups[gte]=<name>`

Additional attributes added by Thruk:

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `active_checks_disabled_active` | number |  | Hosts with active checks disabled that are active |
| `active_checks_disabled_passive` | number |  | Hosts with active checks disabled that are passive |
| `down` | number |  | Number of hosts in DOWN state |
| `down_and_ack` | number |  | Number of hosts in DOWN state with acknowledgement |
| `down_and_disabled_active` | number |  | Number of hosts in DOWN state with active checks disabled |
| `down_and_disabled_passive` | number |  | Number of hosts in DOWN state with passive checks disabled |
| `down_and_scheduled` | number |  | Number of hosts in DOWN state with scheduled downtime |
| `down_and_unhandled` | number |  | Number of unhandled hosts in DOWN state |
| `down_hard` | number |  | Number of hosts in hard DOWN state |
| `down_soft` | number |  | Number of hosts in soft DOWN state |
| `eventhandler_disabled` | boolean |  | Whether event handler is disabled |
| `flapping` | boolean |  | Whether the host is flapping |
| `flapping_disabled` | boolean |  | Whether flap detection is disabled |
| `hard` | string |  | Hard state as string |
| `notifications_disabled` | boolean |  | Whether notifications are disabled |
| `outages` | number |  | Number of current outages |
| `passive_checks_disabled` | boolean |  | Whether passive checks are disabled |
| `pending` | number |  | Number of pending hosts |
| `pending_and_disabled` | number |  | Number of pending hosts with checks disabled |

### `GET /hosts` {#get-hosts}

lists livestatus hosts.
see https://www.naemon.io/documentation/usersguide/livestatus.html#hosts for details.

Additional attributes added by Thruk:

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `accept_passive_checks` | boolean |  | Whether passive host checks are accepted (0/1) |
| `action_url_expanded` | string |  | The action url with the most important macros expanded |
| `check_freshness` | number |  | Whether freshness checks are activated (0/1) |
| `check_options` | number |  | The current check option: forced, normal, freshness (0-2) |
| `checks_enabled` | number |  | Whether checks are enabled (0/1) |
| `childs` | array_of_strings |  | A list of all direct children of the host |
| `comments` | array_of_strings |  | A list of the ids of all comments |
| `comments_info` | string |  | A list of all comments with id, author, comment, entry_type and entry_time |
| `comments_with_info` | string |  | A list of all comments with id, author, comment, entry_type, expires and expire_time |
| `custom_variable_names` | array_of_strings |  | A list of the names of all custom variables |
| `custom_variable_values` | array_of_strings |  | A list of the values of the custom variables |
| `custom_variables` | array_of_strings |  | A dictionary of the custom variables |
| `downtimes_info` | string |  | A list of the ids of all downtimes with additional info |
| `downtimes_with_info` | number |  | Number of downtimes with additional info |
| `groups` | array_of_strings |  | A list of all host groups this host is in |
| `hard_state` | number |  | The hard state of the host |
| `icon_image_expanded` | string |  | The icon image with the most important macros expanded |
| `in_check_period` | boolean |  | Whether this host is currently in its check period (0/1) |
| `in_notification_period` | boolean |  | Whether this host is currently in its notification period (0/1) |
| `is_executing` | boolean |  | Whether there is a check currently running (0/1) |
| `latency` | number |  | Host check latency in seconds |
| `modified_attributes_list` | array_of_strings |  | A list of all modified attributes |
| `notes_expanded` | string |  | The notes with the most important macros expanded |
| `notes_url_expanded` | string |  | The notes url with the most important macros expanded |

### `GET /hosts/<name>` {#get-hostsname}

lists hosts for given name.
alias for `/hosts?name=<name>`

### `GET /hosts/<name>/alerts` {#get-hostsnamealerts}

lists alerts for given host.
alias for `/logs?type[~]=^(HOST|SERVICE) ALERT&host_name=<name>`
supports wildcards for: `<name>`

### `GET /hosts/<name>/availability` {#get-hostsnameavailability}

list availability for this host.

Optional arguments:

  * timeperiod        - last24hours | lastmonth | thismonth | ...
  * start             - unix timestamp
  * end               - unix timestamp
  * withdowntimes     - 0/1 whether downtimes should count as outages
  * includesoftstates - 0/1 whether soft states should be used as well

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `scheduled_time_down` | number | s | total seconds in state down (during downtimes) |
| `scheduled_time_down_percent` | number | % | time down in percent of total time (during downtimes) |
| `scheduled_time_indeterminate` | number | s | total seconds unknown (during downtimes) |
| `scheduled_time_indeterminate_percent` | number | % | time unknown in percent of total time (during downtimes) |
| `scheduled_time_unreachable` | number | s | total seconds in state unreachable (during downtimes) |
| `scheduled_time_unreachable_percent` | number | % | time unreachable in percent of total time (during downtimes) |
| `scheduled_time_up` | number | s | total seconds in state up (during downtimes) |
| `scheduled_time_up_percent` | number | % | time up in percent of total time (during downtimes) |
| `time_down` | number | s | total seconds in state down |
| `time_down_percent` | number | % | time down in percent of total time |
| `time_indeterminate_nodata` | number | s | total seconds without any data |
| `time_indeterminate_nodata_percent` | number | % | time without any data in percent of total time |
| `time_indeterminate_notrunning` | number | s | total seconds during core not running |
| `time_indeterminate_notrunning_percent` | number | % | time during core not running in percent of total time |
| `time_indeterminate_outside_timeperiod` | number | s | total seconds outside the given timeperiod |
| `time_indeterminate_outside_timeperiod_percent` | number | % | time outside the given timeperiod in percent of total time |
| `time_unreachable` | number | s | total seconds in state unreachable |
| `time_unreachable_percent` | number | % | time unreachable in percent of total time |
| `time_up` | number | s | total seconds in state up |
| `time_up_percent` | number | % | time up in percent of total time |

### `POST /hosts/<name>/cmd/...` {#post-hostsnamecmd}

list of supported commands:

 - [acknowledge_host_problem](#post-hostsnamecmdacknowledge_host_problem)
 - [acknowledge_host_problem_expire](#post-hostsnamecmdacknowledge_host_problem_expire)
 - [add_host_comment](#post-hostsnamecmdadd_host_comment)
 - [change_custom_host_var](#post-hostsnamecmdchange_custom_host_var)
 - [change_host_check_timeperiod](#post-hostsnamecmdchange_host_check_timeperiod)
 - [change_host_modattr](#post-hostsnamecmdchange_host_modattr)
 - [change_host_notification_timeperiod](#post-hostsnamecmdchange_host_notification_timeperiod)
 - [change_max_host_check_attempts](#post-hostsnamecmdchange_max_host_check_attempts)
 - [change_normal_host_check_interval](#post-hostsnamecmdchange_normal_host_check_interval)
 - [change_retry_host_check_interval](#post-hostsnamecmdchange_retry_host_check_interval)
 - [del_active_host_downtimes](#post-hostsnamecmddel_active_host_downtimes)
 - [del_all_host_comments](#post-hostsnamecmddel_all_host_comments)
 - [del_comment](#post-hostsnamecmddel_comment)
 - [del_downtime](#post-hostsnamecmddel_downtime)
 - [delay_host_notification](#post-hostsnamecmddelay_host_notification)
 - [disable_all_notifications_beyond_host](#post-hostsnamecmddisable_all_notifications_beyond_host)
 - [disable_host_and_child_notifications](#post-hostsnamecmddisable_host_and_child_notifications)
 - [disable_host_check](#post-hostsnamecmddisable_host_check)
 - [disable_host_event_handler](#post-hostsnamecmddisable_host_event_handler)
 - [disable_host_flap_detection](#post-hostsnamecmddisable_host_flap_detection)
 - [disable_host_notifications](#post-hostsnamecmddisable_host_notifications)
 - [disable_host_svc_checks](#post-hostsnamecmddisable_host_svc_checks)
 - [disable_host_svc_notifications](#post-hostsnamecmddisable_host_svc_notifications)
 - [disable_passive_host_checks](#post-hostsnamecmddisable_passive_host_checks)
 - [enable_all_notifications_beyond_host](#post-hostsnamecmdenable_all_notifications_beyond_host)
 - [enable_host_and_child_notifications](#post-hostsnamecmdenable_host_and_child_notifications)
 - [enable_host_check](#post-hostsnamecmdenable_host_check)
 - [enable_host_event_handler](#post-hostsnamecmdenable_host_event_handler)
 - [enable_host_flap_detection](#post-hostsnamecmdenable_host_flap_detection)
 - [enable_host_notifications](#post-hostsnamecmdenable_host_notifications)
 - [enable_host_svc_checks](#post-hostsnamecmdenable_host_svc_checks)
 - [enable_host_svc_notifications](#post-hostsnamecmdenable_host_svc_notifications)
 - [enable_passive_host_checks](#post-hostsnamecmdenable_passive_host_checks)
 - [note](#post-hostsnamecmdnote)
 - [process_host_check_result](#post-hostsnamecmdprocess_host_check_result)
 - [remove_host_acknowledgement](#post-hostsnamecmdremove_host_acknowledgement)
 - [schedule_and_propagate_host_downtime](#post-hostsnamecmdschedule_and_propagate_host_downtime)
 - [schedule_and_propagate_triggered_host_downtime](#post-hostsnamecmdschedule_and_propagate_triggered_host_downtime)
 - [schedule_forced_host_check](#post-hostsnamecmdschedule_forced_host_check)
 - [schedule_forced_host_svc_checks](#post-hostsnamecmdschedule_forced_host_svc_checks)
 - [schedule_host_check](#post-hostsnamecmdschedule_host_check)
 - [schedule_host_downtime](#post-hostsnamecmdschedule_host_downtime)
 - [schedule_host_svc_checks](#post-hostsnamecmdschedule_host_svc_checks)
 - [schedule_host_svc_downtime](#post-hostsnamecmdschedule_host_svc_downtime)
 - [send_custom_host_notification](#post-hostsnamecmdsend_custom_host_notification)
 - [set_host_notification_number](#post-hostsnamecmdset_host_notification_number)
 - [start_obsessing_over_host](#post-hostsnamecmdstart_obsessing_over_host)
 - [stop_obsessing_over_host](#post-hostsnamecmdstop_obsessing_over_host)

### `POST /hosts/<name>/cmd/acknowledge_host_problem` {#post-hostsnamecmdacknowledge_host_problem}

Sends the ACKNOWLEDGE_HOST_PROBLEM command.

Required arguments:

  * comment_data

Optional arguments:

  * sticky_ack
  * send_notification
  * persistent_comment
  * comment_author

See https://www.naemon.io/documentation/developer/externalcommands/acknowledge_host_problem.html for details.

### `POST /hosts/<name>/cmd/acknowledge_host_problem_expire` {#post-hostsnamecmdacknowledge_host_problem_expire}

Sends the ACKNOWLEDGE_HOST_PROBLEM_EXPIRE command.

Required arguments:

  * comment_data

Optional arguments:

  * sticky_ack
  * send_notification
  * persistent_comment
  * end_time
  * comment_author

See https://www.naemon.io/documentation/developer/externalcommands/acknowledge_host_problem_expire.html for details.

### `POST /hosts/<name>/cmd/add_host_comment` {#post-hostsnamecmdadd_host_comment}

Sends the ADD_HOST_COMMENT command.

Required arguments:

  * comment_data

Optional arguments:

  * persistent_comment
  * comment_author

See https://www.naemon.io/documentation/developer/externalcommands/add_host_comment.html for details.

### `POST /hosts/<name>/cmd/change_custom_host_var` {#post-hostsnamecmdchange_custom_host_var}

Changes the value of a custom host variable.

Required arguments:

  * name
  * value

See https://www.naemon.io/documentation/developer/externalcommands/change_custom_host_var.html for details.

### `POST /hosts/<name>/cmd/change_host_check_timeperiod` {#post-hostsnamecmdchange_host_check_timeperiod}

Changes the valid check period for the specified host.

Required arguments:

  * timeperiod

See https://www.naemon.io/documentation/developer/externalcommands/change_host_check_timeperiod.html for details.

### `POST /hosts/<name>/cmd/change_host_modattr` {#post-hostsnamecmdchange_host_modattr}

Sends the CHANGE_HOST_MODATTR command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/change_host_modattr.html for details.

### `POST /hosts/<name>/cmd/change_host_notification_timeperiod` {#post-hostsnamecmdchange_host_notification_timeperiod}

Changes the host notification timeperiod to what is specified by the 'notification_timeperiod' option. The 'notification_timeperiod' option should be the short name of the timeperiod that is to be used as the service notification timeperiod. The timeperiod must have been configured in Naemon before it was last (re)started.

Required arguments:

  * timeperiod

See https://www.naemon.io/documentation/developer/externalcommands/change_host_notification_timeperiod.html for details.

### `POST /hosts/<name>/cmd/change_max_host_check_attempts` {#post-hostsnamecmdchange_max_host_check_attempts}

Changes the maximum number of check attempts (retries) for a particular host.

Required arguments:

  * interval

See https://www.naemon.io/documentation/developer/externalcommands/change_max_host_check_attempts.html for details.

### `POST /hosts/<name>/cmd/change_normal_host_check_interval` {#post-hostsnamecmdchange_normal_host_check_interval}

Changes the normal (regularly scheduled) check interval for a particular host.

Required arguments:

  * interval

See https://www.naemon.io/documentation/developer/externalcommands/change_normal_host_check_interval.html for details.

### `POST /hosts/<name>/cmd/change_retry_host_check_interval` {#post-hostsnamecmdchange_retry_host_check_interval}

Changes the retry check interval for a particular host.

Required arguments:

  * interval

See https://www.naemon.io/documentation/developer/externalcommands/change_retry_host_check_interval.html for details.

### `POST /hosts/<name>/cmd/del_active_host_downtimes` {#post-hostsnamecmddel_active_host_downtimes}

Removes all currently active downtimes for this host.

This command does not require any arguments.

### `POST /hosts/<name>/cmd/del_all_host_comments` {#post-hostsnamecmddel_all_host_comments}

Sends the DEL_ALL_HOST_COMMENTS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/del_all_host_comments.html for details.

### `POST /hosts/<name>/cmd/del_comment` {#post-hostsnamecmddel_comment}

Removes comment by id for this host.

Required arguments:

  * comment_id

### `POST /hosts/<name>/cmd/del_downtime` {#post-hostsnamecmddel_downtime}

Removes downtime by id for this host.

Required arguments:

  * downtime_id

### `POST /hosts/<name>/cmd/delay_host_notification` {#post-hostsnamecmddelay_host_notification}

Sends the DELAY_HOST_NOTIFICATION command.

Required arguments:

  * notification_time

See https://www.naemon.io/documentation/developer/externalcommands/delay_host_notification.html for details.

### `POST /hosts/<name>/cmd/disable_all_notifications_beyond_host` {#post-hostsnamecmddisable_all_notifications_beyond_host}

Sends the DISABLE_ALL_NOTIFICATIONS_BEYOND_HOST command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_all_notifications_beyond_host.html for details.

### `POST /hosts/<name>/cmd/disable_host_and_child_notifications` {#post-hostsnamecmddisable_host_and_child_notifications}

Sends the DISABLE_HOST_AND_CHILD_NOTIFICATIONS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_host_and_child_notifications.html for details.

### `POST /hosts/<name>/cmd/disable_host_check` {#post-hostsnamecmddisable_host_check}

Sends the DISABLE_HOST_CHECK command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_host_check.html for details.

### `POST /hosts/<name>/cmd/disable_host_event_handler` {#post-hostsnamecmddisable_host_event_handler}

Sends the DISABLE_HOST_EVENT_HANDLER command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_host_event_handler.html for details.

### `POST /hosts/<name>/cmd/disable_host_flap_detection` {#post-hostsnamecmddisable_host_flap_detection}

Sends the DISABLE_HOST_FLAP_DETECTION command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_host_flap_detection.html for details.

### `POST /hosts/<name>/cmd/disable_host_notifications` {#post-hostsnamecmddisable_host_notifications}

Sends the DISABLE_HOST_NOTIFICATIONS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_host_notifications.html for details.

### `POST /hosts/<name>/cmd/disable_host_svc_checks` {#post-hostsnamecmddisable_host_svc_checks}

Sends the DISABLE_HOST_SVC_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_host_svc_checks.html for details.

### `POST /hosts/<name>/cmd/disable_host_svc_notifications` {#post-hostsnamecmddisable_host_svc_notifications}

Sends the DISABLE_HOST_SVC_NOTIFICATIONS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_host_svc_notifications.html for details.

### `POST /hosts/<name>/cmd/disable_passive_host_checks` {#post-hostsnamecmddisable_passive_host_checks}

Sends the DISABLE_PASSIVE_HOST_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_passive_host_checks.html for details.

### `POST /hosts/<name>/cmd/enable_all_notifications_beyond_host` {#post-hostsnamecmdenable_all_notifications_beyond_host}

Sends the ENABLE_ALL_NOTIFICATIONS_BEYOND_HOST command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_all_notifications_beyond_host.html for details.

### `POST /hosts/<name>/cmd/enable_host_and_child_notifications` {#post-hostsnamecmdenable_host_and_child_notifications}

Sends the ENABLE_HOST_AND_CHILD_NOTIFICATIONS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_host_and_child_notifications.html for details.

### `POST /hosts/<name>/cmd/enable_host_check` {#post-hostsnamecmdenable_host_check}

Sends the ENABLE_HOST_CHECK command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_host_check.html for details.

### `POST /hosts/<name>/cmd/enable_host_event_handler` {#post-hostsnamecmdenable_host_event_handler}

Sends the ENABLE_HOST_EVENT_HANDLER command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_host_event_handler.html for details.

### `POST /hosts/<name>/cmd/enable_host_flap_detection` {#post-hostsnamecmdenable_host_flap_detection}

Sends the ENABLE_HOST_FLAP_DETECTION command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_host_flap_detection.html for details.

### `POST /hosts/<name>/cmd/enable_host_notifications` {#post-hostsnamecmdenable_host_notifications}

Sends the ENABLE_HOST_NOTIFICATIONS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_host_notifications.html for details.

### `POST /hosts/<name>/cmd/enable_host_svc_checks` {#post-hostsnamecmdenable_host_svc_checks}

Sends the ENABLE_HOST_SVC_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_host_svc_checks.html for details.

### `POST /hosts/<name>/cmd/enable_host_svc_notifications` {#post-hostsnamecmdenable_host_svc_notifications}

Sends the ENABLE_HOST_SVC_NOTIFICATIONS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_host_svc_notifications.html for details.

### `POST /hosts/<name>/cmd/enable_passive_host_checks` {#post-hostsnamecmdenable_passive_host_checks}

Sends the ENABLE_PASSIVE_HOST_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_passive_host_checks.html for details.

### `POST /hosts/<name>/cmd/note` {#post-hostsnamecmdnote}

Add host note to core log.

Required arguments:

  * log

### `POST /hosts/<name>/cmd/process_host_check_result` {#post-hostsnamecmdprocess_host_check_result}

Sends the PROCESS_HOST_CHECK_RESULT command.

Required arguments:

  * plugin_state
  * plugin_output

Optional arguments:

  * performance_data

See https://www.naemon.io/documentation/developer/externalcommands/process_host_check_result.html for details.

### `POST /hosts/<name>/cmd/remove_host_acknowledgement` {#post-hostsnamecmdremove_host_acknowledgement}

Sends the REMOVE_HOST_ACKNOWLEDGEMENT command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/remove_host_acknowledgement.html for details.

### `POST /hosts/<name>/cmd/schedule_and_propagate_host_downtime` {#post-hostsnamecmdschedule_and_propagate_host_downtime}

Sends the SCHEDULE_AND_PROPAGATE_HOST_DOWNTIME command.

Required arguments:

  * comment_data

Optional arguments:

  * start_time
  * end_time
  * fixed
  * triggered_by
  * duration
  * comment_author

See https://www.naemon.io/documentation/developer/externalcommands/schedule_and_propagate_host_downtime.html for details.

### `POST /hosts/<name>/cmd/schedule_and_propagate_triggered_host_downtime` {#post-hostsnamecmdschedule_and_propagate_triggered_host_downtime}

Sends the SCHEDULE_AND_PROPAGATE_TRIGGERED_HOST_DOWNTIME command.

Required arguments:

  * comment_data

Optional arguments:

  * start_time
  * end_time
  * fixed
  * triggered_by
  * duration
  * comment_author

See https://www.naemon.io/documentation/developer/externalcommands/schedule_and_propagate_triggered_host_downtime.html for details.

### `POST /hosts/<name>/cmd/schedule_forced_host_check` {#post-hostsnamecmdschedule_forced_host_check}

Sends the SCHEDULE_FORCED_HOST_CHECK command.

Optional arguments:

  * start_time

See https://www.naemon.io/documentation/developer/externalcommands/schedule_forced_host_check.html for details.

### `POST /hosts/<name>/cmd/schedule_forced_host_svc_checks` {#post-hostsnamecmdschedule_forced_host_svc_checks}

Sends the SCHEDULE_FORCED_HOST_SVC_CHECKS command.

Optional arguments:

  * start_time

See https://www.naemon.io/documentation/developer/externalcommands/schedule_forced_host_svc_checks.html for details.

### `POST /hosts/<name>/cmd/schedule_host_check` {#post-hostsnamecmdschedule_host_check}

Sends the SCHEDULE_HOST_CHECK command.

Optional arguments:

  * start_time

See https://www.naemon.io/documentation/developer/externalcommands/schedule_host_check.html for details.

### `POST /hosts/<name>/cmd/schedule_host_downtime` {#post-hostsnamecmdschedule_host_downtime}

Sends the SCHEDULE_HOST_DOWNTIME command.

Required arguments:

  * comment_data

Optional arguments:

  * start_time
  * end_time
  * fixed
  * triggered_by
  * duration
  * comment_author

See https://www.naemon.io/documentation/developer/externalcommands/schedule_host_downtime.html for details.

### `POST /hosts/<name>/cmd/schedule_host_svc_checks` {#post-hostsnamecmdschedule_host_svc_checks}

Sends the SCHEDULE_HOST_SVC_CHECKS command.

Optional arguments:

  * start_time

See https://www.naemon.io/documentation/developer/externalcommands/schedule_host_svc_checks.html for details.

### `POST /hosts/<name>/cmd/schedule_host_svc_downtime` {#post-hostsnamecmdschedule_host_svc_downtime}

Sends the SCHEDULE_HOST_SVC_DOWNTIME command.

Required arguments:

  * comment_data

Optional arguments:

  * start_time
  * end_time
  * fixed
  * triggered_by
  * duration
  * comment_author

See https://www.naemon.io/documentation/developer/externalcommands/schedule_host_svc_downtime.html for details.

### `POST /hosts/<name>/cmd/send_custom_host_notification` {#post-hostsnamecmdsend_custom_host_notification}

Sends the SEND_CUSTOM_HOST_NOTIFICATION command.

Required arguments:

  * comment_data

Optional arguments:

  * options
  * comment_author

See https://www.naemon.io/documentation/developer/externalcommands/send_custom_host_notification.html for details.

### `POST /hosts/<name>/cmd/set_host_notification_number` {#post-hostsnamecmdset_host_notification_number}

Sets the current notification number for a particular host. A value of 0 indicates that no notification has yet been sent for the current host problem. Useful for forcing an escalation (based on notification number) or replicating notification information in redundant monitoring environments. Notification numbers greater than zero have no noticeable affect on the notification process if the host is currently in an UP state.

Required arguments:

  * number

See https://www.naemon.io/documentation/developer/externalcommands/set_host_notification_number.html for details.

### `POST /hosts/<name>/cmd/start_obsessing_over_host` {#post-hostsnamecmdstart_obsessing_over_host}

Sends the START_OBSESSING_OVER_HOST command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/start_obsessing_over_host.html for details.

### `POST /hosts/<name>/cmd/stop_obsessing_over_host` {#post-hostsnamecmdstop_obsessing_over_host}

Sends the STOP_OBSESSING_OVER_HOST command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/stop_obsessing_over_host.html for details.

### `GET /hosts/<name>/commandline` {#get-hostsnamecommandline}

displays commandline for check command of given hosts.
supports wildcards for: `<name>`

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `check_command` | string |  | name of the check_command including arguments |
| `command_line` | string |  | full expanded command line (if possible) |
| `error` | string |  | contains the error if expanding failed for some reason |
| `host_name` | string |  | host name |
| `peer_key` | string |  | id as defined in Thruk::Backend component configuration |
| `peer_name` | string |  | name as defined in Thruk::Backend component configuration |
| `peer_section` | string |  | section as defined in Thruk::Backend component configuration |

### `GET /hosts/<name>/config` {#get-hostsnameconfig}

Returns configuration for given host.
You will find available attributes here: https://www.naemon.io/documentation/usersguide/objectdefinitions.html#host

### `POST /hosts/<name>/config` {#post-hostsnameconfig}

Replace host configuration completely, use PATCH to only update specific attributes.

### `PATCH /hosts/<name>/config` {#patch-hostsnameconfig}

Update host configuration partially.

### `DELETE /hosts/<name>/config` {#delete-hostsnameconfig}

Deletes given host from configuration.

### `GET /hosts/<name>/notifications` {#get-hostsnamenotifications}

lists notifications for given host.
alias for `/logs?class=3&host_name=<name>`
supports wildcards for: `<name>`

### `GET /hosts/<name>/outages` {#get-hostsnameoutages}

list of outages for this host.

Optional arguments:

  * type              - both | hosts | services
  * timeperiod        - last24hours | lastmonth | thismonth | ...
  * start             - unix timestamp
  * end               - unix timestamp
  * withdowntimes     - 0/1 whether downtimes should count as outages
  * includesoftstates - 0/1 whether soft states should be used as well

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `class` | string |  | host/service status |
| `duration` | number | s | outage duration in seconds |
| `end` | time |  | unix timestamp of outage end |
| `host` | string |  | host name |
| `plugin_output` | string |  | last plugin output during outage |
| `start` | time |  | unix timestamp of outage start |
| `type` | string |  | log entry type |

### `GET /hosts/<name>/services` {#get-hostsnameservices}

lists services for given host.
alias for `/services?host_name=<name>`

### `GET /hosts/availability` {#get-hostsavailability}

list availability for all hosts.

Optional arguments:

  * type              - both | hosts | services
  * timeperiod        - last24hours | lastmonth | thismonth | ...
  * start             - unix timestamp
  * end               - unix timestamp
  * withdowntimes     - 0/1 whether downtimes should count as outages
  * includesoftstates - 0/1 whether soft states should be used as well

supports hostgroup filter, ex. GET /hosts/availability?hostgroup=foo


| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `host` | string |  | host name |
| `scheduled_time_down` | number | s | total seconds in state down (during downtimes) |
| `scheduled_time_down_percent` | number | % | time down in percent of total time (during downtimes) |
| `scheduled_time_indeterminate` | number | s | total seconds unknown (during downtimes) |
| `scheduled_time_indeterminate_percent` | number | % | time unknown in percent of total time (during downtimes) |
| `scheduled_time_unreachable` | number | s | total seconds in state unreachable (during downtimes) |
| `scheduled_time_unreachable_percent` | number | % | time unreachable in percent of total time (during downtimes) |
| `scheduled_time_up` | number | s | total seconds in state up (during downtimes) |
| `scheduled_time_up_percent` | number | % | time up in percent of total time (during downtimes) |
| `time_down` | number | s | total seconds in state down |
| `time_down_percent` | number | % | time down in percent of total time |
| `time_indeterminate_nodata` | number | s | total seconds without any data |
| `time_indeterminate_nodata_percent` | number | % | time without any data in percent of total time |
| `time_indeterminate_notrunning` | number | s | total seconds during core not running |
| `time_indeterminate_notrunning_percent` | number | % | time during core not running in percent of total time |
| `time_indeterminate_outside_timeperiod` | number | s | total seconds outside the given timeperiod |
| `time_indeterminate_outside_timeperiod_percent` | number | % | time outside the given timeperiod in percent of total time |
| `time_unreachable` | number | s | total seconds in state unreachable |
| `time_unreachable_percent` | number | % | time unreachable in percent of total time |
| `time_up` | number | s | total seconds in state up |
| `time_up_percent` | number | % | time up in percent of total time |

### `GET /hosts/outages` {#get-hostsoutages}

list of outages for all hosts.

Optional arguments:

  * type              - both | hosts | services
  * timeperiod        - last24hours | lastmonth | thismonth | ...
  * start             - unix timestamp
  * end               - unix timestamp
  * withdowntimes     - 0/1 whether downtimes should count as outages
  * includesoftstates - 0/1 whether soft states should be used as well

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `class` |  |  | host/service status |
| `duration` | number | s | outage duration in seconds |
| `end` | time |  | unix timestamp of outage end |
| `host` | string |  | host name |
| `plugin_output` | string |  | last plugin output during outage |
| `start` | time |  | unix timestamp of outage start |
| `type` | string |  | log entry type |

### `GET /hosts/stats` {#get-hostsstats}

hash of livestatus host statistics.

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `active_checks_disabled_active` | number |  | number of active hosts which have active checks disabled |
| `active_checks_disabled_passive` | number |  | number of passive hosts which have active checks disabled |
| `down` | number |  | number of down hosts |
| `down_and_ack` | number |  | number of down hosts which are acknowledged |
| `down_and_disabled_active` | number |  | number of active down hosts which have active checks disabled |
| `down_and_disabled_passive` | number |  | number of passive down hosts which have active checks disabled |
| `down_and_scheduled` | number |  | number of down hosts which are in a scheduled downtime |
| `down_and_unhandled` | number |  | number of unhandled down hosts |
| `down_hard` | number |  | number of hard down hosts |
| `down_hard_unhandled` | number |  | number of unhandled hard down hosts |
| `down_soft` | number |  | number of soft down hosts |
| `eventhandler_disabled` | number |  | number of hosts with eventhandlers disabled |
| `flapping` | number |  | number of flapping hosts |
| `flapping_disabled` | number |  | number of hosts with flapping detection disabled |
| `hard` | number |  | number of hosts in hard state |
| `notifications_disabled` | number |  | number of hosts with notifications disabled |
| `outages` | number |  | number of network outages |
| `passive_checks_disabled` | number |  | number of hosts which do not accept passive check results |
| `pending` | number |  | number of pending hosts |
| `pending_and_disabled` | number |  | number of pending hosts with active checks disabled |
| `pending_and_scheduled` | number |  | number of pending hosts which are in a scheduled downtime |
| `plain_down` | number |  | number of down hosts which are not acknowleded or in a downtime |
| `plain_pending` | number |  | number of pending hosts which are not acknowleded or in a downtime |
| `plain_unreachable` | number |  | number of unreachable hosts which are not acknowleded or in a downtime |
| `plain_up` | number |  | number of up hosts which are not acknowleded or in a downtime |
| `soft` | number |  | number of hosts in soft state |
| `total` | number |  | total number of hosts |
| `total_active` | number |  | total number of active hosts |
| `total_passive` | number |  | total number of passive hosts |
| `unreachable` | number |  | number of unreachable hosts |
| `unreachable_and_ack` | number |  | number of unreachable hosts which are acknowledged |
| `unreachable_and_disabled_active` | number |  | number of active unreachable hosts which have active checks disabled |
| `unreachable_and_disabled_passive` | number |  | number of passive unreachable hosts which have active checks disabled |
| `unreachable_and_scheduled` | number |  | number of unreachable hosts which are in a scheduled downtime |
| `unreachable_and_unhandled` | number |  | number of unhandled unreachable hosts |
| `unreachable_hard` | number |  | number of unreachable hosts in hard state |
| `unreachable_hard_unhandled` | number |  | number of unhandled unreachable hosts in hard state |
| `unreachable_soft` | number |  | number of unreachable hosts in soft state |
| `up` | number |  | number of up hosts |
| `up_and_disabled_active` | number |  | number of active up hosts which have active checks disabled |
| `up_and_disabled_passive` | number |  | number of passive up hosts which have active checks disabled |
| `up_and_scheduled` | number |  | number of up hosts which are in a scheduled downtime |

### `GET /hosts/totals` {#get-hoststotals}

hash of livestatus host totals statistics.
its basically a reduced set of /hosts/stats.

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `down` | number |  | number of down hosts |
| `down_and_unhandled` | number |  | number of down hosts which are neither acknowledged nor in scheduled downtime |
| `pending` | number |  | number of pending hosts |
| `total` | number |  | total number of hosts |
| `unreachable` | number |  | number of unreachable hosts |
| `unreachable_and_unhandled` | number |  | number of unreachable hosts which are neither acknowledged nor in scheduled downtime |
| `up` | number |  | number of up hosts |

### `GET /index` {#get-index}

lists all available rest urls.

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `description` | string |  | description of the url |
| `protocol` | string |  | protocol to use for this url |
| `url` | string |  | the rest url |

### `GET /lmd/sites` {#get-lmdsites}

lists connected sites. Only available if LMD (`use_lmd`) is enabled.

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `addr` | string |  | address of the remote site |
| `bytes_received` | number | bytes | total bytes received from this site |
| `bytes_send` | number | bytes | total bytes send to this site |
| `federation_addr` | string |  | contains the real address if using federation |
| `federation_key` | string |  | contains the real peer key if using federation |
| `federation_name` | string |  | contains the real name if using federation |
| `federation_type` | string |  | contains the real backend type if using federation |
| `federation_version` | string |  | contains the real backend version if using federation |
| `flags` | array_of_strings |  | contains the lmd flags for this backend |
| `idling` | boolean |  | flag if the connection is in idle mode |
| `key` | string |  | primary id of this site |
| `last_error` | time |  | last error message |
| `last_online` | time |  | timestamp when the site was last time online |
| `last_query` | time |  | timestamp of the last received query for this site |
| `last_update` | time |  | timestamp of the last update |
| `lmd_last_cache_update` | time |  | same as last_update |
| `name` | string |  | name of the site |
| `parent` | string |  | parent id for lmd federation setups |
| `peer_key` | string |  | id as defined in Thruk::Backend component configuration |
| `peer_name` | string |  | name as defined in Thruk::Backend component configuration |
| `queries` | number |  | number of queries received |
| `response_time` | number | s | response time in seconds |
| `section` |  |  | thruks section |
| `status` | string |  | connection status of this site |

### `GET /logs` {#get-logs}

lists livestatus logs.
see https://www.naemon.io/documentation/usersguide/livestatus.html#log for details.

### `GET /notifications` {#get-notifications}

lists notifications based on logfiles.
alias for `/logs?class=3`

Additional attributes added by Thruk:

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `attempt` | number |  | Current attempt number when this log entry was generated |
| `class` | number |  | The class of the message as integer (0:info, 1:state, 2:program, 3:notification, 4:passive, 5:command) |
| `command_name` | string |  | Command name associated with this log entry |
| `comment` | string |  | Comment text from the log entry |
| `contact_name` | string |  | Contact name associated with this log entry |
| `host_name` | string |  | Host name associated with this log entry |
| `lineno` | number |  | Line number of the log entry in the log file |
| `message` | string |  | Log message text |
| `options` | string |  | Options string from the log entry |
| `peer_key` | string |  | id as defined in Thruk::Backend component configuration |
| `peer_name` | string |  | name as defined in Thruk::Backend component configuration |
| `plugin_output` | string |  | Plugin output from the log entry |
| `service_description` | string |  | Service description associated with this log entry |
| `state` | number |  | State of the host or service at the time of the log entry |
| `state_type` | string |  | State type (HARD or SOFT) |
| `time` | time |  | Timestamp of the log entry (unix timestamp) |
| `type` | string |  | Type of the log entry |

### `GET /processinfo` {#get-processinfo}

lists livestatus sites status.
see https://www.naemon.io/documentation/usersguide/livestatus.html#status for details.

Additional attributes added by Thruk:

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `check_external_commands` | number |  | Whether the core accepts external commands (0/1) |
| `data_source_version` | string |  | Version of the data source (livestatus version) |
| `nagios_pid` | number |  | The process ID of the monitoring core |
| `obsess_over_hosts` | boolean |  | Whether the core obsesses over hosts (0/1) |
| `obsess_over_services` | boolean |  | Whether the core obsesses over services (0/1) |
| `peer_addr` | string |  | Address of the peer (ip:port or unix socket) |
| `peer_key` | string |  | id as defined in Thruk::Backend component configuration |
| `peer_name` | string |  | name as defined in Thruk::Backend component configuration |

### `GET /processinfo/stats` {#get-processinfostats}

lists livestatus sites statistics.
see https://www.naemon.io/documentation/usersguide/livestatus.html#status for details.

Additional attributes added by Thruk:

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `cached_log_messages` | number |  | Number of cached log messages |
| `connections` | number |  | Number of connections |
| `connections_rate` | number |  | Connections per second |
| `forks` | number |  | Number of forks |
| `forks_rate` | number |  | Forks per second |
| `host_checks` | number |  | Number of host checks |
| `host_checks_rate` | number |  | Host checks per second |
| `log_messages` | number |  | Number of log messages |
| `log_messages_rate` | number |  | Log messages per second |
| `neb_callbacks` | number |  | Number of NEB callbacks |
| `neb_callbacks_rate` | number |  | NEB callbacks per second |
| `requests` | number |  | Number of requests |
| `requests_rate` | number |  | Requests per second |
| `service_checks` | number |  | Number of service checks |
| `service_checks_rate` | number |  | Service checks per second |

### `GET /servicegroups` {#get-servicegroups}

lists livestatus servicegroups.
see https://www.naemon.io/documentation/usersguide/livestatus.html#servicegroups for details.

Additional attributes added by Thruk:

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `num_services_hard_crit` | number |  | Number of services in hard CRITICAL state |
| `num_services_hard_ok` | number |  | Number of services in hard OK state |
| `num_services_hard_unknown` | number |  | Number of services in hard UNKNOWN state |
| `num_services_hard_warn` | number |  | Number of services in hard WARNING state |
| `peer_key` | string |  | id as defined in Thruk::Backend component configuration |
| `peer_name` | string |  | name as defined in Thruk::Backend component configuration |

### `GET /servicegroups/<name>` {#get-servicegroupsname}

lists servicegroups for given name.
alias for `/servicegroups?name=<name>`

### `GET /servicegroups/<name>/availability` {#get-servicegroupsnameavailability}

list availability for this servicegroup.

Optional arguments:

  * type              - both | hosts | services
  * timeperiod        - last24hours | lastmonth | thismonth | ...
  * start             - unix timestamp
  * end               - unix timestamp
  * withdowntimes     - 0/1 whether downtimes should count as outages
  * includesoftstates - 0/1 whether soft states should be used as well

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `host` | string |  | host name |
| `scheduled_time_critical` | number | s | total seconds in state critical (during downtimes) |
| `scheduled_time_critical_percent` | number | % | time critical in percent of total time (during downtimes) |
| `scheduled_time_indeterminate` | number | s | total seconds unknown (during downtimes) |
| `scheduled_time_indeterminate_percent` | number | % | time unknown in percent of total time (during downtimes) |
| `scheduled_time_ok` | number | s | total seconds in state ok (during downtimes) |
| `scheduled_time_ok_percent` | number | % | time ok in percent of total time (during downtimes) |
| `scheduled_time_unknown` | number | s | total seconds in state unknown (during downtimes) |
| `scheduled_time_unknown_percent` | number | % | time unknown in percent of total time (during downtimes) |
| `scheduled_time_warning` | number | s | total seconds in state warning (during downtimes) |
| `scheduled_time_warning_percent` | number | % | time warning in percent of total time (during downtimes) |
| `service` | string |  | service description |
| `time_critical` | number | s | total seconds in state critical |
| `time_critical_percent` | number | % | time critical in percent of total time |
| `time_indeterminate_nodata` | number | s | total seconds without any data |
| `time_indeterminate_nodata_percent` | number | % | time without any data in percent of total time (during downtimes) |
| `time_indeterminate_notrunning` | number | s | total seconds during core not running |
| `time_indeterminate_notrunning_percent` | number | % | time during core not running in percent of total time |
| `time_indeterminate_outside_timeperiod` | number | s | total seconds outside the given timeperiod |
| `time_indeterminate_outside_timeperiod_percent` | number | % | time outside the given timeperiod in percent of total time |
| `time_ok` | number | s | total seconds in state ok |
| `time_ok_percent` | number | % | time ok in percent of total time |
| `time_unknown` | number | s | total seconds in state unknown |
| `time_unknown_percent` | number | % | time unknown in percent of total time |
| `time_warning` | number | s | total seconds in state warning |
| `time_warning_percent` | number | % | time warning in percent of total time |

### `POST /servicegroups/<name>/cmd/...` {#post-servicegroupsnamecmd}

list of supported commands:

 - [disable_servicegroup_host_checks](#post-servicegroupsnamecmddisable_servicegroup_host_checks)
 - [disable_servicegroup_host_notifications](#post-servicegroupsnamecmddisable_servicegroup_host_notifications)
 - [disable_servicegroup_passive_host_checks](#post-servicegroupsnamecmddisable_servicegroup_passive_host_checks)
 - [disable_servicegroup_passive_svc_checks](#post-servicegroupsnamecmddisable_servicegroup_passive_svc_checks)
 - [disable_servicegroup_svc_checks](#post-servicegroupsnamecmddisable_servicegroup_svc_checks)
 - [disable_servicegroup_svc_notifications](#post-servicegroupsnamecmddisable_servicegroup_svc_notifications)
 - [enable_servicegroup_host_checks](#post-servicegroupsnamecmdenable_servicegroup_host_checks)
 - [enable_servicegroup_host_notifications](#post-servicegroupsnamecmdenable_servicegroup_host_notifications)
 - [enable_servicegroup_passive_host_checks](#post-servicegroupsnamecmdenable_servicegroup_passive_host_checks)
 - [enable_servicegroup_passive_svc_checks](#post-servicegroupsnamecmdenable_servicegroup_passive_svc_checks)
 - [enable_servicegroup_svc_checks](#post-servicegroupsnamecmdenable_servicegroup_svc_checks)
 - [enable_servicegroup_svc_notifications](#post-servicegroupsnamecmdenable_servicegroup_svc_notifications)
 - [schedule_servicegroup_host_downtime](#post-servicegroupsnamecmdschedule_servicegroup_host_downtime)
 - [schedule_servicegroup_svc_downtime](#post-servicegroupsnamecmdschedule_servicegroup_svc_downtime)

### `POST /servicegroups/<name>/cmd/disable_servicegroup_host_checks` {#post-servicegroupsnamecmddisable_servicegroup_host_checks}

Sends the DISABLE_SERVICEGROUP_HOST_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_servicegroup_host_checks.html for details.

### `POST /servicegroups/<name>/cmd/disable_servicegroup_host_notifications` {#post-servicegroupsnamecmddisable_servicegroup_host_notifications}

Sends the DISABLE_SERVICEGROUP_HOST_NOTIFICATIONS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_servicegroup_host_notifications.html for details.

### `POST /servicegroups/<name>/cmd/disable_servicegroup_passive_host_checks` {#post-servicegroupsnamecmddisable_servicegroup_passive_host_checks}

Disables the acceptance and processing of passive checks for all hosts that have services that are members of a particular service group.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_servicegroup_passive_host_checks.html for details.

### `POST /servicegroups/<name>/cmd/disable_servicegroup_passive_svc_checks` {#post-servicegroupsnamecmddisable_servicegroup_passive_svc_checks}

Disables the acceptance and processing of passive checks for all services in a particular servicegroup.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_servicegroup_passive_svc_checks.html for details.

### `POST /servicegroups/<name>/cmd/disable_servicegroup_svc_checks` {#post-servicegroupsnamecmddisable_servicegroup_svc_checks}

Sends the DISABLE_SERVICEGROUP_SVC_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_servicegroup_svc_checks.html for details.

### `POST /servicegroups/<name>/cmd/disable_servicegroup_svc_notifications` {#post-servicegroupsnamecmddisable_servicegroup_svc_notifications}

Sends the DISABLE_SERVICEGROUP_SVC_NOTIFICATIONS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_servicegroup_svc_notifications.html for details.

### `POST /servicegroups/<name>/cmd/enable_servicegroup_host_checks` {#post-servicegroupsnamecmdenable_servicegroup_host_checks}

Sends the ENABLE_SERVICEGROUP_HOST_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_servicegroup_host_checks.html for details.

### `POST /servicegroups/<name>/cmd/enable_servicegroup_host_notifications` {#post-servicegroupsnamecmdenable_servicegroup_host_notifications}

Sends the ENABLE_SERVICEGROUP_HOST_NOTIFICATIONS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_servicegroup_host_notifications.html for details.

### `POST /servicegroups/<name>/cmd/enable_servicegroup_passive_host_checks` {#post-servicegroupsnamecmdenable_servicegroup_passive_host_checks}

Enables the acceptance and processing of passive checks for all hosts that have services that are members of a particular service group.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_servicegroup_passive_host_checks.html for details.

### `POST /servicegroups/<name>/cmd/enable_servicegroup_passive_svc_checks` {#post-servicegroupsnamecmdenable_servicegroup_passive_svc_checks}

Enables the acceptance and processing of passive checks for all services in a particular servicegroup.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_servicegroup_passive_svc_checks.html for details.

### `POST /servicegroups/<name>/cmd/enable_servicegroup_svc_checks` {#post-servicegroupsnamecmdenable_servicegroup_svc_checks}

Sends the ENABLE_SERVICEGROUP_SVC_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_servicegroup_svc_checks.html for details.

### `POST /servicegroups/<name>/cmd/enable_servicegroup_svc_notifications` {#post-servicegroupsnamecmdenable_servicegroup_svc_notifications}

Sends the ENABLE_SERVICEGROUP_SVC_NOTIFICATIONS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_servicegroup_svc_notifications.html for details.

### `POST /servicegroups/<name>/cmd/schedule_servicegroup_host_downtime` {#post-servicegroupsnamecmdschedule_servicegroup_host_downtime}

Sends the SCHEDULE_SERVICEGROUP_HOST_DOWNTIME command.

Required arguments:

  * comment_data

Optional arguments:

  * start_time
  * end_time
  * fixed
  * triggered_by
  * duration
  * comment_author

See https://www.naemon.io/documentation/developer/externalcommands/schedule_servicegroup_host_downtime.html for details.

### `POST /servicegroups/<name>/cmd/schedule_servicegroup_svc_downtime` {#post-servicegroupsnamecmdschedule_servicegroup_svc_downtime}

Sends the SCHEDULE_SERVICEGROUP_SVC_DOWNTIME command.

Required arguments:

  * comment_data

Optional arguments:

  * start_time
  * end_time
  * fixed
  * triggered_by
  * duration
  * comment_author

See https://www.naemon.io/documentation/developer/externalcommands/schedule_servicegroup_svc_downtime.html for details.

### `GET /servicegroups/<name>/config` {#get-servicegroupsnameconfig}

Returns configuration for given servicegroup.
You will find available attributes here: https://www.naemon.io/documentation/usersguide/objectdefinitions.html#servicegroup

### `POST /servicegroups/<name>/config` {#post-servicegroupsnameconfig}

Replace servicegroup configuration completely, use PATCH to only update specific attributes.

### `PATCH /servicegroups/<name>/config` {#patch-servicegroupsnameconfig}

Update servicegroup configuration partially.

### `DELETE /servicegroups/<name>/config` {#delete-servicegroupsnameconfig}

Deletes given servicegroup from configuration.

### `GET /servicegroups/<name>/outages` {#get-servicegroupsnameoutages}

list of outages for this servicegroup.

Optional arguments:

  * type              - both | hosts | services
  * timeperiod        - last24hours | lastmonth | thismonth | ...
  * start             - unix timestamp
  * end               - unix timestamp
  * withdowntimes     - 0/1 whether downtimes should count as outages
  * includesoftstates - 0/1 whether soft states should be used as well

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `class` | string |  | host/service status |
| `duration` | number | s | outage duration in seconds |
| `end` | time |  | unix timestamp of outage end |
| `host` | string |  | host name |
| `plugin_output` | string |  | last plugin output during outage |
| `service` | string |  | service description (only for service outages) |
| `start` | time |  | unix timestamp of outage start |
| `type` | string |  | log entry type |

### `GET /servicegroups/<name>/stats` {#get-servicegroupsnamestats}

hash of livestatus servicegroup statistics.
alias for `/services/stats?service_groups[gte]=<name>`

Additional attributes added by Thruk:

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `active_checks_disabled_active` | number |  | Services with active checks disabled that are active |
| `active_checks_disabled_passive` | number |  | Services with active checks disabled that are passive |
| `critical` | number |  | Number of services in CRITICAL state |
| `critical_and_ack` | number |  | Number of services in CRITICAL state with acknowledgement |
| `critical_and_disabled_active` | number |  | Number of services in CRITICAL state with active checks disabled |
| `critical_and_disabled_passive` | number |  | Number of services in CRITICAL state with passive checks disabled |
| `critical_and_scheduled` | number |  | Number of services in CRITICAL state with scheduled downtime |
| `critical_and_unhandled` | number |  | Number of unhandled services in CRITICAL state |
| `critical_hard` | number |  | Number of services in hard CRITICAL state |
| `critical_hard_unhandled` | number |  | Number of unhandled services in hard CRITICAL state |
| `critical_on_down_host` | number |  | Number of services in CRITICAL state on down hosts |
| `critical_soft` | number |  | Number of services in soft CRITICAL state |
| `eventhandler_disabled` | boolean |  | Whether event handler is disabled |
| `flapping` | number |  | Number of services that are flapping |
| `flapping_disabled` | boolean |  | Whether flap detection is disabled |
| `hard` | number |  | Number of services in hard state |
| `notifications_disabled` | boolean |  | Whether notifications are disabled |
| `ok` | number |  | Number of services in OK state |
| `ok_and_disabled_active` | number |  | Number of services in OK state with active checks disabled |
| `ok_and_disabled_passive` | number |  | Number of services in OK state with passive checks disabled |

### `GET /services` {#get-services}

lists livestatus services.
see https://www.naemon.io/documentation/usersguide/livestatus.html#services for details.

Additional attributes added by Thruk:

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `accept_passive_checks` | boolean |  | Whether passive service checks are accepted (0/1) |
| `action_url_expanded` | string |  | The action url with the most important macros expanded |
| `check_options` | string |  | The current check option: forced, normal, freshness (0-2) |
| `checks_enabled` | boolean |  | Whether checks are enabled (0/1) |
| `comments` | string |  | A list of the ids of all comments |
| `comments_info` | string |  | A list of all comments with id, author, comment, entry_type and entry_time |
| `comments_with_info` | string |  | A list of all comments with id, author, comment, entry_type, expires and expire_time |
| `custom_variable_names` | array_of_strings |  | A list of the names of all custom variables |
| `custom_variable_values` | array_of_strings |  | A list of the values of the custom variables |

### `GET /services/<host>/<service>` {#get-serviceshostservice}

lists services for given host and name.
alias for `/services?host_name=<host_name>&description=<service>`
supports wildcards for: `<host>` and `<service>`

### `GET /services/<host>/<service>/availability` {#get-serviceshostserviceavailability}

list of outages for this service.

Optional arguments:

  * type              - both | hosts | services
  * timeperiod        - last24hours | lastmonth | thismonth | ...
  * start             - unix timestamp
  * end               - unix timestamp
  * withdowntimes     - 0/1 whether downtimes should count as outages
  * includesoftstates - 0/1 whether soft states should be used as well

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `scheduled_time_critical` | number | s | total seconds in state critical (during downtimes) |
| `scheduled_time_critical_percent` | number | % | time critical in percent of total time (during downtimes) |
| `scheduled_time_indeterminate` | number | s | total seconds unknown (during downtimes) |
| `scheduled_time_indeterminate_percent` | number | % | time unknown in percent of total time (during downtimes) |
| `scheduled_time_ok` | number | s | total seconds in state ok (during downtimes) |
| `scheduled_time_ok_percent` | number | % | time ok in percent of total time (during downtimes) |
| `scheduled_time_unknown` | number | s | total seconds in state unknown (during downtimes) |
| `scheduled_time_unknown_percent` | number | % | time unknown in percent of total time (during downtimes) |
| `scheduled_time_warning` | number | s | total seconds in state warning (during downtimes) |
| `scheduled_time_warning_percent` | number | % | time warning in percent of total time (during downtimes) |
| `time_critical` | number | s | total seconds in state critical |
| `time_critical_percent` | number | % | time critical in percent of total time |
| `time_indeterminate_nodata` | number | s | total seconds without any data |
| `time_indeterminate_nodata_percent` | number | % | time without any data in percent of total time (during downtimes) |
| `time_indeterminate_notrunning` | number | s | total seconds during core not running |
| `time_indeterminate_notrunning_percent` | number | % | time during core not running in percent of total time |
| `time_indeterminate_outside_timeperiod` | number | s | total seconds outside the given timeperiod |
| `time_indeterminate_outside_timeperiod_percent` | number | % | time outside the given timeperiod in percent of total time |
| `time_ok` | number | s | total seconds in state ok |
| `time_ok_percent` | number | % | time ok in percent of total time |
| `time_unknown` | number | s | total seconds in state unknown |
| `time_unknown_percent` | number | % | time unknown in percent of total time |
| `time_warning` | number | s | total seconds in state warning |
| `time_warning_percent` | number | % | time warning in percent of total time |

### `POST /services/<host>/<service>/cmd/...` {#post-serviceshostservicecmd}

list of supported commands:

 - [acknowledge_svc_problem](#post-serviceshostservicecmdacknowledge_svc_problem)
 - [acknowledge_svc_problem_expire](#post-serviceshostservicecmdacknowledge_svc_problem_expire)
 - [add_svc_comment](#post-serviceshostservicecmdadd_svc_comment)
 - [change_custom_svc_var](#post-serviceshostservicecmdchange_custom_svc_var)
 - [change_max_svc_check_attempts](#post-serviceshostservicecmdchange_max_svc_check_attempts)
 - [change_normal_svc_check_interval](#post-serviceshostservicecmdchange_normal_svc_check_interval)
 - [change_retry_svc_check_interval](#post-serviceshostservicecmdchange_retry_svc_check_interval)
 - [change_svc_check_timeperiod](#post-serviceshostservicecmdchange_svc_check_timeperiod)
 - [change_svc_modattr](#post-serviceshostservicecmdchange_svc_modattr)
 - [change_svc_notification_timeperiod](#post-serviceshostservicecmdchange_svc_notification_timeperiod)
 - [del_active_service_downtimes](#post-serviceshostservicecmddel_active_service_downtimes)
 - [del_all_svc_comments](#post-serviceshostservicecmddel_all_svc_comments)
 - [del_comment](#post-serviceshostservicecmddel_comment)
 - [del_downtime](#post-serviceshostservicecmddel_downtime)
 - [delay_svc_notification](#post-serviceshostservicecmddelay_svc_notification)
 - [disable_passive_svc_checks](#post-serviceshostservicecmddisable_passive_svc_checks)
 - [disable_svc_check](#post-serviceshostservicecmddisable_svc_check)
 - [disable_svc_event_handler](#post-serviceshostservicecmddisable_svc_event_handler)
 - [disable_svc_flap_detection](#post-serviceshostservicecmddisable_svc_flap_detection)
 - [disable_svc_notifications](#post-serviceshostservicecmddisable_svc_notifications)
 - [enable_passive_svc_checks](#post-serviceshostservicecmdenable_passive_svc_checks)
 - [enable_svc_check](#post-serviceshostservicecmdenable_svc_check)
 - [enable_svc_event_handler](#post-serviceshostservicecmdenable_svc_event_handler)
 - [enable_svc_flap_detection](#post-serviceshostservicecmdenable_svc_flap_detection)
 - [enable_svc_notifications](#post-serviceshostservicecmdenable_svc_notifications)
 - [note](#post-serviceshostservicecmdnote)
 - [process_service_check_result](#post-serviceshostservicecmdprocess_service_check_result)
 - [remove_svc_acknowledgement](#post-serviceshostservicecmdremove_svc_acknowledgement)
 - [schedule_forced_svc_check](#post-serviceshostservicecmdschedule_forced_svc_check)
 - [schedule_svc_check](#post-serviceshostservicecmdschedule_svc_check)
 - [schedule_svc_downtime](#post-serviceshostservicecmdschedule_svc_downtime)
 - [send_custom_svc_notification](#post-serviceshostservicecmdsend_custom_svc_notification)
 - [set_svc_notification_number](#post-serviceshostservicecmdset_svc_notification_number)
 - [start_obsessing_over_svc](#post-serviceshostservicecmdstart_obsessing_over_svc)
 - [stop_obsessing_over_svc](#post-serviceshostservicecmdstop_obsessing_over_svc)

### `POST /services/<host>/<service>/cmd/acknowledge_svc_problem` {#post-serviceshostservicecmdacknowledge_svc_problem}

Sends the ACKNOWLEDGE_SVC_PROBLEM command.

Required arguments:

  * comment_data

Optional arguments:

  * sticky_ack
  * send_notification
  * persistent_comment
  * comment_author

See https://www.naemon.io/documentation/developer/externalcommands/acknowledge_svc_problem.html for details.

### `POST /services/<host>/<service>/cmd/acknowledge_svc_problem_expire` {#post-serviceshostservicecmdacknowledge_svc_problem_expire}

Sends the ACKNOWLEDGE_SVC_PROBLEM_EXPIRE command.

Required arguments:

  * comment_data

Optional arguments:

  * sticky_ack
  * send_notification
  * persistent_comment
  * end_time
  * comment_author

See https://www.naemon.io/documentation/developer/externalcommands/acknowledge_svc_problem_expire.html for details.

### `POST /services/<host>/<service>/cmd/add_svc_comment` {#post-serviceshostservicecmdadd_svc_comment}

Sends the ADD_SVC_COMMENT command.

Required arguments:

  * comment_data

Optional arguments:

  * persistent_comment
  * comment_author

See https://www.naemon.io/documentation/developer/externalcommands/add_svc_comment.html for details.

### `POST /services/<host>/<service>/cmd/change_custom_svc_var` {#post-serviceshostservicecmdchange_custom_svc_var}

Changes the value of a custom service variable.

Required arguments:

  * name
  * value

See https://www.naemon.io/documentation/developer/externalcommands/change_custom_svc_var.html for details.

### `POST /services/<host>/<service>/cmd/change_max_svc_check_attempts` {#post-serviceshostservicecmdchange_max_svc_check_attempts}

Changes the maximum number of check attempts (retries) for a particular service.

Required arguments:

  * attempts

See https://www.naemon.io/documentation/developer/externalcommands/change_max_svc_check_attempts.html for details.

### `POST /services/<host>/<service>/cmd/change_normal_svc_check_interval` {#post-serviceshostservicecmdchange_normal_svc_check_interval}

Changes the normal (regularly scheduled) check interval for a particular service

Required arguments:

  * interval

See https://www.naemon.io/documentation/developer/externalcommands/change_normal_svc_check_interval.html for details.

### `POST /services/<host>/<service>/cmd/change_retry_svc_check_interval` {#post-serviceshostservicecmdchange_retry_svc_check_interval}

Changes the retry check interval for a particular service.

Required arguments:

  * interval

See https://www.naemon.io/documentation/developer/externalcommands/change_retry_svc_check_interval.html for details.

### `POST /services/<host>/<service>/cmd/change_svc_check_timeperiod` {#post-serviceshostservicecmdchange_svc_check_timeperiod}

Changes the check timeperiod for a particular service to what is specified by the 'check_timeperiod' option. The 'check_timeperiod' option should be the short name of the timeperiod that is to be used as the service check timeperiod. The timeperiod must have been configured in Naemon before it was last (re)started.

Required arguments:

  * timeperiod

See https://www.naemon.io/documentation/developer/externalcommands/change_svc_check_timeperiod.html for details.

### `POST /services/<host>/<service>/cmd/change_svc_modattr` {#post-serviceshostservicecmdchange_svc_modattr}

Sends the CHANGE_SVC_MODATTR command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/change_svc_modattr.html for details.

### `POST /services/<host>/<service>/cmd/change_svc_notification_timeperiod` {#post-serviceshostservicecmdchange_svc_notification_timeperiod}

Changes the service notification timeperiod to what is specified by the 'notification_timeperiod' option. The 'notification_timeperiod' option should be the short name of the timeperiod that is to be used as the service notification timeperiod. The timeperiod must have been configured in Naemon before it was last (re)started.

Required arguments:

  * timeperiod

See https://www.naemon.io/documentation/developer/externalcommands/change_svc_notification_timeperiod.html for details.

### `POST /services/<host>/<service>/cmd/del_active_service_downtimes` {#post-serviceshostservicecmddel_active_service_downtimes}

Removes all currently active downtimes for this service.

This command does not require any arguments.

### `POST /services/<host>/<service>/cmd/del_all_svc_comments` {#post-serviceshostservicecmddel_all_svc_comments}

Sends the DEL_ALL_SVC_COMMENTS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/del_all_svc_comments.html for details.

### `POST /services/<host>/<service>/cmd/del_comment` {#post-serviceshostservicecmddel_comment}

Removes comment by id for this service.

Required arguments:

  * comment_id

### `POST /services/<host>/<service>/cmd/del_downtime` {#post-serviceshostservicecmddel_downtime}

Removes downtime by id for this service.

Required arguments:

  * downtime_id

### `POST /services/<host>/<service>/cmd/delay_svc_notification` {#post-serviceshostservicecmddelay_svc_notification}

Sends the DELAY_SVC_NOTIFICATION command.

Required arguments:

  * notification_time

See https://www.naemon.io/documentation/developer/externalcommands/delay_svc_notification.html for details.

### `POST /services/<host>/<service>/cmd/disable_passive_svc_checks` {#post-serviceshostservicecmddisable_passive_svc_checks}

Sends the DISABLE_PASSIVE_SVC_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_passive_svc_checks.html for details.

### `POST /services/<host>/<service>/cmd/disable_svc_check` {#post-serviceshostservicecmddisable_svc_check}

Sends the DISABLE_SVC_CHECK command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_svc_check.html for details.

### `POST /services/<host>/<service>/cmd/disable_svc_event_handler` {#post-serviceshostservicecmddisable_svc_event_handler}

Sends the DISABLE_SVC_EVENT_HANDLER command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_svc_event_handler.html for details.

### `POST /services/<host>/<service>/cmd/disable_svc_flap_detection` {#post-serviceshostservicecmddisable_svc_flap_detection}

Sends the DISABLE_SVC_FLAP_DETECTION command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_svc_flap_detection.html for details.

### `POST /services/<host>/<service>/cmd/disable_svc_notifications` {#post-serviceshostservicecmddisable_svc_notifications}

Sends the DISABLE_SVC_NOTIFICATIONS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_svc_notifications.html for details.

### `POST /services/<host>/<service>/cmd/enable_passive_svc_checks` {#post-serviceshostservicecmdenable_passive_svc_checks}

Sends the ENABLE_PASSIVE_SVC_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_passive_svc_checks.html for details.

### `POST /services/<host>/<service>/cmd/enable_svc_check` {#post-serviceshostservicecmdenable_svc_check}

Sends the ENABLE_SVC_CHECK command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_svc_check.html for details.

### `POST /services/<host>/<service>/cmd/enable_svc_event_handler` {#post-serviceshostservicecmdenable_svc_event_handler}

Sends the ENABLE_SVC_EVENT_HANDLER command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_svc_event_handler.html for details.

### `POST /services/<host>/<service>/cmd/enable_svc_flap_detection` {#post-serviceshostservicecmdenable_svc_flap_detection}

Sends the ENABLE_SVC_FLAP_DETECTION command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_svc_flap_detection.html for details.

### `POST /services/<host>/<service>/cmd/enable_svc_notifications` {#post-serviceshostservicecmdenable_svc_notifications}

Sends the ENABLE_SVC_NOTIFICATIONS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_svc_notifications.html for details.

### `POST /services/<host>/<service>/cmd/note` {#post-serviceshostservicecmdnote}

Add service note to core log.

Required arguments:

  * log

### `POST /services/<host>/<service>/cmd/process_service_check_result` {#post-serviceshostservicecmdprocess_service_check_result}

Sends the PROCESS_SERVICE_CHECK_RESULT command.

Required arguments:

  * plugin_state
  * plugin_output

Optional arguments:

  * performance_data

See https://www.naemon.io/documentation/developer/externalcommands/process_service_check_result.html for details.

### `POST /services/<host>/<service>/cmd/remove_svc_acknowledgement` {#post-serviceshostservicecmdremove_svc_acknowledgement}

Sends the REMOVE_SVC_ACKNOWLEDGEMENT command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/remove_svc_acknowledgement.html for details.

### `POST /services/<host>/<service>/cmd/schedule_forced_svc_check` {#post-serviceshostservicecmdschedule_forced_svc_check}

Sends the SCHEDULE_FORCED_SVC_CHECK command.

Optional arguments:

  * start_time

See https://www.naemon.io/documentation/developer/externalcommands/schedule_forced_svc_check.html for details.

### `POST /services/<host>/<service>/cmd/schedule_svc_check` {#post-serviceshostservicecmdschedule_svc_check}

Sends the SCHEDULE_SVC_CHECK command.

Optional arguments:

  * start_time

See https://www.naemon.io/documentation/developer/externalcommands/schedule_svc_check.html for details.

### `POST /services/<host>/<service>/cmd/schedule_svc_downtime` {#post-serviceshostservicecmdschedule_svc_downtime}

Sends the SCHEDULE_SVC_DOWNTIME command.

Required arguments:

  * comment_data

Optional arguments:

  * start_time
  * end_time
  * fixed
  * triggered_by
  * duration
  * comment_author

See https://www.naemon.io/documentation/developer/externalcommands/schedule_svc_downtime.html for details.

### `POST /services/<host>/<service>/cmd/send_custom_svc_notification` {#post-serviceshostservicecmdsend_custom_svc_notification}

Sends the SEND_CUSTOM_SVC_NOTIFICATION command.

Required arguments:

  * comment_data

Optional arguments:

  * options
  * comment_author

See https://www.naemon.io/documentation/developer/externalcommands/send_custom_svc_notification.html for details.

### `POST /services/<host>/<service>/cmd/set_svc_notification_number` {#post-serviceshostservicecmdset_svc_notification_number}

Sets the current notification number for a particular service. A value of 0 indicates that no notification has yet been sent for the current service problem. Useful for forcing an escalation (based on notification number) or replicating notification information in redundant monitoring environments. Notification numbers greater than zero have no noticeable affect on the notification process if the service is currently in an OK state.

Required arguments:

  * number

See https://www.naemon.io/documentation/developer/externalcommands/set_svc_notification_number.html for details.

### `POST /services/<host>/<service>/cmd/start_obsessing_over_svc` {#post-serviceshostservicecmdstart_obsessing_over_svc}

Sends the START_OBSESSING_OVER_SVC command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/start_obsessing_over_svc.html for details.

### `POST /services/<host>/<service>/cmd/stop_obsessing_over_svc` {#post-serviceshostservicecmdstop_obsessing_over_svc}

Sends the STOP_OBSESSING_OVER_SVC command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/stop_obsessing_over_svc.html for details.

### `GET /services/<host>/<service>/commandline` {#get-serviceshostservicecommandline}

displays commandline for check command of given services.
supports wildcards for: `<host>` and `<service>`

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `check_command` | string |  | name of the check_command including arguments |
| `command_line` | string |  | full expanded command line (if possible) |
| `error` | string |  | contains the error if expanding failed for some reason |
| `host_name` | string |  | host name |
| `peer_key` | string |  | id as defined in Thruk::Backend component configuration |
| `peer_name` | string |  | name as defined in Thruk::Backend component configuration |
| `peer_section` | string |  | section as defined in Thruk::Backend component configuration |
| `service_description` | string |  | service name |

### `GET /services/<host>/<service>/config` {#get-serviceshostserviceconfig}

Returns configuration for given service.
You will find available attributes here: https://www.naemon.io/documentation/usersguide/objectdefinitions.html#service

### `POST /services/<host>/<service>/config` {#post-serviceshostserviceconfig}

Replace service configuration completely, use PATCH to only update specific attributes.

### `PATCH /services/<host>/<service>/config` {#patch-serviceshostserviceconfig}

Update service configuration partially.

### `DELETE /services/<host>/<service>/config` {#delete-serviceshostserviceconfig}

Deletes given service from configuration.

### `GET /services/<host>/<service>/outages` {#get-serviceshostserviceoutages}

list of outages for this service.

Optional arguments:

  * type              - both | hosts | services
  * timeperiod        - last24hours | lastmonth | thismonth | ...
  * start             - unix timestamp
  * end               - unix timestamp
  * withdowntimes     - 0/1 whether downtimes should count as outages
  * includesoftstates - 0/1 whether soft states should be used as well

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `class` | string |  | host/service status |
| `duration` | number | s | outage duration in seconds |
| `end` | time |  | unix timestamp of outage end |
| `host` | string |  | host name |
| `plugin_output` | string |  | last plugin output during outage |
| `service` | string |  | service description (only for service outages) |
| `start` | time |  | unix timestamp of outage start |
| `type` | string |  | log entry type |

### `GET /services/availability` {#get-servicesavailability}

list availability for all services.

Optional arguments:

  * type              - both | hosts | services
  * timeperiod        - last24hours | lastmonth | thismonth | ...
  * start             - unix timestamp
  * end               - unix timestamp
  * withdowntimes     - 0/1 whether downtimes should count as outages
  * includesoftstates - 0/1 whether soft states should be used as well

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `host` | string |  | host name |
| `scheduled_time_critical` | number | s | total seconds in state critical (during downtimes) |
| `scheduled_time_critical_percent` | number | % | time critical in percent of total time (during downtimes) |
| `scheduled_time_indeterminate` | number | s | total seconds unknown (during downtimes) |
| `scheduled_time_indeterminate_percent` | number | % | time unknown in percent of total time (during downtimes) |
| `scheduled_time_ok` | number | s | total seconds in state ok (during downtimes) |
| `scheduled_time_ok_percent` | number | % | time ok in percent of total time (during downtimes) |
| `scheduled_time_unknown` | number | s | total seconds in state unknown (during downtimes) |
| `scheduled_time_unknown_percent` | number | % | time unknown in percent of total time (during downtimes) |
| `scheduled_time_warning` | number | s | total seconds in state warning (during downtimes) |
| `scheduled_time_warning_percent` | number | % | time warning in percent of total time (during downtimes) |
| `service` | string |  | service description |
| `time_critical` | number | s | total seconds in state critical |
| `time_critical_percent` | number | % | time critical in percent of total time |
| `time_indeterminate_nodata` | number | s | total seconds without any data |
| `time_indeterminate_nodata_percent` | number | % | time without any data in percent of total time (during downtimes) |
| `time_indeterminate_notrunning` | number | s | total seconds during core not running |
| `time_indeterminate_notrunning_percent` | number | % | time during core not running in percent of total time |
| `time_indeterminate_outside_timeperiod` | number | s | total seconds outside the given timeperiod |
| `time_indeterminate_outside_timeperiod_percent` | number | % | time outside the given timeperiod in percent of total time |
| `time_ok` | number | s | total seconds in state ok |
| `time_ok_percent` | number | % | time ok in percent of total time |
| `time_unknown` | number | s | total seconds in state unknown |
| `time_unknown_percent` | number | % | time unknown in percent of total time |
| `time_warning` | number | s | total seconds in state warning |
| `time_warning_percent` | number | % | time warning in percent of total time |

### `GET /services/outages` {#get-servicesoutages}

list of outages for all services.

Optional arguments:

  * type              - both | hosts | services
  * timeperiod        - last24hours | lastmonth | thismonth | ...
  * start             - unix timestamp
  * end               - unix timestamp
  * withdowntimes     - 0/1 whether downtimes should count as outages
  * includesoftstates - 0/1 whether soft states should be used as well

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `class` | string |  | host/service status |
| `duration` | number | s | outage duration in seconds |
| `end` | time |  | unix timestamp of outage end |
| `host` | string |  | host name |
| `plugin_output` | string |  | last plugin output during outage |
| `service` | string |  | service description (only for service outages) |
| `start` | time |  | unix timestamp of outage start |
| `type` | string |  | log entry type |

### `GET /services/stats` {#get-servicesstats}

livestatus service statistics.

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `active_checks_disabled_active` | number |  | number of active services which have active checks disabled |
| `active_checks_disabled_passive` | number |  | number of passive services which have active checks disabled |
| `critical` | number |  | number of critical services |
| `critical_and_ack` | number |  | number of critical services which are acknowledged |
| `critical_and_disabled_active` | number |  | number of active critical services which have active checks disabled |
| `critical_and_disabled_passive` | number |  | number of passive critical services which have active checks disabled |
| `critical_and_scheduled` | number |  | number of critical services which are in a scheduled downtime |
| `critical_and_unhandled` | number |  | number of unhandled critical services |
| `critical_hard` | number |  | number of critical services in hard state |
| `critical_hard_unhandled` | number |  | number of unhandled critical services in hard state |
| `critical_on_down_host` | number |  | number of unhandled critical services on down hosts |
| `critical_soft` | number |  | number of critical services in soft state |
| `eventhandler_disabled` | number |  | number of services with eventhandlers disabled |
| `flapping` | number |  | number of flapping services |
| `flapping_disabled` | number |  | number of services with flapping detection disabled |
| `hard` | number |  | number of services in hard state |
| `notifications_disabled` | number |  | number of services with notifications disabled |
| `ok` | number |  | number of ok services |
| `ok_and_disabled_active` | number |  | number of active ok services which have active checks disabled |
| `ok_and_disabled_passive` | number |  | number of passive ok services which have active checks disabled |
| `ok_and_scheduled` | number |  | number of ok services which are in a scheduled downtime |
| `passive_checks_disabled` | number |  | number of services which do not accept passive check results |
| `pending` | number |  | number of pending services |
| `pending_and_disabled` | number |  | number of pending services with active checks disabled |
| `pending_and_scheduled` | number |  | number of pending services which are in a scheduled downtime |
| `plain_critical` | number |  | number of critical services which are not acknowleded or in a downtime |
| `plain_ok` | number |  | number of ok services which are not acknowleded or in a downtime |
| `plain_pending` | number |  | number of pending services which are not acknowleded or in a downtime |
| `plain_unknown` | number |  | number of unknown services which are not acknowleded or in a downtime |
| `plain_warning` | number |  | number of warning services which are not acknowleded or in a downtime |
| `soft` | number |  | number of services in soft state |
| `total` | number |  | total number of services |
| `total_active` | number |  | total number of active services |
| `total_passive` | number |  | total number of passive services |
| `unknown` | number |  | number of unknown services |
| `unknown_and_ack` | number |  | number of unknown services which are acknowledged |
| `unknown_and_disabled_active` | number |  | number of active unknown services which have active checks disabled |
| `unknown_and_disabled_passive` | number |  | number of passive unknown services which have active checks disabled |
| `unknown_and_scheduled` | number |  | number of unknown services which are in a scheduled downtime |
| `unknown_and_unhandled` | number |  | number of unhandled unknown services |
| `unknown_hard` | number |  | number of unknown services in hard state |
| `unknown_hard_unhandled` | number |  | number of unhandled unknown services in hard state |
| `unknown_on_down_host` | number |  | number of unhandled unknown services on down hosts |
| `unknown_soft` | number |  | number of unknown services in soft state |
| `warning` | number |  | number of warning services |
| `warning_and_ack` | number |  | number of warning services which are acknowledged |
| `warning_and_disabled_active` | number |  | number of active warning services which have active checks disabled |
| `warning_and_disabled_passive` | number |  | number of passive warning services which have active checks disabled |
| `warning_and_scheduled` | number |  | number of warning services which are in a scheduled downtime |
| `warning_and_unhandled` | number |  | number of unhandled warning services |
| `warning_hard` | number |  | number of warning services in hard state |
| `warning_hard_unhandled` | number |  | number of unhandled warning services in hard state |
| `warning_on_down_host` | number |  | number of unhandled warning services on down hosts |
| `warning_soft` | number |  | number of warning services in soft state |

### `GET /services/totals` {#get-servicestotals}

livestatus service totals statistics.
its basically a reduced set of /services/stats.

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `critical` | number |  | number of critical services |
| `critical_and_unhandled` | number |  | number of critical services which are neither acknowledged nor in scheduled downtime |
| `ok` | number |  | number of ok services |
| `pending` | number |  | number of pending services |
| `total` | number |  | total number of services |
| `unknown` | number |  | number of unknown services |
| `unknown_and_unhandled` | number |  | number of unknown services which are neither acknowledged nor in scheduled downtime |
| `warning` | number |  | number of warning services |
| `warning_and_unhandled` | number |  | number of warning services which are neither acknowledged nor in scheduled downtime |

### `GET /sites` {#get-sites}

lists configured backends

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `addr` | string |  | address for this connection |
| `connected` | boolean |  | flag whether sites is connected (1) or not (0) |
| `federation_addr` | string |  | contains the real address if using federation |
| `federation_key` | string |  | contains the real peer key if using federation |
| `federation_name` | string |  | contains the real name if using federation |
| `federation_type` | string |  | contains the real backend type if using federation |
| `federation_version` | string |  | contains the real backend version if using federation |
| `id` | string |  | id for this backend |
| `last_error` | time |  | error message if backend is not connected |
| `localtime` | time |  | current local unix timestamp of thruk host |
| `name` | string |  | name of the backend |
| `section` | string |  | section name |
| `status` | boolean |  | 0 (OK), 1 (DOWN) |
| `type` | string |  | type of the backend |

### `POST /system/cmd/...` {#post-systemcmd}

list of supported commands:

 - [change_global_host_event_handler](#post-systemcmdchange_global_host_event_handler)
 - [change_global_svc_event_handler](#post-systemcmdchange_global_svc_event_handler)
 - [del_downtime_by_host_name](#post-systemcmddel_downtime_by_host_name)
 - [del_downtime_by_hostgroup_name](#post-systemcmddel_downtime_by_hostgroup_name)
 - [del_downtime_by_start_time_comment](#post-systemcmddel_downtime_by_start_time_comment)
 - [del_host_comment](#post-systemcmddel_host_comment)
 - [del_host_downtime](#post-systemcmddel_host_downtime)
 - [del_svc_comment](#post-systemcmddel_svc_comment)
 - [del_svc_downtime](#post-systemcmddel_svc_downtime)
 - [disable_event_handlers](#post-systemcmddisable_event_handlers)
 - [disable_flap_detection](#post-systemcmddisable_flap_detection)
 - [disable_host_freshness_checks](#post-systemcmddisable_host_freshness_checks)
 - [disable_notifications](#post-systemcmddisable_notifications)
 - [disable_performance_data](#post-systemcmddisable_performance_data)
 - [disable_service_freshness_checks](#post-systemcmddisable_service_freshness_checks)
 - [enable_event_handlers](#post-systemcmdenable_event_handlers)
 - [enable_flap_detection](#post-systemcmdenable_flap_detection)
 - [enable_host_freshness_checks](#post-systemcmdenable_host_freshness_checks)
 - [enable_notifications](#post-systemcmdenable_notifications)
 - [enable_performance_data](#post-systemcmdenable_performance_data)
 - [enable_service_freshness_checks](#post-systemcmdenable_service_freshness_checks)
 - [log](#post-systemcmdlog)
 - [read_state_information](#post-systemcmdread_state_information)
 - [restart_process](#post-systemcmdrestart_process)
 - [restart_program](#post-systemcmdrestart_program)
 - [save_state_information](#post-systemcmdsave_state_information)
 - [shutdown_process](#post-systemcmdshutdown_process)
 - [shutdown_program](#post-systemcmdshutdown_program)
 - [start_accepting_passive_host_checks](#post-systemcmdstart_accepting_passive_host_checks)
 - [start_accepting_passive_svc_checks](#post-systemcmdstart_accepting_passive_svc_checks)
 - [start_executing_host_checks](#post-systemcmdstart_executing_host_checks)
 - [start_executing_svc_checks](#post-systemcmdstart_executing_svc_checks)
 - [start_obsessing_over_host_checks](#post-systemcmdstart_obsessing_over_host_checks)
 - [start_obsessing_over_svc_checks](#post-systemcmdstart_obsessing_over_svc_checks)
 - [stop_accepting_passive_host_checks](#post-systemcmdstop_accepting_passive_host_checks)
 - [stop_accepting_passive_svc_checks](#post-systemcmdstop_accepting_passive_svc_checks)
 - [stop_executing_host_checks](#post-systemcmdstop_executing_host_checks)
 - [stop_executing_svc_checks](#post-systemcmdstop_executing_svc_checks)
 - [stop_obsessing_over_host_checks](#post-systemcmdstop_obsessing_over_host_checks)
 - [stop_obsessing_over_svc_checks](#post-systemcmdstop_obsessing_over_svc_checks)

### `POST /system/cmd/change_global_host_event_handler` {#post-systemcmdchange_global_host_event_handler}

Changes the global host event handler command to be that specified by the 'event_handler_command' option. The 'event_handler_command' option specifies the short name of the command that should be used as the new host event handler. The command must have been configured in Naemon before it was last (re)started.

Required arguments:

  * eventhandler

See https://www.naemon.io/documentation/developer/externalcommands/change_global_host_event_handler.html for details.

### `POST /system/cmd/change_global_svc_event_handler` {#post-systemcmdchange_global_svc_event_handler}

Changes the global service event handler command to be that specified by the 'event_handler_command' option. The 'event_handler_command' option specifies the short name of the command that should be used as the new service event handler. The command must have been configured in Naemon before it was last (re)started.

Required arguments:

  * eventhandler

See https://www.naemon.io/documentation/developer/externalcommands/change_global_svc_event_handler.html for details.

### `POST /system/cmd/del_downtime_by_host_name` {#post-systemcmddel_downtime_by_host_name}

This command deletes all downtimes matching the specified filters.

Optional arguments:

  * hostname
  * service_desc
  * start_time
  * comment

See https://www.naemon.io/documentation/developer/externalcommands/del_downtime_by_host_name.html for details.

### `POST /system/cmd/del_downtime_by_hostgroup_name` {#post-systemcmddel_downtime_by_hostgroup_name}

This command deletes all downtimes matching the specified filters.

Optional arguments:

  * hostgroup_name
  * hostname
  * service_desc
  * start_time
  * comment

See https://www.naemon.io/documentation/developer/externalcommands/del_downtime_by_hostgroup_name.html for details.

### `POST /system/cmd/del_downtime_by_start_time_comment` {#post-systemcmddel_downtime_by_start_time_comment}

This command deletes all downtimes matching the specified filters.

Optional arguments:

  * start_time
  * comment

See https://www.naemon.io/documentation/developer/externalcommands/del_downtime_by_start_time_comment.html for details.

### `POST /system/cmd/del_host_comment` {#post-systemcmddel_host_comment}

Sends the DEL_HOST_COMMENT command.

Required arguments:

  * comment_id

See https://www.naemon.io/documentation/developer/externalcommands/del_host_comment.html for details.

### `POST /system/cmd/del_host_downtime` {#post-systemcmddel_host_downtime}

Sends the DEL_HOST_DOWNTIME command.

Required arguments:

  * downtime_id

See https://www.naemon.io/documentation/developer/externalcommands/del_host_downtime.html for details.

### `POST /system/cmd/del_svc_comment` {#post-systemcmddel_svc_comment}

Sends the DEL_SVC_COMMENT command.

Required arguments:

  * comment_id

See https://www.naemon.io/documentation/developer/externalcommands/del_svc_comment.html for details.

### `POST /system/cmd/del_svc_downtime` {#post-systemcmddel_svc_downtime}

Sends the DEL_SVC_DOWNTIME command.

Required arguments:

  * downtime_id

See https://www.naemon.io/documentation/developer/externalcommands/del_svc_downtime.html for details.

### `POST /system/cmd/disable_event_handlers` {#post-systemcmddisable_event_handlers}

Sends the DISABLE_EVENT_HANDLERS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_event_handlers.html for details.

### `POST /system/cmd/disable_flap_detection` {#post-systemcmddisable_flap_detection}

Sends the DISABLE_FLAP_DETECTION command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_flap_detection.html for details.

### `POST /system/cmd/disable_host_freshness_checks` {#post-systemcmddisable_host_freshness_checks}

Disables freshness checks of all hosts on a program-wide basis.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_host_freshness_checks.html for details.

### `POST /system/cmd/disable_notifications` {#post-systemcmddisable_notifications}

Sends the DISABLE_NOTIFICATIONS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_notifications.html for details.

### `POST /system/cmd/disable_performance_data` {#post-systemcmddisable_performance_data}

Sends the DISABLE_PERFORMANCE_DATA command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_performance_data.html for details.

### `POST /system/cmd/disable_service_freshness_checks` {#post-systemcmddisable_service_freshness_checks}

Disables freshness checks of all services on a program-wide basis.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/disable_service_freshness_checks.html for details.

### `POST /system/cmd/enable_event_handlers` {#post-systemcmdenable_event_handlers}

Sends the ENABLE_EVENT_HANDLERS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_event_handlers.html for details.

### `POST /system/cmd/enable_flap_detection` {#post-systemcmdenable_flap_detection}

Sends the ENABLE_FLAP_DETECTION command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_flap_detection.html for details.

### `POST /system/cmd/enable_host_freshness_checks` {#post-systemcmdenable_host_freshness_checks}

Enables freshness checks of all hosts on a program-wide basis. Individual hosts that have freshness checks disabled will not be checked for freshness.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_host_freshness_checks.html for details.

### `POST /system/cmd/enable_notifications` {#post-systemcmdenable_notifications}

Sends the ENABLE_NOTIFICATIONS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_notifications.html for details.

### `POST /system/cmd/enable_performance_data` {#post-systemcmdenable_performance_data}

Sends the ENABLE_PERFORMANCE_DATA command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_performance_data.html for details.

### `POST /system/cmd/enable_service_freshness_checks` {#post-systemcmdenable_service_freshness_checks}

Enables freshness checks of all services on a program-wide basis. Individual services that have freshness checks disabled will not be checked for freshness.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/enable_service_freshness_checks.html for details.

### `POST /system/cmd/log` {#post-systemcmdlog}

Add custom log entry to core log.

Required arguments:

  * log

See https://www.naemon.io/documentation/developer/externalcommands/log.html for details.

### `POST /system/cmd/read_state_information` {#post-systemcmdread_state_information}

Causes Naemon to load all current monitoring status information from the state retention file. Normally, state retention information is loaded when the Naemon process starts up and before it starts monitoring. WARNING: This command will cause Naemon to discard all current monitoring status information and use the information stored in state retention file! Use with care.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/read_state_information.html for details.

### `POST /system/cmd/restart_process` {#post-systemcmdrestart_process}

Sends the RESTART_PROCESS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/restart_process.html for details.

### `POST /system/cmd/restart_program` {#post-systemcmdrestart_program}

Restarts the Naemon process.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/restart_program.html for details.

### `POST /system/cmd/save_state_information` {#post-systemcmdsave_state_information}

Causes Naemon to save all current monitoring status information to the state retention file. Normally, state retention information is saved before the Naemon process shuts down and (potentially) at regularly scheduled intervals. This command allows you to force Naemon to save this information to the state retention file immediately. This does not affect the current status information in the Naemon process.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/save_state_information.html for details.

### `POST /system/cmd/shutdown_process` {#post-systemcmdshutdown_process}

Sends the SHUTDOWN_PROCESS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/shutdown_process.html for details.

### `POST /system/cmd/shutdown_program` {#post-systemcmdshutdown_program}

Shuts down the Naemon process.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/shutdown_program.html for details.

### `POST /system/cmd/start_accepting_passive_host_checks` {#post-systemcmdstart_accepting_passive_host_checks}

Sends the START_ACCEPTING_PASSIVE_HOST_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/start_accepting_passive_host_checks.html for details.

### `POST /system/cmd/start_accepting_passive_svc_checks` {#post-systemcmdstart_accepting_passive_svc_checks}

Sends the START_ACCEPTING_PASSIVE_SVC_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/start_accepting_passive_svc_checks.html for details.

### `POST /system/cmd/start_executing_host_checks` {#post-systemcmdstart_executing_host_checks}

Sends the START_EXECUTING_HOST_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/start_executing_host_checks.html for details.

### `POST /system/cmd/start_executing_svc_checks` {#post-systemcmdstart_executing_svc_checks}

Sends the START_EXECUTING_SVC_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/start_executing_svc_checks.html for details.

### `POST /system/cmd/start_obsessing_over_host_checks` {#post-systemcmdstart_obsessing_over_host_checks}

Sends the START_OBSESSING_OVER_HOST_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/start_obsessing_over_host_checks.html for details.

### `POST /system/cmd/start_obsessing_over_svc_checks` {#post-systemcmdstart_obsessing_over_svc_checks}

Sends the START_OBSESSING_OVER_SVC_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/start_obsessing_over_svc_checks.html for details.

### `POST /system/cmd/stop_accepting_passive_host_checks` {#post-systemcmdstop_accepting_passive_host_checks}

Sends the STOP_ACCEPTING_PASSIVE_HOST_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/stop_accepting_passive_host_checks.html for details.

### `POST /system/cmd/stop_accepting_passive_svc_checks` {#post-systemcmdstop_accepting_passive_svc_checks}

Sends the STOP_ACCEPTING_PASSIVE_SVC_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/stop_accepting_passive_svc_checks.html for details.

### `POST /system/cmd/stop_executing_host_checks` {#post-systemcmdstop_executing_host_checks}

Sends the STOP_EXECUTING_HOST_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/stop_executing_host_checks.html for details.

### `POST /system/cmd/stop_executing_svc_checks` {#post-systemcmdstop_executing_svc_checks}

Sends the STOP_EXECUTING_SVC_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/stop_executing_svc_checks.html for details.

### `POST /system/cmd/stop_obsessing_over_host_checks` {#post-systemcmdstop_obsessing_over_host_checks}

Sends the STOP_OBSESSING_OVER_HOST_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/stop_obsessing_over_host_checks.html for details.

### `POST /system/cmd/stop_obsessing_over_svc_checks` {#post-systemcmdstop_obsessing_over_svc_checks}

Sends the STOP_OBSESSING_OVER_SVC_CHECKS command.

This command does not require any arguments.

See https://www.naemon.io/documentation/developer/externalcommands/stop_obsessing_over_svc_checks.html for details.

### `GET /thruk` {#get-thruk}

hash of basic information about this thruk instance

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `rest_version` | string |  | rest api version |
| `thruk_version` | string |  | thruk version |
| `thruk_release_date` | string |  | thruk release date |
| `localtime` | time |  | current server unix timestamp / epoch |
| `project_root` | string |  | thruk root folder |
| `etc_path` | string |  | configuration folder |
| `var_path` | string |  | variable data folder |
| `extra_version` | string |  | might contain omd version |
| `extra_link` | string |  | contains link from extra_versions product |

### `GET /thruk/api_keys` {#get-thrukapi_keys}

lists api keys

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `comment` | string |  | comment of this api key |
| `created` | time |  | unixtimestamp of when the key was created |
| `digest` | string |  | used hash algorithm |
| `file` | string |  | path to stored file |
| `force_user` | string |  | super user keys can enforce a specific user |
| `hashed_key` | string |  | hashed private key |
| `last_from` | time |  | ip address of last usage |
| `last_used` | time |  | unixtimestamp of last usage |
| `roles` | array_of_strings |  | list of roles this key is limited too |
| `superuser` | string |  | flag whether this a global superuser key and not bound to a specific user |
| `user` | string |  | username of key owner |

### `POST /thruk/api_keys` {#post-thrukapi_keys}

create new api key.

Optional arguments:

  * comment
  * superuser  (flag to create superuser api key)
  * username   (requires admin privileges, assigns key to specific user)
  * roles      (restrict roles to given list)
  * force_user (sets username in combination with super user flag)

### `GET /thruk/api_keys/<id>` {#get-thrukapi_keysid}

alias for `/thruk/api_keys?hashed_key=<id>`

### `DELETE /thruk/api_keys/<id>` {#delete-thrukapi_keysid}

remove key for given id.

### `GET /thruk/bp` {#get-thrukbp}

lists business processes.

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `affected_peers` | array_of_strings |  | list of backend ids used for the last calculation |
| `bp_backend` | string |  | id of backend which hosts the business process |
| `create_host_object` | boolean |  | 0 - do no create a host object, 1 - create naemon host object |
| `draft` | string |  | flag whether this is a draft only |
| `filter` | array_of_strings |  | list of enabled filters |
| `id` | string |  | primary id |
| `last_check` | time |  | timestamp of last check result submited |
| `last_state_change` | time |  | timestamp of last state change |
| `name` | string |  | name of this business proces |
| `nodes` | string |  | all nodes of this business process |
| `rankDir` | string |  | flag whether this business process is horizontal or vertical |
| `state_type` | boolean |  | flag if this business process uses hard or soft state types |
| `status` | number |  | current status |
| `status_text` | string |  | current status text |
| `template` | string |  | naemon template used for the generated object |
| `time` | number | s | calculation duration |

### `POST /thruk/bp` {#post-thrukbp}

create new business process.

### `GET /thruk/bp/<nr>` {#get-thrukbpnr}

business processes for given number.
alias for `/thruk/bp?id=<nr>`

### `POST /thruk/bp/<nr>` {#post-thrukbpnr}

update business processes configuration for given number.

### `PATCH /thruk/bp/<nr>` {#patch-thrukbpnr}

update business processes configuration partially for given number.

### `DELETE /thruk/bp/<nr>` {#delete-thrukbpnr}

remove business processes for given number.

### `GET /thruk/bp/<nr>/objects` {#get-thrukbpnrobjects}

combined list of hosts and services directly referenced by a business process.
see https://www.naemon.io/documentation/usersguide/livestatus.html#hosts for host columns.
see https://www.naemon.io/documentation/usersguide/livestatus.html#services for service columns.

Additional attributes added by Thruk:

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `_type` | string |  | object type: "host" or "service" |
| `host_name` | string |  | host name (added to host rows for uniformity with service rows) |

### `GET /thruk/bp/<nr>/objects/recursive` {#get-thrukbpnrobjectsrecursive}

combined list of hosts and services including all transitively linked BPs.
see https://www.naemon.io/documentation/usersguide/livestatus.html#hosts for host columns.
see https://www.naemon.io/documentation/usersguide/livestatus.html#services for service columns.

Additional attributes added by Thruk:

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `_type` | string |  | object type: "host" or "service" |
| `host_name` | string |  | host name (added to host rows for uniformity with service rows) |

### `POST /thruk/bp/<nr>/refresh` {#post-thrukbpnrrefresh}

recalculate business processes status for given number.

### `GET /thruk/broadcasts` {#get-thrukbroadcasts}

lists broadcasts

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `annotation` | string |  | annotation icon for this broadcast |
| `author` | string |  | author of the broadcast |
| `authoremail` | string |  | authors E-Mail address, mainly used as macro |
| `contactgroups` | array_of_strings |  | list of contactgroups if broadcast should be limited to specific groups |
| `contacts` | array_of_strings |  | list of contacts if broadcast should be limited to specific contacts |
| `expires` | string |  | expire date after which the broadcast won't be displayed anymore |
| `expires_ts` | time |  | expire data as unix timestamp |
| `file` | string |  | filename |
| `frontmatter` | string |  | hash list of extraceted frontmatter variables |
| `hide_before` | string |  | do not show broadcast before this date |
| `hide_before_ts` | time |  | hide_before as unix timestamp |
| `loginpage` | boolean |  | flag whether broadcast should be displayed on the loginpage as well |
| `macros` | array_of_strings |  | hash list of macros |
| `name` | string |  | name of this broadcast, mostly used for templates |
| `panorama` | boolean |  | flag whether broadcast should be displayed on panorama dashboards |
| `raw_text` | string |  | raw broadcast text |
| `template` | string |  | flag whether this broadcast is a template |
| `text` | string |  | processed broadcast message |

### `POST /thruk/broadcasts` {#post-thrukbroadcasts}

create new broadcast.

### `GET /thruk/broadcasts/<file>` {#get-thrukbroadcastsfile}

alias for `/thruk/broadcasts?file=<file>`

### `POST /thruk/broadcasts/<file>` {#post-thrukbroadcastsfile}

update entire broadcast for given file.

### `PATCH /thruk/broadcasts/<file>` {#patch-thrukbroadcastsfile}

update attributes for given broadcast.

### `DELETE /thruk/broadcasts/<file>` {#delete-thrukbroadcastsfile}

remove broadcast for given file.

### `GET /thruk/cluster` {#get-thrukcluster}

lists cluster nodes

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `hostname` | string |  | host name of the cluster node |
| `last_contact` | time |  | timestamp of last successful contact |
| `last_error` | time |  | text of last error message |
| `maintenance` |  |  | Flag whether this node is in maintenance mode |
| `node_id` | string |  | internal id for this node |
| `node_url` | string |  | url to access this node directly |
| `pids` | array_of_strings |  | list of current process ids of this node |
| `response_time` | number | s | response time in seconds |
| `version` | string |  | version information of this node |

### `GET /thruk/cluster/<id>` {#get-thrukclusterid}

return cluster state for given node.

See `/thruk/cluster/` for the description of the attributes.

### `GET /thruk/cluster/heartbeat` {#get-thrukclusterheartbeat}

should not be used, use POST method instead

### `POST /thruk/cluster/heartbeat` {#post-thrukclusterheartbeat}

send cluster heartbeat to all other nodes

### `POST /thruk/cluster/restart` {#post-thrukclusterrestart}

restarts all cluster nodes sequentially

### `GET /thruk/config` {#get-thrukconfig}

lists configuration information

### `GET /thruk/jobs` {#get-thrukjobs}

lists thruk jobs.

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `cmd` | string |  | the executed command line or perl code |
| `end` | time |  | timestamp when the job finished |
| `forward` | string |  | url to forward when the job is done |
| `host_id` | number |  | thruk node id this job is run on |
| `host_name` | string |  | hostname of the node |
| `id` | number |  | job id |
| `is_running` | boolean |  | flag whether the job is still running |
| `message` | string |  | current status text |
| `percent` | number | % | percent of completion |
| `perl_res` | string |  | contains the perl result in case this was a perl job |
| `pid` | number |  | process id |
| `rc` | number |  | return code |
| `remaining` | number | s | remaining seconds for the job to complete |
| `show_output` | boolean |  | flag whether output console will be displayed |
| `start` | time |  | timestamp when the job started |
| `stderr` | string |  | stderr output |
| `stdout` | string |  | stdout output |
| `time` | number | s | duration in seconds |
| `user` | string |  | username of the owner |

### `GET /thruk/jobs/<id>` {#get-thrukjobsid}

get thruk job status for given id.
alias for `/thruk/jobs?id=<id>`

### `GET /thruk/jobs/<id>/output` {#get-thrukjobsidoutput}

get thruk job output for given id.

Will return the plain result of a finished job as initially requested. In case
jobs takes longer than 30 seconds, this will return 302 redirects to itself
until the job succeeds. So if you follow those redirect, you will get the
final result as soon as its calculated.

### `GET /thruk/logcache/stats` {#get-thruklogcachestats}

lists logcache statistics

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `cache_version` | string |  | db schema version |
| `compact_duration` | number | s | duration of last compact run in seconds |
| `compact_till` | time |  | timestamp marker where last compact run finished |
| `data_size` | number | bytes | used size of data in bytes |
| `enabled` | string |  | flag whether logcache is enabled for this backend or not |
| `index_size` | number | bytes | used size of index in bytes |
| `items` | string |  | number of items/rows |
| `key` | string |  | peer key |
| `last_compact` | time |  | timestamp of last compact run |
| `last_entry` | time |  | timestamp of last log entry |
| `last_reorder` | time |  | timestamp of last optimize run |
| `last_update` | time |  | timestamp of last update run |
| `mode` | string |  | current lock mode |
| `name` | string |  | peer name |
| `reorder_duration` | number | s | duration of last reorder run in seconds |
| `status` | string |  | human readable status |
| `update_duration` | number | s | duration of last update run in seconds |

### `POST /thruk/logcache/update` {#post-thruklogcacheupdate}

runs the logcache delta update.

### `GET /thruk/metrics` {#get-thrukmetrics}

alias for `/thruk/stats`

### `GET /thruk/panorama` {#get-thrukpanorama}

lists all panorama dashboards.

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `file` | string |  | filename of the dashboard |
| `file_version` | string |  | version of dashboard format |
| `id` |  |  | internal id |
| `maintenance` | string |  | maintenance reason (only if in maintenance mode) |
| `nr` | number |  | number of the dashboard |
| `objects` | number |  | number of objects |
| `panlet_<nr>` | string |  | panlet definition |
| `readonly` | boolean |  | flag whether this dashboard is read-only |
| `scripted` | boolean |  | flag whether this is a scripted dashboard |
| `tab` | string |  | structure of global dashboard settings |
| `ts` | time |  | timestamp of last modification |
| `user` | string |  | owner of this dashboard |

### `GET /thruk/panorama/<nr>` {#get-thrukpanoramanr}

returns panorama dashboard for given number.
alias for `/thruk/panorama?nr=<nr>`

### `POST /thruk/panorama/<nr>/maintenance` {#post-thrukpanoramanrmaintenance}

Puts given dashboard into maintenance mode.

Required arguments:

  * text

### `DELETE /thruk/panorama/<nr>/maintenance` {#delete-thrukpanoramanrmaintenance}

removes maintenance mode from given dashboard.

### `GET /thruk/recurring_downtimes` {#get-thrukrecurring_downtimes}

lists recurring downtimes.

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `backends` | array_of_strings |  | list of backends this downtime is used for |
| `childoptions` | boolean |  | flag used for the downtime command |
| `comment` | string |  | comment used for the downtime command |
| `created_by` | string |  | username who created this downtime |
| `duration` | number | minutes | duration in minutes |
| `edited_by` | string |  | username who last edited this downtime |
| `error` | string |  | contains the error message if something got wrong with this downtime |
| `file` | number |  | file number |
| `fixed` | boolean |  | flag whether this should create a fixed downtime |
| `flex_range` | number | minutes | range in minutes for flexible downtimes |
| `host` | array_of_strings |  | list of hostnames |
| `hostgroup` | array_of_strings |  | list of hostgroups |
| `last_changed` | time |  | unix timestamp of last change |
| `schedule` | array_of_strings |  | list of schedules |
| `service` | array_of_strings |  | list of services |
| `servicegroup` | array_of_strings |  | list of servicegroups |
| `target` | string |  | sets the type of the downtime, ex. host or hostgroup |

### `POST /thruk/recurring_downtimes` {#post-thrukrecurring_downtimes}

create new downtime.

### `GET /thruk/recurring_downtimes/<file>` {#get-thrukrecurring_downtimesfile}

alias for `/thruk/recurring_downtimes?file=<file>`

### `POST /thruk/recurring_downtimes/<file>` {#post-thrukrecurring_downtimesfile}

update entire downtime for given file.

### `PATCH /thruk/recurring_downtimes/<file>` {#patch-thrukrecurring_downtimesfile}

update attributes for given downtime.

### `DELETE /thruk/recurring_downtimes/<file>` {#delete-thrukrecurring_downtimesfile}

remove downtime for given file.

### `GET /thruk/reports` {#get-thrukreports}

list of reports.

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `backends` | array_of_strings |  | list of backends used in this report |
| `cc` | string |  | email cc address if this report is send by mail |
| `desc` | string |  | report description |
| `error` | string |  | contains error messages (optional) |
| `failed` | boolean |  | flag whether the report failed to generate last time |
| `is_public` | boolean |  | flag whether the report is public or not |
| `name` | string |  | name of the report |
| `nr` | number |  | number of the report |
| `params` | string |  | reporting parameters |
| `permissions` | string |  | user/group permission |
| `readonly` | boolean |  | flag whether the report is read-only |
| `send_types` | array_of_strings |  | list of cron entries |
| `template` | string |  | template of the report |
| `to` | string |  | email to address if this report is send by mail |
| `user` | string |  | owner |

### `POST /thruk/reports` {#post-thrukreports}

create new report.

### `GET /thruk/reports/<nr>` {#get-thrukreportsnr}

report for given number.

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `backends` | array_of_strings |  | list of selected backends. |
| `cc` | string |  | carbon-copy for report email. |
| `desc` | string |  | description. |
| `error` | string |  | contains error messages (optional) |
| `failed` | boolean |  | failed flag. |
| `is_public` | boolean |  | flag for public reports. |
| `name` | string |  | name of the report. |
| `nr` | string |  | primary id. |
| `params` | string |  | report parameters. |
| `permissions` | string |  | user/group permission |
| `readonly` | boolean |  | readonly flag. |
| `send_types` | array_of_strings |  | list of crontab entries. |
| `template` | string |  | report template. |
| `to` | string |  | email address the report email. |
| `user` | string |  | owner of the report. |

### `POST /thruk/reports/<nr>` {#post-thrukreportsnr}

update entire report for given number.

### `PATCH /thruk/reports/<nr>` {#patch-thrukreportsnr}

update attributes for given number.

### `DELETE /thruk/reports/<nr>` {#delete-thrukreportsnr}

remove report for given number.

### `POST /thruk/reports/<nr>/generate` {#post-thrukreportsnrgenerate}

generate report for given number.

### `GET /thruk/reports/<nr>/report` {#get-thrukreportsnrreport}

return the actual report file in binary format.

### `GET /thruk/sessions` {#get-thruksessions}

lists thruk sessions.

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `active` | time |  | timestamp when session was last time used |
| `address` | string |  | remote address of user |
| `digest` | string |  | used hash algorithm |
| `fake` | boolean |  | flag whether this is a fake session or not |
| `file` | string |  | file name the session data file |
| `hashed_key` | string |  | hashed session id |
| `oauth_groups` | string |  | groups/roles as provided by the oauth server |
| `roles` | string |  | extra session roles |
| `username` | string |  | username of this session |

### `GET /thruk/sessions/<id>` {#get-thruksessionsid}

get thruk sessions status for given id.
alias for `/thruk/sessions?id=<id>`

### `GET /thruk/stats` {#get-thrukstats}

lists thruk statistics.

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `business_process_duration_seconds` | number | s | business process calculation duration in seconds |
| `business_process_last_update` | time |  | timestamp of last business process calculation |
| `business_process_total` | number |  | total number of business processes |
| `business_process_worker_total` | number |  | total number of worker processes used to calculate business processes |
| `sessions_active_5min_total` | number |  | total number of active thruk sessions (active during the last 5 minutes) |
| `sessions_total` | number |  | total number of thruk sessions |
| `sessions_uniq_user_5min_total` | number |  | total number of uniq users active during the last 5 minutes |
| `sessions_uniq_user_total` | number |  | total number of uniq users |
| `users_locked_total` | number |  | total number of locked thruk users |
| `users_total` | number |  | total number of thruk users |

### `GET /thruk/users` {#get-thrukusers}

lists thruk user profiles.

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `alias` | string |  | alias name |
| `can_submit_commands` | boolean |  | flag whether this account is allowed to submit commands |
| `email` | string |  | email address |
| `groups` | array_of_strings |  | list of contactgroups |
| `has_thruk_profile` | boolean |  | flag whether this account has a thruk profile or not |
| `id` | string |  | username |
| `last_login` | time |  | timestamp of last successfull login |
| `locked` | boolean |  | flag whether account is locked or not |
| `roles` | array_of_strings |  | list of roles for this user |
| `tz` | string |  | users selected timezone |

### `GET /thruk/users/<id>` {#get-thrukusersid}

get thruk profile for given user.
alias for `/thruk/users?id=<id>`

### `POST /thruk/users/<id>/cmd/...` {#post-thrukusersidcmd}

list of supported commands:

 - [lock](#post-thrukusersidcmdlock)
 - [unlock](#post-thrukusersidcmdunlock)

### `POST /thruk/users/<id>/cmd/lock` {#post-thrukusersidcmdlock}

lock given thruk user.

### `POST /thruk/users/<id>/cmd/unlock` {#post-thrukusersidcmdunlock}

unlock given thruk user.

### `GET /thruk/whoami` {#get-thrukwhoami}

show current profile information.
alias for `/thruk/users?id=<id>`

### `GET /timeperiods` {#get-timeperiods}

lists livestatus timeperiods.
see https://www.naemon.io/documentation/usersguide/livestatus.html#timeperiods for details.

Additional attributes added by Thruk:

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `peer_key` | string |  | id as defined in Thruk::Backend component configuration |
| `peer_name` | string |  | name as defined in Thruk::Backend component configuration |

### `GET /timeperiods/<name>` {#get-timeperiodsname}

lists timeperiods for given name.
alias for `/timeperiods?name=<name>`

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| `peer_key` | string |  | id as defined in Thruk::Backend component configuration |
| `peer_name` | string |  | name as defined in Thruk::Backend component configuration |

### `GET /timeperiods/<name>/config` {#get-timeperiodsnameconfig}

Returns configuration for given timeperiod.
You will find available attributes here: https://www.naemon.io/documentation/usersguide/objectdefinitions.html#timeperiod

### `POST /timeperiods/<name>/config` {#post-timeperiodsnameconfig}

Replace timeperiod configuration completely, use PATCH to only update specific attributes.

### `PATCH /timeperiods/<name>/config` {#patch-timeperiodsnameconfig}

Update timeperiods configuration partially.

### `DELETE /timeperiods/<name>/config` {#delete-timeperiodsnameconfig}

Deletes given timeperiod from configuration.

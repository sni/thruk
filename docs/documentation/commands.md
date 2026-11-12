---
title: External Commands
---

# Available External Commands

There are numerous external commands. Sometimes you need the number of a specific command, for example in the `command_enabled` or `command_disabled` option.

Note, these numbers are more or less the ones from the [naemon source](https://github.com/naemon/naemon-core/blob/master/src/naemon/common.h#L74). However, a few are missing and a few are used twice. This is because Thruk combines some commands which have options but are different commands in naemon.

<!--DATA-->
| Nr  | Category      | Name                             | Details      |
|-----|---------------|----------------------------------|--------------|
| 33 | hosts | acknowledge_host_problem | [details](https://www.naemon.io/documentation/developer/externalcommands/acknowledge_host_problem.html) |
| 33 | hosts | acknowledge_host_problem_expire | [details](https://www.naemon.io/documentation/developer/externalcommands/acknowledge_host_problem_expire.html) |
| 1 | hosts | add_host_comment | [details](https://www.naemon.io/documentation/developer/externalcommands/add_host_comment.html) |
| 154 | hosts | change_host_modattr | [details](https://www.naemon.io/documentation/developer/externalcommands/change_host_modattr.html) |
| 20 | hosts | del_all_host_comments | [details](https://www.naemon.io/documentation/developer/externalcommands/del_all_host_comments.html) |
| 10 | hosts | delay_host_notification | [details](https://www.naemon.io/documentation/developer/externalcommands/delay_host_notification.html) |
| 27 | hosts | disable_all_notifications_beyond_host | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_all_notifications_beyond_host.html) |
| 25 | hosts | disable_host_and_child_notifications | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_host_and_child_notifications.html) |
| 48 | hosts | disable_host_check | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_host_check.html) |
| 44 | hosts | disable_host_event_handler | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_host_event_handler.html) |
| 58 | hosts | disable_host_flap_detection | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_host_flap_detection.html) |
| 29 | hosts | disable_host_notifications | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_host_notifications.html) |
| 16 | hosts | disable_host_svc_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_host_svc_checks.html) |
| 29 | hosts | disable_host_svc_notifications | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_host_svc_notifications.html) |
| 93 | hosts | disable_passive_host_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_passive_host_checks.html) |
| 26 | hosts | enable_all_notifications_beyond_host | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_all_notifications_beyond_host.html) |
| 24 | hosts | enable_host_and_child_notifications | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_host_and_child_notifications.html) |
| 47 | hosts | enable_host_check | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_host_check.html) |
| 43 | hosts | enable_host_event_handler | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_host_event_handler.html) |
| 57 | hosts | enable_host_flap_detection | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_host_flap_detection.html) |
| 28 | hosts | enable_host_notifications | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_host_notifications.html) |
| 15 | hosts | enable_host_svc_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_host_svc_checks.html) |
| 28 | hosts | enable_host_svc_notifications | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_host_svc_notifications.html) |
| 92 | hosts | enable_passive_host_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_passive_host_checks.html) |
| 87 | hosts | process_host_check_result | [details](https://www.naemon.io/documentation/developer/externalcommands/process_host_check_result.html) |
| 51 | hosts | remove_host_acknowledgement | [details](https://www.naemon.io/documentation/developer/externalcommands/remove_host_acknowledgement.html) |
| 55 | hosts | schedule_and_propagate_host_downtime | [details](https://www.naemon.io/documentation/developer/externalcommands/schedule_and_propagate_host_downtime.html) |
| 55 | hosts | schedule_and_propagate_triggered_host_downtime | [details](https://www.naemon.io/documentation/developer/externalcommands/schedule_and_propagate_triggered_host_downtime.html) |
| 96 | hosts | schedule_forced_host_check | [details](https://www.naemon.io/documentation/developer/externalcommands/schedule_forced_host_check.html) |
| 17 | hosts | schedule_forced_host_svc_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/schedule_forced_host_svc_checks.html) |
| 96 | hosts | schedule_host_check | [details](https://www.naemon.io/documentation/developer/externalcommands/schedule_host_check.html) |
| 55 | hosts | schedule_host_downtime | [details](https://www.naemon.io/documentation/developer/externalcommands/schedule_host_downtime.html) |
| 17 | hosts | schedule_host_svc_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/schedule_host_svc_checks.html) |
| 86 | hosts | schedule_host_svc_downtime | [details](https://www.naemon.io/documentation/developer/externalcommands/schedule_host_svc_downtime.html) |
| 159 | hosts | send_custom_host_notification | [details](https://www.naemon.io/documentation/developer/externalcommands/send_custom_host_notification.html) |
| 101 | hosts | start_obsessing_over_host | [details](https://www.naemon.io/documentation/developer/externalcommands/start_obsessing_over_host.html) |
| 102 | hosts | stop_obsessing_over_host | [details](https://www.naemon.io/documentation/developer/externalcommands/stop_obsessing_over_host.html) |
| 34 | services | acknowledge_svc_problem | [details](https://www.naemon.io/documentation/developer/externalcommands/acknowledge_svc_problem.html) |
| 34 | services | acknowledge_svc_problem_expire | [details](https://www.naemon.io/documentation/developer/externalcommands/acknowledge_svc_problem_expire.html) |
| 3 | services | add_svc_comment | [details](https://www.naemon.io/documentation/developer/externalcommands/add_svc_comment.html) |
| 155 | services | change_svc_modattr | [details](https://www.naemon.io/documentation/developer/externalcommands/change_svc_modattr.html) |
| 21 | services | del_all_svc_comments | [details](https://www.naemon.io/documentation/developer/externalcommands/del_all_svc_comments.html) |
| 9 | services | delay_svc_notification | [details](https://www.naemon.io/documentation/developer/externalcommands/delay_svc_notification.html) |
| 40 | services | disable_passive_svc_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_passive_svc_checks.html) |
| 6 | services | disable_svc_check | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_svc_check.html) |
| 46 | services | disable_svc_event_handler | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_svc_event_handler.html) |
| 60 | services | disable_svc_flap_detection | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_svc_flap_detection.html) |
| 23 | services | disable_svc_notifications | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_svc_notifications.html) |
| 39 | services | enable_passive_svc_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_passive_svc_checks.html) |
| 5 | services | enable_svc_check | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_svc_check.html) |
| 45 | services | enable_svc_event_handler | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_svc_event_handler.html) |
| 59 | services | enable_svc_flap_detection | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_svc_flap_detection.html) |
| 22 | services | enable_svc_notifications | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_svc_notifications.html) |
| 30 | services | process_service_check_result | [details](https://www.naemon.io/documentation/developer/externalcommands/process_service_check_result.html) |
| 52 | services | remove_svc_acknowledgement | [details](https://www.naemon.io/documentation/developer/externalcommands/remove_svc_acknowledgement.html) |
| 7 | services | schedule_forced_svc_check | [details](https://www.naemon.io/documentation/developer/externalcommands/schedule_forced_svc_check.html) |
| 7 | services | schedule_svc_check | [details](https://www.naemon.io/documentation/developer/externalcommands/schedule_svc_check.html) |
| 56 | services | schedule_svc_downtime | [details](https://www.naemon.io/documentation/developer/externalcommands/schedule_svc_downtime.html) |
| 160 | services | send_custom_svc_notification | [details](https://www.naemon.io/documentation/developer/externalcommands/send_custom_svc_notification.html) |
| 99 | services | start_obsessing_over_svc | [details](https://www.naemon.io/documentation/developer/externalcommands/start_obsessing_over_svc.html) |
| 100 | services | stop_obsessing_over_svc | [details](https://www.naemon.io/documentation/developer/externalcommands/stop_obsessing_over_svc.html) |
| 2 | all_host_service | del_host_comment | [details](https://www.naemon.io/documentation/developer/externalcommands/del_host_comment.html) |
| 78 | all_host_service | del_host_downtime | [details](https://www.naemon.io/documentation/developer/externalcommands/del_host_downtime.html) |
| 4 | all_host_service | del_svc_comment | [details](https://www.naemon.io/documentation/developer/externalcommands/del_svc_comment.html) |
| 79 | all_host_service | del_svc_downtime | [details](https://www.naemon.io/documentation/developer/externalcommands/del_svc_downtime.html) |
| 68 | hostgroups | disable_hostgroup_host_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_hostgroup_host_checks.html) |
| 66 | hostgroups | disable_hostgroup_host_notifications | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_hostgroup_host_notifications.html) |
| 68 | hostgroups | disable_hostgroup_svc_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_hostgroup_svc_checks.html) |
| 64 | hostgroups | disable_hostgroup_svc_notifications | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_hostgroup_svc_notifications.html) |
| 67 | hostgroups | enable_hostgroup_host_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_hostgroup_host_checks.html) |
| 65 | hostgroups | enable_hostgroup_host_notifications | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_hostgroup_host_notifications.html) |
| 67 | hostgroups | enable_hostgroup_svc_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_hostgroup_svc_checks.html) |
| 63 | hostgroups | enable_hostgroup_svc_notifications | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_hostgroup_svc_notifications.html) |
| 85 | hostgroups | schedule_hostgroup_host_downtime | [details](https://www.naemon.io/documentation/developer/externalcommands/schedule_hostgroup_host_downtime.html) |
| 85 | hostgroups | schedule_hostgroup_svc_downtime | [details](https://www.naemon.io/documentation/developer/externalcommands/schedule_hostgroup_svc_downtime.html) |
| 114 | servicegroups | disable_servicegroup_host_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_servicegroup_host_checks.html) |
| 112 | servicegroups | disable_servicegroup_host_notifications | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_servicegroup_host_notifications.html) |
| 114 | servicegroups | disable_servicegroup_svc_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_servicegroup_svc_checks.html) |
| 110 | servicegroups | disable_servicegroup_svc_notifications | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_servicegroup_svc_notifications.html) |
| 113 | servicegroups | enable_servicegroup_host_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_servicegroup_host_checks.html) |
| 111 | servicegroups | enable_servicegroup_host_notifications | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_servicegroup_host_notifications.html) |
| 113 | servicegroups | enable_servicegroup_svc_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_servicegroup_svc_checks.html) |
| 109 | servicegroups | enable_servicegroup_svc_notifications | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_servicegroup_svc_notifications.html) |
| 122 | servicegroups | schedule_servicegroup_host_downtime | [details](https://www.naemon.io/documentation/developer/externalcommands/schedule_servicegroup_host_downtime.html) |
| 122 | servicegroups | schedule_servicegroup_svc_downtime | [details](https://www.naemon.io/documentation/developer/externalcommands/schedule_servicegroup_svc_downtime.html) |
| 42 | system | disable_event_handlers | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_event_handlers.html) |
| 62 | system | disable_flap_detection | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_flap_detection.html) |
| 11 | system | disable_notifications | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_notifications.html) |
| 83 | system | disable_performance_data | [details](https://www.naemon.io/documentation/developer/externalcommands/disable_performance_data.html) |
| 41 | system | enable_event_handlers | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_event_handlers.html) |
| 61 | system | enable_flap_detection | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_flap_detection.html) |
| 12 | system | enable_notifications | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_notifications.html) |
| 82 | system | enable_performance_data | [details](https://www.naemon.io/documentation/developer/externalcommands/enable_performance_data.html) |
| 13 | system | restart_process | [details](https://www.naemon.io/documentation/developer/externalcommands/restart_process.html) |
| 14 | system | shutdown_process | [details](https://www.naemon.io/documentation/developer/externalcommands/shutdown_process.html) |
| 90 | system | start_accepting_passive_host_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/start_accepting_passive_host_checks.html) |
| 37 | system | start_accepting_passive_svc_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/start_accepting_passive_svc_checks.html) |
| 88 | system | start_executing_host_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/start_executing_host_checks.html) |
| 35 | system | start_executing_svc_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/start_executing_svc_checks.html) |
| 94 | system | start_obsessing_over_host_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/start_obsessing_over_host_checks.html) |
| 49 | system | start_obsessing_over_svc_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/start_obsessing_over_svc_checks.html) |
| 91 | system | stop_accepting_passive_host_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/stop_accepting_passive_host_checks.html) |
| 38 | system | stop_accepting_passive_svc_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/stop_accepting_passive_svc_checks.html) |
| 89 | system | stop_executing_host_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/stop_executing_host_checks.html) |
| 36 | system | stop_executing_svc_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/stop_executing_svc_checks.html) |
| 95 | system | stop_obsessing_over_host_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/stop_obsessing_over_host_checks.html) |
| 50 | system | stop_obsessing_over_svc_checks | [details](https://www.naemon.io/documentation/developer/externalcommands/stop_obsessing_over_svc_checks.html) |

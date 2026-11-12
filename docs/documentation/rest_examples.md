---
title: REST API Examples
---

# REST API Examples

<Badge type="tip" text="New in Thruk 2.24" />
The Thruk REST API provides access to Thruk and Livestatus information.

For API details, see [REST API](rest.html).

### Simple Host List

Fetch a list of all host names:

```
  %> thruk r /csv/hosts?columns=name
```

or by curl:

```
  %> curl -g 'http://user:password@localhost/thruk/r/csv/hosts?columns=name'
```

### Notifications Per Hour Group by Site

List the total notifications sent in the last 60 minutes, grouped by backend name:

```
  %> thruk r '/notifications?time[gt]=-60m&columns=count(*):notifications_per_hour,peer_name'
```

### Sending Commands {#sending-commands}

#### Add Service Downtime

To schedule service downtime, use the `thruk` CLI tool:

```
  %> thruk r -d "start_time=now" -d "end_time=+60m" -d "comment_data='downtime comment'" '/services/<host>/<svc>/cmd/schedule_svc_downtime'
```

Or send an HTTP request, for example with curl:

```
  %> curl -d "start_time=now" --data-urlencode "end_time=+60m" -d "comment_data='downtime comment'" http://0:3000/thruk/r/services/<host>/<svc>/cmd/schedule_svc_downtime
```

Set only the required parameters. You can use relative start and end times.
For example, `now` means the current timestamp, and `+60m` means 60 minutes in the future.

Read more about [relative timestamps](rest_commands.html#relative-timestamps).

`start_time` is optional and will be set to the current timestamp.

`end_time` is optional as well and will be set to the default `downtime_duration`.

This leaves a single required argument with the downtime comment:

```
  %> curl -d "comment_data='downtime comment'" http://0:3000/thruk/r/services/<host>/<svc>/cmd/schedule_svc_downtime
```

#### Send Any Command

To avoid escaping issues, use the generic `/cmd` endpoint to send any command.

```
    %> curl -H "X-Thruk-Auth-Key: ****" \
            -d "cmd=acknowledge_svc_problem" \
            -d "host=hostname" \
            -d "service=servicedescription" \
            -d "comment_data=test" \
          'http://localhost/thruk/r/cmd'
```

### Grouping

List sessions that were active within the last 10 minutes:

```
  %> thruk r '/thruk/sessions?columns=username,max(active)&active[gte]=-10m'
```

### Create new Host Object

To create objects through the config tool, use the generic /config/objects endpoint:

```
    %> curl -H "X-Thruk-Auth-Key: ****" \
            -X POST \
            --header "Content-Type: application/json" \
            -d '{":TYPE": "host", ":FILE":"testhosts.cfg","name":"testhost123"}' \
            http://localhost/thruk/r/config/objects
```


The complete list of endpoints is on the [REST API endpoints page](rest_endpoints.html).

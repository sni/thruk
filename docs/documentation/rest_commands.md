---
title: REST API Commands
---

# REST API Commands

<Badge type="tip" text="New in Thruk 2.24" />
The Thruk REST API provides access to Thruk and Livestatus information.

For API details, see [REST API](rest.html).
The command list below includes all available external commands.

## Response

When command submission succeeds, the API returns a JSON message:

```
    %> thruk r -d "comment_data=test" /hosts/localhost/cmd/schedule_host_downtime
    {
      "message" : "Command successfully submitted"
    }
```

This confirms submission only. It does not confirm that the core executed the
command successfully, because cores implement external commands differently.

If the core supports error responses, currently only Naemon >= 1.0.9, failures
return a response like this:

```
    %> thruk r -d "comment_data=test" -d "triggered_by=xxx" /hosts/localhost/cmd/schedule_host_downtime
    {
      "code" : 400,
      "error" : "400: Couldn't parse ulong argument trigger_id (argument 4): No digits found in ulong 'xxx'\n",
      "message" : "sending command failed"
    }
```

## Arguments and default values

Each command lists its required and optional arguments.

Some of the arguments have default values:

- `comment_author`: defaults to the current user and cannot be changed usually
- `fixed`:          defaults to 1
- `duration`:       defaults to 0
- `triggered_by`:   defaults to 0
- `start_time`:     defaults to now
- `end_time`:       defaults to now + downtime_duration from the thruk.conf

## Relative timestamps

Use relative timestamps, such as start_date and end_date, to make commands reusable.

```
    %> thruk r -d "end_time=+60m" -d "comment_data='downtime comment'" '/services/<host>/<svc>/cmd/schedule_svc_downtime'
```

This creates a 1-hour downtime. Other suffixes are:

- `y`: years
- `w`: weeks
- `d`: days
- `h`: hours
- `m`: minutes

For more examples, see the [time definitions page](timedefinitions.html).

## Generic Command Endpoint

<Badge type="tip" text="New in Thruk 2.34" />
To avoid escaping issues, use the generic `/cmd` endpoint to send any command.

```
    %> curl -H "X-Thruk-Auth-Key: ****" \
            -d "cmd=acknowledge_svc_problem" \
            -d "host=hostname" \
            -d "service=servicedescription" \
            -d "comment_data=test" \
          'http://localhost/thruk/r/cmd'
```

## Example Usage

All examples can be found on the [REST API Examples page](rest_examples.html#sending-commands).

## Endpoints

The individual command endpoints are documented together with all other endpoints on the [REST API endpoints page](rest_endpoints.html), which has a filter box to find them quickly.

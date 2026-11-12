---
title: CLI Tool & Scripting
---

# Command Line Tool

The command line tool 'thruk' exports Excel files and other reports.
For source installations, the tool is in script/thruk. Packages install it
in '/usr/bin/thruk', which should be in your PATH.
Use the tool with cron and mail to send regular reports.

Examples:

Export the event log as an Excel file:

```
  %> thruk -A thrukadmin 'showlog.cgi?view_mode=xls' > eventlog.xls
```

For more examples, read the man page or run 'thruk -h'.

## Scripting

Use scripts to set downtimes automatically, schedule reports or change
objects in your monitoring core configuration.

See [CLI API](https://www.thruk.org/api/Thruk/Utils/CLI.html) for details and examples.

The examples folder also contains scripts.

## Curl & Wget

<Badge type="tip" text="New in Thruk 2.10" />
You can fetch pages with wget or curl even when Cookie Authentication is enabled.

```
  %> curl --user thrukadmin "http://localhost/thruk/cgi-bin/status.cgi?format=json"
```

## Integration With 3rd Party Software

### Configuration Generators

If a third-party tool generates your object configuration, it can export
additional information for each host or service. Thruk displays this information
in the object's configuration section.
Export the special custom variables: '_SRC', '_SRC2' or '_SRC3'.
![3rd Party Config Generator](source/config_3rd_party.png)

## Environment Variables {#_environment-variables}

Most `Server Actions` and `Hooks` scripts can read special environment variables.

These are the standard variables available:

```
** `REMOTE_USER`          username of the logged in user
** `REMOTE_USER_GROUPS`   contact groups of the current user
** `REMOTE_USER_ALIAS`    contact alias name (if available)
** `REMOTE_USER_EMAIL`    contact email address (if available)
** `THRUK_REQ_URL`        contains the current url
```

---
title: Logfiles
---

# Logfiles

Logfiles are usually in `/var/log/thruk/thruk.log`. If you use OMD, then
the logfiles are in `~/var/log/thruk.log`.

Cronjobs have their own logfile in `~/var/thruk/cron.log` for OMD or
`/var/lib/thruk/cron.log` for standalone installations.

## Logfile Configuration

Configure logging in log4perl.conf. Thruk supports all log4perl options.
For details, read the log4perl manual:
http://log4perl.sourceforge.net/releases/Log-Log4perl/docs/html/Log/Log4perl/Config.html
The package includes log4perl.conf.example.

ex.:

```
log4perl.logger=ALL, ErrorLog, DebugLog
log4perl.appender.ErrorLog=Log::Dispatch::File
log4perl.appender.ErrorLog.filename=/home/thruk/Thruk/logs/error.log
log4perl.appender.ErrorLog.mode=append
log4perl.appender.ErrorLog.Threshold=ERROR
log4perl.appender.ErrorLog.layout=Log::Log4perl::Layout::PatternLayout
log4perl.appender.ErrorLog.layout.ConversionPattern=[%d][%H][%p][%c] %m%n
```

::: tip command logging
To log all sent commands, set the log level to INFO.

```text
log4perl.appender.ErrorLog.Threshold=INFO
```
:::

## Enable Debug Logging {#enable-debug-logging}

To get more detailed logs, create a `.thruk` file in the Thruk user's home
directory (usually the webserver user). For OMD, create it in the site folder.

The following locations will work depending on your setup:

- ~/.thruk
- /etc/sysconfig/thruk
- /etc/default/thruk

Add these settings to the file:

To increase the log level, use a value from 0-4. The most detailed level is 4.

```
export THRUK_VERBOSE=4
```

To track CPU and memory usage for all requests:

```
export THRUK_PERFORMANCE_DEBUG=1
```

Also adjust the log level threshold in `/etc/thruk/log4perl.conf`, for example:

```text
log4perl.appender.ThrukLog.Threshold=DEBUG
```

Some log output also goes to the Apache error log.

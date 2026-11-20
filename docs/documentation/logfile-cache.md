---
title: Logfile Cache
---

# Logfile Cache

Accessing logfiles can take time and memory, especially with remote sites.
Livestatus caches logfile data for queries. This increases the naemon process's
memory use, slows monitoring and increases the monitoring host's load.
Thruk can use a separate logfile cache to speed up logfile access and reports.

For maximum performance, install the logfile cache database on the Thruk server
or at least in the same network.

![Thruk reads and writes a MariaDB or PostgreSQL cache database and supplies cached logfiles to reports and logfile pages.](source/logfile-cache.svg)

The cache is intended to store complete log data for about half a year.
It can also store up to 2 years of compacted logfiles for SLA reports.

### Configuration

::: tip
Starting with OMD-Labs 2.40 you can simply run `omd config set MYSQL on; omd config set THRUK_LOGCACHE on` to enable the logcache.
:::

Specify the MySQL connection in thruk_local.conf.
Make sure the user and database exist. Thruk creates the tables automatically.

PostgreSQL support is experimental. Install the packages defined in the
experimental_postgresql_support feature.

thruk_local.conf:

```
  logcache = mysql://username:password@localhost:3306/thruk_logs
  logcache = postgresql://username:password@localhost:5432/thruk_logs # experimental_postgresql_support
```

::: tip create mysql user and tables

```
#> mysql -u root -p
mysql> CREATE USER 'thruk'@'localhost' IDENTIFIED BY '****';
mysql> CREATE DATABASE IF NOT EXISTS `thruk_logs`;
mysql> GRANT ALL PRIVILEGES ON `thruk_logs`.* TO 'thruk'@'localhost';
```
:::

### Actions

#### Import

After you enable the logfile cache, import the logfiles.

::: warning
The 'logcacheimport' command deletes all currently cached data. Run the initial import only once.
:::

Initial import:

```
    %> thruk -a logcache import --local -v
    ...
    OK - imported 20374 log items from 1 site successfully in 4.94s (4122/s)
```

Depending on the size, this may take a while.

#### Update

Logfile Cache Update

```
    %> thruk -a logcache update -v
    OK - imported 3 log items from 3 sites successfully in 0.13s (23/s)
```

The logcacheupdate command imports only changes since the last update.
This is fast and runs automatically when you access logfiles through Thruk.
If you rarely access the eventlog page, use a cronjob to update the cache regularly.

#### Import from Logfile Archive Files

The MySQL logcache can also import files. It skips duplicates, so you can
repeat file imports safely.

```
    %> thruk -a logcache update --local /var/log/naemon/archive/naemon-09-07-2012-00.log
    OK - imported 2 log items from 1 site successfully in 0.01s (247/s)
```

#### Authentication Update

The cache needs authentication information. Update it whenever contacts change.

Update logfile caches authentication information:

```
    %> thruk -a logcache authupdate
    OK - updated 71 log items from 3 sites successfully in 0.25s (286/s)
```

#### Cleanup

Use logcacheclean to remove old logfile entries.
You can specify how many days to keep in the cache.

```
    %> thruk -a logcache clean -v
    OK - removed 18046 log items from 1 site successfully in 0.08s (218816/s)
```

#### Compact

Compact removes duplicate information that SLA reports do not need.
It keeps notifications.

```
    %> thruk -a logcache compact -v
    OK - compacted 18046 log items from 1 site successfully in 0.08s (218816/s)
```

#### Statistics

To check logfile cache usage statistics, run:

```
    %> thruk -a logcache stats
    Backend              Index Size      Data Size       Items
    Devel                 14.4 MB        136.4 MB       238104
```

### Example Cronjobs

The logfile cache needs regular maintenance. The following cronjobs should cover it.
If you do not use OMD, adjust the paths.

```
  THRUK_CRON=1

  # update logcache data
  */5 * * * * $OMD_ROOT/bin/thruk -a logcache update     >>$OMD_ROOT/var/log/thruk.log 2>&1

  # update authentication data in our logcache
  0   2 * * * $OMD_ROOT/bin/thruk -a logcache authupdate >>$OMD_ROOT/var/log/thruk.log 2>&1

  # optimize and repair tables
  0  20 * * * $OMD_ROOT/bin/thruk -a logcache optimize   >>$OMD_ROOT/var/log/thruk.log 2>&1

  # clean logfiles from cache after default duration (thruk.conf: logcache_clean_duration)
  0   1 * * * $OMD_ROOT/bin/thruk -a logcache clean      >>$OMD_ROOT/var/log/thruk.log 2>&1

  # compact logfiles from cache after default duration (thruk.conf: logcache_compact_duration)
  0   1 * * * $OMD_ROOT/bin/thruk -a logcache compact    >>$OMD_ROOT/var/log/thruk.log 2>&1

  THRUK_CRON=0
```

### Icinga 2

For Icinga 2, use the logcache with file imports.
Its Livestatus API returns incorrect results for the logs table.
If file imports are not possible, you can use the experimental IDO import.

#### File Import

For file imports the following settings are recommended (OMD-Labs):

etc/thruk/thruk_local.d/logcache.conf:

```
  logcache = mysql://root@tmp/run/mysqld/mysqld.sock/thruk_logs
  logcache_delta_updates = 0
  report_update_logcache = 0
```

These settings disable on-demand updates, which do not work with this setup.

Use this crontab to import data directly from the compat logfiles:

etc/cron.d/thruk_logcache

```
  THRUK_CRON=1

  # update logcache data
  * * * * * $OMD_ROOT/bin/thruk -a logcache update var/icinga2/log/icinga2/compat/icinga.log >>$OMD_ROOT/var/log/thruk.log 2>&1
  5 0 * * * $OMD_ROOT/bin/thruk -a logcache update $(ls -1tr var/icinga2/log/icinga2/compat/archives/*.log) >>$OMD_ROOT/var/log/thruk.log 2>&1

  # update authentication data in our logcache
  0   2 * * * $OMD_ROOT/bin/thruk -a logcache authupdate >>$OMD_ROOT/var/log/thruk.log 2>&1

  # optimize and repair tables
  0  20 * * * $OMD_ROOT/bin/thruk -a logcache optimize   >>$OMD_ROOT/var/log/thruk.log 2>&1

  # clean logfiles from cache after default duration (thruk.conf: logcache_clean_duration)
  0   1 * * * $OMD_ROOT/bin/thruk -a logcache clean      >>$OMD_ROOT/var/log/thruk.log 2>&1

  # compact logfiles from cache after default duration (thruk.conf: logcache_compact_duration)
  0   1 * * * $OMD_ROOT/bin/thruk -a logcache compact    >>$OMD_ROOT/var/log/thruk.log 2>&1

  THRUK_CRON=0
```

#### IDO Import

<Badge type="tip" text="New in Thruk 2.22" />
If compat-log produces incorrect timestamps in an icinga2 cluster, consider the
experimental IDO import script.

Known issues:

- no support for timeperiods, reports will be 24x7 only
- no initial states which might result in unknown states for sla reports
- no command names for notifications

thruk_local.conf

```
logcache_fetchlogs_command = IDO_DB_HOST=127.0.0.1 IDO_DB_PORT=3306 IDO_DB_USER=root IDO_DB_PW=root IDO_DB_NAME=icinga /usr/share/thruk/support/icinga2_ido_fetchlogs.sh mysql
```

if using OMD, change the path to

thruk_local.conf

```
logcache_fetchlogs_command = IDO_DB_HOST=127.0.0.1 IDO_DB_PORT=3306 IDO_DB_USER=root IDO_DB_PW=root IDO_DB_NAME=icinga ./share/thruk/support/icinga2_ido_fetchlogs.sh mysql
```

For postgres database replace the literal 'mysql' with 'postgres' in the command above.

### PostgreSQL

<Badge type="tip" text="New in Thruk 3.20" />
Thruk supports PostgreSQL as an alternative logcache backend to MySQL/MariaDB.
The PostgreSQL provider follows the same interface as the MySQL provider, so all
logcache CLI actions (import, update, clean, compact, stats, authupdate) work
identically.

#### Configuration

Specify your PostgreSQL connection string in your thruk_local.conf.
Make sure the user and database exist beforehand. Thruk creates the tables
automatically.

thruk_local.conf:

```
  logcache = postgresql://username:password@localhost:5432/thruk_logs
```

::: tip create PostgreSQL user and database

```
#> psql -U postgres
postgres=# CREATE USER thruk WITH PASSWORD '****';
postgres=# CREATE DATABASE thruk_logs OWNER thruk;
postgres=# GRANT ALL PRIVILEGES ON DATABASE thruk_logs TO thruk;
```
:::

If Thruk runs on the same host as PostgreSQL and you want to use a Unix
socket instead of TCP, provide the socket directory as the host:

```
  logcache = postgresql://thruk:password@/var/run/postgresql/thruk_logs
```

#### Differences from the MySQL Provider

::: info

- **Bulk imports**: MySQL uses `LOAD DATA LOCAL INFILE` for fast bulk inserts.
  PostgreSQL falls back to extended INSERT statements. For very large initial
  imports this can be slower. Consider running the import in batches with
  `thruk -a logcache import --local -v` during off-peak hours, or use the
  PostgreSQL `COPY` command for a custom import pipeline if needed.
- **Locking**: `_release_write_locks()` is a no-op under PostgreSQL because
  PostgreSQL releases row-level locks automatically at transaction commit or
  rollback. No explicit unlock step is required.
- **Transaction recovery**: If a lock attempt fails, Thruk issues an explicit
  `ROLLBACK` so that the connection is cleanly returned to idle state before
  retrying. This is required by PostgreSQL's strict transaction semantics.
:::

#### Performance Tuning

For a dedicated logcache PostgreSQL instance, consider the following settings in
`postgresql.conf`:

```
  # Allow PostgreSQL to use more RAM for sorting/hashing large log imports.
  # A good starting point is 25% of total system RAM.
  shared_buffers = 512MB

  # Per-operation sort/hash memory. Set higher for large log imports that
  # involve GROUP BY or ORDER BY across millions of rows.
  work_mem = 64MB

  # Helps the query planner choose better index scan plans.
  # Typically 50-75% of total system RAM.
  effective_cache_size = 2GB

  # Tune autovacuum more aggressively for tables that receive frequent inserts
  # and deletes (the log tables grow and shrink during clean/compact cycles).
  autovacuum_vacuum_scale_factor = 0.01
  autovacuum_analyze_scale_factor = 0.005
```

After large initial imports, run `ANALYZE` manually to update planner
statistics before query-heavy operations:

```
  %> psql -U thruk thruk_logs -c "ANALYZE;"
```

#### Example Cronjobs

The cronjob schedule is identical to the MySQL setup.
The `logcache optimize` command is not applicable, because PostgreSQL does not
have a direct equivalent of `OPTIMIZE TABLE`. Autovacuum handles this
automatically.

```
  THRUK_CRON=1

  # update logcache data
  */5 * * * * $OMD_ROOT/bin/thruk -a logcache update     >>$OMD_ROOT/var/log/thruk.log 2>&1

  # update authentication data in our logcache
  0   2 * * * $OMD_ROOT/bin/thruk -a logcache authupdate >>$OMD_ROOT/var/log/thruk.log 2>&1

  # clean logfiles from cache after default duration (thruk.conf: logcache_clean_duration)
  0   1 * * * $OMD_ROOT/bin/thruk -a logcache clean      >>$OMD_ROOT/var/log/thruk.log 2>&1

  # compact logfiles from cache after default duration (thruk.conf: logcache_compact_duration)
  0   1 * * * $OMD_ROOT/bin/thruk -a logcache compact    >>$OMD_ROOT/var/log/thruk.log 2>&1

  THRUK_CRON=0
```

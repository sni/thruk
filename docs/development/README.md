# Thruk development guide

## JavaScript section tags

Use figlet to create section tags:

```console
  %> figlet -w 900 -f univers SEARCH
  %> figlet -w 900 -f big SEARCH # if above font does not exist
```

## Environment variables

Thruk uses these environment variables:

### NO_DISABLED_PLUGINS_TEST

Set this to skip tests of disabled plugins.

### NO_EXTERNAL_JOBS

Override 'no_external_job_forks' config setting.

### REMOTE_USER

Contains the current username.

### REMOTE_USER_GROUPS

Contains the current contactgroups when Thruk runs external hooks and scripts.

### REMOTE_USER_ALIAS

Contains the current contact's alias when Thruk runs external hooks and scripts.

### REMOTE_USER_EMAIL

Contains the current contact's email address when Thruk runs external hooks and scripts.

### TEST_AUTHOR

Set this to run author-specific tests, which may fail in some cases.

### TEST_ERROR

Suppress logging of errors.

### THRUK_AUTHOR

Enable author mode. This enables strict template checks and disables all template caches.

### THRUK_BACKENDS

Override currently used backends. Comma-separated list.

### THRUK_BIN

Specify the location of the thruk binary used for tests.

### THRUK_CONFIG

Specify location of config files.

### THRUK_VERBOSE

Set debug level.

### THRUK_TIMER

Enable debug timer on STDERR.

### THRUK_STRACE_DEBUG

Enable debug timer output as "write" system call so it can be traced with
strace.

### THRUK_DEMO_MODE

Enable demo mode, which prevents configuration saves.

### THRUK_GROUP_ID

Contains Thruk's primary group ID.

### THRUK_GROUPS

Contains all groups as a semicolon-separated list.

### THRUK_NO_COMMANDS

Don't send commands from cmd.cgi.

### THRUK_NO_CONNECTION_POOL

Skip the connection pool and make all requests serially.

You can use this whenever Thruk accesses backends.

### THRUK_NO_TOUCH_PERM

Do not touch permissions of opened files.

### THRUK_MODE

Can be one of:

- `FASTCGI`: FastCGI script.
- `DEVSERVER`: Development server.
- `CLI_SETUID`: bin/thruk and scripts/* that should change user when started as root.
- `CLI`: script/*.
- `TEST`: Tests from t/*.

### THRUK_TEST_NO_AUDIT_LOG

Don't log to audit log.

### THRUK_TEST_NO_STDOUT_LOG

Don't log stdout messages during some tests

### THRUK_NO_COLOR

Don't use colours in terminal output.

### THRUK_USER_ID

Contains Thruk's user ID.

### THRUK_PERFORMANCE_DEBUG

Print memory and CPU usage to stderr.

### PLACK_TEST_EXTERNALSERVER_URI

Specify an external test URL for tests.

## Livestatus reference {#livestatus-samples}

See the [Naemon Livestatus reference](https://www.naemon.io/documentation/usersguide/livestatus.html) for table and column descriptions.

See the [documentation maintenance guide](../README.md) for the VitePress preview and validation commands.

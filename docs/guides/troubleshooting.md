# Troubleshooting

Identify which layer failed before you change settings.
Start with the web request, then authentication, backend access and the affected feature.

::: warning Diagnostic data
Logs and debug exports can contain usernames, host details, URLs and credentials.
Remove sensitive data before you share them.
:::

## The page does not load

1. Check that the web server and Thruk application process are running.
2. Read the web server's error log.
3. Read the [Thruk log](../documentation/logfiles.md).
4. Confirm that the web server configuration points to the installed Thruk paths.
5. Confirm that the application user can read the required files and Perl libraries.

Package paths differ from source and OMD paths.
Do not copy an example's home directory into a different installation unchanged.

If startup reports an undefined Perl symbol, check that the package matches your distribution and release.
See the [FAQ](../documentation/faq.md) for specific error messages.

## Login succeeds, but objects are missing

A successful login confirms identity, not object access.

1. Check the displayed username and its spelling.
2. Confirm that the backend is available.
3. Clear active host/service filters and check which backends are selected.
4. Check contact assignments and `cgi.cfg` roles.
5. For OAuth2, check the login field and Teams group mappings.

Compare the results with an administrator account.
If only one account is affected, investigate permissions before changing backend connectivity.

Do not disable authentication or grant all users administrator access as a diagnostic shortcut.
See [access control](access-control.md).

## A backend is unavailable

For a local Livestatus backend:

1. Check that the monitoring core is running and provides Livestatus.
2. Check that the configured socket path exists.
3. Check that the Thruk process can access the socket and its parent directories.

For a remote backend:

1. Check the configured hostname, port and URL.
2. Check network reachability from the Thruk host.
3. For TLS, check certificate trust and hostname verification.
4. For HTTP, check the remote Thruk service and its configured authentication key.

Do not disable TLS verification as a permanent fix.
If LMD is enabled, include its connection handling in the investigation.
See [backend configuration](../documentation/install.md#backend-configuration) and [LMD](../documentation/lmd.md).

## An API request fails

First, read the HTTP status and the returned error body.
Check the [REST authentication method](../documentation/rest.md#authentication) and the account's object permissions.

Use a read-only request to isolate authentication from command handling:

```sh
thruk -A username r '/hosts?columns=name&limit=1'
```

Replace `username` with the account you intend to test.
The CLI can select a user context. It does not test the web server's HTTP authentication configuration.

For HTTP, use the documented API key header and the correct `/thruk/r/` URL.
Do not paste a real key into a support request.

If a command reports successful submission, confirm the result in the monitoring core.
Submission does not always confirm successful execution.
See [command responses](../documentation/rest_commands.md#response).

## Reports fail or take too long

1. Confirm that the reporting plugin and its package dependencies are installed.
2. Check whether the HTML report renders before investigating PDF conversion.
3. For PDF failures, check the puppeteer and Chromium installation.
4. For slow historical queries, review the logfile cache and backend log access.
5. Check the cron log if only scheduled reports fail.

For reproducible report failures, use the [report debug export](../documentation/reporting.md#debugging-reports).
Review the export for sensitive data before you share it.

## Cluster requests fail intermittently

Check each node separately. A working node can hide another node's failure behind the load balancer.

1. Check the load balancer's heartbeat results.
2. Confirm that every node uses the intended shared `etc_path` and `var_path`.
3. Confirm that `tmp_path` remains local.
4. Check node URLs and shared-storage permissions.
5. Inspect the cluster state with the commands in the [cluster guide](../documentation/cluster.md#troubleshooting).

Maintenance mode returns a different heartbeat status.
Do not treat a deliberately maintained node as an unexpected application failure.

## Collect a useful support report

Include:

- The Thruk version, installation method and operating-system release.
- The affected page or API path, without credentials.
- The exact error and the time it occurred.
- Whether the problem affects all users, one backend or one cluster node.
- Recent configuration or package changes.
- Relevant sanitized logs and a minimal reproduction.

Enable [debug logging](../documentation/logfiles.md#enable-debug-logging) only when normal logs do not explain the failure.
Return to the normal log level after collecting the needed information.

Use [GitHub Issues](https://github.com/sni/thruk/issues) for public bug reports.
Report security-sensitive problems through the [security policy](https://github.com/sni/thruk/security/policy).

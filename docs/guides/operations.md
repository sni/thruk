# Backups and upgrades

Back up configuration and persistent state before an upgrade.
The paths depend on whether Thruk runs from packages, OMD or a source checkout.

## Identify the data

Check the effective `etc_path`, `var_path` and `tmp_path` settings.
Do not assume that every installation uses the standalone package paths.

| Data | Include in the backup |
| --- | --- |
| Configuration | Local overrides, `cgi.cfg`, menu changes and backend connection settings. |
| Credentials | Password files, OAuth secrets, API key files and `secret.key`. |
| Persistent state | User settings, scheduled tasks, reports and other data under `var_path`. |
| Customizations | Custom templates, themes, plugins, action scripts and executable includes. |
| Monitoring configuration | Core configuration and files that Thruk's config tool or business process engine writes. |
| External databases | The logfile cache or other databases that your deployment needs to retain. |

Some custom files can live outside `etc_path` and `var_path`.
Review configured paths, symbolic links and external script locations.

`tmp_path` holds temporary data. It does not replace a backup of persistent state.
See the [configuration reference](../documentation/configuration.md) for path settings.

::: warning Backup credentials
Backups can contain passwords and superuser credentials. Restrict access to the backup storage and protect transfers.
:::

## Make a consistent backup

Use the backup tools supported by your operating system, OMD installation and database.
This procedure does not prescribe one archive command because file locations and storage differ.

1. Record the installed Thruk version, package source and enabled plugins.
2. Record file owners, permissions and external dependencies.
3. Stop or coordinate writers before you copy persistent state.
4. Back up the configuration, state and custom files identified above.
5. Back up required databases with their database tools.
6. Restore a copy in an isolated test installation and verify it.

For a cluster, coordinate all nodes and scheduled jobs. Stopping one node does not stop other nodes from writing shared state.

### OMD sites

For an OMD installation, use `omd backup` to archive the site. Run this example as root, using your site name and a protected backup directory:

```sh
omd backup mysite /secure/backups/mysite.tar.gz
```

Check the available options with `omd help backup`.
Options such as `--no-rrds`, `--no-dbs` and `--no-logs` omit data from the archive.
Back up external databases and files outside the site separately. Test restoration before an upgrade.

## Prepare an upgrade

1. Read the release notes for every relevant version.
2. Check custom plugin compatibility and runtime dependencies.
3. Test the upgrade against a restored copy of the installation.
4. Make a fresh backup before the production change.
5. Plan a maintenance window and a rollback procedure.

Keep local overrides in `thruk_local.conf` or `thruk_local.d/`.
Updates replace shipped defaults in `thruk.conf`.
Do not preserve a changed default file as a substitute for local overrides.

## Upgrade and verify

Use the package manager or OMD update process appropriate for your installation.
Do not mix packages from different distributions or releases.

After the upgrade:

1. Start or reload the services required by your deployment.
2. Check startup and request logs for errors.
3. Confirm backend connectivity and current host/service data.
4. Test administrator and normal-user access.
5. Test a read-only API request with an automation account.
6. Check dashboards, scheduled reports and recurring downtimes.

Use [logfiles](../documentation/logfiles.md), [REST examples](../documentation/rest_examples.md) and the [FAQ](../documentation/faq.md) for focused checks.

## Recover safely

If verification fails, keep the failed installation's logs for diagnosis.
Follow the rollback procedure that you tested before the upgrade.

Restore a compatible application version together with its configuration and state.
Preserve ownership and permissions, especially for credential files.
Do not overwrite a live installation while its processes or cluster peers still write to the same files.

Restored sessions and API keys can still grant access.
Review whether those credentials should remain valid before you reopen the service.

## Cluster maintenance

Cluster nodes share `etc_path` and `var_path`. Keep `tmp_path` local to each node.
Use a load balancer that checks the node's heartbeat URL.

To mark a node for maintenance:

```sh
thruk cluster maint
```

Confirm that the load balancer removes the node before you stop its service.
To reactivate it after verification:

```sh
thruk cluster unmaint
```

Maintenance mode changes the heartbeat response. It is not a replacement for stopping all writers during a shared-state backup.
See [cluster setup](../documentation/cluster.md) for heartbeat responses and configuration.

# First steps

Use this checklist for a new Thruk installation. Choose the installation method before you change the configuration.

## Choose an installation

| Method | Use it when |
| --- | --- |
| [Packages](../documentation/install.md) | You want Thruk on an existing monitoring server or a separate web server. |
| [OMD](../documentation/install.md#omd) | You want a monitoring stack with Thruk and other monitoring tools. |
| [Source](../documentation/install_from_source.md) | You need custom paths or dependencies and can maintain the installation yourself. |

Use the packages for your distribution. Do not install a package built for another distribution or release.

::: warning Production web server
The development server on port 3000 is not a production server. Use a configured web server and FastCGI or PSGI deployment.
:::

## Configure access

1. Open the Thruk URL supplied by your installation. Standalone packages normally use `http://your-host/thruk/`.
2. Configure HTTPS before you send credentials over the network.
3. For standalone packages, set a password for the `thrukadmin` account:

   ```sh
   htpasswd /etc/thruk/htpasswd thrukadmin
   ```

4. Sign in and check the displayed username.

OMD uses site-specific paths and accounts. Follow its site setup instructions instead of applying standalone paths unchanged.

See [web server integration](../documentation/install-webserver.md) and [access control](access-control.md) for authentication details.

## Connect one backend

First, confirm that the monitoring core provides Livestatus. Thruk displays core data. Installing Thruk does not create monitoring checks.

For a standalone package, put local settings in `/etc/thruk/thruk_local.conf`.
Replace the socket path below with the socket supplied by your monitoring core:

```text
<Component Thruk::Backend>
  <peer>
    name = local
    type = livestatus
    <options>
      peer = /var/run/live
    </options>
  </peer>
</Component>
```

1. Give the Thruk process access to the socket.
2. Reload the service that runs Thruk after configuration changes, as required by your deployment.
3. Open the host or service list.
4. Check that the backend is available and its objects appear.

Do not expose an unencrypted Livestatus connection to an untrusted network.
For remote sites, see [TLS and HTTP backends](../documentation/install.md#backend-configuration).

## Check a normal user's access

Test with a non-administrator account before you give users access.

1. Confirm that the username matches a monitoring contact or the intended role mapping.
2. Check which hosts and services the user can see.
3. Check whether the user can submit commands.
4. For read-only users, confirm that command submission is unavailable.

Authentication alone does not assign monitoring permissions.
See [access control](access-control.md) and [CGI authorization settings](../documentation/cgi-cfg.md).

## Add features after the basic checks pass

- Create [dashboards](../documentation/dashboard.md) for operators.
- Configure [SLA reports](../documentation/reporting.md) if you need scheduled availability reports.
- Use the [REST API](../documentation/rest.md) for automation.
- Plan [backups and upgrades](operations.md) before production use.

If objects do not appear, check [logs](../documentation/logfiles.md) and the [FAQ](../documentation/faq.md).

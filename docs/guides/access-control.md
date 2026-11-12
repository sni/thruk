# Access control

Thruk separates authentication from authorization. Authentication identifies the user. Authorization controls which objects and commands that user can access.

## Choose an authentication method

Thruk can use web server authentication, cookie sessions, OAuth2 and API keys.
The method depends on the deployment and request type.

- For web server authentication, the server supplies the authenticated identity, such as `REMOTE_USER`.
- For cookie authentication, Thruk retrieves the user's session.
- For OAuth2, configure a provider and map its user identity to the intended Thruk account.
- For automation, create an API key with the permissions that the task needs.

Configure [HTTPS](../documentation/faq.md) before transmitting passwords, session cookies or API keys.
For setup details, see [web server integration](../documentation/install-webserver.md), [OAuth2](../documentation/oauth2.md) and [REST authentication](../documentation/rest.md#authentication).

## Assign permissions

Monitoring contacts and contact groups control object access. The roles in `cgi.cfg` can grant wider access and command permissions.
OAuth group mappings can also supply roles and contact groups through [Teams](../documentation/teams.md).

Keep `use_authentication=1`. Review these settings before you publish the site:

| Setting | What to review |
| --- | --- |
| `default_user_name` | Requests without an authenticated identity can inherit this user's permissions. |
| `authorized_for_admin` | Listed users receive broad administrative permissions. |
| `authorized_for_all_hosts` and `authorized_for_all_services` | These roles widen visibility beyond the user's contacts. |
| `authorized_for_read_only` | Use this role for accounts that must not submit monitoring commands. |
| `use_strict_host_authorization` | If disabled, a host contact can see its services without being a service contact. |

Read [CGI settings](../documentation/cgi-cfg.md) before changing role assignments.
Do not assume that a hidden menu item prevents access to its URL.

::: warning Implicit administrator access
By default, combining `authorized_for_system_commands` with `authorized_for_configuration_information` also grants administrator access.
Set `admin_role_from_system_and_conf = 0` to disable this compatibility behavior.
Review existing role assignments before you change it.
:::

## Protect automation credentials

Prefer a task-specific API key over the installation's `secret.key`.
The secret key grants superuser access. A superuser API key can also select a user context, subject to its restrictions.

::: warning Credential exposure
Do not put real credentials in documentation, screenshots, shell history or source control.
Protect backup copies of API keys and `secret.key` as credentials.
:::

The secret key lives under `var_path`, normally as `secret.key`.
Thruk creates it with mode `0600`. Preserve its owner and restrictive permissions when you restore it.

For API key creation and role restrictions, see the [REST API](../documentation/rest.md#api-key).
Revise or revoke an automation account's keys when its responsibilities change.

## Review executable extensions

Server actions, executable includes, editor hooks and scripted dashboards run code.
Treat their configuration and source files as administrative code.

1. Limit who can edit these files and their configuration.
2. Give the Thruk process only the operating-system permissions that its tasks need.
3. Validate values supplied by a URL or form before a script uses them.
4. Check the user's identity and permissions before a script performs a privileged action.

For server actions, Thruk supplies `REMOTE_USER` and `REMOTE_USER_GROUPS`.
URL arguments remain user input. See [action menu security](../documentation/action-menu.md#authorization-security).

## Keep request protections enabled

Thruk uses CSRF tokens for protected requests. The `csrf_allowed_hosts` setting bypasses this check for selected client addresses.
Keep exceptions narrow. Do not add a broad wildcard to fix an integration error.

Before enabling full command-line display or expanding resource macros, check whether the values contain passwords.
Use the relevant [configuration settings](../documentation/configuration.md) to control what users can see.

## Verify access after changes

Use separate administrator, operator and read-only test accounts.
Check each account's object visibility and command access after changes to roles, OAuth mappings or backend contacts.

For a suspected vulnerability, follow the [security reporting policy](https://github.com/sni/thruk/security/policy).

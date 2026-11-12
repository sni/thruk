---
title: Teams - Authorization via OAuth Groups
---

# Teams

<Badge type="tip" text="New in Thruk 3.24" />

Teams let administrators manage roles and permissions through groups from
OAuth providers. User permissions follow the organizational groups defined
in the OAuth provider.

### Terms

- **team**  : a collection of roles, groups and permissions supplied by

```
          an external OAuth provider.
```

- **role**  : cgi.cfg role, like authorized_for_all_hosts, etc.
- **group** : naemon contact group

### How It Works

When a user authenticates through OAuth, Thruk retrieves the user's group
memberships from the OAuth provider. Thruk maps these groups to roles and
permissions, so administrators do not need to manage each user manually.

### Configuration

Data files define teams and their roles and permissions. You can edit these
files manually or generate them with external systems or custom workflows.

These files typically reside in the `var/thruk/teams/` directory and must have
the same name as the OAuth group they represent, with a `.json` extension.

Use the config tool UI to manage these files.

### Fallback Mechanism

If the teams configuration does not map a user's group, Thruk can use default
roles or permissions. Define these defaults in `_fallback.json` in the same
directory as the other team files.

### Scripting Data Files

You can also define teams through scripts that use external data or logic.
The scripts must be executable and return valid JSON data.
Place them in the same `var/thruk/teams/` directory without a file extension, for example:
`var/thruk/teams/team_name`

You can also create a generic fallback script named `_fallback` in the same directory:
`var/thruk/teams/_fallback`

All scripts receive the following environment variables:

- `THRUK_LOGIN_FORM_USER` : the username of the user who logs in

The first argument is the group name itself.

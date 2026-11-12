---
title: OMD Multisite
---

# How to setup Multisite with OMD

## Introduction

### What is OMD?

The OMD Labs-Edition is a platform to install, maintain and update Nagios-based monitoring systems.
It includes most monitoring components from labs.consol.de and useful addons from other authors.
OMD integrates into your existing system as one rpm or deb package.
It is not a Linux distribution.

### What use is a multisite?

Service providers can host separate monitoring sites for several clients on one server.
With OMD, you can manage each site without affecting other clients' sites.
You can give clients accounts without exposing data from other organizations.

### What will this article cover?

These instructions install OMD on Rocky Linux 10 and create a "master" Thruk site,
two client sites and read-only users.
They show one way to give clients access without exposing other clients' data.
They do not cover all OMD or Thruk features or best practices for this setup.

## Installing and configuring OMD on Rocky Linux 10 {#installing-and-configuring-omd-on-centos-7}

### Installation

Run these commands as root. Enable CRB and EPEL for OMD dependencies, then install the ConSol Labs repository and OMD:

```bash
dnf -y install dnf-plugins-core
dnf config-manager --set-enabled crb
dnf -y install epel-release
dnf -y install https://labs.consol.de/repo/stable/rhel10/x86_64/labs-consol-stable.rhel10.noarch.rpm
dnf -y install omd
```

See the [ConSol Labs repository instructions](https://labs.consol.de/repo/stable/#_10) for repository updates.
If SELinux blocks access, inspect `/var/log/audit/audit.log` and review the required policy before changing enforcement.

### Creating and starting sites

Create three OMD sites: one "master" site and two client sites.
Use `abcmsp` for the master and `clienta` and `clientb` for the clients.

```bash
omd create abcmsp
omd create clienta
omd create clientb
```

Each `omd create` generates a separate password for `omdadmin` and prints it in the command output.
Store each site's password securely before you continue.

This creates 3 sites:
- `https://localhost/abcmsp/`
- `https://localhost/clienta/`
- `https://localhost/clientb/`

Before you open the sites, start them:

```bash
omd start abcmsp
omd start clienta
omd start clientb
```

Replace `localhost` with the IP address or hostname of your OMD server.

### Logging into an OMD site for the first time

Log into each site with:

- User: `omdadmin`
- Password: the password printed by `omd create` for that site.

::: info Generated passwords
There is no shared default password. Each new site has its own generated password.
To change it, log in as the site user and run `set_admin_password`.
:::

### Creating simple service checks

To test the setup, log into Thruk on each site and create a service check for localhost.
Detailed instructions for service checks are outside this guide's scope.

Within Thruk:

`Config Tool > Object Settings > Create a new host > `
Using the following as an example, create a simple check for each site.
Be sure to hit `apply` and then `save & reload` when you are finished.

```text
save to: /hosts.cfg
host_name: ClientAHost
alias: ClientAHost
address: 127.0.0.1
use: check_mk_host
contact_groups: check_mk
```

### Configuring the Livestatus Backends

For this setup, enable Livestatus TCP on the two client sites.
Stop the sites before changing their configuration:

```bash
omd stop clienta
omd stop clientb
```

Use a separate port for each client site. Restrict connections to localhost because all sites run on the same server:

```bash
omd config clienta set LIVESTATUS_TCP on
omd config clienta set LIVESTATUS_TCP_PORT 6558
omd config clienta set LIVESTATUS_TCP_ONLY_FROM 127.0.0.1
omd config clientb set LIVESTATUS_TCP on
omd config clientb set LIVESTATUS_TCP_PORT 6559
omd config clientb set LIVESTATUS_TCP_ONLY_FROM 127.0.0.1
omd start clienta
omd start clientb
```

In the `abcmsp` site, add the two client backends:
Go to `Config Tool` > `Backend / Sites` > `add new connection`.
Use the client name for `name` and `section`. Leave `type` as livestatus.
For the connections, use `127.0.0.1:6558` and `127.0.0.1:6559`, or your chosen ports.
Save the changes.

### Creating Read-Only Users for Thruk

We can create our Apache users and Thruk authorized users within Thruk:

`Config Tool` > `User settings` > type a new username in the `username` field > specify a password,
and leave all authorization settings to `no` and click `save`.

Next, we can change the `Configuration Type` in the drop-down at the top-right of the page to
`CGI & Access`. Under the `authorized_for_read_only` field, select the new user and click the
`>>` button to move them to the `selected` field.

## Conclusion

You can also isolate client data with containers and Livestatus backends.
Another option is to export a dashboard as a PNG image for a web page:
https://github.com/sni/thruk/blob/master/support/panorama2img

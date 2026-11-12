---
title: FAQ
---

# Frequently Asked Questions

## General

### What is Thruk?

Thruk is a web interface for Nagios and compatible systems through the Livestatus API.
It combines multiple cores in one display and is much faster than the original cgis.
It improves usability and includes addons such as a dashboard, business process
tools and a configuration interface.

### Is Thruk an Abbreviation? What does Thruk mean?

Thruk is a random word with no meaning. Pronounce it like 'Truck'.

### Where is the statusmap?

Thruk has its own statusmap that scales better in large environments.
It ships as an addon and is enabled by default.
For details and screenshots, see the [plugins page](plugins.html).

### Authorization/Authentication is not working

Use a production web server with a FastCGI or PSGI deployment.
Check the [authentication and authorization settings](../guides/access-control.md).
The development server is not a replacement for production authentication.

### All dates and times are displayed with the wrong timezone

Set the 'server_timezone' configuration option in your thruk_local.conf.
See the [configuration page](configuration.html#server_timezone) for details.

## Usage

### How do I select hosts/services on the status page?

When the table row is highlighted, click an empty area in it.
Clicking a link does not select the row.

### How can i enable debug logging

Have a look at the [logfiles section](logfiles.html#enable-debug-logging).

### Where can I see the full command line for a host or servicecheck?

::: warning
Full command lines can expose passwords through the web interface.
The `show_full_commandline` option is enabled by default for users with the configuration role.
Set `show_full_commandline = 0` to hide the command line for everyone.
:::

## Customization

### Enable HTTPS / TLS / SSL in Apache Webserver for Thruk

Thruk supports HTTPS. Add the include file to the SSL vhost as well.
Virtual hosts do not inherit rewrite rules.

Example on Centos 7:

Install `mod_ssl` package to enable ssl in the Apache.

```console
  #> yum install mod_ssl
```

Open `/etc/httpd/conf.d/ssl.conf` and find `<VirtualHost _default_:443>`.
Add the include inside the `VirtualHost` tag, for example at the end of the block.

```
  <VirtualHost _default_:443>
    ...
    Include /usr/share/thruk/thruk_cookie_auth.include
  </VirtualHost>
```

You may also wish to modify your `/etc/thruk/thruk_local.conf` to use an updated `cookie_auth_restricted_url`:

```
  cookie_auth_restricted_url = https://localhost/thruk/cgi-bin/restricted.cgi
```

Finally reload Apache:

```console
  #> systemctl reload httpd
```

### How to change the side menu

This is covered in the [advanced menu](menu.html) section.

### How can I add more themes?

Themes are in 'themes'. Copy and modify the one you
like. See the [themes page](themes.html) for details.

### How can I disable themes?

To disable a theme, remove its symlink from 'themes/themes-enabled'.
See the [themes page](themes.html) for details.

### How can I customize reports?

See the [official documentation](reporting.html#customized-reports) to customize reports.

### Why are the PNP graphs missing in my reports?

First you need a working PNP installation. Then check
the [official documenation](configuration.html#pnp_export).

If nothing helps, add some debug output to the script which is responsible for
the pnp export (experienced users only).

Add these lines to 'plugins/plugins-available/reports2/script/pnp_export.sh'.

```
exec >/tmp/pnp.log 2>&1
set -x
```

Then regenerate a report and investigate that new logfile.

### How can I create a readonly Panorama dashboard for my boss

Add user-specific settings to thruk_local.conf:

```
  <User boss>
    <Component Thruk::Plugin::Panorama>
      default_view    = /var/lib/thruk/panorama_view.boss
      readonly        = 1
  </Component>
  </User>
```

The default view can be exported from the 'Settings' menu inside the panorama
dashboard.

### How can I set custom page titles

To use bookmark names as page titles, enable use_bookmark_titles in thruk_local.conf:

```
    use_bookmark_titles = 1
```

When you open a Thruk bookmark, its name becomes the page title.
On most pages, you can also add 'title=your title here' to the URL to set a custom title.

### How can I enable form based authentication

> activated by default since v2.0
To use form or cookie-based authentication like demo.thruk.org, change the Apache configuration.
Get [thruk_cookie_auth.example](https://github.com/sni/thruk/blob/master/support/thruk_cookie_auth.example)
and put everything except the RewriteLock into the virtualhost of your choice.
The RewriteLock must be outside any virtualhost. Then restart Apache.

### How can I disable cookie authentication

::: tip
In OMD you just need to run `omd config set THRUK_COOKIE_AUTH off`
:::

From v2.0, cookie (form-based) authentication is enabled by default.
To switch back to basic authentication, comment out the includes in the Apache configuration.

On Debian and Ubuntu open all files matching:

```
/etc/apache2/sites-enabled/*default*
/etc/apache2/conf-available/thruk_cookie_auth_vhost.conf
```

On SLES systems open:

```
/etc/apache2/conf.d/thruk_cookie_auth_vhost.conf
```

On Centos/RHEL systems open:

```
/etc/httpd/conf.d/thruk_cookie_auth_vhost.conf
```

then comment the line with:

```
Include /usr/share/thruk/thruk_cookie_auth.include
```

Then restart Apache.

### How can I setup multiple sites with OMD

There is a [guide](omd-multisite.html) here.

## Installation

### Is it possible to operate Thruk in a cluster?

Yes. Put a load balancer in front of 2 or more Thruk installations.
Share `etc_path` and `var_path` across all instances through NFS, DRBD or a similar system.
Keep `tmp_path` local to each node. The state folder usually has little traffic.
See the [cluster setup](cluster.md) for details.

### wkhtmltopdf

wkhtmltopdf is no longer required and has been replaced by puppeteer.

### phantomjs

phantomjs is no longer required and has been replaced by puppeteer.

### puppeteer {#puppeteer}

The reports2 plugin requires puppeteer to create PDF reports.
For details about puppeteer, see https://pptr.dev/.
OMD includes puppeteer from version 5.

The easiest way to install puppeteer is with the included installer:

```console
  #> /usr/share/thruk/script/install_puppeteer.sh
```

This will install puppeteer into /var/lib/thruk/puppeteer

It requires node and npm to be installed.

If chromium is installed before you run the installer, Thruk uses the system chromium.
Otherwise, puppeteer downloads chromium into /var/lib/thruk/puppeteer/chromium.

To prevent the chromium download, set this environment variable before you run the installer:

```console
  #> export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
```

Then specify which chromium puppeteer should use, for example in /etc/thruk/thruk.env:

```console
  #> export PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
```

### How can I enable the business process addon.

It works out of the box with OMD. If not using OMD, some manual steps
are required which are described in the
[official documenation](business-process.html).

## Hacking Thruk

### Within OMD

For OMD, follow this guide:
https://github.com/sni/omd_utils/tree/master/thruk_developer
It connects a test OMD site to the git version of Thruk.
This works well if changes to Perl module dependencies are small.

The installer adds a new OMD daemon which restarts Thruk whenever you change
a perl file or template.

### Install Test Environment from Source

1. Get a fresh copy of the sources:

   ```console
   /tmp %> git clone git://github.com/sni/thruk.git
   ```

2. Create a .author file to disable some caches:

   ```console
   /tmp %> cd Thruk && touch .author
   ```

3. Use Perl dependencies from an existing installation:

   ```console
   /tmp/Thruk %> export PERL5LIB=/usr/lib/thruk/perl5
   ```

   See the [installation instructions](install.html) for dependency setup.

4. Start the development server:

   ```console
   /tmp/Thruk %> ./script/thruk_server.pl -r
   HTTP::Server::PSGI: Accepting connections at http://0:3000/
   ```

5. Make and review your changes.
6. Commit the changes and create a patch file to send upstream:

   ```console
   /tmp/Thruk %> git commit -av
   /tmp/Thruk %> git format-patch -o /tmp/ --signoff -1
   ```

## Errors

### Backend not available

Livestatus over SSL through socat no longer works because of problems with socat and JSON data.
If you see errors like these:

```
[ERROR][Thruk.Controller.Root] Caught exception in Thruk::Controller::status->index "socket error at thruk/script/../lib/Monitoring/Livestatus/Class/Base/Table.pm line 186"
[ERROR][Thruk.Controller.error] internal server error
```

and you use socat for livestatus over ssl, please change to stunnel or
ssh with the normal xinetd solution.

### undefined symbol: Perl_Istack_sp_ptr

Perl can report undefined symbols if you install a package built for another platform.
Examples include a Debian package on Ubuntu or an Ubuntu 11 deb file on Ubuntu 12.

```
/usr/bin/perl: symbol lookup error: /usr/lib/thruk/perl5/x86_64-linux-gnu-thread-multi/auto/List/Util/Util.so: undefined symbol: Perl_Istack_sp_ptr
```

Use the package for your distribution.
If no package is available for your platform, install from source.

### Premature end of script headers: fcgid_env.sh

A few things to check:

- Check the Apache error log for details.
- Check the [Thruk log](logfiles.md).
- On Redhat/Centos, check whether SELinux is enabled:

  ```console
  #>getenforce
  Disabled
  ```

`Enforcing` means that SELinux enforcement is enabled.
Read `/var/log/audit/audit.log` for access-denial details.

::: warning Legacy workaround
The old CentOS workaround set `SELINUX=disabled` in '/etc/selinux/config' and required a reboot.
This disables SELinux enforcement. Review access denials and the required policy before changing enforcement.
:::

For details, see http://wiki.centos.org/HowTos/SELinux.

If neither the Apache nor Thruk logs show an error, run the fcgi script manually
as the webserver user, usually `www-data` or `apache`.

```console
  su - www-data -c "/usr/share/thruk/fcgid_env.sh"
  STDIN is not a socket: specify a listen location at /usr/lib/thruk/perl5/Plack/Handler/FCGI.pm line 57.
```

The error above is expected for this test.
Otherwise, the output should show the actual error.

### possible csrf, no or invalid token

This error occurs when you send commands without a valid CSRF protection token,
as with nagstamon. Add those clients to the exception list:
[csrf_allowed_hosts](configuration.html#csrf_allowed_hosts).

More information about [csrf](http://en.wikipedia.org/wiki/Cross-site_request_forgery).

### Error: TypeError: $.browser is undefined

If you use ssi files for PNP4Nagios popups, update them from
[Thruks examples](https://github.com/sni/thruk/tree/master/ssi).

The cluetip plugin used by these popups does not work with Thruk's latest jQuery release.
Thruk includes its own updated copy of the JavaScript library.

---
title: Installation
---

# Installation

You can install Thruk in several ways.

### Labs Consol Repository

The [Labs Repository](https://labs.consol.de/repo/) provides packages of
the latest Thruk releases (including daily development builds) and other
tools such as Mod-Gearman. Follow the guide for your distribution on the labs page.

### OMD

OMD from [omdistro.org](http://omdistro.org) provides a preconfigured Thruk installation.
Debian, Ubuntu, Centos and Suse packages contain the latest versions of Nagios
and Thruk. They also include Icinga, Shinken, pnp4nagios, check_mk and Nagvis.
Use OMD for new Nagios / Thruk installations when you want several addons at once.

### Use Packages

You can also install Thruk as a standalone binary package.

Download packages from the [download page](https://www.thruk.org/download.html).

All packages have the following filesystem structure:

```
  /etc/thruk                       Thruks config
  /etc/httpd/conf.d/thruk.conf     Apache config
  /usr/share/thruk                 shared files
  /usr/lib/thruk/perl5             Perl libraries
  /var/cache/thruk                 temporary files
  /var/lib/thruk                   stored user settings
```

After installation, Thruk is available at http://your-host/thruk/.
The 'thrukadmin' account is disabled until you set a password:

```
  #> htpasswd /etc/thruk/htpasswd thrukadmin
```

Package upgrades disable the old shipped default password.
They preserve operator-set passwords and other accounts.
If you still used the default password, run the command above to restore access.

You may need to change the backend configuration.
Use thruk_local.conf to override any settings.

#### Debian / Ubuntu

```
  #> dpkg -i thruk_1.84_debian6_amd64.deb
```

If dependency errors occur, run 'apt-get -f install', then retry 'dpkg -i...'.

#### Centos / Redhat

```
  #> yum install --nogpgcheck thruk-1.84-1.rhel6.x86_64.rpm
```

You may need to include an external repository for mod_fastcgi module.
Epel or Rpmforge should do it.

#### SLES

```
  #> zypper install thruk-1.84-1.sles11.x86_64.rpm
```

You may need the SLES sdk dvd for additional dependencies.

### Source Installation

A [Source Installation](install_from_source.html) can help if you have special
requirements for paths and users. Only experienced users should use this method,
as a last resort.

There is a separate page with [detailed instructions](install_from_source.html).

## Configuration

Updates overwrite `thruk.conf` with new defaults. The thruk_local.conf file
contains local overrides, and updates never overwrite it.

```
    /etc/thruk/thruk_local.conf
    /etc/thruk/cgi.cfg
```

See the [Thruk Configuration](configuration.html) section for a detailed explanation of the options in `thruk_local.conf`.

See the [CGI Configuration](cgi-cfg.html) section for options from the `cgi.cfg` file.

## Apache Configuration {#apache-configuration}

::: tip apache is preconfigured when using packages
OMD and packages preconfigure Apache. You do not need to configure it separately.
:::

Apache configuration is covered in the [Webserver Integration](install-webserver.html) section.

## Backend Configuration {#backend-configuration}

To connect multiple backends to one Thruk interface, specify multiple 'peer' items.

### Livestatus

Livestatus is an add-on for Naemon, Nagios or Icinga that provides real-time
status data. It adds very little overhead to the Naemon core compared with
database addons. This makes Livestatus-based GUIs fast and keeps their data current.

::: tip Shinken
Shinken has livestatus support built-in and does not require additional
modules.
:::

Follow https://checkmk.com/cms_livestatus.html
to install Livestatus on your monitoring server. The
[Lab Consol Repository](#labs-consol-repository) has livestatus rpm
packages. For Debian-based Linux systems, use your distribution's packages.

Build the NEB module and add it to your naemon.cfg,
nagios.cfg or icinga.cfg.

```
 broker_module=/opt/local/livestatus/livestatus.o /tmp/live.sock
```

Then use the socket as 'peer' parameter in your backend configuration.

**Thruk backends**
![Thruk Backends Manager](source/backends.png)

**Livestatus architecture**
![Livestatus Architecture](source/livestatus.png)

**thruk_local.conf:**

```
  <Component Thruk::Backend>
      <peer>
          name    = local livestatus
          type    = livestatus
          <options>
              peer    = /var/run/live
          </options>
      </peer>
  </Component>
```

### TLS Livestatus

<Badge type="tip" text="New in Thruk 2.20" />

TLS Livestatus encrypts Livestatus connections with TLS/SSL.
Create certificates and configure your backends, for example:

**thruk_local.conf:**

```
  <Component Thruk::Backend>
      <peer>
          name    = remote_site
          type    = livestatus
          <options>
              peer    = tls://remote_host:6557
              cert    = /etc/thruk/client.pem
              key     = /etc/thruk/client.key
              ca_file = /etc/thruk/server.crt
              verify  = 1
          </options>
      </peer>
  </Component>
```

Adding `cert` and `key` is optional and enables client certificate authorization.
Thruk uses `ca_file` to verify the server certificate.
Do not disable hostname and certificate verification: this makes the connection
as insecure as one without TLS. Setting `verify` to 0 disables these checks.

This full configuration example assumes an OMD installation with a site named `demo`:

Fetch makecert.sh from https://github.com/sni/thruk/blob/master/support/makecert.sh

```
  %> ./makecert.sh remote_host your@email.com
```

xinetd.conf:

```
  service tls_livestatus
  {
          type            = UNLISTED
          socket_type     = stream
          protocol        = tcp
          port            = 6557
          wait            = no
          cps             = 100 3
          instances       = 500
          per_source      = 250
          flags           = NODELAY
          disable         = no
          user            = demo
          server          = /usr/bin/stunnel
          server_args     = /omd/sites/demo/etc/stunnel/stunnel.conf
  }
```

stunnel.conf:

```
  service                = tls_livestatus
  exec                   = /usr/bin/timeout
  execargs               = timeout 600 /omd/versions/default/bin/unixcat /omd/sites/demo/tmp/run/live
  cert                   = /omd/sites/demo/etc/stunnel/server.pem
  key                    = /omd/sites/demo/etc/stunnel/server.key
  compression            = zlib
  ciphers                = AES128-SHA
  verify                 = 2
  CAfile                 = /omd/sites/demo/etc/stunnel/client.pem
  TIMEOUTidle            = 600
  debug                  = debug
  output                 = /omd/sites/demo/var/log/stunnel.log
  syslog                 = no
```

### HTTP

You can connect Thruk installations through HTTP to access live data and
securely manage remote object configurations. To authenticate the central Thruk
installation, provide the secret key from the slave instance.
This lets you manage several independent installations from one central installation.

::: tip use SSL
Use HTTPS for remote connections.
:::

```
    # package installation
    %> cat /var/lib/thruk/secret.key

    # omd site
    OMD[site]:~$ cat var/thruk/secret.key
```

**HTTP architecture**
![HTTP Architecture](source/livestatus_http.png)

**thruk_local.conf:**

```
  <Component Thruk::Backend>
      <peer>
          name    = remote_http
          type    = http
          <options>
              peer  = http://remote_host/thruk/
              auth  = key from remote installation var/thruk/secret.key
          </options>
      </peer>
  </Component>
```

### MySQL

MySQL can store a logfile cache. It is not a backend for status data.

ex.:

```text
  logcache = mysql://username:password@localhost:3306/thruk_logs
```

Details are explained in the [Logfile Cache](logfile-cache.html) section.

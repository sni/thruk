---
title: Source Installation
---

# Install from Source

These steps create a thruk user with Thruk and all required libraries in its home folder.

::: warning Experienced Users Only
Source installation is for experienced users only. Use packages or repositories
in almost all situations, especially in production environments.
:::

### Requirements

To install the Thruk Monitoring WebUI from source, you need:

- Perl
- Git Client
- compiler tools: automake, make, g++, gcc
- Apache Webserver (optional for fastcgi only)

### Create New User

Follow your system manual to add a user.
Use these names for this guide:

```
  user:  thruk
  group: thruk
```

::: info Important
Run all following steps as the thruk user.
:::

### Install Thruk Libraries

All required Perl modules are available via the thruk_libs repository:

```
  %> su - thruk
  %> cd /tmp
  %> git clone git://github.com/sni/thruk_libs.git
  %> cd /tmp/thruk_libs
  %> make
```

You now have all required modules in `/tmp/thruk_libs/local-lib/dest`.

### Git Clone Thruk

```
    %> cd /tmp
    %> git clone https://github.com/sni/thruk.git
    %> cd /tmp/Thruk
    %> ./configure
    %> make
```

### Move Perl Librarys

Move the libraries into the thruk folder:

```
    %> mv /tmp/thruk_libs/local-lib/dest/lib/perl5 ~/Thruk/
```

Add this setting to `.profile`:

```
    PERL5LIB=lib:~/Thruk/perl5
```

Log out and log in again. Check that `$PERL5LIB` contains the correct path.

To test whether Thruk works, run:

```
    %> cd ~/Thruk && ./script/thruk
```

Or run the development server:

```
    %> cd ~/Thruk && ./script/thruk_server.pl
```

Open http://&lt;your_host&gt;:3000 in your browser.

### Configuration

Copy the sections you need to change from 'thruk.conf' into 'thruk_local.conf'.
You probably need to adjust the Livestatus settings.

```
  %> vim thruk_local.conf
```

Updates overwrite thruk.conf with new defaults. The thruk_local.conf file
contains local overrides, and updates never overwrite it.

Adjust the settings in 'cgi.conf' for your installation.

For details about configuration options, see [Thruk Configuration](configuration.html).

### Webserver Integration

If Thruk works, continue with [integrating Thruk into your webserver](install.html#apache-configuration).

### Backend Configuration

Finally, configure backends as described in [Backend Configuration](install.html#backend-configuration).

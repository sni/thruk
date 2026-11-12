---
title: Graphing Addons Integration
---

# Graphing Addons Integration

### PNP4Nagios

Thruk can display [PNP4Nagios](http://docs.pnp4nagios.org/) graphs in host and
service details and SLA reports.

Set 'action_url' to the path of your pnp4nagios installation.
Make sure `shown_inline_pnp=1` is set.
Do not set `graph_url`: only other graphing addons need it.

OMD preconfigures PNP4Nagios integration.

Example Service

```
define service {
  host_name             Example Host
  service_description   Service with Performance Data
  use                   generic_service
  action_url            /pnp4nagios/index.php/graph?host=$HOSTNAME$&srv=$SERVICEDESC$' class='tips' rel='/pnp4nagios/index.php/popup?host=$HOSTNAME$&srv=$SERVICEDESC$
}
```

Thruk inserts the value verbatim into an +<a href=\'action_url\'>+.
The quoting adds extra HTML parameters.

::: tip templates
Often you can use the templates 'host-pnp' or 'srv-pnp' which set the right action_url automatically.
:::

#### Cookie Authentication

For single sign-on, enable cookie authentication for PNP4Nagios as well.
Copy the cookie auth include file, usually '/usr/share/thruk/thruk_cookie_auth.include', to the httpd configuration directory.
Change every occurrence of this RewriteCond statement from:

```
RewriteCond %{REQUEST_URI}           ^/thruk
```

to:

```
RewriteCond %{REQUEST_URI}           ^/(thruk|pnp4nagios)
```

Include the updated file instead of the default.
Edit 'thruk_cookie_auth_vhost.conf' or your custom virtual host configuration.

Then add the path used for cookies to your local thruk configuration. You can add the following line to '/etc/thruk/thruk.conf'.

```
cookie_path = /
```

Finally, change the authorization settings in the default PNP4nagios httpd configuration from:

```
AllowOverride None
Order allow,deny
Allow from all
#
# Use the same value as defined in nagios.conf
#
AuthName "Nagios Access"
AuthType Basic
AuthUserFile /usr/local/nagios/etc/htpasswd.users
Require valid-user
```

to:

```
AllowOverride None
Require all granted
```

Read more about the integration in web interfaces on [pnp4nagios.org](http://docs.pnp4nagios.org/pnp-0.6/webfe).

#### Popups

With the example action URL, Thruk can display popups on host and service lists.
Enable etc/thruk/ssi/status-header.ssi-pnp. OMD already enables this file.
After renaming the file, restart Thruk or the webserver.

### Grafana / Histou

The integration of [Grafana](http://grafana.org/) graphs is very similar to
the PNP4Nagios integration by using the 'action_url'.

::: tip labs-omd
The OMD Labs Edition from [labs.consol.de](https://labs.consol.de/omd/) comes with grafana preconfigured and is
the easiest way to configure Thruk with Grafana. [This guide](https://labs.consol.de/omd/packages/grafana/) explains how to enable Grafana
in OMD-Labs].
:::

Example Service:

```
define service {
  host_name             Example Host
  service_description   Service with Performance Data
  use                   generic_service
  action_url            /grafana/dashboard/script/histou.js?host=$HOSTNAME$$&service=$SERVICEDESC$
}
```

Install [Histou](https://github.com/Griesbacher/histou) to add PNP4Nagios-like
templates to Grafana. OMD-Labs already prepares this integration.

### Other 3rd Party Grapher

To integrate other graphing tools, such as graphite or graphios, set
[graph_word](configuration.html#graph_word) in thruk_local.conf.
If their URLs need different host or service names, use regular expressions
in [graph_replace](configuration.html#graph_replace) to replace unwanted characters.

graphite:

```
graph_replace = s/[^\w\-]/_/gmx
```

graphios:

```
graph_replace = s/\s//gmx
graph_replace = s/[^\w\-]/_/gmx
```

### General Tips & Tricks

#### Action Url Icons

You can change the action url icons from the thruk_local.conf with
[host_action_icon](configuration.html#host_action_icon) and [service_action_icon](configuration.html#service_action_icon).

Set the custom variable '_ACTION_ICON' to override an individual host or service icon.

Example Service

```
define service {
  ...
  _ACTION_ICON          action_pnp.png
}
```

#### Specifying Default Graph

<Badge type="tip" text="New in Thruk 2.06" />
Hosts and services often have multiple graphs. For example, ping checks have
graphs for round trip time and packet loss.
By default, Thruk uses the first graph in details and reports.
Since release 2.06, you can select a graph index through the custom variable '_GRAPH_SOURCE'.
The PNP4Nagios source index starts at 0.
To use the second graph by default, set it to 1.

Since v3.20 you can also use descriptive names to address specific graphs.

Example Service

```
define host {
  ...
  _GRAPH_SOURCE         rta   # use graph by name
}

define service {
  ...
  _GRAPH_SOURCE         1     # use graph by number
}
```

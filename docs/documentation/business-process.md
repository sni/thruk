---
title: Business Process
---

# Business Process

Thruk includes an engine to design, operate and display business intelligence models.
Business processes can span multiple sites. One local site performs all calculations.
Thruk needs access to the 'check_results' folder to submit results.
It also needs a configuration file to create hosts and services for your objects.

In 'edit mode', right-click a node and select 'Edit Node' to change it.
To change general options, such as hard or soft states, open any node's 'General' tab.

## How it works

**Business process workflow**
![Business Process Architecture](source/bp_arch.png)

- Cron usually runs 'Thruks Business Process Engine'. Thruk adds the cronjob automatically when you create your first business process.
- 'Business Process Config' and 'Runtime Status' are JSON files that store objects and status.
- Thruk submits results to Naemon through the check_results folder or Livestatus.
- Livestatus supplies input data for the calculations.

## Setup

If you do not use OMD, configure these settings manually:

1. Copy `<Component Thruk::Plugin::BP>` from /etc/thruk/thruk.conf into thruk_local.conf for local changes.
2. Copy the Thruk BP Templates into your Naemon conf.d folder, for example /etc/naemon/conf.d/thruk_bp_templates.cfg.
   Get them from [GitHub](https://github.com/sni/thruk/blob/master/support/thruk_templates.cfg) or /usr/share/thruk/thruk_templates.cfg.
3. Add default contacts or contactgroups to the Thruk BP Host Template (thruk-bp-template).
4. Set 'objects_templates_file' to the template file's location.
5. Create an empty thruk_bp_generated.cfg file, for example /etc/naemon/conf.d/thruk_bp_generated.cfg.
6. Set 'objects_save_file' to that file's location.
7. Give the webserver/Thruk user permission to edit it, for example:

   ```sh
   chown www-data: /etc/naemon/conf.d/thruk_bp_generated.cfg
   ```

8. Set 'spool_dir' to Naemon's 'check_result_path', for example /var/naemon/rw/check_results.
   Alternatively, set 'result_backend' to reuse an existing backend.
9. Give the webserver/Thruk user write access to the folder, for example:

   ```sh
   chgrp www-data /var/naemon/rw/check_results && chmod g+rwx /var/naemon/rw/check_results
   ```

10. Set 'objects_reload_cmd' to the reload command:

    ```text
    sudo -u naemon /etc/init.d/naemon reload
    ```

    Add the required sudo permissions. For example, put this rule in /etc/sudoers:

    ```text
    thruk ALL=(ALL) NOPASSWD: /etc/init.d/naemon
    ```

### Integration in Naemon

Thruk creates a Naemon Host object for the business process and Service objects
for its selected nodes. These objects can send notifications, including for
individual steps of the business process.

You need 2 files:

- Thruk BP Templates (see an [example on GitHub](https://github.com/sni/thruk/blob/master/support/thruk_templates.cfg))
- Thruk BP Objects

Set both file locations in 'thruk_local.conf'.
You maintain the templates file. Thruk overwrites the objects file whenever you
change a business process. Make sure Thruk can write to the objects file.

You can only select from the available templates.
Edit them with the Thruk Config Tool or manually in 'objects_templates_file'.

Thruk uses the business process name as the hostname.
Use a unique prefix or similar method to avoid conflicts with existing hosts.

::: tip notifications
Each business process creates at least one host and one service.
Configure notifications on the service. The host is almost always ok and changes
state only when an internal error occurs.
:::

### Integration in Icinga2

To integrate Thruk Business Processes with Icinga2, use a minimal configuration like this:

```
<Component Thruk::Plugin::BP>
    objects_save_file      = /etc/icinga2/conf.d/thruk_bp.conf
    objects_templates_file = /etc/icinga2/conf.d/thruk_templates.conf
    objects_save_format    = icinga2
</Component>
```

Get the Icinga 2 template file from [GitHub](https://github.com/sni/thruk/blob/master/support/thruk_templates_icinga2.conf).
Make sure Thruk is able to write to the `/etc/icinga2/conf.d/thruk_bp.conf` file.

## Creating New Business Processes

To create or change business processes, you need these roles from cgi.cfg:

- authorized_for_configuration_information
- authorized_for_system_commands

Then model the business process in the web GUI.

## Configuration

Configuration settings are covered by the
[configuration sections](configuration.html#component-thrukpluginbp).

## Custom Functions

You can write custom aggregation functions in Perl.
Store them in &lt;config dir&gt;/bp/ with the .pm filename extension.
Function names must end with `function` to distinguish them from custom filters.

Example: /etc/thruk/bp/echo.pm

```
# echofunction:
#
# This function just echoes the
# provided text sample and optionally
# reverses the text.
#
# Arguments:
# arg1: Text;      text;     text that should be echoed
# arg2: Reverse;   checkbox; yes; no
# arg3: Uppercase; select;   yes; no
sub echofunction {
    my($c, $bp, $n, $args, $livedata) = @_;
    my($text, $reverse, $upper) = @{$args};
    $text = scalar reverse $text if $reverse eq 'yes';
    $text =             uc $text if $upper   eq 'yes';
    return(0, $text, $text, {});
}
```

Input arguments are:

- $c: thruk context object containing livestatus connection pool
- $bp: business process object
- $node: business process node object
- $args: array ref of arguments from the node edit dialog
- $livestatus: optional livestatus data for all hosts and services in this business process

A custom aggregation function must return at least 3 values.
It can also return a 4th value as a hash.

- status code: 0 = Ok, 1 = Warning, 2 = Critical, 3 = Unknown
- node sub label: short text used inside the node
- textual output: text output of aggregation function with optional performance data
- extra arguments: hash list of node attributes which will be overridden.

Define arguments in comments in the Perl module that contains your function.
See the example above.
Each argument requires 3 attributes separated by semicolons (;).

```
# arg1: Text;      text;     text that should be echoed
```

- Name: name of this attribute, used in the edit dialog
- Type: can be any of 'Text', 'Select', 'Checkbox', 'Host', 'Hostgroup', 'Service', 'Servicegroup'.
- Options: optional arguments. For Text, this is a placeholder. For Select or Checkbox, this is a semicolon-separated list of options.

::: tip perl
All custom aggregation functions enable 'use warnings' and 'use strict' by default.
They run in the 'Thruk::BP::Functions' context and can use all normal aggregation
functions and helpers from [../api/Thruk/BP/Functions.html](https://www.thruk.org/api/Thruk/BP/Functions.html)
:::

## Scripted Business Processes

You can generate business processes with a custom script.

1. Generate the JSON structure and write it to your `bp` folder.
2. Run `thruk bp commit` to update cronjobs and generate objects.

The `bp` folder is usually in `~/var/thruk/bp/` when using OMD or `/var/lib/thruk/bp` otherwise.

There are a few extra attributes you can add to your nodes when exporting them:

### Extra Node Attributes

- `create_obj`: if set to 1, node will be exported as service.
- `host_name`: use this host to add the exported service to.
- `service_object_attributes`: hash list of extra attributes added to this service.
- `host_object_attributes`: hash list of extra attributes for the business process's host container. This is only useful for node1.

### Extra BP Attributes

- `create_host_object`: if set to 0, no BP host object is exported. You must ensure that the host already exists.

For other attributes, refer to a manually created business process file in your `bp` folder.
You can copy attributes from that file.

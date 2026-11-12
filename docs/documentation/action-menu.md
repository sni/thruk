---
title: Action Items
---

# Action Menu

<Badge type="tip" text="New in Thruk 1.86" />
Action Menus provide custom icons and menus for hosts and services.
You can add multiple action icons and menus to each host or service.
Use them to open links or run server actions.

![Action Menu](source/action_menu.png)

## Adding an Action Menu

There are 3 ways to add an action menu to a host or service.

- set the menu directly by the `_THRUK_ACTION_MENU` custom variable
- reference an existing menu from the `action_menu_items` by a  `_THRUK_ACTION_MENU` custom variable
- use apply rules from `action_menu_apply`

For examples, see the [configuration](configuration.html#action-menu-settings) documentation.

## Server Actions

To run a server action from an icon or menu item, use a pseudo URL like this.
For details about where to set the link, see [configuration](configuration.html#action-menu-settings).

```
    server://*scriptname*/argument1/argument2/...
```

To make this work, you need to define that `scriptname` in your thruk_local.conf:

```
  <action_menu_actions>
      scriptname   = /usr/local/bin/sample.sh $HOSTNAME$ $SERVICEDESC$
  </action_menu_actions>
```

When someone clicks the link, Thruk runs `sample.sh` like this:

```
    /usr/local/bin/sample.sh <hostname> <servicename> argument1 argument2
```

Thruk takes the complete command line from `thruk_local.conf` and replaces all
available macros. Then it adds the arguments from the link configuration.

## Macros

Server-side scripts can use most macros.
See [Macros](macros.html) for a list of all available macros.

Inside the actual menu definition you can only use the following macros:

- `$HOSTNAME$`
- `$SERVICEDESC$`
- `{{ theme }}`
- `{{ remote_user }}`
- `{{ site }}`
- `{{ prefix }}`

### Scripts

Scripts can perform any action. Follow these guidelines:

- Make the script exit quickly. Thruk waits for the script to return. Long running
  tasks should be started in the background.
- Give the user useful feedback on STDOUT
- Exit codes should be zero if OK and greater than zero on errors.

::: tip script output
Thruk displays script output as feedback to the user.
The output can contain HTML, which Thruk renders.
:::

### Authorization / Security

Thruk runs the script if the user has access to the given host and service.
Before running critical scripts, check `$REMOTE_USER` or `$REMOTE_USER_GROUPS`, or both.
You can trust macros in the configured command line and the REMOTE_USER variables.
Treat URL-supplied variables as unsafe: users can forge them.

You can use the `action_wrapper` script from the examples folder to check for valid users and groups.

```
  <action_menu_actions>
      scriptname   = .../examples/action_wrapper -u omdadmin -g Admins,Operators ./sample.sh $HOSTNAME$ $SERVICEDESC$
  </action_menu_actions>
```

Available standard environment variables are listed on the
[CLI Environment](cli.html#_environment-variables) page.

## Dynamic Javascript Menus

<Badge type="tip" text="New in Thruk 2.24" />
Since version 2.24, you can create menus dynamically with JavaScript.
Create a file ending in `.js` in `action_menus`.
Thruk calls its first function, which must return a JSON structure for the menu.

The file can contain other functions, for example to generate submenus.

The first function in the file must return an array of ([action_menu_items](configuration.html#action_menu_items)). The menu
itself can be a function again to create more dynamic menus.

::: warning
All functions share one namespace. Use unique function names across all menus.
Use the filename as a prefix.
:::

::: tip user data
<Badge type="tip" text="New in Thruk 3.02" />

The current user with its roles and groups is available in the `thruk_user` variable and can be used to make your menu depend on user attributes.
ex.:

```
{
  "name":"thrukadmin",
  "groups":["example"],
  "roles":["authorized_for_admin","authorized_for_all_host_commands",,...],
  "can_submit_commands":true,
  "readonly":false
}
```
:::

A very simple example:

**action_menus/js_basic_menu.js**

```

function js_basic_menu(data) {
    return({
      "icon":"../themes/{{theme}}/images/dropdown.png",
      "title": "javascript menu",
      "menu":[{
          "icon":"uil-link",
          "label":"test menu item",
          "action":"http://..."
        }]
    });
}
```

Menu callbacks can return thenables in a jQuery context.
This lets you create submenus from Ajax responses.
The following example creates a submenu that lists all hosts.

**action_menus/js_adv_menu.js**

```

function js_adv_menu(cfg) {
    return({
      "icon":"../themes/{{theme}}/images/dropdown.png",
      "title": "javascript advanced menu",
      "menu":[
        {
          "icon":"uil-link",
          "label":"test menu item",
          "action":"http://..."
        },
        {
          "icon":"fa-folder",
          "label":"list all hosts",
          "menu": js_adv_menu_submenu
        }
      ]
    });
}

function js_adv_menu_submenu(cfg) {
  return(jQuery.get("../r/hosts?columns=name").then(function(data, textStatus, jqXHR) {
    var result = [];
    jQuery(data).each(function(i, r) {
      result.push({ label: r.name });
    });
    return(result);
  }));
}
```

## Custom Quick Actions

<Badge type="tip" text="New in Thruk 3.24" />

Custom server actions can be added to the quick action menu on host and service detail pages.
There is a detailed example in the [quick actions](custom-quick-actions.html) documentation.

## Examples

### Panorama Dashboard

This Perl script changes the color of a shaped icon.

**icon settings**

![Dashboard Icon](source/switch_color.png)

**thruk_local.conf**

```
  <action_menu_actions>
    switch_color    = .../switch_color.pl $DASHBOARD_ID$ $DASHBOARD_ICON$
  </action_menu_actions>
```

::: tip switch_color.pl
just changes the color of the icon.
:::

```perl
#!/usr/bin/perl

use warnings;
use strict;
use Thruk::Utils;

my $file  = 'var/panorama/'.$ARGV[0].'.tab';
my $data  = Thruk::Utils::read_data_file($file);
my $color = $data->{$ARGV[1]}->{'xdata'}->{'appearance'}->{'shapecolor_ok'};
if($color eq '#CA1414') {
    $color = '#199C0F';
} else {
    $color = '#CA1414';
}
$data->{$ARGV[1]}->{'xdata'}->{'appearance'}->{'shapecolor_ok'} = $color;
Thruk::Utils::write_data_file($file, $data);

print "switched color to $color\n";
```

### Confirmation Dialog

<Badge type="tip" text="New in Thruk 2.14-2" />
Use arbitrary attributes to add a confirmation dialog to server actions.

**action_menus/confirm_restart.json**

```

{
  "icon":"uil-redo",
  "label":"service restart",
  "action":"server://restart_service",
  "onclick": "return(confirm('Really restart service?'));"
}
```

### Hide Menu Item for Readonly Users

<Badge type="tip" text="New in Thruk 3.02" />
Use the hidden attribute to hide menu items.
This example hides the item if the user has the readonly role.

**action_menus/hidden_items.json**

```

{
  "icon":"uil-redo",
  "label":"service restart",
  "action":"server://restart_service",
  "onclick": "return(confirm('Really restart service?'));",
  "hidden": thruk_user.readonly
}
```

### Custom Form Elements

Combine raw HTML menu items with JavaScript menus to create custom menus.

**action_menus/js_form_menu.js**

```

function js_menu(d) {
  return({
    "icon":"../themes/{{theme}}/images/dropdown.png",
    "title": "form menu",
    "menu":[
      {
        "icon":"uil-document-info",
        "html":"<div class='flexrow gap-1 flex-nowrap'>"
              +"<b>test</b>"
              +"<input type='text'>"
              +"<button onclick='test_form_handler(this)'>ok</button>"
              +"</div>"
      }
    ]
  });
}

function test_form_handler(btn) {
  // prevent clicking twice
  // and give user some response by adding a loading gif to the button
  jQuery(btn).attr('disabled', true).html("<div class='spinner'>");

  // send user input as server action
  var input = jQuery(btn).prev().val();
  jQuery.post("status.cgi?serveraction=1",{
    link:    'server://NameOfServerAction/'+encodeURIComponent(input),
    host:    action_menu_options.host,
    service: action_menu_options.service,
    backend: action_menu_options.backend,
    token:   CSRFtoken
  }, function(response) {
    // show repsonse
    thruk_message(response.rc, response.msg);

    // close menu again
    action_menu_close();
  });
}
```

### Sending Commands

This example fetches host details from the REST API and creates a menu from
the host's attributes. It also sends commands.

**action_menus/js_cmd_menu.js**

```

function js_menu(d) {
  return({
    "icon":"../themes/{{theme}}/images/dropdown.png",
    "title": "confirm menu",
    "menu": js_menu_items
  });
}

function js_menu_items(d) {
  // fetch host attributes
  return(
    jQuery.get("../r/sites/"+d.backend+"/hosts/"+d.host)
    .then(function(data, textStatus, jqXHR) {
    var result = [];
    host_data = data[0];
    if(!host_data) {
      return({ 'label': 'host not found?'});
    }

    result.push({ label: d.host+":", disabled: true });

    // add submenu with all parents
    if(host_data.parents.length > 0) {
      parents_menu = [];
      jQuery(host_data.parents).each(function(i, r) {
        parents_menu.push({ label: r, action: "extinfo.cgi?type=1&host="+r });
      });
      var parents = {
        'label': 'parents',
        'menu': parents_menu
      };
      result.push(parents);
    }

    // add submenu with all child hosts
    if(host_data.childs.length > 0) {
      childs_menu = [];
      jQuery(host_data.childs).each(function(i, r) {
        childs_menu.push({ label: r, action: "extinfo.cgi?type=1&host="+r });
      });
      var childs = {
        'label': 'childs',
        'menu': childs_menu
      };
      result.push(childs);
    }

    // add active checks switch
    result.push({
      'label': "active checks",
      'menu': [{
        'label': 'disable active checks',
        'disabled': !host_data.active_checks_enabled,
        'action': function() {
          jQuery.post("../r/sites/"+d.backend+"/hosts/"+d.host+'/cmd/disable_host_check')
                .then(function(data, textStatus, jqXHR) {
                  thruk_message(0, "active checks disabled");
                });
        }
      }, {
        'label':   'enable active checks',
        'disabled': host_data.active_checks_enabled,
        'action': function() {
          jQuery.post("../r/sites/"+d.backend+"/hosts/"+d.host+'/cmd/enable_host_check')
                .then(function(data, textStatus, jqXHR) {
                  thruk_message(0, "active checks enabled");
                });
        }
      }]
    });

    return(result);
  }));
}
```

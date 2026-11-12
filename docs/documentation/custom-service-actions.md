---
title: Custom Service Action
---

# Custom Service Actions

<Badge type="tip" text="New in Thruk 3.26" />

To add custom actions to the Service Actions menu on service detail pages,
create `user_service_commands.tt` in your user template path.

![Custom Service Action](source/custom_service_action.png)

The template file has two parts:

1. The first part adds service actions that send GET requests. These follow the existing service command format. Users click a link to run them.

2. The second part adds service actions that send POST requests. When users click the link, JavaScript submits a form with hidden fields.

The quick action's script receives the form fields as POST variables.

All variables are available as environment variables prefixed with `POST_`.

To print these variables to stdout for testing, use `print_post_variables.sh`
in the Thruk script folder. The template includes an example that calls this script.

Two special variables contain the selected objects:

- `POST_SELECTED_SERVICES`: A list of all selected services.
- `POST_SELECTED_HOSTS`: A list of all selected hosts.

The format of the selected services is:

```
HOST;SERVICE;BACKEND~~HOST;SERVICE;BACKEND~~...
```

The format of the selected hosts is:

```
HOST;;BACKEND~~HOST;;BACKEND~~...
```

When a service action runs from a service overview page with a single script,
selected_services contains only that service in the format above.
The selected_hosts variable is empty in that case.

## Examples

### Add a custom quick action

This custom service action prints all POST variables to stdout.

![Print POST variables](source/service_print_post_variables.png)

If the user template path is not set, add it to `thruk_local.conf`:

**thruk_local.conf**

```
  user_template_path = ./my_templates
```

Create `user_service_commands.tt` in that directory with this content:

**my_templates/user_service_commands.tt**

```

[%# This template is for custom service commands that the user specifies. #%]
[%# It will be put directly after the hardcoded service commands. It is evaluated all at once, does not need to be split into multiple blocks. #%]

[%# ========================= Templated GET Service Actions ========================= #%]

[%# The command pane already includes commands. #%]
[%# Take note to adapt to their style for custom actions. #%]

[%# Example GET command taken from template. #%]
<div>
    [% IF service.checks_enabled %]
        <a class="js-modal-command-link" href="cmd.cgi?cmd_typ=6&amp;host=[% service.host_name | uri %]&amp;service=[% service.description | uri %]&amp;backend=[% service.peer_key %]">
            <i class="fa-solid fa-xmark round small red"></i>Disable active checks of this service
        </a>
    [% END %]
</div>

[%# ========================= Templated POST Service Actions ========================= #%]

[%# You can insert a html form for submitting POST requests. #%]
[%# These forms can be sent with the link via JS so they look like the other links. #%]

[%# Example POST command. #%]
<div>
    <form id="service_print_post_variables_form" action="cmd.cgi" method="POST" onsubmit="">
        [%# These values here can be taken from the service object, which is in the scope where this template is included. #%]
        <input type='hidden' name='host' value="[% service.host_name | html %]">
        <input type='hidden' name='service' value="[% service.description | html %]">
        <input type='hidden' name='backend' value="[% service.peer_key | html %]">

        [%# In the quick command menu, one can select multiple services on a host. This builds a string called selected services. #%]
        [%# An example of this string looks like this: localhost;Http;f4423~~localhost;Ping;f4423 #%]
        [%# In the service commands pane, we only have one service, so we do not need to join multiple services with '~~' . #%]
        [%# We are also adding this field so that the scripts for the quick commands can be used as a reference for further processing. #%]
        <input type='hidden' name='selected_services' value="[% service.host_name | html %];[% service.description | html %];[% service.peer_key | html %]">
        [%# Also define the other variable. In the service overview, there is no host to select. #%]
        <input type='hidden' name='selected_hosts' value="">

        [%# These values are are required for sending post requests. #%]
        <input type='hidden' name='referer' value="[% short_uri(c, {referer => 'undef'}) %]">
        <input type="hidden" name="CSRFtoken" value="[% get_user_token(c) %]">

        [%# This is the command name that is defined in the Thruk configuration for this custom command #%]
        [%# It should be defined under action_menu_actions section in one of the thruk configuration files #%]
        [%# This example just calls the custom command 'print_post_variables'. #%]
        <input type='hidden' name='quick_command' value="server://print_post_variables">
    </form>
    <a class="js-modal-command-link" href="#" onclick="document.getElementById('service_print_post_variables_form').submit(); return false;">
        <i class="fa-solid fa-terminal"></i>Print POST variables
    </a>
</div>
```

Add an entry for the script that runs when someone uses the quick action.

**thruk_local.conf**

```
<action_menu_actions>
  print_post_variables = ./share/thruk/script/print_post_variables.sh
</action_menu_actions>
```

The `print_post_variables.sh` script could look like this:

**print_post_variables.sh**

```bash
#!/bin/bash

# This script is intended to print details of a post request to the CGI.
# It should be invoked with a POST request to the CGI.
# This should be added as a custom service/host action to the Thruk.
# See the documentation for custom service/host actions more information.

echo "Showing fields of the POST request:"
env | grep 'POST_'
```

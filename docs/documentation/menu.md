---
title: Menu Customization
---

# Menu Configuration

Use menu_local.conf to customize the left menu.
Keep all changes in this file to avoid conflicts when you update Thruk.

Two files configure navigation:

- menu.conf
- menu_local.conf

The menu.conf file contains the default side menu configuration.
Do not change it: every update overwrites it.
To replace the entire menu, copy menu.conf to menu_local.conf and edit the copy.
To add only a few links, use the example below without copying the whole file.

The menu_local.conf file contains your side menu configuration.
It usually does not exist by default. Create it in `/etc/thruk/`.

The file uses Perl syntax and supports any Perl operation.
Changes take effect immediately, so consider using a test instance first.
Check the syntax after you edit the file.

::: tip Syntax Check for Menu Configuration

```
%>perl -wc menu_local.conf
menu_local.conf syntax OK
```
:::

::: tip No Restart Required
Thruk displays menu_local.conf changes immediately. You do not need to restart it.
:::

To add a few entries, create an empty menu_local.conf with these lines:

```
do '/usr/share/thruk/menu.conf';
insert_item('General', { 'href' => 'http://labs.consol.de', 'name' => 'Labs', target => '_blank' });
```

### Adding new Section

You can add new sections with:

```
add_section('name' => 'General');
```

You can insert sections at a given position with:

```
insert_section(2, 'name' => 'Projects');
```

### Adding a new Link

To add a new link use the following syntax:

```
add_link('name' => 'Home', 'href' => '/thruk/main.html');
```

**Available parameters**

- name: This is how the link is called in the web front end.
- href: This is the destination link optional you can add.
- target: Target frame for this link. (`_parent` and `_blank` open as popup, `embedded` opens embedded. Empty target opens in the same window.)
- icon: Used for themes which support icons.
- html: If set, all other attributes are ignored and the plain html data is inserted in the menu

Open grafana in a new window:

```
add_link('name' => 'Grafana', 'href' => '/grafana', 'target' => '_blank');
```

Open grafana embedded:

```
add_link('name' => 'Grafana', 'href' => '/grafana', 'target' => 'embedded');
```

'add_link' always adds the new link to the last section. Use 'insert_item' to
add a link to any section.

### Including original side navigation

Use the Perl do statement to include the main menu configuration.
For example, to add a link to the config menu, use this menu_local.conf:

```
do $ENV{'OMD_ROOT'}.'/share/thruk/menu.conf';
add_link('name' => 'Wato', 'href' => '/'.$ENV{'OMD_SITE'}.'/check_mk/wato.py?filename=wato.mk');
```

This example adds the Wato link from check_mks Multisite to the config section.
If you do not use [OMD](http://omdistro.org), replace the ENV part with the correct path.

### Inserting item in existing Section

Use 'insert_item' to add items to existing sections:

```
do $ENV{'OMD_ROOT'}.'/share/thruk/menu.conf';
insert_item('General', { 'href' => 'http://your-company.com', 'name' => 'Company' });
```

Use 'insert_sub_item' to create a new sub entry to an existing link.

```
do $ENV{'OMD_ROOT'}.'/share/thruk/menu.conf';
insert_sub_item('General', 'Home', { 'href' => 'http://your-company.com', 'name' => 'Company' });
```

### Removing item in existing Section

Use 'remove_item' to remove an existing item:

```
do $ENV{'OMD_ROOT'}.'/share/thruk/menu.conf';
remove_item('Reports', 'Availability');
```

To remove a sub menuitem, use the 3 arguments variant of `remove_item`:

```
do $ENV{'OMD_ROOT'}.'/share/thruk/menu.conf';
remove_item('Current Status', 'Problems', 'Network Outages');
```

To remove a sub menuitem hint, use the 4 arguments variant of `remove_item`:

```
do $ENV{'OMD_ROOT'}.'/share/thruk/menu.conf';
remove_item('Current Status', 'Problems', 'Services', 'Unhandled');
```

### Remove complete Section

Use 'remove_section' to remove an entire section:

```
do $ENV{'OMD_ROOT'}.'/share/thruk/menu.conf';
remove_section('Reports');
```

### Make item available for some groups only

Wrap the changes in a 'has_group' condition.

```
if(has_group('Admins')) {
  insert_item('Admins Only', { 'href' => '.../only_for_admins.html', 'name' => 'Admin Link' });
}
```

### Make item available for some roles only

Wrap the changes in a 'has_role' condition.

```
if(has_role('authorized_for_configuration_information')) {
  insert_item('System', { 'href' => '.../only_for_some_roles.html', 'name' => 'Admin Link' });
}
```

You can check multiple roles at once:

```
if(has_role('authorized_for_configuration_information', 'authorized_for_system_information')) {
  insert_item('System', { 'href' => '.../only_for_some_roles.html', 'name' => 'Admin Link' });
}
```

### Make item available for some specific user only

Wrap the changes in an 'is_user' condition.

```
if(is_user('thrukadmin')) {
  insert_item('Admins Only', { 'href' => '.../only_for_some_user.html', 'name' => 'Admin Link' });
}
```

### Add item at specific position

Use `before` or `after` to set a specific position.

```
insert_item('Current Status', { 'href' => '...', 'name' => 'My Hosts', 'after' => 'Hosts' });
```

### Insert arbitrary HTML

Use the html attribute to insert arbitrary HTML in the menu.
You may need CSS to style the content.

```
  insert_item("General", {html => "<a href='#test'>test: <img src='/thruk/themes/Thruk/images/logo_thruk_small.png'></a>" })
```

## Examples

### Hide Reporting for Non-Admins

Create a `/etc/thruk/menu_local.conf` like this:

```
do $ENV{'OMD_ROOT'}.'/share/thruk/menu.conf';
if(!has_group('Admins')) {
  remove_item('Reports', 'Reporting');
}
```

::: info
This only hides the reporting menu item. Anyone who knows the URL can still access it.
:::

### Add new item with arbitrary HTML

This example adds a company link with an image icon after it.

```
do $ENV{'OMD_ROOT'}.'/share/thruk/menu.conf';

insert_item('General', {
                'href'   => 'http://your-company.com',
                'name'   => 'Company',
                'target' => '_blank',
                'html'   => '<img src="/thruk/themes/Thruk/images/stop.gif" style="height:16px; width: 16px; vertical-align: bottom;">'
});
```

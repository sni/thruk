---
title: Webserver Integration
---

# Webserver Integration

::: tip apache is preconfigured when using packages
OMD and packages preconfigure Apache. You do not need to configure it separately.
:::

## Apache Configuration

Thruk integrates with Apache through fastcgi. Choose one of the two Apache
fastcgi modules. If unsure, use <&lt;mod_fcgid,mod_fcgid&gt;>.
The mod_fcgid module starts the fastcgi process on the first request.
With mod_fastcgi, you must start the process yourself.

Do not use the port 3000 Thruk server in production. It is only for testing
and development. It cannot handle authentication and is slower than the fastcgi variants.

### mod_fcgid

::: info Important
Thruk runs as the webserver user in this setup.
Give that user access to all Thruk files and Perl modules.
:::

**Apache configuration with mod_fcgid**

```
LoadModule fcgid_module /usr/lib/apache2/modules/mod_fcgid.so
<VirtualHost *:80>
    ServerName   thruk.company.local

    DocumentRoot /home/thruk/Thruk/root/
    CustomLog    /home/thruk/Thruk/logs/access.log combined
    ErrorLog     /home/thruk/Thruk/logs/error.log

    <Directory /home/thruk/Thruk/root/>
        Options FollowSymLinks
        AllowOverride All
        order allow,deny
        allow from all
    </Directory>

    AliasMatch /thruk/(.*\.cgi|.*\.html)  /home/thruk/Thruk/script/thruk_fastcgi.pl/thruk/$1
    <Location /thruk>
        Options ExecCGI
        Order allow,deny
        Allow from all
        AuthName "Monitoring Access"
        AuthType Basic
        AuthUserFile /home/thruk/Thruk/htpasswd.users
        Require valid-user
    </Location>

    <IfModule mod_fcgid.c>
      AddHandler fcgid-script .pl
      MaxRequestsPerProcess 100
    </IfModule>

</VirtualHost>
```

::: tip Example
A more complex example is available on GitHub:
[apache_fcgid.conf](https://github.com/sni/thruk/blob/master/support/apache_fcgid.conf).
This file is used for the official Thruk packages.
:::

### mod_fastcgi

Start the fcgi server:

```
    %>./script/thruk_fastcgi.pl -n 5 \
                -l /tmp/thruk_fastcgi.socket \
                -p /tmp/thruk_fastcgi.pid
```

You can copy the init.d script to /etc/init.d and adjust its paths:

```
    %> sudo cp ./script/thruk_fastcgi_server.sh /etc/init.d/thruk_fastcgi_server
    %> vi /etc/init.d/thruk_fastcgi_server
    %> sudo chown root: /etc/init.d/thruk_fastcgi_server
```

Or create a custom init.d script (additional modules required) with:

```
    %> ./script/thruk_create.pl FastCGI::ExternalServer l=/tmp/thruk_fastcgi.socket n=5 p=/tmp/thruk_fastcgi.pid
```

Adapt the Apache configuration example below:

- replace /home/thruk/Thruk with your installation path
- replace your-web-host.local with your hostname
- create a /home/thruk/Thruk/htpasswd.users with htpasswd2
- make sure the /home/thruk/Thruk/logs/ directory exists

**Apache configuration within existing vhost**

```
<VirtualHost *:80>
    # ... existing configuration

    # thruk configuration
    <Directory /home/thruk/Thruk/root/>
        order allow,deny
        allow from all
        Options FollowSymLinks
        AllowOverride All
    </Directory>
    <Directory /home/thruk/Thruk/plugins/>
        order allow,deny
        allow from all
        Options FollowSymLinks
        AllowOverride All
    </Directory>

    Alias /thruk/ /home/thruk/Thruk/root/thruk/

    # authorization
    <Location "/thruk">
        AuthName "Monitoring Access"
        AuthType Basic
        AuthUserFile /home/thruk/Thruk/htpasswd.users
        Order Allow,Deny
        Allow from all
        require valid-user
    </Location>

    # Load fastcgi module unless already loaded
    LoadModule fastcgi_module /usr/lib/apache2/modules/mod_fastcgi.so

    # fastcgi configuration
    FastCGIExternalServer /tmp/thruk_fastcgi.fcgi -socket /tmp/thruk_fastcgi.socket -idle-timeout 120

    # Load rewrite module unless already loaded
    LoadModule rewrite_module /usr/lib/apache2/modules/mod_rewrite.so

    # rewrite configuration
    RewriteEngine On
    RewriteCond %{DOCUMENT_ROOT}%{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^/thruk(.*)$ /tmp/thruk_fastcgi.fcgi/thruk$1 [E=HTTP_AUTHORIZATION:%{HTTP:Authorization},QSA,L]

</VirtualHost>
```

**Apache configuration with own vhost**

```
<VirtualHost *:80>
    ServerName   thruk.your-host.local

    DocumentRoot /home/thruk/Thruk/root/
    CustomLog    /home/thruk/Thruk/logs/access.log combined
    ErrorLog     /home/thruk/Thruk/logs/error.log

    <Directory />
        order deny,allow
        deny from all
    </Directory>

    <Directory /home/thruk/Thruk/root/>
        Options FollowSymLinks
        AllowOverride All
        order allow,deny
        allow from all
    </Directory>
    <Directory /home/thruk/Thruk/plugins/>
        order allow,deny
        allow from all
        Options FollowSymLinks
        AllowOverride All
    </Directory>

    # authorization
    <Location "/">
        AuthName "Monitoring Access"
        AuthType Basic
        AuthUserFile /home/thruk/Thruk/htpasswd.users
        Order Allow,Deny
        Allow from all
        require valid-user
    </Location>

    # Load fastcgi module unless already loaded
    LoadModule fastcgi_module /usr/lib/apache2/modules/mod_fastcgi.so

    # fastcgi configuration
    FastCGIExternalServer /tmp/thruk_fastcgi.fcgi -socket /tmp/thruk_fastcgi.socket -idle-timeout 120

    # Load rewrite module unless already loaded
    LoadModule rewrite_module /usr/lib/apache2/modules/mod_rewrite.so

    # rewrite configuration
    RewriteEngine On
    RewriteCond %{DOCUMENT_ROOT}%{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^/(.*)$ /tmp/thruk_fastcgi.fcgi/$1 [E=HTTP_AUTHORIZATION:%{HTTP:Authorization},QSA,L]
</VirtualHost>
```

### LDAP / AD authentication.

To authenticate users against LDAP or Active Directory, use the sample below.
It also works with the newer 2.x cookie-based authentication.

Apache first searches the legacy htpasswd file for a matching user, then the LDAP server.
This lets you keep the legacy thrukadmin account as a full-access administrator or as a fallback when LDAP is unavailable.

Make sure the backend has a contact definition that matches the LDAP username.
Assign that contact to hosts or services. Otherwise, the user will not see any objects.

/etc/apache2/conf-available/thruk.conf

```
  #...
  <Location /thruk/>
        Options ExecCGI FollowSymLinks
        AuthName "Thruk Monitoring"
        AuthType Basic

        #leagacy file authentication first, then ldap
        AuthBasicProvider file ldap

        #legacy file (or set it to /dev/null
        AuthUserFile /etc/thruk/htpasswd

        #ldap
        AuthLDAPBindDN "CN=thruk-ldap,OU=serviceaccounts,OU=bla,DC=site,DC=org,DC=com"
        AuthLDAPBindPassword "xxx"
        AuthLDAPURL "ldap://site.org.com/OU=bla,DC=site,DC=org,DC=com?sAMAccountName?sub?(objectClass=*)"
        require valid-user
  </Location>
   #...
```

### Kerberos authentication

See [thruk in omd](https://labs.consol.de/omd/howtos/kerberos/).

## Lighthttpd

::: tip lighthttpd
Francois Ponsard wrote an article on how to integrate Thruk in Lighthttpd:
http://www.dahwa.fr/dotclear/index.php?post/2011/03/15/Thruk-in-Lighttpd
:::

## Nginx

For Nginx on Ubuntu, follow the [howto](ubuntu-nginx.html).
General Nginx documentation is not available here.

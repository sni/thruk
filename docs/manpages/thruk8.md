% THRUK(8)
% Sven Nierlein
% 03/21/2023

# NAME

thruk - monitoring webinterface for nagios, icinga and shinken

# DESCRIPTION

Thruk is a monitoring web interface for multiple backends. It supports
Nagios, Icinga and Shinken through the Livestatus API. It is designed as a
'dropin' replacement and covers almost all original features. It also adds
features for large installations.

Access Thruk at http://host/thruk/.

The default account is 'thrukadmin'. The package ships it without a
password, so it is disabled until you set one:

```
htpasswd /etc/thruk/htpasswd thrukadmin
```

Package upgrades disable only the shipped legacy default password. They
preserve operator-set passwords and other accounts.

You probably need to change the backend configuration in
/etc/thruk/thruk_local.conf.

# NOTES

Complete documentation is online at http://www.thruk.org/documentation/

# BUGS

Please report bugs to https://github.com/sni/thruk/issues

# AUTHOR

Written by Sven Nierlein, sven.nierlein@consol.de

# RESOURCES

GitHub: https://github.com/sni/thruk/

Main web site: http://www.thruk.org

# COPYING

Copyright (C) 2009-present Sven Nierlein. Free use of this software is
granted under the terms of the GNU General Public License (GPL).

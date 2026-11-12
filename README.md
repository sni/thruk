Thruk - Monitoring Web Interface
===============================

Thruk is a monitoring web interface for multiple backends. It supports
Naemon, Icinga, Shinken and Nagios through the Livestatus API.
It is designed as a drop-in replacement that covers the original features.
It adds support for large installations, usability improvements and add-ons.

![Thruk Startpage](https://thruk.org/images/galleries/01_main-thumb.png "Thruk Startpage")
![Thruk Panorama](https://thruk.org/images/galleries/geomaps-thumb.png "Thruk Panorama")

[See more screenshots...](https://thruk.org/screenshots/)

Documentation
-------------
The Markdown documentation is under `docs/`.
Start with [first steps](docs/guides/first-steps.md) or the
[documentation development guide](docs/README.md).

Support
-------

  * Ask a question on [Stack Overflow](https://stackoverflow.com/questions/tagged/thruk)
  * Mailing list on [Google Groups](https://groups.google.com/group/thruk).
  * File a bug in [GitHub Issues](https://github.com/sni/thruk/issues).
  * Report a security vulnerability through [GitHub Security](https://github.com/sni/thruk/security).
  * Chat with developers on [IRC Libera #thruk](irc://irc.libera.chat/thruk) ([Webchat](https://web.libera.chat/?nick=Guest?#thruk)).


Main features
--------------------------

  * Multiple backends
  * Faster while using less CPU
  * Displays live data, no delay between core and GUI
  * Can be clustered across multiple hosts
  * Business Process Add-on
  * Advanced status filters
  * Extended logfile search
  * Multiple themes included
  * Excel export for status and logfiles
  * Adjustable side menu
  * Fully expanded plugin command line for easy testing
  * Save searches in personal bookmarks
  * Config Tool included
  * Mobile interface included
  * SLA Reports in PDF format
  * Recurring Downtimes
  * Full-featured dashboard
  * Independent of the monitoring core, can be installed on a remote host
  * Easy to extend with plugins

### Contributions

Thanks to the [community contributors for sending PRs](https://github.com/sni/thruk/graphs/contributors) and keeping this project updated.

To suggest an improvement, submit a pull request.

<p align="center">
<a href="https://github.com/sni/thruk/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=sni/Thruk&max=500">
</a>
</p>


License
-------

Thruk is Copyright (c) 2009-present by Sven Nierlein and others.
This is free software; you can redistribute it and/or modify it under the same terms as the Perl5 programming language system itself:

a) the "Artistic License 1.0" as published by The Perl Foundation
   http://dev.perl.org/licenses/artistic.html

b) the GNU General Public License as published by the Free Software Foundation;
   either version 1 http://www.gnu.org/licenses/gpl-1.0.html
   or (at your option) any later version

`SPDX-License-Identifier: Artistic-1.0-Perl OR GPL-1.0-or-later`

Vendor-specific libraries under `./root/thruk/vendor/` may have different
licenses. See the `THANKS` file for details.

Thruk - Monitoring Web Interface
===============================

Thruk is a multi-backend monitoring web interface that currently
supports Naemon, Icinga, Shinken and Nagios as backends using the Livestatus
API. It is designed to be a drop-in replacement, covering the original
features and adding enhancements for large installations, improved
usability and many useful add-ons.

![Thruk Startpage](https://thruk.org/images/galleries/01_main-thumb.png "Thruk Startpage")
![Thruk Panorama](https://thruk.org/images/galleries/geomaps-thumb.png "Thruk Panorama")

[See more screenshots...](https://thruk.org/screenshots/)

Documentation
-------------
All documentation is under `docs/`.

Support
-------

  * Ask a question on [Stack Overflow](https://stackoverflow.com/questions/tagged/thruk)
  * Mailing list on [Google Groups](https://groups.google.com/group/thruk).
  * File a bug in [GitHub Issues](https://github.com/sni/thruk/issues).
  * Report a security vulnerability through [GitHub Security](https://github.com/sni/thruk/security).
  * Chat with developers on [IRC Libera #thruk](irc://irc.libera.chat/thruk) ([Webchat](https://web.libera.chat/?nick=Guest?#thruk)).


Main Features / Advantages
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
  * Fully Featured Dashboard
  * Independent of the monitoring core, can be installed on a remote host
  * Easy to extend with plugins

### Contributions

Thanks to all the amazing [community contributors for sending PRs](https://github.com/sni/thruk/graphs/contributors) and keeping this project updated. :heart:

If you have an idea for an improvement, you are welcome to contribute to the project. Feel free to submit a pull request.

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

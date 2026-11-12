---
title: CGI Parameters
---

# CGI Parameters

You can change most CGI parameters with buttons.
Some parameters are available only when you add them directly to the URL.

## List of Parameters

### columns

Pages: status overview

Description: Sets the number of columns

Values:

- any number greater than 0

Example: /thruk/cgi-bin/status.cgi?hostgroup=all&style=overview&columns=5

### debug

Pages: availability reports

Description: Creates a file with debug information regarding this report

Values:

- 1: enable debug mode

Example: /thruk/cgi-bin/avail.cgi?host=HOSTNAME&debug=1

### hidetop

Pages: status pages

Description: Show/Hide the status totals header.

Values:

- 0: show top panel
- 1: hide top panel

Example: /thruk/cgi-bin/status.cgi?hidetop=1

### minimal

Pages: status page

Description: Hides almost all user interface buttons. Useful for
monitor screens where only the current problems should be displayed.

Values:

- 1: Activates minimal mode
- 2: Activates minimal mode but keeps backend sites panel
- 3: Activates minimal mode and hides filter and pager

Example: /thruk/cgi-bin/status.cgi?host=all&servicestatustypes=28&minimal=1

### nav

Pages: all pages

Description: Show/Hide the navigation. Only useful in non-frames mode.

Values:

- 0: hide navigation
- 1: show the navigation

Example: /thruk/cgi-bin/tac.cgi?nav=0

### noexternalforks

Pages: all pages

Description: Skip external page generation. Used primarily in reports.

Values:

- no value

Example: /thruk/cgi-bin/avail.cgi?noexternalforks

### noheader

Pages: status pages

Description: Show/Hide the status totals header.

Values:

- no value

Example: /thruk/cgi-bin/status.cgi?noheader

### refresh

Pages: all pages

Description: Sets refresh timer to a custom value.

Values:

- refresh interval number in seconds

Example: /thruk/cgi-bin/status.cgi?refresh=30

---
title: JSON Exporting
---

# JSON Exporting

Several pages support JSON exports.

The [REST API](rest.html) provides all these exports and additional features.

### List of Pages

#### Status Data

Example: /thruk/cgi-bin/status.cgi?view_mode=json&host=all

Parameters: all usual status page parameters and filters.
Set the filters in the GUI, then use the JSON export link.

Use the 'columns' parameter to select columns:

Example: /thruk/cgi-bin/status.cgi?view_mode=json&host=all&columns=name,status

#### Availability Data

Example: /thruk/cgi-bin/avail.cgi?view_mode=json&host=all

Parameters:

```
    t1=1357575984                       # start timestamp
    t2=1357662384                       # end timestamp
    host=hostname                       # hostname
    assumestateretention=yes            # assume state retention or not
    assumeinitialstates=yes             # assume initial state or not
    assumestatesduringnotrunning=yes    # assume state during core not running or not
    initialassumedhoststate=0           # initial assumed host state
    initialassumedservicestate=0        # initial assumed service state
    full_log_entries                    # include full logs
    showscheduleddowntime=
    rpttimeperiod=
```

See [Monitoring::Availability](http://search.cpan.org/perldoc?Monitoring%3A%3AAvailability#CONSTRUCTOR)
for a detailed description of all parameters.

#### Statistics Data / Tactical Overview Data

Example: /thruk/cgi-bin/tac.cgi?view_mode=json

Parameters: none

Example: /thruk/cgi-bin/tac.cgi?view_mode=json

#### Backends / Sites Data

<Badge type="tip" text="New in Thruk 2.04" />
Export all site/backend-specific data:

Example: /thruk/cgi-bin/extinfo.cgi?type=0&view_mode=json

#### Business Process Data

Example: /thruk/cgi-bin/bp.cgi?view_mode=json&bp=id

Parameters: optional business process id

Example: /thruk/cgi-bin/bp.cgi?view_mode=json&bp=1

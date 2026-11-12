---
title: SLA Reporting
---

# SLA Reporting

### Installation

This plugin is optional/recommended because it depends on xlibs, xvfb and fonts.

Install the 'thruk-plugin-reporting' package from Consol Labs Repository.

### How it works

SLA Reporting follows these steps:

- report configuration
- report template
- converting html report into pdf
- optionally send report by mail

#### Report Configuration

Make sure the plugin is enabled. Create or adjust a report on the 'Reporting' page.
Select a template, then complete its input fields on the second page.

If you make a report public, everyone can view and refresh it.

#### Report Templates

Report templates are in 'plugins/plugins-enabled/reports2/templates/reports'.
To adjust or override templates, put your versions in a 'reports' subfolder
of the 'user_template_path'.

```
  | reports     contains the selectable reports
  |- comp       contains components used in reports
  |- locale     contains localization settings
  |- style      contains css used to make reports pretty
```

See [../api/Thruk/Utils/Reports/Render.html](https://www.thruk.org/api/Thruk/Utils/Reports/Render.html) for details on
available functions and examples.

The templates use Template::Toolkit. For documentation, see
http://template-toolkit.org/docs/manual/index.html

#### Converting

Puppeteer converts the generated HTML report to a PDF file.

#### Sending Reports By Mail

To email SLA reports, create a send option in the report configuration.
You can send one report at multiple times.

#### Debugging Reports

Debug mode saves information that developers can use to reproduce a report.

To create debug information, open the reports page and add the debug parameter.
The URL should end with `reports2.cgi?debug=1`.
You may need to remove the `#` sign and everything after it.

- Append `?debug=1` to the url. This will show an additional icon next to each report.
- Click on the wizards wand icon next to the refresh button
- Download the debug information with the icon next to the wizards wand.

### Customized Reports {#customized-reports}

You can customize reports with HTML and CSS.
Reports have blocks that define the steps used to produce them:

- styles
- edit
- prepare
- render
- mail

#### Styles

To customize report CSS, create 'reports/style/custom.tt' below your 'user_template_path'.

For example:

```
<style type="text/css">
/* override css styles */
BODY {
    /* use a different font */
    font-family: arial, sans-serif;

    /* change default font color */
    color: DarkSlateGray;
}
TD.header DIV.title {
    /* change gradient on page cover and page header */
    background: linear-gradient(to bottom, #d0e4f7 0%,#73b1e7 24%,#0a77d5 50%,#539fe1 79%,#87bcea 100%);
}
</style>

<script language="javascript" type="text/javascript">
  /* add complete new elements by javascript, ex.: company logo on page cover */
  jQuery(document).ready(function() {
    jQuery('<img src="http://www.thruk.org/images/logo_thruk.png">').insertBefore('DIV.page.cover DIV.titletext');

    // note: the image must be accesible from the monitoring host, sometimes its easier to use embedded base64 encoded images:
    //jQuery('<img src="data:image/png;base64,...">').insertBefore('DIV.page.cover DIV.titletext');
  });
</script>
```

You can also change any template used to create the reports.

#### Edit Block

The edit block defines all required and optional fields for the report.
These fields appear on the edit page when someone creates or edits a report
of this type.

For example:

```
[% IF block == 'edit' %]
  [%
    required_fields = [
        { 'host'       => [ 'Host',        'hosts',         ''              , '', 1 ] },
        { 'timeperiod' => [ 'Timeperiod',  'rptimeperiod',  'last12months'          ] },
    ];
  %]
[% END %]
```

The hash key defines the parameter used to access the value later.
Each field must point to an array with at least 3 values.
The required flag is optional.

- Name
- Type
- Default value
- Required Flag

#### Prepare Block

The prepare block gathers report data. It usually gets availability data
through Livestatus or fetches events from logfiles.

For example:

```
[% IF block == 'prepare' %]
  [%
    set_unavailable_states(param.unavailable);
    calculate_availability();
  %]
[% END %]
```

You may use all functions available from the [Render Helper](https://www.thruk.org/api/Thruk/Utils/Reports/Render.html)

#### Render Block

The render block defines the layout of the report.

For example:

```
[% IF block == 'render' %]
  [% PROCESS 'reports/locale/en.tt' %]
  [%
    title        = 'Hello World Report'
    subtitle     = r.name
    coverdetails = [ 'Report Timeperiod:', get_report_timeperiod(start, end, reportDateFormat),
                     'Host:', param.host,
                   ]
  %]

  [% WRAPPER 'reports/comp/report.tt' %]
    [% WRAPPER 'reports/comp/page_cover.tt' %][% END %]
    [% WRAPPER 'reports/comp/page_standard.tt' %]
      <b>hello world</b>
    [% END %]
  [% END %]
[% END %]
```

This report contains 2 pages. The report.tt wrapper defines the basic layout
and contains the stylesheets. The cover page uses the settings defined above.
The 'r' variable refers to the report object and supplies the subtitle in this example.
The 'coverdetails' list contains name/value pairs for the cover page's details list.

The standard page wraps 'hello world'. Its content can also contain standard
HTML tags, such as tables and images.

#### Mail Block

The mail block defines the email layout for reports sent by email.

For example:

```
[% IF block == 'mail' +%]
SUBJECT: Report: [% r.name %]

Your report is attached.

[% IF r.desc %]Description: [%+ r.desc %][% END %]
[%+ END %]
```

We use the report name 'r.name' as subject and put the report description 'r.desc'
in the body.

#### Custom Perl Render Helper

You can create a Perl module named 'Thruk::Utils::Reports::CustomRender'.
Thruk automatically adds it to the stash, so report templates can use its functions.

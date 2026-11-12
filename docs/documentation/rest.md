---
title: REST API
---

# REST API

<Badge type="tip" text="New in Thruk 2.24" />
The Thruk REST API provides access to Thruk and Livestatus information.

- All endpoints with a filter to find them quickly are on the [REST API endpoints page](rest_endpoints.html).
- For examples, see the [REST API examples page](rest_examples.html).
- A list of external commands is here: [REST API commands](rest_commands.html).

Access the API through HTTP(S) at http://your_webserver/thruk/r/ or through the CLI client:

```
  %> thruk r /hostgroups
```

## Versions

The REST API currently has only version 1. Use the generic URL
http://your_webserver/thruk/r/ or the version-specific URL
http://your_webserver/thruk/r/v1/.

## Authentication

### Basic Auth

The REST API supports basic authentication, but API keys are recommended.
The Apache configuration cannot both set a supplied remote user and pass through
requests that have no remote user.

```
  %> curl -gk 'https://username:password@localhost/thruk/r/hosts'
```

### Cookie Auth

If you are already logged in, you can use your authentication cookie.
The API returns results with the current user's permissions.

### API Key

The web REST API accepts API keys through an HTTP header.
If `api_keys_enabled` is enabled, create keys on the user profile page.
You can also create keys through the `/thruk/api_keys` endpoint.

```
  %> curl -H 'X-Thruk-Auth-Key: apikey' \
          -gk 'https://localhost/thruk/r/hosts'
```

### Superuser API Key

Administrators can create superuser API keys, previously called system API keys.
These keys are not bound to a user. Set a username through the
`X-Thruk-Auth-User` HTTP header.
Handle superuser API keys with the same care as the secret key because they grant broad access.
You can still restrict a superuser key to specific roles.

```
  %> curl -H 'X-Thruk-Auth-Key: apikey' \
          -H 'X-Thruk-Auth-User: automation' \
          -d 'comment=test' \
          -gk 'https://localhost/thruk/r/hosts/localhost/cmd/schedule_host_downtime'
```

### Secret Key

The web REST API accepts the secret key through an HTTP header.
The key is usually in `/var/lib/thruk/secret.key` or, for OMD, `var/thruk/secret.key`.

```
  %> curl -H 'X-Thruk-Auth-Key: secretkey' \
          -H 'X-Thruk-Auth-User: thrukadmin' \
          -gk 'https://localhost/thruk/r/hosts'
```

The secret key grants superadmin access.
Use the `X-Thruk-Auth-User` HTTP header to set the result's user context to any user.

### Command Line

With the CLI client, use `-A`:

```
  %> thruk -A user r /
```

Command line access also grants superadmin access.
Use `-A` to set the context to any user.

## Parameters

Parameters are mainly used with `POST` and `PATCH` requests.
With the CLI tool, use `-d` to pass key/value pairs, JSON data or both.

use key/value pairs:

```
  %> thruk r -m PATCH -d max_check_attempts=3 -d first_notification_delay=10 /hosts/localhost/config
```

use json structure:

```
  %> thruk r -m PATCH -d "{'max_check_attempts':3, 'first_notification_delay':10}" /hosts/localhost/config
```

Using curl, you can set parameters like this:

```
  %> curl -d "alias=test" -d "max_check_attempts=3" http://your_webserver/thruk/r/hosts/localhost/config
```

or you can use json data as well:

```
  %> curl --header "Content-Type: application/json" \
          --X PATCH \
          --data '{"max_check_attempts":3, "first_notification=delay":10}' \
          http://your_webserver/thruk/r/hosts/localhost/config
```

## Filtering

All pages offer filtering using query parameters:

```
  %> thruk r '/hosts?name=localhost'
```

Use bracket syntax for operators other than equals, such as regular expressions:

ex.: return all hosts starting with literal `m`:

```
  %> thruk r '/hosts?name[regex]=^m'
```

ex.: list all services which are currently in a downtime:

```
  %> thruk r '/services?scheduled_downtime_depth[gte]=1'
```

Curl requires you to set the `globoff` option:

```
  %> curl -gk 'https://user:pass@localhost/thruk/r/hosts?name[regex]=^t'
```

ex.: numeric filter using the operators `<`, `>`, `>=` or `+++<=+++` will be expanded
like described in [relative timestamps](rest_commands.html#relative-timestamps).

list session which had been active within the last 10minutes

```
  %> thruk r '/thruk/sessions?columns=username,max(active)&active[gte]=-10m'
```

Possible operators with their alias:

| Operator | Alias | Description |
|  ---  |  ---  |  ---  |
| = | eq | Equal match |
| != | ne | Not equal match |
| ~ | sregex | Strict regular expression match (case-sensitive) |
| !~ | snregex | Strict negated regular expression match (case-sensitive) |
| ~~ | regex | Regular expression match (case-insensitive) |
| !~~ | nregex | Negated regular expression match (case-insensitive) |
| > | gt | Greater than numeric comparisson |
| < | lt | Lower than numeric comparisson |
| >= | gte | Greater or equal numeric comparisson. `contains` in list context |
| <= | lte | Lower or equal numeric comparisson. `contains not` in list context |
| !>= | notin | `contains not` in list context |

Use operator aliases to avoid URL encoding issues.

## Complex Filtering

For complex filters, use the query language with logical operators.
Pass the URL-encoded query through `q`.
Alternatively, enclose the query in `+***+` to encode it automatically.
You must still quote the query correctly.

```
  %> thruk r '/hosts?q=***name = "test" or name = "other"***'
```

Another example, fetch all hosts from hostgroups linux and windows which are not ok.

```
  %> thruk r '/hosts?q=***(groups >= "linux" or groups >= "windows") and status != 0***'
```

Example using curl:

```
  %> curl -d 'q=***name = "test"***' 'http://.../thruk/r/hosts'
```

If you need `***` in the query itself, any other three characters will do as well:

```
  %> thruk r '/notifications?q=///message = "test" or name = "other"///
```

Lexical filters support the same time expansion as normal filters:

```
  %> thruk r '/services?q=***last_check <= "-7d"***'
```

This selects services with a `last_check` date earlier than `now - 7 days`.
Keep the quotes around the value.

## Sorting

Use `sort` to sort list results on any page.
Repeat the parameter or use a comma-separated list.
The order is ascending unless the column has a minus prefix.

ex.: sort by name ascending and status descending:

```
  %> thruk r /hosts?sort=name,-state
```

## Limits

All pages support `limit` and `offset`.

The offset starts at 0. Setting offset=1 skips the first item and starts with the second.
For example, show 10 hosts starting at item 101:

```
  %> thruk r /hosts?limit=10&offset=100
```

## Columns

Use `columns` to select columns on any page.

ex.: return name and state for all hosts:

```
  %> thruk r /hosts?columns=name,state
```

Rename columns by appending `:name` like this:

```
  %> thruk r /hosts?columns=name:host_name,state:status
```

or by adding `as aliasname`

```
  %> thruk r '/hosts?columns=name:host_name,state as status'
```

Note: If the column contains special characters, use backticks to enclose the column name, ex.:

```
  %> thruk r '/hosts?columns=`Disk C:\`'
```

or:

```
  %> thruk r '/hosts?columns=`Disk C:\` as size'
```

### Performance Data Columns

Thruk expands performance data into separate columns for host/service queries.

For a host with the check_icmp check, Thruk returns performance data in separate columns,
as this shortened JSON shows.

Each performance value has 2 columns: its value and its unit.

There is also a hash containing the expanded performance values.

Use these columns to filter results or select specific performance values.

```
  %> thruk r /hosts?limit=1

[
   {
...
      "name" : "icmp checked host",
...
      "perf_data" : "rta=0.030ms;3000.000;5000.000;0; pl=0%;80;100;;",
      "perf_data_expanded" : [
         {
            "crit" : "5000.000",
            "max" : "",
            "min" : "0",
            "name" : "rta",
            "orig" : "rta=0.030ms;3000.000;5000.000;0;",
            "parent" : "",
            "unit" : "ms",
            "value" : "0.030",
            "warn" : "3000.000"
         },
         {
            "crit" : "100",
            "max" : "",
            "min" : "",
            "name" : "pl",
            "orig" : "pl=0%;80;100;;",
            "parent" : "",
            "unit" : "%",
            "value" : "0",
            "warn" : "80"
         }
      ],
      "pl" : "0",
      "pl_unit" : "%",
      "rta" : "0.030",
      "rta_unit" : "ms"
...
   }
]
```

::: tip Filter by performance values
Those columns can also be used for filtering. Ex. get all hosts having packing loss greater zero.

`%> thruk r '/hosts?columns=pl,name&pl[gte]=0'`
:::

### Custom Data Columns

Thruk expands custom data values into separate columns for host/service queries.

Use these columns to filter results or select specific custom values.

```
  %> thruk r '/hosts?limit=1&_WORKER=local'
[
   {
...
      "_THRUK_BP_ID" : "666",
      "_THRUK_NODE_ID" : "node1",
      "_WORKER" : "local",
      "custom_variable_names" : [
         "THRUK_BP_ID",
         "THRUK_NODE_ID",
         "WORKER"
      ],
      "custom_variable_values" : [
         "666",
         "node1",
         "local"
      ],
      "custom_variables" : {
         "THRUK_BP_ID" : "666",
         "THRUK_NODE_ID" : "node1",
         "WORKER" : "local"
      },
...
      "name" : "host with custom variables",
...
   }
]
```

::: tip Host custom variables
Host custom variables are accessible with the _HOST prefix for example like.:

`%> thruk r '/services?columns=_HOSTWORKER&description'`
:::

## Calculations

Use `+`, `-`, `*` and `/` in the column selection for simple calculations.

ex.: sum the number of problems for each host

```
  %> thruk r '/hosts?columns=name,num_services_crit+num_services_unknown+num_services_warn as num_services_problems'
```

## Functions

### Transformation Functions

Transformation functions adjust result data.

Available transformations functions are:

| Function | Example | Description |
|  ---  |  ---  |  ---  |
| `age(<column>)` | `age(last_check)` | Subtract value from current unix timestamp to get the age in seconds. |
| `calc(<column>, <operator>, <value>)` | `calc(last_check, '*', 1000)` | Apply a mathematical operation. |
| `concat(<column>\|<text>, ...)` | `concat(name, ';', state)` | Combine multiple columns into one. |
| `duration(<column>)` | `duration(execution_time)` | Convert amount of seconds into human readable duration. |
| `fmt('format', <column>\|<text>, ...)` | `fmt('%.1f', execution_time)` | Applies format string to column value(s). |
| `lc(<column>)` | `lc(host_name)` | Make column lower case. |
| `lower(<column>)` | `lower(host_name)` | Make column lower case. |
| `s(<column>, <regex>, <replacement>)` | `s(host_name, '/\..*$/', '')` | Apply regex replacement. Note: you cannot use backreferences like `$1` in the replacement string for security reasons. |
| `substr(<column>, <offset> [, <length>])` | `substr(name, 0, 3)` | Extract substring. |
| `unit(<column>, <unit>)` | `unit(calc(rta, '*', 1000), 's')` | Set the unit for this column. (used by grafana with the thruk datasource) |
| `uc(<column>)` | `uc(host_name)` | Make column upper case. |
| `upper(<column>)` | `upper(host_name)` | Make column upper case. |
| `utc(<column>, [<format>])` | `utc(last_check, '%Y-%m-%d %H:%M:%S %Z')` | Convert unix timestamp to UTC date. |
| `date(<column>, [<format>])` | `date(last_check, '%Y-%m-%d %H:%M:%S %Z')` | Convert unix timestamp to date in local timezone. |
| `hoststate(<column>)` | `hoststate(state)` | Convert numeric host state into text representation, ex.: 0 -> UP, 1 -> DOWN, ... |
| `servicestate(<column>)` | `servicestate(state)` | Convert numeric service state into text representation, ex.: 0 -> OK, 1 -> WARNING, ... |

Example: return first 3 characters from upper case host name.

```
  %> thruk r '/hosts?columns=upper(substr(name, 0, 3)) as host'
```

### Aggregation Functions

Aggregation functions calculate statistics.

Available aggregation functions are:

- `count`: total number of matches
- `avg`: calculated average for numerical columns
- `sum`: calculated sum for numerical columns
- `min`: calculated minimum value for numerical columns
- `max`: calculated maximum value for numerical columns
- `uniq`: return uniq rows only once (uniqueness is calculated over all columns)

ex.: return average latency over all hosts

```
  %> thruk r '/hosts?columns=avg(latency)'
```

The query can include grouping columns without aggregation functions.

ex.: list average execution time over all services grouped by state.

```
  %> thruk r '/services?columns=avg(execution_time),state&sort=avg(execution_time)'
```

ex.: list unique custom variable values from all services

```
  %> thruk r '/services?columns=uniq(),_DEVICE_ID&sort=_DEVICE_ID'
```

Rename columns by appending `:name`

```
  %> thruk r '/thruk/sessions?columns=count(*):sessions'
```

Renaming can be combined with grouping columns.

```
  %> thruk r '/services?columns=avg(execution_time):avg_exec_time,host_name'
```

The group by column can be renamed as well:

```
  %> thruk r '/services?columns=avg(execution_time),peer_name:site'
```

Use aggregation functions in filters. You cannot use their aliases in filters:

```
  %> thruk r '/services?columns=avg(execution_time):exec_time&avg(execution_time)[gt]=0'
```

### Disaggregation Functions

Disaggregation functions create multiple result rows from a single attribute.

Available disaggregation functions are:

- `to_rows`: allocate result rows from list column
- `as_rows`: alias for to_rows

```
  %> thruk r '/hosts?columns=name,to_rows(services) as services'
```

For this example, querying the services table would be simpler.

### Mixing Functions

When mixing aggregation and transformation functions, apply the aggregation function
as the outer most function, as for example in:

```
  %> thruk r '/hosts/localhost?columns=avg(unit(calc(latency,/,1000), "ms"))'
```

When mixing disaggregation and transformation functions, apply the disaggregation function
as the inner most function, as for example in:

```
  %> thruk r '/hosts/localhost?columns=upper(name),upper(to_rows(services))'
```

## Backends / Sites

To query specific sites, select the backends with one of these methods.
Separate multiple sites with commas.

- Use a path prefix `/sites/<sitename,...>`:

```
  %> thruk r /sites/test,prod/hosts
```

- Use the `backends` option with the cli client:

```
  %> thruk r -b test,prod /hosts
```

- Set the `backends` url parameter:

```
  %> thruk r /hosts?backends=test,prod
```

::: tip All Sites
Thruk uses all backends except those configured as `hidden=yes`.
To include hidden backends, use the `/sites/ALL/` prefix.
:::

::: tip Local Sites
To query only local backends that use Unix sockets, use the `/sites/LOCAL/` prefix.
:::

## Error Handling

Failed REST requests return a hash and an HTTP error code:

```
  %> thruk r /none
  {
    "code" : 404,
    "message" : "unknown rest path"
    "description" : "optional additional error messages"
  }
```

## Output Formats

### JSON

JSON is the default output format.

### Wrapped JSON

Wrapped JSON wraps the result into a hash containing additional metadata.

```
  %> thruk r /wrapped_json/hosts?columns=name,last_check
```

Will return something like:

```
{
   "data" : [...], # data as returned by the json format
   "meta" : {
      "columns" : [{
            "name" : "last_check"
            "type" : "time"
         },
         ...
      ]
   }
}
```

If the unit is known, for example in perf_data, Thruk adds it to the column metadata as a config hash.

### CSV

Use the `/csv/` prefix for CSV output.
Thruk adds column names as a commented first line.
To omit this line, set `headers=0`.

**Escaping and nested objects**

::: warning
Support for nested objects and semicolon escaping is limited.
Nested objects use JSON encoding. If possible, use JSON output for better speed and reliability.
:::

```
  %> thruk r /csv/hosts?columns=name,state
```

```
  %> thruk r '/csv/hosts?columns=name,state&headers=0'
```

```
  %> thruk r /hosts?columns=name,state --csv
```

```
  %> curl -g http://localhost/thruk/r/csv/hosts/stats
```

### XLS

Excel output is available via `/xls/` path prefix.

```
  %> thruk r /xls/hosts?columns=name,state
```

```
  %> thruk r /hosts?columns=name,state --xls
```

### Table

Human readable table output is available via `/human/` or `/text/` path prefix.

```
  %> thruk r /human/hosts?columns=name,state
```

```
  %> thruk r /hosts?columns=name,state --human
```

```
  %> thruk r /hosts?columns=name,state --text
```

```
  %> thruk r /hosts?columns=name,state -t
```

## HTTP Methods

HTTP methods are implemented according to [RFC2616](https://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html#sec9),
summarized below:

| GET | retrieve resources, e.g.: `GET /thruk/reports` to list all reports. |
|  ---  |  ---  |
| POST | update/create resources or trigger actions, e.g.: `POST /thruk/reports` to create a new report. |
| PUT | overwrite an existing resource, e.g.: `PUT /thruk/reports/1` to update an entire existing report. Thruk does not distinguish between POST and PUT. You can use PUT for all POST URLs and vice versa. |
| PATCH | replace parts of an existing resource, e.g.: `PATCH /thruk/reports/1` to set specific attributes of an existing report. |
| DELETE | remove an existing resource, e.g.: `DELETE /thruk/reports/1` to remove the report entirely. |

## Long Running Requests

If a REST request may exceed the usual 40-second timeout, start it in the background.
Retrieve its result with a separate request once it is ready.

```
  %> curl -k -d "" 'https://username:password@localhost/thruk/r/config/check?background=1'
```

This returns something like:

```
  {
    "job_id" : "737aa",
    "message" : "request started in background with job id: 737aa",
    "result_url" : "/thruk/jobs/737aa/output",
    "success" : true
  }
```

Use curl's follow feature to retrieve the result when it is ready.

```
  %> curl -k -L https://omdadmin:omd@localhost/demo/thruk/r/thruk/jobs/1263d/output
```

If the result takes more than 30 seconds, the endpoint returns a 302 redirect
every 30 seconds until it finishes.

## Object configuration notes

To create objects such as hosts, use `POST /config/objects` as documented below.

Use `POST /*/<name>/config` only to overwrite existing objects.

After changing object configuration, use this sequence, as in the GUI config tool:

1. Inspect the changes with `GET /config/diff`.
   To discard the pending changes at this point, use `POST /config/revert`.
2. Save with `POST /config/save`.
3. Validate with `POST /config/check`.
4. Reload with `POST /config/reload`.

Check each step's output before continuing.

## Endpoints

The complete list of endpoints is on the [REST API endpoints page](rest_endpoints.html).
It has a filter to quickly find the endpoint you need.

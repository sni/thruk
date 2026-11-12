---
title: Graph Exporting
---

# Grafana Graph Exporting

Thruk exports third-party performance graphs through a single URL.
It currently supports only Grafana.

Use the `.../extinfo.cgi?type=grafana&options_see_below...` URL to export graphs.

### List of Options

- **`host`**: Hostname to export.
- **`service`**: Service description to export. Leave empty for host graphs.
- **`format`**: Can be either `png` (default) or `base64`.
- **`from`**: Either a unixtimestamp of the start date or relative date like `-2h`.
- **`to`**: Either unixtimestamp of the end date or relative date like `now`.
- **`width`**: Image width in px.
- **`height`**: Image height in px.
- **`source`**: If a Grafana dashboard has multiple graphs, use `source` to select one. The index starts at `1`.
- **`disablePanelTitle`**: Can be set to `1` to hide the panel title.
- **`legend`**: Can be set to `0` to hide the legend.
- **`theme`**: Can be either `light` or `dark` and sets the grafana theme.
- **`font_color`**: Sets the font color, ex.: `#000000`
- **`background_color`**: Sets the background color, can be either `transparent` or a hex colour like `#FFFFFF`

### Example

Fetch an exported graph with curl:

```
  %> curl -k 'https://user:password@your_webserver/thruk/cgi-bin/extinfo.cgi?type=grafana&host=localhost&service=Ping&from=-1d&to=now'
```

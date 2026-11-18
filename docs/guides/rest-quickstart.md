# REST API quickstart

Use a personal API key to find out which hosts your account can see. These requests only read data.

## Check your identity

Open your Thruk profile using the gear icon at the top right. Create a personal
API key. If the option is missing, ask your administrator to check `api_keys_enabled`.

Set `api` to your installation's API URL, including the OMD site prefix if needed.
Replace `YOUR_API_KEY` with your personal key.

```sh
api='https://monitor.example.org/thruk/r/v1'
key='YOUR_API_KEY'
```

Ask Thruk which user the key belongs to:

```sh
curl --header "X-Thruk-Auth-Key: $key" "$api/thruk/whoami"
```

Check the `id` in the JSON response. It should match your Thruk username. If
you see a login page instead, check the base URL and the [authentication
settings](../documentation/rest.md#authentication).

## Read two hosts

```sh
curl --header "X-Thruk-Auth-Key: $key" "$api/hosts?columns=name,state&limit=2"
```

For example, if your account can see one host named `web01`, you might get:

```json
[{"name":"web01","state":0}]
```

An empty array means the request returned no visible hosts. On the Thruk
server, run the same query as the user from `whoami`. Replace `alice` with that
user:

```sh
thruk -A alice r '/hosts?columns=name,state&limit=2'
```

Without `-A`, the local CLI has superadmin access and can return more hosts.
For the next query, choose columns from the [endpoint reference](../documentation/rest_endpoints.md#get-hosts)
or try a [filter](../documentation/rest.md#filtering).

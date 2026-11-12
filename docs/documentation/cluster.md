---
title: Cluster Setup
---

# Thruk Clustering

<Badge type="tip" text="New in Thruk 2.24" />
Clusters improve availability and performance but add complexity.
All Thruk nodes in a cluster must share storage for `etc_path` and `var_path`.
Keep `tmp_path` local.

### Setup

- Create shared storage for `etc_path` and `var_path`
- Configure a load balancer
- Check the node URL in `cluster_nodes`
- Enable the cluster with `cluster_enabled=1`

#### Static Cluster

To use a fixed number of cluster nodes, configure multiple cluster_nodes with
fixed hostnames:

```
cluster_enabled = 1
cluster_nodes = http://clusternode1/$url_prefix$/
cluster_nodes = http://clusternode2/$url_prefix$/
```

#### Autoscaling / Dynamic Cluster

If you define no cluster_node URL (the default) or one generic URL, Thruk uses
autoscaling cluster mode. It registers new nodes automatically when they start.

```
cluster_enabled = 1
# optionally set generic url if the default does not work
#cluster_nodes = http://$hostname$/$url_prefix$/
```

### Features

#### Shared cronjobs

Cluster nodes share cronjobs. Reports and jobs that schedule recurring downtimes
run only once in a cluster.

#### High Availability

A load balancer distributes requests across Thruk nodes. The cluster continues
to work while at least one node is available.

##### Load Balancer Configuration

Thruk does not include a load balancer. You can use any load balancer.
Use this URL for heartbeat checks to detect which cluster nodes are online.

```
/thruk/cgi-bin/remote.cgi?lb_ping
```

The page returns one of these responses:

- 200 OK
- 503 MAINTENANCE

To put a node in maintenance mode, run `thruk cluster maint`.
To reactivate it, run `thruk cluster unmaint`.

#### Maintenance

To put a cluster node in maintenance mode, run:

```
%> thruk cluster maint
```

This changes the response at `/thruk/cgi-bin/remote.cgi?lb_ping` to `MAINTENANCE`.
It also returns HTTP code 503 `Service Unavailable`.
If your load balancer checks for `OK`, it should remove this node from the active nodes.

Remove the maintenance mode with the command:

```
%> thruk cluster unmaint
```

### Troubleshooting

- First, make sure Thruk works without cluster mode. Then enable clustering.
- Moving etc and var to shared storage can break relative symlinks. You may need to link folders to the share to restore them.
- Run `thruk r /thruk/cluster` and `thruk r -d "" /thruk/cluster/heartbeat` to check whether Thruk detects the cluster nodes correctly.

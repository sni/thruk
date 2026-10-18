#!/bin/bash
# showcase action: restart a service (the grafana service of the demo site)
host="$1"; service="$2"
OMD=/opt/omd/bin/omd
[ -x "$OMD" ] || OMD=omd
echo "restarting service: host='$host' service='$service'"
echo "running: $OMD restart grafana"
"$OMD" restart grafana

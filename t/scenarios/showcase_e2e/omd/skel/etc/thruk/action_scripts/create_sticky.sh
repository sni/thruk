#!/bin/bash
# showcase action: (re-)create the sticky logfile problem of the 'Sticky Logfile' demo service
host="$1"; service="$2"
state="/omd/sites/demo/var/thruk/showcase_sticky.state"
echo "$(date '+%F %T') created by user '$REMOTE_USER'" > "$state" || { echo "ERROR: could not write to $state"; exit 1; }
echo "sticky logfile problem created, force rescheduling the service check"
service_url=$(printf '%s' "$service" | sed 's/ /%20/g')
THRUK=/omd/sites/demo/bin/thruk
[ -x "$THRUK" ] || THRUK=thruk
"$THRUK" r -d "start_time=now" "/services/$host/$service_url/cmd/schedule_forced_svc_check"
sleep 1

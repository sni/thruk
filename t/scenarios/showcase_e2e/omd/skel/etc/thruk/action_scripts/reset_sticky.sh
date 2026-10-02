#!/bin/bash
# showcase action: reset the sticky logfile check of the 'Sticky Logfile' demo service
host="$1"; service="$2"
state="/omd/sites/demo/var/thruk/showcase_sticky.state"
[ -e "$state" ] || { echo "nothing to reset, sticky state file does not exist"; exit 0; }
rm -f "$state"
echo "sticky logfile check reset, force rescheduling the service check"
service_url=$(printf '%s' "$service" | sed 's/ /%20/g')
THRUK=/omd/sites/demo/bin/thruk
[ -x "$THRUK" ] || THRUK=thruk
"$THRUK" r -d "start_time=now" "/services/$host/$service_url/cmd/schedule_forced_svc_check"
sleep 1

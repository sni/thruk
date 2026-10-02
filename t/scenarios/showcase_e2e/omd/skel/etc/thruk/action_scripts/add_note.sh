#!/bin/bash
# showcase action: save a note for a host / service, called from the form based action menu
host="$1"; service="$2"; note="$3"
[ -n "$note" ] || { echo "ERROR: no note given"; exit 1; }
file="/omd/sites/demo/var/thruk/showcase_notes.log"
echo "$(date '+%F %T') $REMOTE_USER: $host${service:+ / $service}: $note" >> "$file" || { echo "ERROR: could not write to $file"; exit 1; }
echo "note for $host${service:+ / $service} saved to $file"

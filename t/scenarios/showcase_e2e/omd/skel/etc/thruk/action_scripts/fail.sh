#!/bin/bash
# showcase action: intentionally fails to demo the error handling
host="$1"; service="$2"
echo "ERROR: simulated failure for host '$host'${service:+ / service '$service'}"
exit 1

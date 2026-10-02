#!/bin/bash
# showcase check: sticky logfile check, fails while the state file exists
state="$1"
if [ -e "$state" ]; then
  echo "CRITICAL - sticky logfile problem: | errors=1"
  cat "$state"
  exit 2
fi
echo "OK - logfile clean | errors=0"
exit 0

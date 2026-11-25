#!/bin/bash
#
# This script exports a grafana graph and stores it in a temp file.
#
# usage:
#
# grafana_export.sh <imgwidth> <imgheight> <start> <end> <grafanaurl> <tempfile>

# read rc files if exist
[ -e /etc/thruk/thruk.env  ] && . /etc/thruk/thruk.env
[ -e ~/etc/thruk/thruk.env ] && . ~/etc/thruk/thruk.env
[ -e ~/.thruk              ] && . ~/.thruk
[ -e ~/.profile            ] && . ~/.profile

WIDTH=$1
HEIGHT=$2
START=$(($3 * 1000))
END=$(($4 * 1000))
INPUT=$5
TEMPFILE=$6

DIR=$(dirname $0)
export PATH=$PATH:$DIR
export THRUK_BROWSER THRUK_BROWSER_NO_SANDBOX WAIT_TIMEOUT START_TIMEOUT THRUK_COOKIE_AUTH_DOMAIN

INPUT="$INPUT&from=$START&to=$END"

if [ -d "$TEMPFILE" ]; then
    echo "ERROR: $TEMPFILE is a directory"
    exit 1
fi

# the output is only put in place after the renderer succeeded.
# Each call has its own staging file, so parallel calls cannot publish each other's output.
STAGE="${TEMPFILE}.$$.png"
trap 'rm -f "$STAGE"' EXIT
rm -f "$STAGE"
perl "$DIR/render_url.pl" "$INPUT" "$STAGE" "$WIDTH" "$HEIGHT" "$THRUK_SESSION_ID" 2>&1
rc=$?
if [ $rc -eq 0 ]; then
    mv "$STAGE" "${TEMPFILE}" || rc=1
fi
exit $rc

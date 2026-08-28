#!/bin/bash

NUM=$1
if [ "x$NUM" = "x" ]; then
    echo "usage: $0 <num>"
    echo "creates number of hosts with agent monitoring."
    echo "enables mod-gearman to avoid to heavy load when running lots of parallel checks."
    exit 1
fi

# enable mod-gearman unless already enabled
if [ "$CONFIG_MOD_GEARMAN" != "on" ]; then
    echo "enabling mod-gearman"
    omd stop
    omd config set MOD_GEARMAN on
    omd start
fi

rm -f etc/naemon/conf.d/agents/host*
thruk agents -I --password test --ip 127.0.0.1 host0001 || exit 1

sed -e "/_WORKER/d" -i etc/naemon/conf.d/agents/host0001.cfg

for i in $(seq 2 $NUM); do
    host=$(printf "host%04d" $i)
    cp var/thruk/agents/hosts/host0001.json var/thruk/agents/hosts/$host.json
    cp etc/naemon/conf.d/agents/host0001.cfg etc/naemon/conf.d/agents/$host.cfg
    sed -e "s/host0001/$host/g" -i etc/naemon/conf.d/agents/$host.cfg
done

thruk agents -R


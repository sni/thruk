#!/bin/bash

export PATH=$PATH:/usr/sbin:/sbin

docker image prune -a -f
docker network prune -f
docker system prune -af

exit 0

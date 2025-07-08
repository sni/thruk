#!/bin/bash

ROLE=$1
shift

if [ "$ROLE" = "" ]; then
  echo "Usage: $0 <role>"
  echo "available roles:"
  ls -1 $ANSIBLE_ROLES_PATH
  exit 1
fi

export ANSIBLE_RETRY_FILES_ENABLED="False"
ansible-playbook -f1 -i localhost, -c local -e SITENAME=demo "$@" /dev/stdin <<END
---
- hosts: localhost
  vars:
    site: demo
  roles:
    - $ROLE
END

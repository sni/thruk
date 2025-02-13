#!/bin/bash

ROLE=$1
shift

export ANSIBLE_RETRY_FILES_ENABLED="False"
ansible-playbook -f1 -i localhost, -c local -e SITENAME=demo "$@" /dev/stdin <<END
---
- hosts: localhost
  vars:
    site: demo
  roles:
    - $ROLE
END

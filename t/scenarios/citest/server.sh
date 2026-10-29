#!/bin/bash

if [ $(whoami) != "naemon" ]; then
    exec sudo su naemon -c "$0 $*"
    exit 1
fi

cd ~naemon/thruk

eval $(perl -I ~/perl5/lib/perl5/ -Mlocal::lib)
export PERL5LIB=./lib:.:$PERL5LIB

export TEST_AUTHOR=1
export THRUK_AUTHOR=1
export TEST_MYSQL="mysql://naemon:naemon@localhost:3306/test"

exec stdbuf -o0 -e0 /usr/bin/env perl ./script/thruk_server.pl -r "$*"

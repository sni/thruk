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
export THRUK_HTML_LINT_ARE_ERRORS=1
export TEST_MYSQL="mysql://naemon:naemon@localhost:3306/test"

export HARNESS_TIMER=1
export PERL_DL_NONLAZY=1

VERBOSE=0
FILES=""
while [ $# -gt 0 ]; do
    ARG="$1"
    shift
    if test -f "$ARG"; then
        if [ "x$FILES" = "x" ]; then
            FILES="$ARG"
        else
            FILES="$FILES $ARG"
        fi
    elif test -f "/thruk/$ARG"; then
        FILES="$FILES /thruk/$ARG"
    elif [ "$ARG" == "-v" ]; then
        VERBOSE=1
    elif [ "$ARG" == "1" ]; then
        VERBOSE=1
    elif [ "$ARG" == "clean" ]; then
        :
    elif [ "$ARG" == "prepare" ]; then
        :
    elif [ "$ARG" == "update" ]; then
        :
    else
        # single file may have options
        # ex.: make test_verbose t/800-plugins.t pansnaps
        if test -f "$FILES"; then
            stdbuf -o0 -e0 /usr/bin/env perl $FILES $ARG $*
            exit $?
        else
            echo "ERROR: unknown option: '$ARG'"
            exit 1
        fi
    fi
done

if [ "$FILES" == "" ]; then
    FILES="t/*.t t/xt/*/*.t"
fi

stdbuf -o0 -e0 /usr/bin/env perl "-MExtUtils::Command::MM" "-e" "test_harness($VERBOSE)" $FILES

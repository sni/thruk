#!/bin/bash

VERBOSE=0
if [ "x$1" != "x" ]; then
  VERBOSE=$1
  shift
fi

TESTS="/test/t/local/*.t"
if [ "x$1" != "x" ]; then
  TESTS="$*"
  shift
fi

# make sure we have test files
if ! ls $TESTS >/dev/null 2>&1; then
    echo "no test files found for $TESTS"
    exit 1
fi


# export some more when run as root
if [ $(id -un) = "root" ]; then
    export OMD_SITE=demo
    export OMD_ROOT=/omd/sites/demo
    export PERL5LIB=/thruk/lib/:/omd/versions/default/lib/perl5/lib/perl5/
    export PATH=/thruk/script:/omd/versions/default/bin:$PATH
fi

THRUK_CONFIG=$(pwd)/etc/thruk \
  TEST_AUTHOR=1 \
  PERL_DL_NONLAZY=1 \
  unbuffer \
  perl -MExtUtils::Command::MM -e "test_harness($VERBOSE, '/thruk/t', 'lib/')" \
  $TESTS
exit $?

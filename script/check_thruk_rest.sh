#!/bin/bash
# vim: expandtab:ts=4:sw=4:syntax=perl

# read rc files if exist
unset PROFILEDOTD
[ -e /etc/thruk/thruk.env  ] && . /etc/thruk/thruk.env
[ -e ~/etc/thruk/thruk.env ] && . ~/etc/thruk/thruk.env
[ -e ~/.thruk              ] && . ~/.thruk
[ -e ~/.profile            ] && . ~/.profile

BASEDIR=$(dirname $0)/..

# git version
if [ -d $BASEDIR/.git -a -e $BASEDIR/lib/Thruk.pm ]; then
  export PERL5LIB="$BASEDIR/lib:$PERL5LIB";
  if [ "$OMD_ROOT" != "" -a "$THRUK_CONFIG" = "" ]; then export THRUK_CONFIG="$OMD_ROOT/etc/thruk"; fi
  if [ "$THRUK_CONFIG" = "" ]; then export THRUK_CONFIG="$BASEDIR/"; fi

# omd
elif [ "$OMD_ROOT" != "" ]; then
  export PERL5LIB=$OMD_ROOT/share/thruk/lib:$PERL5LIB
  if [ "$THRUK_CONFIG" = "" ]; then export THRUK_CONFIG="$OMD_ROOT/etc/thruk"; fi

# pkg installation
else
  export PERL5LIB=$PERL5LIB:@DATADIR@/lib:@THRUKLIBS@;
  if [ "$THRUK_CONFIG" = "" ]; then export THRUK_CONFIG='@SYSCONFDIR@'; fi
fi

eval 'exec perl -x $0 ${1+"$@"} ;'
    if 0;
# / this slash makes vscode syntax highlighting work
#! -*- perl -*-
#line 35

# this is just a wrapper to call check_thruk_rest.pl with the right perl environment
my $script = $0;
$script =~ s/\.sh$//;
my $res = do($script);
if($@) {
    die "could not parse $script: $@";
}
if(!defined $res) {
    die "could not do $script: $!";
}

###################################################

1;

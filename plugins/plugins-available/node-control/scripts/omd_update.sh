#!/bin/bash

if [ "$OMD_UPDATE" = "" ]; then
    echo "[ERROR] script requires OMD_UPDATE env variable"
    exit 1
fi

# try dry-run first (available since OMD 5.10)
DRYRUN=$(omd -V $OMD_UPDATE update -n 2>&1)
CONFLICTS=$(echo "$DRYRUN" | grep "conflicts during dry run" | awk '{ print $2 }')
if [ -n "$CONFLICTS" -a "$CONFLICTS" != "0" ]; then
    echo "[ERROR] no automatic update possible, $CONFLICTS conflict(s) found."
    echo "$DRYRUN"
    exit 1
fi

# check if tmux is available on this host
HAS_TMUX=0
if command -v tmux >/dev/null 2>&1; then
    HAS_TMUX=1
fi

echo "*** updating site $(id -un) from $(omd version -b) to version $OMD_UPDATE..."
echo "*** Site will be stopped during the update, so no progress can be displayed."
echo "*** this may take a couple of minutes...";

SITE_STARTED=0
THRUK_MAINT=0
omd status -b > /dev/null 2>&1
if [ $? -ne 1 ]; then
    # set thruk cluster in maintenance mode
    if thruk cluster status >/dev/null 2>&1; then
        thruk cluster maint
        THRUK_MAINT=1
        echo "*** thruk cluster maintenance mode activated";
    fi

    sleep 3 # wait 3 seconds, so the messages above can be transferred back via http

    SITE_STARTED=1
    omd stop

    # make sure it is stopped
    omd status -b > /dev/null 2>&1
    if [ $? -ne 1 ]; then
        omd stop
    fi
fi

CMD="omd -f -V $OMD_UPDATE update --conflict=ask"
# start update in tmux
if [ "$HAS_TMUX" = "1" ]; then
    session="omd_update"
    tmux -f /dev/null new-session -d -s $session -x 120 -y 25
    window=0
    tmux -f /dev/null rename-window -t $session:$window 'omd_update'
    tmux -f /dev/null send-keys -t $session:$window "$CMD" C-m
    sleep 2

    # now wait till the omd update is finished and tail the output till then
    # end tmux on success
    PID_BASH=$(tmux -f /dev/null list-panes -a -F "#{pane_pid} #{session_name}" | grep $session | awk '{ print $1 }')
    PID_OMD=$(ps -efl | grep $PID_BASH | grep omd | awk '{ print $4 }')
    X=0
    if [ "$PID_OMD" = "" ]; then
        while [ $X -lt 10 ]; do
            PID_OMD=$(ps -efl | grep $PID_BASH | grep omd | awk '{ print $4 }')
            [ "$PID_OMD" != "" ] && break;
            if [ $(tmux -f /dev/null capture-pane -p -t $session:$window 2>/dev/null | grep -c "Finished update") -gt 0 ]; then
                break
            fi
            sleep 1
            X=$((X+1))
        done
    fi

    if [ "$PID_OMD" != "" ]; then
        X=0
        while kill -0 $PID_OMD >/dev/null 2>&1; do
            sleep 1
            X=$((X+1))
            if [ $X -gt 120 ]; then
                # print output of tmux session
                tmux -f /dev/null capture-pane -p -t $session:$window
                echo "[ERROR] update timed out, ssh into $HOSTNAME and"
                echo "[ERROR] run 'tmux attach -t $session:$window' to manually investigate"

                # at least try to start apache again
                omd start apache
                if [ "$THRUK_MAINT" = "1" ]; then
                    thruk cluster unmaint
                    echo "*** thruk cluster maintenance mode deactivated";
                fi

                exit 1
            fi
        done
    fi
    # print output of tmux session
    tmux -f /dev/null capture-pane -p -t $session:$window
else
    $CMD
fi

if [ "$(omd version -b)" = "$OMD_UPDATE" ]; then
    # exit tmux again
    if [ "$HAS_TMUX" = "1" ]; then
        tmux -f /dev/null send-keys -t $session:$window "exit" C-m
    fi

    if [ $SITE_STARTED = 1 ]; then
        echo "%> omd start"
        omd start
        if [ "$THRUK_MAINT" = "1" ]; then
            thruk cluster unmaint
            echo "*** thruk cluster maintenance mode deactivated";
        fi
    else
        echo "SITE was not started before the update, won't start it again"
    fi

    echo "%> omd status"
    omd status

    echo "%> omd version"
    omd version

    echo "*** update finished: $(omd version -b)"
    exit 0
fi

if [ "$HAS_TMUX" = "1" ]; then
    echo "*** [ERROR] update failed, ssh into $HOSTNAME and"
    echo "*** [ERROR] run 'tmux attach -t $session:$window' to manually investigate"
else
    echo "*** [ERROR] update failed"
fi

# at least try to start apache again
omd start apache
if [ "$THRUK_MAINT" = "1" ]; then
    thruk cluster unmaint
    echo "*** thruk cluster maintenance mode deactivated";
fi

exit 1

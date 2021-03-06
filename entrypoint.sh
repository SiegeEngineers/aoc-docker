#!/bin/bash

log () {
    echo "[$(date +"%x %X")] $1"
}

# for reasons unknown, this command can not be run in the build (this just accepts the EULA)
wine regedit $HOME/registry_update.reg

# set up virtual display
Xvfb :0 -screen 0 800x600x8 > $HOME/xvfb.log 2>&1 &

# set up VNC server for debug purposes
if [ -n $VNC_PASSWORD ]; then
    x11vnc -display :0 -noxrecord -noxfixes -noxdamage -forever -passwd $VNC_PASSWORD > $HOME/xvnc.log 2>&1 &
fi

# clear out dropbox
rm -f /dropbox/*

# wait for recorded game files to appear in the dropbox
log "aoc version $(cat "$WKPATH/version.ini")"
log "waiting for files ..."

inotifywait -q -m /dropbox -e create -e moved_to |
    while read path action file; do
        log "$file received"

        # kill aoc if it's already running
        if [ -n "$PID" ]; then kill $PID; fi
        rm -f $HOME/aoc.log

        # kill debug/console (remnant of crash)
        ps -ef | grep 'winedbg' | grep -v grep | awk '{print $2}' | xargs -r kill -9
        ps -ef | grep 'wineconsole' | grep -v grep | awk '{print $2}' | xargs -r kill -9

        # move incoming file
        mv "/dropbox/$file" "$WKPATH/SaveGame/$HOSTNAME.mgz"

        # launch aoc
        WINEDEBUG=+loaddll wine "$AOCPATH/age2_x1/WK.exe" '"'$HOSTNAME.mgz'"' NOSOUND NODXCHECK > $HOME/aoc.log 2>&1 &
        PID=$!

        # wait for rec to load
        SECONDS=0
        SUCCESS=0
        while [ $SECONDS -le 5 ]; do
            grep -q -I SPI_SETSHOWIMEUI $HOME/aoc.log
            if [ $? -eq 0 ]; then SUCCESS=1; break; fi
            sleep 1
            ((SECONDS++))
        done

        if [ $SUCCESS -eq 1 ]; then
            sleep 2
            log "$file playback started"
            # run specified additional commands
            eval "$@"
        else
            log "$file failed to play"
        fi
    done

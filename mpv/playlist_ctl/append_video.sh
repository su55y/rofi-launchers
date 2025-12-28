#!/bin/sh

MPV_START_LOCK=/tmp/mpv_start.lock
MPV_SOCKET_FILE=/tmp/mpv.sock

notify() { [ -n "$1" ] && notify-send -i mpv -a append-script "$1"; }

if [ -f "$MPV_START_LOCK" ]; then
    notify 'mpv process already running...'
    exit 1
fi

cleanup() { [ -f "$MPV_START_LOCK" ] && rm "$MPV_START_LOCK"; }
trap cleanup EXIT

if ! echo '{"command":["get_property","pause"]}' | nc -NU "$MPV_SOCKET_FILE" >/dev/null 2>&1; then
    notify 'starting mpv...'
    touch "$MPV_START_LOCK"
    [ -S "$MPV_SOCKET_FILE" ] && rm "$MPV_SOCKET_FILE"
    setsid -f mpv --idle --no-terminal --input-ipc-server="$MPV_SOCKET_FILE" >/dev/null 2>&1

    # 5 sec timeout
    for _ in $(seq 50); do
        if [ ! -S "$MPV_SOCKET_FILE" ]; then
            sleep 0.1
        else
            echo '{"command":["get_property","pause"]}' |
                nc -NU "$MPV_SOCKET_FILE" >/dev/null 2>&1 && break
        fi
    done
fi

if [ ! -S "$MPV_SOCKET_FILE" ]; then
    notify "can't find $MPV_SOCKET_FILE"
    killall mpv
    exit 1
fi

notify "$(playlist-ctl -a "$1" 2>&1)"

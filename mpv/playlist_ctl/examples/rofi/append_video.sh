#!/bin/sh

MPV_START_LOCK="/tmp/mpv_start.lock"
MPV_SOCKET_FILE="/tmp/mpv.sock"
RX_URL=".*youtube\.com\/watch\?v=([\w\d_\-]{11})|.*youtu\.be\/([\w\d_\-]{11})"

notify() { [ -n "$1" ] && notify-send -i mpv -a append-script "$1"; }

[ -f "$MPV_START_LOCK" ] && {
    notify "MPV process already running..."
    exit 1
}

cleanup() { [ -f "$MPV_START_LOCK" ] && rm "$MPV_START_LOCK"; }
trap cleanup EXIT

input="$1"
[ -z "$input" ] && input="$(xclip -o -selection clipboard)"
if [ ! -f "$input" ]; then
    echo "$input" | grep -sqP "$RX_URL" || {
        notify "invalid url '$input'"
        exit 1
    }
    URL="$(echo "$input" | grep -oP "$RX_URL")"
else
    URL="$input"
fi

pidof mpv >/dev/null 2>&1 || {
    touch "$MPV_START_LOCK"
    [ -S "$MPV_SOCKET_FILE" ] && rm "$MPV_SOCKET_FILE"
    setsid -f mpv --idle --no-terminal --input-ipc-server="$MPV_SOCKET_FILE"

    # 5 sec timeout
    for _ in $(seq 50); do
        [ -S "$MPV_SOCKET_FILE" ] && pidof mpv >/dev/null 2>&1 && break
        sleep 0.1
    done
}

[ -S "$MPV_SOCKET_FILE" ] || {
    notify "can't find $MPV_SOCKET_FILE"
    killall mpv
    exit 1
}

notify "$(playlist-ctl -a "$URL")"

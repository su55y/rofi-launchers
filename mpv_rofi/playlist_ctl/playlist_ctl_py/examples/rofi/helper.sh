#!/bin/sh

err_msg(){ [ -n "$1" ] && printf '\000message\037error: %s\n' "$1"; }
pidof -q mpv || { err_msg "mpv process not found"; exit 1; }

MPV_SOCKET_FILE="/tmp/mpv.sock"
[ -S "$MPV_SOCKET_FILE" ] || { err_msg "$MPV_SOCKET_FILE not found"; exit 1; }

play_index(){
    printf '%s' "$(printf '{"command": ["playlist-play-index", "%s"]}\n' "$1" |\
        nc -NU "$MPV_SOCKET_FILE" |\
        jq .error)"
}

case $ROFI_RETV in
0) playlist-ctl ;;
1)
    error="$(play_index "$ROFI_INFO")"
    case $error in
    *success*) exit 0 ;;
    *) err_msg "$error" ;;
    esac
;;
esac

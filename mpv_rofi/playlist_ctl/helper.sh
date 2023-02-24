#!/bin/sh

MPV_SOCKET_FILE="/tmp/mpv.sock"
MPV_PLAYLIST_FILE="/tmp/mpv_current_playlist"


play_index(){
    [ -S "$MPV_SOCKET_FILE" ] || {
        printf 'sock'
        return
    }
    printf '%s' "$(printf '{"command": ["playlist-play-index", "%s"]}\n' "$1" |\
        nc -NU "$MPV_SOCKET_FILE" |\
        jq .error)"
}

print_playlist(){
    [ -f "$MPV_PLAYLIST_FILE" ] || {
        printf '%s not found\000nonselectable\037true\n' "$MPV_PLAYLIST_FILE"
        return
    }
    while read -r entry || [ "$entry" ]; do
        id="${entry%% *}"
        title="${entry#* }"
        printf '%s\000info\037%s\n' "$title" "$id"
    done < "$MPV_PLAYLIST_FILE"
}

case $ROFI_RETV in
    0) print_playlist ;;
    1)
        case $(play_index "$ROFI_INFO") in
            *success*) exit 0 ;;
            sock) echo "$MPV_SOCKET_FILE not found" ;;
            *)
                pidof mpv >/dev/null 2>&1 || echo "mpv process not found"
                echo "some error occurred, check logs"
            ;;
        esac
    ;;
esac

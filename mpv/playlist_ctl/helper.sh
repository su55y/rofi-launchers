#!/bin/sh

# shellcheck source=../common_utils
. "${UTILS_PATH}"
: "${MPV_SOCKET_FILE:=/tmp/mpv.sock}"
: "${PL_HISTORY_CACHE_FILE:=/tmp/playlist_ctl_history}"
: "${PL_HISTORY_LIMIT:=100}"

printf '\000use-hot-keys\037true\n'

print_refreshed_history() {
    _msg HISTORY
    playlist-ctl --history -l "$PL_HISTORY_LIMIT" | tee "$PL_HISTORY_CACHE_FILE"
}

print_history() {
    printf '\000data\037history\n'
    printf '\000keep-filter\037true\n'
    printf '\000keep-selection\037true\n'
    if ! grep -q '[^[:space:]]' "$PL_HISTORY_CACHE_FILE" 2>/dev/null; then
        print_refreshed_history
    elif [ -f "$PL_HISTORY_CACHE_FILE" ] && [ "$ROFI_RETV" -ne 13 ]; then
        _msg 'HISTORY [C]'
        awk '{gsub(/\\000/, "\0"); gsub(/\\037/, "\037"); print}' "$PL_HISTORY_CACHE_FILE"
    else
        print_refreshed_history
    fi
}

play_index() {
    error="$(printf '%s' "$(printf '{"command": ["playlist-play-index", "%s"]}\n' "$1" |
        nc -NU "$MPV_SOCKET_FILE" |
        grep -oP 'error\"\:\"\K[^\"]+')")"
    [ "$error" = "success" ] || _err_msg "$error"
}

# kb-custom-1 (ctrl+h) - prints history
[ "$ROFI_RETV" -eq 10 ] && {
    print_history
    exit 0
}

if [ "$ROFI_DATA" = history ]; then
    case $ROFI_RETV in
    1) _play "$ROFI_INFO" ;;
    # kb-custom-2 (ctrl+a) - append to playlist
    11) _append "$ROFI_INFO" ;;
    # kb-custom-3 (ctrl+d) - download from history
    12) _download_vid "$ROFI_INFO" "$1" playlist-ctl ;;
    # kb-custom-5 (ctrl+o) - open in browser
    14) setsid -f "$BROWSER" "$ROFI_INFO" >/dev/null 2>&1 ;;
    # kb-custom-6 (ctrl+x,Delete) - delete history item
    15)
        playlist-ctl -d "$ROFI_INFO" || _err_msg "Can't delete $ROFI_INFO"
        [ -f "$PL_HISTORY_CACHE_FILE" ] &&
            sed -i "/$(echo $ROFI_INFO | sed -e 's/[]\/$*.^|[]/\\&/g')/d" "$PL_HISTORY_CACHE_FILE"
        ;;
    esac
    # kb-custom-4 (ctrl+r) - refresh history
    case $ROFI_RETV in
    1 | 11 | 12 | 13 | 14 | 15) print_history ;;
    esac
else
    pidof -q mpv || _err_msg 'mpv process not found'
    [ -S "$MPV_SOCKET_FILE" ] || _err_msg "$MPV_SOCKET_FILE not found"
    printf '\000keep-selection\037true\n'
    case $ROFI_RETV in
    0) playlist-ctl ;;
    1) play_index "$ROFI_INFO" ;;
    15) playlist-ctl -r "$ROFI_INFO" && playlist-ctl ;;
    esac
fi

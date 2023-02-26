#!/bin/sh

MPV_SOCKET_FILE="/tmp/mpv.sock"
MPV_PLAYLIST_FILE="/tmp/mpv_current_playlist"
RX_URL=".*youtube\.com\/watch\?v=([\w\d_\-]{11})|.*youtu\.be\/([\w\d_\-]{11})|.*twitch\.tv\/videos\/(\d{10})$"

notify(){
    [ -n "$1" ] && notify-send -i mpv -a mpv "$1"
}

append_play(){
    printf '%s' "$(printf '{"command": ["loadfile", "%s", "append-play"]}\n' "$1" |\
        nc -NU "$MPV_SOCKET_FILE" |\
        jq .error)"
}

update_playlist(){
    i=0
    for url in $(printf '{"command": ["get_property", "playlist"]}\n' |\
            nc -NU "$MPV_SOCKET_FILE" |\
            jq '.data[]? | .filename'); do
        
        current_entry="$(sed -n "$((i+1))p" $MPV_PLAYLIST_FILE)"
        current_entry_url="${current_entry##* }"
        current_entry_id="${current_entry%% *}"
        [ "$i" = "$current_entry_id" ] && [ "$url" = "$current_entry_url" ] && {
            i=$((i+1))
            continue
        }

        title="$(yt-dlp -e "$(printf '%s' "$url" | sed 's/\"//g')" 2>/dev/null)" || continue
        case $i in
            0) echo "$i $title $url" > "$MPV_PLAYLIST_FILE" ;;
            *) echo "$i $title $url" >> "$MPV_PLAYLIST_FILE" ;;
        esac
        i=$((i+1))
    done

    case $i in
        0) notify "playlist not updated" ;;
        *) notify "playlist successfully updated ($i)" ;;
    esac
}

pidof mpv >/dev/null 2>&1 || {
    [ -S "$MPV_SOCKET_FILE" ] && rm "$MPV_SOCKET_FILE"
    setsid -f mpv --idle --no-terminal --input-ipc-server="$MPV_SOCKET_FILE"

    for _ in $(seq 10); do
        [ -S "$MPV_SOCKET_FILE" ] && pidof mpv >/dev/null 2>&1 && break
        sleep 0.1
    done

    [ -S "$MPV_SOCKET_FILE" ] || {
        notify "can't find mpv socket file"
        killall mpv
        exit 1
    }
}

url="$(xclip -o -selection clipboard)"
[ "$(printf '%s' "$url" |\
    grep -oP "$RX_URL")" = "$url" ] && {
        case $(append_play "$url") in
            *success*)
                notify "video added to playlist: $url"
                update_playlist
            ;;
            *) notify "can't add video: $url" ;;
        esac
}

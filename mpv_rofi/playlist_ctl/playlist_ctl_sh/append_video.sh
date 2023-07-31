#!/bin/sh

MPV_START_LOCK="/tmp/mpv_start.lock"
MPV_SOCKET_FILE="/tmp/mpv.sock"
MPV_PLAYLIST_FILE="/tmp/mpv_current_playlist"
RX_URL=".*youtube\.com\/watch\?v=([\w\d_\-]{11})|.*youtu\.be\/([\w\d_\-]{11})|.*twitch\.tv\/videos\/(\d{10})"

notify() { [ -n "$1" ] && notify-send -i mpv -a mpv "$1"; }

[ -f "$MPV_START_LOCK" ] && {
	notify "MPV process already running..."
	exit 1
}

cleanup() { [ -f "$MPV_START_LOCK" ] && rm "$MPV_START_LOCK"; }
trap cleanup EXIT

INPUT_URL="$1"
[ -z "$INPUT_URL" ] && INPUT_URL="$(xclip -o -selection clipboard)"
echo "$INPUT_URL" | grep -sqP "$RX_URL" || {
	notify "invalid url '$INPUT_URL'"
	exit 1
}
URL="$(echo "$INPUT_URL" | grep -oP "$RX_URL")"

update_playlist() {
	i=0
	for url in $(printf '{"command": ["get_property", "playlist"]}\n' |
		nc -NU "$MPV_SOCKET_FILE" |
		jq -r '.data[]? | .filename'); do

		current_entry="$(sed -n "$((i + 1))p" $MPV_PLAYLIST_FILE 2>/dev/null)"
		current_entry_url="${current_entry##* }"
		current_entry_id="${current_entry%% *}"
		[ "$i" = "$current_entry_id" ] && [ "$url" = "$current_entry_url" ] && {
			i=$((i + 1))
			continue
		}

		case $url in
		*youtu*) title="$(curl "https://youtube.com/oembed?format=json&url=$url" 2>/dev/null | jq -r .title)" ;;
		*) title="$(yt-dlp -e "$(printf '%s' "$url" | sed 's/\"//g')" 2>/dev/null)" ;;
		esac

		[ -n "$title" ] || continue

		case $i in
		0) echo "$i $title $url" >"$MPV_PLAYLIST_FILE" ;;
		*) echo "$i $title $url" >>"$MPV_PLAYLIST_FILE" ;;
		esac
		i=$((i + 1))
	done

	case $i in
	0) notify "playlist not updated" ;;
	*) notify "playlist successfully updated ($i)" ;;
	esac
}

pidof -q mpv || {
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
	notify "$MPV_SOCKET_FILE not found"
	killall mpv
	exit 1
}

append_play() {
	printf '%s' "$(printf '{"command": ["loadfile", "%s", "append-play"]}\n' "$1" |
		nc -NU "$MPV_SOCKET_FILE" |
		jq -r .error)"
}

case $(append_play "$URL") in
success)
	notify "video added to playlist: $URL"
	update_playlist
	;;
*) notify "can't add video: $URL" ;;
esac
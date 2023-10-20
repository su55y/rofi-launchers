#!/bin/sh

HISTORY_FILE="/tmp/playlist_ctl_history"
HISTORY_LIMIT=100
APPEND_SCRIPT="${XDG_DATA_HOME:-$HOME/.local/share}/rofi/playlist_ctl_py/append_video.sh"
DOWNLOAD_DIR="$HOME/Videos/YouTube"

printf '\000use-hot-keys\037true\n'

err_msg() { [ -n "$1" ] && printf '\000message\037error: %s\n \000nonselectable\037true\n' "$1"; }

print_history() {
	printf '\000message\037HISTORY\n'
	printf '\000data\037history\n'
	if [ -f "$HISTORY_FILE" ] && [ -z "$1" ]; then
		awk '{gsub(/\\000/, "\0"); gsub(/\\037/, "\037"); print}' "$HISTORY_FILE"
	else
		echo "" >"$HISTORY_FILE"
		playlist-ctl --history -l "$HISTORY_LIMIT" | tee -a "$HISTORY_FILE"
	fi
}

# kb-custom-1 (Ctrl+h) - prints history
[ "$ROFI_RETV" -eq 10 ] && {
	print_history
	exit 0
}

download_vid() {
	notify-send -a "playlist-ctl" "⬇️Start downloading '$2'..."
	qid="$(tsp yt-dlp "$1" -o "$DOWNLOAD_DIR/%(uploader)s/%(title)s.%(ext)s")"
	tsp -D "$qid" notify-send -a "playlist-ctl" "✅Download done: '$2'" >/dev/null 2>&1
}

pidof -q mpv || {
	[ "$ROFI_DATA" = "history" ] || err_msg "mpv process not found"
}

MPV_SOCKET_FILE="/tmp/mpv.sock"
[ -S "$MPV_SOCKET_FILE" ] || {
	[ "$ROFI_DATA" = "history" ] || err_msg "$MPV_SOCKET_FILE not found"
}

play_index() {
	error="$(printf '%s' "$(printf '{"command": ["playlist-play-index", "%s"]}\n' "$1" |
		nc -NU "$MPV_SOCKET_FILE" |
		grep -oP 'error\"\:\"\K[^\"]+')")"
	case $error in
	*success*) ;;
	*) err_msg "$error" ;;
	esac
}

case $ROFI_RETV in
0) playlist-ctl ;;
1)
	case $ROFI_DATA in
	history)
		setsid -f mpv "$ROFI_INFO" >/dev/null 2>&1
		print_history
		;;
	*) play_index "$ROFI_INFO" ;;
	esac

	;;
# kb-custom-2 (Ctrl+a) - append to playlist
11)
	[ "$ROFI_DATA" = "history" ] && {
		setsid -f "$APPEND_SCRIPT" "$ROFI_INFO" >/dev/null 2>&1
		print_history
	}
	;;
	# kb-custom-3 (Ctrl+d) - download from history
12)
	[ "$ROFI_DATA" = "history" ] && {
		download_vid "$ROFI_INFO" "$1"
		print_history
	}
	;;
13)
	[ "$ROFI_DATA" = "history" ] && print_history refreshed
	;;
esac

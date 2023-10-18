#!/bin/sh

HISTORY_FILE="/tmp/playlist_ctl_history"
HISTORY_LIMIT=10
APPEND_SCRIPT="${XDG_DATA_HOME:-$HOME/.local/share}/rofi/playlist_ctl_py/append_video.sh"

err_msg() { [ -n "$1" ] && printf '\000message\037error: %s\n \000nonselectable\037true\n' "$1"; }

print_history() {
	printf '\000message\037HISTORY\n'
	printf '\000data\037history\n'
	if [ -f "$HISTORY_FILE" ]; then
		awk '{gsub(/\\000/, "\0"); gsub(/\\037/, "\037"); print}' "$HISTORY_FILE"
	else
		echo "" >"$HISTORY_FILE"
		playlist-ctl --history -l "$HISTORY_LIMIT" | tee -a "$HISTORY_FILE"
	fi
}

pidof -q mpv || {
	err_msg "mpv process not found"
}

MPV_SOCKET_FILE="/tmp/mpv.sock"
[ -S "$MPV_SOCKET_FILE" ] || {
	err_msg "$MPV_SOCKET_FILE not found"
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

printf '\000use-hot-keys\037true\n'

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
# kb-custom-1 (Ctrl+h) - prints history
10) print_history ;;
# kb-custom-2 (Ctrl+a) - append to playlist
11)
	[ "$ROFI_DATA" = "history" ] && {
		setsid -f "$APPEND_SCRIPT" "$ROFI_INFO" >/dev/null 2>&1
		print_history
	}
	;;
esac

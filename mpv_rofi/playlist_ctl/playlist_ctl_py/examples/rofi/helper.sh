#!/bin/sh

HISTORY_FILE="/tmp/playlist_ctl_history"
HISTORY_LIMIT=10

err_msg() { [ -n "$1" ] && printf '\000message\037error: %s\n \000nonselectable\037true\n' "$1"; }

print_history() {
	printf '\000message\037HISTORY\n'
	printf '\000data\037history\n'
	if [ -f "$HISTORY_FILE" ]; then
		# print from file
		echo
	else
		echo "" >"$HISTORY_FILE"
		playlist-ctl --history -l "$HISTORY_LIMIT" | tee -a "$HISTORY_FILE"
	fi
}

[ "$ROFI_INFO" = "history" ] && {
	print_history
	exit 0
}

pidof -q mpv || {
	err_msg "mpv process not found"
	exit 1
}

MPV_SOCKET_FILE="/tmp/mpv.sock"
[ -S "$MPV_SOCKET_FILE" ] || {
	err_msg "$MPV_SOCKET_FILE not found"
	exit 1
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
	history) print_history ;;
	*) play_index "$ROFI_INFO" ;;
	esac

	;;
# kb-custom-1 (Ctrl+h) - prints history
10) print_history ;;
esac

#!/bin/sh

. "${SCRIPTPATH}/../mpv_rofi_utils"

start_menu() {
	printf "feed\000info\037feed\n"
	pytfeeder-rofi
	printf "\000new-selection\0370\n"
}

printf "\000use-hot-keys\037true\n"

case $ROFI_RETV in
# channels list on start
0) start_menu ;;
# select line
1)
	case "$ROFI_INFO" in
	feed)
		printf "back\000info\037main\n"
		pytfeeder-rofi -f
		printf "\000new-selection\0370\n"
		;;
	main) start_menu ;;
	*)
		if [ "$(printf '%s' "$ROFI_INFO" |
			grep -oP "^[0-9a-zA-Z_\-]{24}$")" = "$ROFI_INFO" ]; then
			printf "back\000info\037main\n"
			pytfeeder-rofi -i="$ROFI_INFO"
			printf "\000new-selection\0370\n"
		elif [ "$(printf '%s' "$ROFI_INFO" |
			grep -oP "^[0-9a-zA-Z_\-]{11}$")" = "$ROFI_INFO" ]; then
			pytfeeder-rofi -v="$ROFI_INFO" >/dev/null 2>&1
			_play "https://youtu.be/$ROFI_INFO"
		else
			_err_msg "invalid id '$ROFI_INFO'"
		fi
		;;
	esac
	;;
# kb-custom-1 (Ctrl-s) -- sync
10)
	[ "$ROFI_DATA" = "main" ] || printf "back\000info\037main\n"
	case $ROFI_DATA in
	feed) pytfeeder-rofi -s -f ;;
	main)
		printf "feed\000info\037feed\n"
		pytfeeder-rofi -s
		;;
	*)
		[ "${#ROFI_DATA}" -eq 24 ] || _err_msg "invalid channel_id '$ROFI_DATA'"
		pytfeeder-rofi -s -i="$ROFI_DATA"
		;;
	esac
	;;
# kb-custom-2 (Ctrl-c) -- clean cache
11) pytfeeder-rofi --clean-cache ;;
# kb-custom-3 (Ctrl-x) -- mark entry as viewed
# kb-custom-6 (Ctrl-d) -- download selected entry
12 | 15)
	[ "$ROFI_DATA" = "main" ] || printf "back\000info\037main\n"
	[ "${#ROFI_INFO}" -eq 11 ] || _err_msg "invalid id '$ROFI_INFO'"
	case $ROFI_DATA in
	feed) pytfeeder-rofi -v="$ROFI_INFO" -f ;;
	*)
		[ "${#ROFI_DATA}" -eq 24 ] || _err_msg "invalid channel_id '$ROFI_DATA'"
		pytfeeder-rofi -v="$ROFI_INFO" -i="$ROFI_DATA"
		;;
	esac
	[ "$ROFI_RETV" -eq 15 ] && _download_vid "https://youtu.be/$ROFI_INFO" "$1"
	;;
# kb-custom-4 (Ctrl-X) -- mark current feed entries as viewed
13)
	[ "$ROFI_DATA" = "main" ] || printf "back\000info\037main\n"
	case $ROFI_DATA in
	feed) pytfeeder-rofi -v all -f ;;
	main) pytfeeder-rofi -v all ;;
	*)
		[ "${#ROFI_DATA}" -eq 24 ] || _err_msg "invalid channel_id '$ROFI_DATA'"
		pytfeeder-rofi -v="$ROFI_DATA" -i="$ROFI_DATA"
		;;
	esac
	printf "\000new-selection\0370"
	;;
# kb-custom-5 (Ctrl-a) -- append selected to playlist
14)
	[ "$ROFI_DATA" = "main" ] || printf "back\000info\037main\n"
	[ -f "$APPEND_SCRIPT" ] || _err_msg "append script not found"
	[ "${#ROFI_INFO}" -eq 11 ] || _err_msg "invalid id '$ROFI_INFO'"
	_append "https://youtu.be/$ROFI_INFO"
	case $ROFI_DATA in
	feed) pytfeeder-rofi -v="$ROFI_INFO" -f ;;
	*)
		[ "${#ROFI_DATA}" -eq 24 ] || _err_msg "invalid channel_id '$ROFI_DATA'"
		pytfeeder-rofi -v="$ROFI_INFO" -i="$ROFI_DATA"
		;;
	esac
	;;
esac

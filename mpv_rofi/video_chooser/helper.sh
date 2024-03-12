#!/bin/sh

SCRIPTPATH="$(
	cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
	pwd -P
)"
. "${SCRIPTPATH}/../mpv_rofi_utils"

VIDSDIR="${HOME}/Videos"
TEMPFILE="${TEMPDIR:-/tmp}/video_chooser.tmp"

# activate hotkeys
printf "\000use-hot-keys\037true\012"
# activate markup
printf "\000markup-rows\037true\012"

print_from_cache() {
	awk '{gsub(/\\000/, "\0"); gsub(/\\037/, "\037"); gsub(/\\012/, "\012"); print}' "$TEMPFILE"
}

printer() {
	if [ -f "$TEMPFILE" ]; then
		print_from_cache
	else
		"${SCRIPTPATH}/printer" "$VIDSDIR" | tee "$TEMPFILE"
	fi
}

restart_with_filter() {
	setsid -f "${SCRIPTPATH}/launcher.sh" "$1" >/dev/null 2>&1
}

parent_dir() {
	parent="$(basename "$(dirname "$ROFI_INFO")")"
	printf '%s' "${parent%% *}"
}

case $ROFI_RETV in
# print found files at start
0) printer ;;
# select line
1) [ -f "$ROFI_INFO" ] && _play "$ROFI_INFO" ;;
# kb-custom-1 (Ctrl+a) - append to playlist and restart with filter
10)
	if [ -f "$ROFI_INFO" ]; then
		_append "$ROFI_INFO"
		restart_with_filter "$(parent_dir)"
	fi
	;;
# kb-custom-2 (Ctrl+space) - play and restart with filter
11)
	if [ -f "$ROFI_INFO" ]; then
		_play "$ROFI_INFO"
		restart_with_filter "$(parent_dir)"
	fi
	;;
# kb-custom-3 (Ctrl=r) - remove cache
12)
	rm -f "$TEMPFILE"
	printer
	;;
esac

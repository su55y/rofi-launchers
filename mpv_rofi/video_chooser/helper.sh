#!/bin/sh

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
	"${SCRIPTPATH}/printer" "$VIDSDIR" | tee "$TEMPFILE"
}

case $ROFI_RETV in
# print found files at start
0) printer ;;
# select line
1) [ -f "$ROFI_INFO" ] && _play "$ROFI_INFO" ;;
# kb-custom-1 (Ctrl+a) - append to playlist
10)
	[ -f "$ROFI_INFO" ] && _append "$ROFI_INFO"
	[ -f "$TEMPFILE" ] && print_from_cache || printer
	;;
esac

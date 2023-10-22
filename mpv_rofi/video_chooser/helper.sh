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
	echo "" >"$TEMPFILE"
	find "$VIDSDIR" -type f -name "*.mp4" | while read -r file; do
		title="${file##*\/}"
		title="${title%.*}"
		base="$(dirname "$file")"
		base="${base%%*\/}"
		parent="${base##*\/}"
		printf '<b>%s</b>\r<i>%s</i>\000info\037%s\037meta\037%s\012' \
			"$title" "$parent" "$file" "${title}$(dirname "$file" | tr '/' ',')" |
			tee -a "$TEMPFILE"
	done
}

alt_printer() {
	echo "" >"$TEMPFILE"
	"${SCRIPTPATH}/alt_printer" "$VIDSDIR" | tee -a "$TEMPFILE"
}

case $ROFI_RETV in
# print printer on start and kb-custom-1 press
0) alt_printer ;;
# select line
1) [ -f "$ROFI_INFO" ] && _play "$ROFI_INFO" ;;
# kb-custom-1 - append to playlist
10)
	[ -f "$ROFI_INFO" ] && _append "$ROFI_INFO"
	[ -f "$TEMPFILE" ] && print_from_cache || alt_printer
	;;
esac

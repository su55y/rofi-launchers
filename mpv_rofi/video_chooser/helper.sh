#!/bin/sh

VIDSDIR="${HOME}/Videos"
TEMPFILE="${TEMPDIR:-/tmp}/video_chooser.tmp"
# optional for append
APPEND_SCRIPT="${XDG_DATA_HOME:-$HOME/.local/share}/rofi/playlist_ctl_py/append_video.sh"

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
	SCRIPTPATH="$(
		cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
		pwd -P
	)"
	echo "" >"$TEMPFILE"
	"${SCRIPTPATH}/alt_printer" "$VIDSDIR" | tee -a "$TEMPFILE"
}

case $ROFI_RETV in
# print printer on start and kb-custom-1 press
0) alt_printer ;;
# select line
1) [ -f "$ROFI_INFO" ] && setsid -f mpv "$ROFI_INFO" >/dev/null 2>&1 ;;
# kb-custom-1 - append to playlist
10)
	[ -f "$ROFI_INFO" ] && setsid -f "$APPEND_SCRIPT" "$ROFI_INFO" >/dev/null 2>&1
	[ -f "$TEMPFILE" ] && print_from_cache || alt_printer
	;;
esac

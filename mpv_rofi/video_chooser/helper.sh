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
	[ -f "$TEMPFILE" ] &&
		awk '{gsub(/\\000/, "\0"); gsub(/\\037/, "\037"); gsub(/\\012/, "\012"); print}' "$TEMPFILE"
}

banner() {
	echo "" >"$TEMPFILE"
	find "$VIDSDIR" -type f -name "*.mp4" | while read -r file; do
		title="${file##*\/}"
		base="$(dirname "$file")"
		base="${base%%*\/}"
		parent="${base##*\/}"
		printf '<b>%s</b>\r<i>%s</i>\000info\037%s\037meta\037%s\012' \
			"$title" "$parent" "$file" "${title}$(dirname "$file" | tr '/' ',')" |
			tee -a "$TEMPFILE"
	done
}

case $ROFI_RETV in
# print banner on start and kb-custom-1 press
0) banner ;;
# select line
1) [ -f "$ROFI_INFO" ] && setsid -f mpv "$ROFI_INFO" >/dev/null 2>&1 ;;
# kb-custom-1 - append to playlist
10)
	[ -f "$ROFI_INFO" ] && setsid -f "$APPEND_SCRIPT" "$ROFI_INFO" >/dev/null 2>&1
	print_from_cache
	;;
esac

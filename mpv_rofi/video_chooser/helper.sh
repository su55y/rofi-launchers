#!/bin/sh

VIDSDIR="${HOME}/Videos"
# activate hotkeys
printf "\000use-hot-keys\037true\n"

banner() {
	find "$VIDSDIR" -type f -name "*.mp4" | while read -r file; do
		title="${file##*\/}"
		printf '%s\000info\037%s\037meta\037%s\n' "$title" "$file" "${title}$(dirname "$file" | tr '/' ',')"
	done
}

case $ROFI_RETV in
# print banner on start and kb-custom-1 press
0) banner ;;
# select line
1) [ -f "$ROFI_INFO" ] && setsid -f mpv "$ROFI_INFO" >/dev/null 2>&1 ;;
esac

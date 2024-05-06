#!/bin/sh

BOOKS_DIR="${HOME}/books"

banner() {
	find "$BOOKS_DIR" -type f -name "*.pdf" | sort | while read -r file; do
		title="${file##*\/}"
		printf '%s\000info\037%s\n' "$title" "$file"
	done
}

case $ROFI_RETV in
# print banner on start
0) banner ;;
# select line
1) [ -f "$ROFI_INFO" ] && setsid -f zathura "$ROFI_INFO" >/dev/null 2>&1 ;;
esac

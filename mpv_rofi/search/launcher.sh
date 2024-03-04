#!/bin/sh

SCRIPTPATH="$(
	cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
	pwd -P
)"

[ -f "$SCRIPTPATH/helper.sh" ] || {
	notify-send -i "rofi" -a "youtube search" "helper script not found"
	exit 1
}
[ -f "$SCRIPTPATH/downloader" ] || {
	notify-send -i "rofi" -a "youtube search" "downloader executable not found"
	exit 1
}

. "${SCRIPTPATH}/../mpv_rofi_utils"

SCRIPTPATH="$SCRIPTPATH" rofi -i -no-config -show "yt_search" -modi "yt_search:$SCRIPTPATH/helper.sh" \
	-kb-move-front "Ctrl+i" -kb-row-select "Ctrl+9" -kb-remove-char-forward "Delete" \
	-kb-custom-1 "Ctrl+c" -kb-custom-2 "Ctrl+a" -kb-custom-3 "Ctrl+space" -kb-custom-4 "Ctrl+d" \
	-kb-remove-char-back "BackSpace,Shift+BackSpace" -kb-custom-5 "Ctrl+h" -theme-str "$(_search_theme)"

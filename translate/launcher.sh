#!/bin/sh

[ -n "$ROFI_PROMPT_CMD" ] || ROFI_PROMPT_CMD="rofi -dmenu -p trans -theme-str 'listview {lines: 0;}'"
[ -n "$TRANS_CMD" ] || TRANS_CMD="trans -no-ansi en:uk '%s'"

while true; do
	inp="$(eval "$ROFI_PROMPT_CMD" 2>/dev/null)"
	[ -z "$inp" ] && exit 0

	# shellcheck disable=SC2059
	TRANS_CMD_="$(printf "$TRANS_CMD" "$inp")"
	rofi -e "$(eval "$TRANS_CMD_")"
done

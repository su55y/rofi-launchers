#!/bin/sh
# shellcheck disable=SC2059
# SC2059: Don't use variables in the printf format string. Use printf "..%s.." "$foo".

[ -n "$ROFI_PROMPT_CMD" ] || ROFI_PROMPT_CMD="rofi -dmenu -p trans -theme-str 'listview {lines: 0;}'"
[ -n "$TRANS_CMD" ] || TRANS_CMD="trans -no-ansi en:uk '%s'"
[ -n "$ROFI_RESULT_CMD" ] || ROFI_RESULT_CMD="rofi -e '%s'"

translate_() {
	TRANS_CMD_="$(printf "$TRANS_CMD" "$1")"
	result="$(eval "$TRANS_CMD_")"

	ROFI_RESULT_CMD_="$(printf "$ROFI_RESULT_CMD" "$result")"
	eval "$ROFI_RESULT_CMD_"
}

while true; do
	inp="$(eval "$ROFI_PROMPT_CMD" 2>/dev/null)"
	[ -z "$inp" ] && exit 0

	translate_ "$inp"
done

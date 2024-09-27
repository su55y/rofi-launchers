#!/bin/sh
# shellcheck disable=SC2059
# SC2059: Don't use variables in the printf format string. Use printf "..%s.." "$foo".

[ -n "$ROFI_PROMPT_CMD" ] || ROFI_PROMPT_CMD="rofi -dmenu -p trans -theme-str 'listview {lines: 0;}'"
[ -n "$TRANS_CMD" ] || TRANS_CMD="trans -no-ansi en:uk '%s'"
[ -n "$ROFI_RESULT_CMD" ] || ROFI_RESULT_CMD="rofi -e '%s'"

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/rofi_translate"
[ -d "$CACHE_DIR" ] || {
	mkdir -p "$CACHE_DIR" || printf "\000message\037error: can't mkdir -p %s\n \000nonselectable\037true\n" "$CACHE_DIR"
}

translate_() {
	results_cache_path="${CACHE_DIR}/$(echo "$1" | base64)"
	if [ -f "$results_cache_path" ]; then
		result="$(cat "$results_cache_path")"
	else
		TRANS_CMD_="$(printf "$TRANS_CMD" "$1")"
		result="$(eval "$TRANS_CMD_")"
		echo "$result" >"$results_cache_path"
	fi

	ROFI_RESULT_CMD_="$(printf "$ROFI_RESULT_CMD" "$result")"
	eval "$ROFI_RESULT_CMD_"
}

while true; do
	inp="$(eval "$ROFI_PROMPT_CMD" 2>/dev/null)"
	[ -z "$inp" ] && exit 0

	translate_ "$inp"
done

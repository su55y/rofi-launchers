#!/bin/sh
# shellcheck disable=SC2059
# SC2059: Don't use variables in the printf format string. Use printf "..%s.." "$foo".

ROFI_PROMPT_="trans"
[ -n "$ROFI_TRANSLATE_CMD" ] || ROFI_TRANSLATE_CMD="trans -no-ansi en:uk '%s'"
TRANS_LANG_="$(echo "$ROFI_TRANSLATE_CMD" | grep -oP '([a-z]{2}\:[a-z]{2})')"
[ -n "$TRANS_LANG_" ] && ROFI_PROMPT_="($TRANS_LANG_)"
[ -n "$ROFI_RESULT_CMD" ] || ROFI_RESULT_CMD="rofi -e '%s'"
[ -n "$ROFI_PROMPT_CMD" ] || ROFI_PROMPT_CMD="rofi -dmenu -p '$ROFI_PROMPT_' -theme-str 'listview {lines: 0;}' -kb-remove-char-back 'BackSpace,Shift+BackSpace' -kb-custom-1 'Ctrl+h'"

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/rofi_translate"
[ -d "$CACHE_DIR" ] || {
    mkdir -p "$CACHE_DIR" || printf "\000message\037error: can't mkdir -p %s\n \000nonselectable\037true\n" "$CACHE_DIR"
}

translate_() {
    results_cache_path="${CACHE_DIR}/$(echo "$1" | base64)"
    if [ -f "$results_cache_path" ] && [ "$(tr -d '\n' <"$results_cache_path")" != "" ]; then
        result="$(cat "$results_cache_path")"
    else
        trans_cmd="$(printf "$ROFI_TRANSLATE_CMD" "$1")"
        result="$(eval "$trans_cmd")"
        echo "$result" >"$results_cache_path"
    fi

    ROFI_RESULT_CMD_="$(printf "$ROFI_RESULT_CMD" "$result")"
    eval "$ROFI_RESULT_CMD_"
}

while true; do
    inp="$(eval "$ROFI_PROMPT_CMD" 2>/dev/null)"
    if [ $? -eq 10 ]; then
        translate_ "$(find "$CACHE_DIR" -type f -printf '%f\n' | base64 -d | rofi -dmenu)"
    elif [ -n "$inp" ]; then
        translate_ "$inp"
    else
        exit 0
    fi
done

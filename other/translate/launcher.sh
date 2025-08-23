#!/bin/sh
# shellcheck disable=SC2059
# SC2059: Don't use variables in the printf format string. Use printf "..%s.." "$foo".

ROFI_PROMPT_=trans
: "${ROFI_TRANSLATE_CMD:=trans -j -no-ansi en:uk}" # -j are required
TRANS_LANG_="$(echo "$ROFI_TRANSLATE_CMD" | grep -oP '([a-z]{2}\:[a-z]{2})')"
[ -n "$TRANS_LANG_" ] && ROFI_PROMPT_="($TRANS_LANG_)"
: "${ROFI_RESULT_CMD:=rofi -normal-window -theme-str 'error-message {padding: 25px;\}'}"
: "${ROFI_PROMPT_CMD:="rofi -dmenu -p '$ROFI_PROMPT_' -theme-str 'listview {lines: 0;}' -kb-remove-char-back BackSpace,Shift+BackSpace,ctrl+H -kb-custom-1 ctrl+h"}"

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/rofi_translate"
[ -d "$CACHE_DIR" ] || {
    mkdir -p "$CACHE_DIR" || printf "\000message\037error: can't mkdir -p %s\n \000nonselectable\037true\n" "$CACHE_DIR"
}

translate_() {
    results_cache_path="${CACHE_DIR}/$(echo "$1" | base64)"
    if [ -f "$results_cache_path" ] && [ "$(tr -d '\n' <"$results_cache_path")" != "" ]; then
        result="$(cat "$results_cache_path")"
    else
        result="$(sh -c "$ROFI_TRANSLATE_CMD -- $1")"
        echo "$result" >"$results_cache_path"
    fi

    sh -c "$ROFI_RESULT_CMD -e '$result'"
}

print_history_=0
while :; do
    [ $print_history_ -eq 0 ] && inp="$(sh -c "$ROFI_PROMPT_CMD" 2>/dev/null)"
    if [ $? -eq 10 ] || [ $print_history_ -eq 1 ]; then
        word="$(
            find "$CACHE_DIR" -type f -printf '%T@ %f\0' |
                sort -zk 1nr |
                sed -z 's/^[^ ]* //' |
                tr '\0' '\n' |
                base64 -d |
                grep -Eo '^.+$' |
                rofi -dmenu -p history -no-custom \
                    -kb-remove-char-forward Ctrl+x \
                    -kb-custom-2 Ctrl+d,Delete
        )"
        if [ $? -eq 11 ]; then
            print_history_=1
            results_cache_path="${CACHE_DIR}/$(echo "$word" | base64)"
            if [ -f "$results_cache_path" ] && [ "$(tr -d '\n' <"$results_cache_path")" != "" ]; then
                rm -f "$results_cache_path" ||
                    rofi -e "Error while deleting '$results_cache_path'"
            fi
        else
            [ -z "$word" ] && exit 0
            print_history_=0
            translate_ "$word"
        fi
    elif [ -n "$inp" ]; then
        translate_ "$inp"
    else
        exit 0
    fi
done

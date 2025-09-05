#!/bin/sh
# shellcheck disable=SC2059,SC2046

: "${SOURCE_LANG=en}"
: "${TARGET_LANG=uk}"

TRANS_CMD="trans -j -no-ansi $SOURCE_LANG:$TARGET_LANG" # -j are required
TRANS_LANG="$SOURCE_LANG:$TARGET_LANG"
: "${ROFI_RESULT_CMD:=rofi -normal-window -theme-str 'error-message {padding: 25px;\}'}"
: "${ROFI_PROMPT_CMD:="rofi -dmenu -p '$TRANS_LANG' -theme-str 'listview {lines: 0;}' -kb-remove-char-back BackSpace,Shift+BackSpace,ctrl+H -kb-custom-1 ctrl+h"}"

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/rofi_translate/$TRANS_LANG"
[ -d "$CACHE_DIR" ] || {
    mkdir -p "$CACHE_DIR" || printf "\000message\037error: can't mkdir -p %s\n \000nonselectable\037true\n" "$CACHE_DIR"
}

translate_() {
    results_cache_path="${CACHE_DIR}/$(echo "$1" | base64 | tr '+/' '-_')"
    if [ -f "$results_cache_path" ] && [ "$(tr -d '\n' <"$results_cache_path")" != "" ]; then
        result="$(cat "$results_cache_path")"
    else
        result="$(sh -c "$TRANS_CMD -- $1")"
        echo "$result" >"$results_cache_path"
    fi

    sh -c "$ROFI_RESULT_CMD -e '$result'"
}

print_history_=0
while :; do
    [ $print_history_ -eq 0 ] && inp="$(sh -c "$ROFI_PROMPT_CMD" 2>/dev/null)"
    if [ $? -eq 10 ] || [ $print_history_ -eq 1 ]; then
        if [ $(find "$CACHE_DIR" -type f | wc -l) -eq 0 ]; then
            print_history_=0
            rofi -e "History for $TRANS_LANG is empty"
            continue
        fi
        word="$(
            find "$CACHE_DIR" -type f -printf '%T@ %f\0' |
                sort -zk 1nr |
                sed -z 's/^[^ ]* //' |
                tr '\0' '\n' |
                tr '\-_' '+/' |
                base64 -d |
                grep -Eo '^.+$' |
                rofi -dmenu -p history -no-custom \
                    -kb-remove-char-forward ctrl+d \
                    -kb-custom-2 ctrl+x,Delete
        )"
        case $? in
        0)
            [ -z "$word" ] && exit 0
            print_history_=1
            translate_ "$word"
            ;;
        1)
            print_history_=0
            continue
            ;;
        11)
            print_history_=1
            results_cache_path="${CACHE_DIR}/$(echo "$word" | base64 | tr '+/' '-_')"
            if [ -f "$results_cache_path" ] && [ "$(tr -d '\n' <"$results_cache_path")" != "" ]; then
                rm -f "$results_cache_path" ||
                    rofi -e "Error while deleting '$results_cache_path'"
            fi
            ;;
        *) exit 0 ;;
        esac
    elif [ -n "$inp" ]; then
        translate_ "$inp"
    else
        exit 0
    fi
done

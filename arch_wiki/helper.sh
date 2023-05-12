#!/bin/sh

WIKIDIR="/usr/share/doc/arch-wiki/html/en/"
BROWSER="${BROWSER:-qutebrowser}"

printf "\000use-hot-keys\037true\n"

print_list() {
    find "$WIKIDIR" -iname '*.html' -printf '%f %p\n' |\
        awk '{
            gsub("_"," ",$1);
            sub(/\.html$/,"",$1);
            printf "%s\000info\037%s\n", $1, $NF}' |\
        sort -g
}

case $ROFI_RETV in
    0) print_list ;;
    1)
        [ -f "$ROFI_INFO" ] || {
            notify-send -a "arch wiki" "can't find '$ROFI_INFO'"
            exit 1
        }
        setsid -f "$BROWSER" "$ROFI_INFO" >/dev/null 2>&1
    ;;
    10) printf '%s' "$ROFI_INFO" | xsel -i -b ;;
esac

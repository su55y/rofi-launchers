#!/bin/sh

WIKIDIR="/usr/share/doc/arch-wiki/html/en/"

printf "\000use-hot-keys\037true\n"

err_msg() {
  [ -n "$1" ] && printf '\000message\037%s\n \000nonselectable\ntrue\n' "$1"
  exit 1
}

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
            notify-send -i "rofi" -a "arch wiki" "can't find '$ROFI_INFO'"
            exit 1
        }
        setsid -f "$BROWSER" "$ROFI_INFO" >/dev/null 2>&1
    ;;
    10) printf '%s' "$ROFI_INFO" | xsel -i -b ;;
    11)
        # TODO: use caching
        [ -f "$ROFI_INFO" ] || err_msg "ERROR: '$ROFI_INFO' not found"
        clean_article="$(basename "$ROFI_INFO")"
        clean_article="${clean_article%.*}"
        clean_article_path="/tmp/${clean_article}.html"
        pdf_path="/tmp/${clean_article}.pdf"
        rdrview -T title,body -H -u "$1" <"$ROFI_INFO" >"$clean_article_path" 2>/dev/null || err_msg "readability conversion error"
        pandoc "$clean_article_path" -t ms -o "$pdf_path" 2>/dev/null || err_msg "pandoc error"
        setsid -f zathura "$pdf_path" >/dev/null 2>&1 || err_msg "can't open in zathura"
        printf '\000message\037open %s in zathura\n' "$1"
        print_list
      ;;
esac

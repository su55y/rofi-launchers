#!/bin/sh

WIKIDIR=/usr/share/doc/arch-wiki/html/en/
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/arch_wiki"

printf '\000use-hot-keys\037true\n'
printf '\000keep-filter\037true\n'
printf '\000keep-selection\037true\n'

err_msg() {
    [ -n "$1" ] && printf '\000message\037%s\n \000nonselectable\ntrue\n' "$1"
    exit 1
}

print_list() {
    find "$WIKIDIR" -iname '*.html' -printf '%f %p\n' |
        awk '{
            gsub("_"," ",$1);
            sub(/\.html$/,"",$1);
            printf "%s\000info\037%s\n", $1, $NF}' |
        sort -g
}

case $ROFI_RETV in
0) print_list ;;
1)
    [ -f "$ROFI_INFO" ] || {
        notify-send -i rofi -a 'arch wiki' "can't find '$ROFI_INFO'"
        exit 1
    }
    setsid -f "$BROWSER" "$ROFI_INFO" >/dev/null 2>&1
    print_list
    ;;
10)
    printf '%s' "$ROFI_INFO" | xsel -i -b
    printf '\000message\037%s copied to clipboard\n' "$ROFI_INFO"
    print_list
    ;;
11)
    [ -d "$CACHE_DIR" ] || mkdir -p "$CACHE_DIR" >/dev/null 2>&1
    article_name="$(basename "$ROFI_INFO")"
    article_name="${article_name%.*}"
    pdf_path="$CACHE_DIR/${article_name}.pdf"
    if [ ! -f "$pdf_path" ]; then
        [ -f "$ROFI_INFO" ] || err_msg "ERROR: '$ROFI_INFO' not found"
        clean_article_path="${TEMPDIR:-/tmp}/${article_name}.html"
        rdrview -T title,body -H -u "$1" <"$ROFI_INFO" >"$clean_article_path" 2>/dev/null || err_msg 'readability conversion error'
        pandoc "$clean_article_path" --pdf-engine=weasyprint -o "$pdf_path" 2>/dev/null || err_msg 'pandoc error'
        # pandoc "$clean_article_path" -t ms -o "$pdf_path" 2>/dev/null || err_msg 'pandoc error'
    fi
    setsid -f zathura "$pdf_path" >/dev/null 2>&1 || err_msg "can't open in zathura"
    print_list
    ;;
esac

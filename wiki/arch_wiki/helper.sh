#!/bin/sh

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/arch_wiki"

printf '\000use-hot-keys\037true\n'
printf '\000keep-filter\037true\n'
printf '\000keep-selection\037true\n'

err_msg() {
    [ -n "$1" ] && printf '\000message\037%s\n \000nonselectable\ntrue\n' "$1"
    exit 1
}

copy_() {
    printf '%s' "$1" | xsel -i -b
    printf '\000message\037%s copied to clipboard\n' "$1"
}

case $ROFI_RETV in
1 | 11) [ -f "$ROFI_INFO" ] || err_msg "'$ROFI_INFO' not found" ;;
esac

case $ROFI_RETV in
# select line
1) setsid -f "$BROWSER" "$ROFI_INFO" >/dev/null 2>&1 ;;
# kb-custom-1 (ctrl-c) - copy filepath to clipboard
10) copy_ "$ROFI_INFO" ;;
# kb-custom-2 (ctrl-space) - open file as pdf in zathura
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
    setsid -f zathura "$pdf_path" >/dev/null 2>&1 || err_msg "can't open '$pdf_path' in zathura"
    ;;
esac

print_list() {
    find "$WIKIDIR" -iname '*.html' -printf '%f %p\n' |
        awk '{
            gsub("_"," ",$1);
            sub(/\.html$/,"",$1);
            printf "%s\000info\037%s\n", $1, $NF}' |
        sort -g
}

print_list

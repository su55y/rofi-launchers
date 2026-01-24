#!/bin/sh

TERM_PAGER='nvim +Man! -u NORC +color\ retrobox'
: "${HL_ROW_FMT:="<b>%s</b> <span weight='bold' color='red'>p</span>"}"

[ -n "$ROFI_MAN_VIEWER_CACHE" ] ||
    ROFI_MAN_VIEWER_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/rofi_man_viewer"
if [ ! -d "$ROFI_MAN_VIEWER_CACHE" ]; then
    mkdir -p "$ROFI_MAN_VIEWER_CACHE" 2>&1 || exit 1
fi

printf '\000use-hot-keys\037true\n'
printf '\000markup-rows\037true\n'

print_manpages() {
    man -k . | awk '$1 !~ /[_:]/ {print $1}' | sort | while read -r manpage; do
        row="$manpage"
        if [ -f "$ROFI_MAN_VIEWER_CACHE/$manpage.pdf" ]; then
            row="$(printf "$HL_ROW_FMT" "$manpage")"
        fi
        printf '%s\000info\037%s\n' "$row" "$manpage"
    done
}

open_as_pdf() {
    [ -n "$1" ] || exit 1
    filepath="$ROFI_MAN_VIEWER_CACHE/$1.pdf"
    if [ ! -f "$filepath" ]; then
        man -Tpdf "$1" >"$filepath" 2>/dev/null || exit 1
    fi
    setsid -f zathura "$filepath" >/dev/null 2>&1
}

open_in_terminal() {
    [ -n "$1" ] || exit 0
    setsid -f "$TERMINAL" -e sh -c "man --pager='$TERM_PAGER' $1" >/dev/null 2>&1
}

case $ROFI_RETV in
# print manpages on start
0) print_manpages ;;
# select line
1) open_as_pdf "$ROFI_INFO" ;;
# ctrl+space - open selected in terminal
10) open_in_terminal "$ROFI_INFO" ;;
esac

#!/bin/sh

banner() {
    man -k . |
        awk '! /[_:]/{print $1}' | sort
}

ROFI_MAN_VIEWER_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/rofi_man_viewer"
if [ ! -d "$ROFI_MAN_VIEWER_CACHE" ]; then
    mkdir -p "$ROFI_MAN_VIEWER_CACHE" || exit 1
fi

printf "\000use-hot-keys\037true\n"

case $ROFI_RETV in
# print banner on start
0) banner ;;
# select line
1)
    [ -n "$1" ] || exit 0
    filepath="$ROFI_MAN_VIEWER_CACHE/$1.pdf"
    if [ ! -f "$filepath" ]; then
        man -Tpdf "$1" >"$filepath" 2>/dev/null || exit 1
    fi
    setsid -f zathura "$filepath" >/dev/null 2>&1
    ;;
# ctrl+space - open selected in terminal
10)
    [ -n "$1" ] || exit 0
    setsid -f "$TERMINAL" -e bash -c "MANPAGER='nvim +Man!' man $1" >/dev/null 2>&1
    ;;
esac

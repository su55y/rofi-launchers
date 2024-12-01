#!/bin/sh

banner() {
    man -k . |
        awk '! /[_:]/{print $1}' | sort
}

printf "\000use-hot-keys\037true\n"

case $ROFI_RETV in
# print banner on start
0) banner ;;
# select line
1)
    [ -n "$1" ] || exit 0
    if [ -f "/tmp/$1.pdf" ]; then
        setsid -f zathura "/tmp/$1.pdf" >/dev/null 2>&1
    else
        man -Tpdf "$1" >"/tmp/$1.pdf" && setsid -f zathura "/tmp/$1.pdf" >/dev/null 2>&1
    fi
    ;;
# ctrl+space - open selected in terminal
10)
    [ -n "$1" ] || exit 0
    setsid -f "$TERMINAL" -e bash -c "MANPAGER='nvim +Man!' man $1" >/dev/null 2>&1
    ;;
esac

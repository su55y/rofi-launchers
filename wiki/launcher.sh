#!/bin/sh

SCRIPTPATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1 ; pwd -P)"

[ -f "$SCRIPTPATH/helper" ] || {
    notify-send "rofi" "wiki helper executable not found"
    exit 1
}

[ -f "$SCRIPTPATH/theme.rasi" ] || {
    notify-send "rofi" "theme not found"
    exit 1
}

# wiki logo:  
logo="$(printf "\Uf266")"

rofi -i -show "$logo" \
    -modi "$logo:$SCRIPTPATH/helper.sh" \
    -normal-window \
    -kb-custom-1 "Ctrl+c" \
    -kb-custom-2 "Ctrl+s" \
    -theme "$SCRIPTPATH/theme.rasi"

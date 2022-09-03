#!/bin/sh

SCRIPTPATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1 ; pwd -P)"
[ ! -f "$SCRIPTPATH/helper" ] && {
    notify-send "rofi" "wiki helper executable not found"
    exit 1
}

# wiki logo:  
logo="$(printf "\Uf266")"

rofi  -show "$logo" \
-modi "$logo:$SCRIPTPATH/helper.sh" \
-i \
-normal-window \
-kb-custom-1 "Ctrl+c"

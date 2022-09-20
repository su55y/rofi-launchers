#!/bin/sh

# inspired by https://github.com/sayan01/scripts/blob/master/yt 

SCRIPTPATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1 ; pwd -P)"
CACHE_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}"
C_DIR="$CACHE_ROOT/yt_rofi"

[ ! -d "$C_DIR" ] && {
    mkdir -p "$C_DIR" || exit 1
}

# activate hotkeys
printf "\000use-hot-keys\037true\n"

case $ROFI_RETV in
    # select line
    1)
        [ "$(printf '%s' "$ROFI_INFO" |\
            grep -oP "^[0-9a-zA-Z_\-]{11}$")" = "$ROFI_INFO" ] &&\
            setsid -f mpv "https://youtu.be/$ROFI_INFO" >/dev/null 2>&1
    ;;
    # execute custom input
    2)
        [ -n "$1" ] && query="$(printf '%s' "$1" | sed 's/\s/+/g')"
        response="$(curl -s "https://www.youtube.com/results?search_query=$query" |\
            sed 's|\\.||g')"

        printf '%s' "$response" | grep -q "script" || {
            echo "unable to fetch yt"
            exit 1
        }

        vgrep='"videoRenderer":{"videoId":"\K.{11}".+?"text":".+?[^\\](?=")'
        THUMB_URLS=
        IFS=$(printf '\t')
        for line in $(printf '%s' "$response" |\
            grep -oP "$vgrep" |\
            awk -F\" '{printf "%s %s %s\t",$9,$NF,$1}'); do
            THUMB_URLS="$THUMB_URLS ${line%%\?*}" 
            TITLE_AND_ID="${line#* }"
            # uncomment if you don't want to use the go downloader
            # [ ! -f "$C_DIR/${TITLE_AND_ID##* }" ] && curl -s "${line%%\?*}" -o "$C_DIR/${TITLE_AND_ID##* }"
            printf '%s\000info\037%s\037icon\037%s\n'\
                "${TITLE_AND_ID% *}" "${TITLE_AND_ID##* }" "$C_DIR/${TITLE_AND_ID##* }"
        done

        # download all previews in parallel
        "$SCRIPTPATH/downloader" -o "$C_DIR" -l "$THUMB_URLS"
    ;;
    # kb-custom-1 - clear list rows
    10) printf "\000urgent\037true\n \000nonselectable\037true";;
esac

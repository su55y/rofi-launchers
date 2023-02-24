#!/usr/bin/env bash

# inspired by https://github.com/sayan01/scripts/blob/master/yt 

SCRIPTPATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1 ; pwd -P)"
CACHE_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}"
C_DIR="$CACHE_ROOT/yt_rofi"

[[ ! -d "$C_DIR" ]] && {
    mkdir -p "$C_DIR" || exit 1
}

# activate hotkeys
echo -en "\x00use-hot-keys\x1ftrue\n"

case $ROFI_RETV in
    # select line
    1)
        [[ "${ROFI_INFO}" =~ ^[0-9a-zA-Z_\-]{11}$ ]] && {
            notify-send -i "mpv" -a "mpv" "$(printf "choosed video:\nhttps://youtu.be/%s" "${ROFI_INFO}")"
            coproc { mpv "https://youtu.be/${ROFI_INFO}" >/dev/null 2>&1; }
            exec 1>&-
            exit;
        } && exit 0
    ;;
    # execute custom input
    2)
        [[ -n "$1" ]] && query="$(echo -n "$1" | sed 's/\s/+/g')"
        response="$(curl -s "https://www.youtube.com/results?search_query=$query" |\
            sed 's|\\.||g')"
        if ! grep -q "script" <<< "$response"; then echo "unable to fetch yt"; exit 1; fi

        vgrep='"videoRenderer":{"videoId":"\K.{11}".+?"text":".+?[^\\](?=")'
        i=0
        id_arr=()
        title_arr=()
        thumb_arr=()

        while IFS=  read -r line; do 
            ((i+=1))
            case $i in
                1) id_arr+=("$line") ;;
                2) thumb_arr+=("${line%%\?*}") ;;
                3)
                    title_arr+=("$line")
                    i=0
                ;;
            esac
        done <<< "$(grep -oP "$vgrep" <<< "$response" | awk -F\" '{printf "%s\n%s\n%s\n",$1,$9,$NF}')"

        # download all previews in parallel
        "$SCRIPTPATH/downloader" -o "$C_DIR" -l "${thumb_arr[*]}"

        for i in "${!id_arr[@]}"; do
            # uncomment if you don't want to use the go downloader
            # [[ ! -f "$C_DIR/${id_arr[i]}" ]] && curl -s "${thumb_arr[i]}" -o "$C_DIR/${id_arr[i]}"
            echo -en "${title_arr[i]}\x00icon\x1f$C_DIR/${id_arr[i]}\x1finfo\x1f${id_arr[i]}\n"
        done
    ;;
    # kb-custom-1 - clear list rows
    10) echo -en "\x00urgent\x1ftrue\n \x00nonselectable\x1ftrue" ;;
esac

# potential TODO
# print history at the beginning or on kb-custom-2 click
# [[ "${ROFI_RETV}" -eq 0 || "${ROFI_RETV}" -eq 11 ]] && banner

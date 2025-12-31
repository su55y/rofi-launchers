#!/bin/sh

# inspired by https://github.com/sayan01/scripts/blob/master/yt

SCRIPTPATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
    pwd -P
)"
. "${SCRIPTPATH}/../mpv_rofi_utils"

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/mpv_rofi_yt_search"
THUMBNAILS_DIR="${CACHE_DIR}/thumbnails"
RESULTS_DIR="${CACHE_DIR}/results"
mkdir -p "$THUMBNAILS_DIR" || _err_msg "can't mkdir -p $THUMBNAILS_DIR"
mkdir -p "$RESULTS_DIR" || _err_msg "can't mkdir -p $RESULTS_DIR"

printf '\000use-hot-keys\037true\n'
case $ROFI_RETV in
0 | 10 | 14) ;;
*)
    printf '\000keep-selection\037true\n'
    printf '\000keep-filter\037true\n'
    ;;
esac

validate_id() {
    printf '%s' "$1" | grep -soP '^[-_0-9a-zA-Z]{11}$' >/dev/null 2>&1 ||
        _err_msg "invalid id '$1'"
}

play() {
    validate_id "$1"
    notify-send -i rofi -a 'youtube search' "$2"
    _play "https://youtu.be/$1"
}

print_from_cache() {
    [ -f "$1" ] || _err_msg 'no recent results found in cache'
    _msg '[Cache]'
    printf '\000data\037%s\n' "$1"
    awk '{gsub(/\\000/, "\0"); gsub(/\\037/, "\037"); print}' "$1"
}

handle_query() {
    [ -n "$1" ] || exit 1
    query="$1"
    results_cache="$RESULTS_DIR/$(echo "$query" | base64)"
    if [ -f "$results_cache" ]; then
        case $2 in
        R) rm -f "$results_cache" >/dev/null 2>&1 && _msg ' ' ;;
        *)
            print_from_cache "$results_cache"
            return
            ;;
        esac
    fi

    response="$(curl --get -s --data-urlencode "search_query=$query" https://www.youtube.com/results |
        sed 's|\\.||g')"

    printf '%s' "$response" | grep -q script || _err_msg 'unable to grep results'

    vgrep='"videoRenderer":{"videoId":"\K.{11}".+?"text":".+?[^\\](?=")'
    THUMB_URLS=
    IFS=$(printf '\t')
    for line in $(printf '%s' "$response" |
        grep -oP "$vgrep" |
        awk -F\" '{printf "%s %s %s\t",$9,$NF,$1}'); do

        THUMB_URLS="$THUMB_URLS ${line%%\?*}"
        TITLE_AND_ID="${line#* }"

        printf '%s\000info\037%s\037icon\037%s\n' \
            "${TITLE_AND_ID% *}" "${TITLE_AND_ID##* }" "$THUMBNAILS_DIR/${TITLE_AND_ID##* }" |
            tee -a "$results_cache"
    done
    printf '\000data\037%s\n' "$results_cache"

    "$SCRIPTPATH/downloader" -o="$THUMBNAILS_DIR" -l="$THUMB_URLS"
}

print_history() {
    case $(find "$RESULTS_DIR" -maxdepth 1 -type f | wc -l) in
    0) printf '\000message\037history is empty\n\000urgent\0370\n \000nonselectable\037true\n' ;;
    *)
        printf '\000message\037history\n\000data\037_history\n'
        find "$RESULTS_DIR" -type f -printf '%T@ %f\n' | sort -k 1nr | sed 's/^[^ ]* //' | base64 -d | xargs -I {} printf '%s\n' "{}"
        ;;
    esac
}

case $ROFI_RETV in
# play selected and exit
1)
    if [ "$ROFI_DATA" = _history ]; then
        handle_query "$@"
    else
        play "$ROFI_INFO" "$1"
    fi
    ;;
# handle search query
2) handle_query "$@" ;;
# kb-custom-1 - clear rows
10) printf '\000message\037\n\000urgent\0370\n \000nonselectable\037true\n' ;;
# kb-custom-2 - append selected to playlist and print last results
11)
    _append "https://youtu.be/$ROFI_INFO"
    print_from_cache "$ROFI_DATA"
    ;;
# kb-custom-3 - play selected and print last results
12)
    play "$ROFI_INFO" "$1"
    print_from_cache "$ROFI_DATA"
    ;;
# kb-custom-4 - downlaad video
13)
    validate_id "$ROFI_INFO"
    if [ "$ROFI_DATA" != _history ]; then
        _download_vid "https://youtu.be/$ROFI_INFO" "$1"
        print_from_cache "$ROFI_DATA"
    fi
    ;;
# kb-custom-5 - print search history
14) print_history ;;
# kb-custom-6 - open in BROWSER
15)
    validate_id "$ROFI_INFO"
    setsid -f "$BROWSER" "https://youtu.be/$ROFI_INFO" >/dev/null 2>&1
    [ "$ROFI_DATA" != _history ] && print_from_cache "$ROFI_DATA"
    ;;
# kb-custom-7 - refresh cached result
16)
    [ "$ROFI_DATA" != _history ] &&
        handle_query "$(basename "$ROFI_DATA" | base64 -d)" R
    ;;
# kb-custom-8 - delete history item
17)
    [ "$ROFI_DATA" != _history ] && exit 1
    results_cache="$RESULTS_DIR/$(echo "$1" | base64)"
    if [ ! -f "$results_cache" ]; then
        printf '\000message\037Not found results for %s\n \000nonselectable\037true\n' "$1"
        print_history
        exit 0
    fi
    for thumbnail in $(grep -aoP '\037\K\/.+$' "$results_cache"); do
        [ -f "$thumbnail" ] || continue
        echo "$thumbnail" | grep -qP "^${THUMBNAILS_DIR}\/[-_0-9a-zA-Z]{11}$" 2>&1 || continue
        rm -f "$thumbnail" >/dev/null 2>&1 || exit 1
    done
    rm -f "$results_cache" >/dev/null 2>&1 || exit 1
    print_history
    ;;
esac

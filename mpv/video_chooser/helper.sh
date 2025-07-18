#!/bin/sh

SCRIPTPATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
    pwd -P
)"
. "${SCRIPTPATH}/../mpv_rofi_utils"

[ -f "${SCRIPTPATH}/printer" ] || _err_msg "$SCRIPTPATH/printer not found"

[ -n "$VIDEO_CHOOSER_ROOTDIR" ] || VIDEO_CHOOSER_ROOTDIR="${HOME}/Videos"
[ -n "$VIDEO_CHOOSER_CACHEFILE" ] || VIDEO_CHOOSER_CACHEFILE="${TEMPDIR:-/tmp}/video_chooser.tmp"

printf "\000use-hot-keys\037true\n"
printf "\000markup-rows\037true\n"
printf "\000keep-selection\037true\n"
printf "\000keep-filter\037true\n"

case $ROFI_RETV in
# select line
1)
    [ -f "$ROFI_INFO" ] && _play "$ROFI_INFO"
    exit 0
    ;;
# kb-custom-1 (Ctrl+a) - append to playlist
10) [ -f "$ROFI_INFO" ] && _append "$ROFI_INFO" ;;
# kb-custom-2 (Ctrl+space) - play
11) [ -f "$ROFI_INFO" ] && _play "$ROFI_INFO" ;;
# kb-custom-3 (Ctrl+r) - remove cache
12) rm -f "$VIDEO_CHOOSER_CACHEFILE" >/dev/null 2>&1 ;;
esac

if [ -f "$VIDEO_CHOOSER_CACHEFILE" ]; then
    printf '\000message\037[Cache]\n'
    awk '{
        gsub(/\\000/, "\0");
        gsub(/\\037/, "\037");
        gsub(/\\n/, "\n");
        print
    }' "$VIDEO_CHOOSER_CACHEFILE"
else
    printf '\000message\037\n'
    "${SCRIPTPATH}/printer" "$VIDEO_CHOOSER_ROOTDIR" | tee "$VIDEO_CHOOSER_CACHEFILE"
fi

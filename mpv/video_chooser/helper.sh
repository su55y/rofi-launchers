#!/bin/bash

# shellcheck disable=SC2086
# Double quote to prevent globbing and word splitting. [SC2086]

: "${VIDEO_CHOOSER_ROOTDIR:=$HOME/Videos}"
: "${VIDEO_CHOOSER_CACHEFILE:=${TEMPDIR:-/tmp}/video_chooser.tmp}"

# shellcheck source=../common_utils
. "$UTILS_PATH"

printf '\000use-hot-keys\037true\n'
printf '\000markup-rows\037true\n'
printf '\000keep-selection\037true\n'
printf '\000keep-filter\037true\n'

case $ROFI_RETV in
1 | 10 | 11) [ -f "$ROFI_INFO" ] || _err_msg "File not found: $ROFI_INFO" ;;
esac

case $ROFI_RETV in
# select line - play | kb-custom-2 (ctrl+space) - play without exit
1 | 11)
    _play "$ROFI_INFO"
    [ $ROFI_RETV -eq 1 ] && exit 0
    ;;
# kb-custom-1 (ctrl+a) - append to playlist
10) _append "$ROFI_INFO" ;;
# kb-custom-3 (ctrl+r) - remove cache
12) rm -f "$VIDEO_CHOOSER_CACHEFILE" >/dev/null 2>&1 ;;
# kb-custom-4 (ctrl+o) - open parent directory in terminal
13) setsid -f "$TERMINAL" -e sh -c "cd \"$(dirname "$ROFI_INFO")\" && exec \$SHELL" >/dev/null 2>&1 ;;
# kb-custom-5 (ctrl+j) - play random video
14) setsid -f mpv "$(shuf -n1 "$VIDEO_CHOOSER_CACHEFILE" | grep -aoP 'info\037\K[^\037]+')" >/dev/null 2>&1 ;;
# kb-custom-6 (ctrl+k) - append to playlist random video
15) _append "$(shuf -n1 "$VIDEO_CHOOSER_CACHEFILE" | grep -aoP 'info\037\K[^\037]+')" ;;
esac

if [ -f "$VIDEO_CHOOSER_CACHEFILE" ]; then
    _msg '[Cache]'
    awk '{
        gsub(/\\000/, "\0");
        gsub(/\\037/, "\037");
        gsub(/\\n/, "\n");
        print
    }' "$VIDEO_CHOOSER_CACHEFILE"
elif command -v fd >/dev/null 2>&1; then
    # Leave VIDEO_CHOOSER_ROOTDIR unquoted to allow multiple dirs
    fd . $VIDEO_CHOOSER_ROOTDIR -at f -0 \
        -e mp4 -e mkv -e webm -e avi -e ogv \
        -e mpg -e mpeg -e 3gp -e mov -e wmv \
        -e flv -e vob -e mts -e m2ts -e ts \
        -e swf -e rm -e rmvb -e y4m -e m4v | perl -ne '
    BEGIN { $/ = "\0" }
    chomp($p = $_);
    ($d, $n) = $p =~ m|([^/]+)/([^/]+)$|;
    if (!$n) { $n = $p; $d = "."; }
    $n =~ s/\.[^.]+$//;
    $n =~ s/&/&amp;/g;
    $d =~ s/&/&amp;/g;
    print "<b>$n</b>\r$d\000info\037$p\n"
' | tee "$VIDEO_CHOOSER_CACHEFILE"
else
    printf '\000message\037\n'
    # Leave VIDEO_CHOOSER_ROOTDIR unquoted to allow multiple dirs
    "$GO_HELPER" $VIDEO_CHOOSER_ROOTDIR | tee "$VIDEO_CHOOSER_CACHEFILE"
fi

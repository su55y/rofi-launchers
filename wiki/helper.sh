#!/bin/sh

SCRIPTPATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1 ; pwd -P)"
[ ! -f "$SCRIPTPATH/helper" ] &&\
    printf "go helper not found\000nonselectable\037true\n" &&\
    exit 0

# activate hotkeys
printf "\000use-hot-keys\037true\n"

banner() {
printf "ua wiki\000icon\037wikipedia\037info\037https://uk.wikipedia.org/\nen wiki\000icon\037wikipedia\037info\037https://en.wikipedia.org/\nua search\000icon\037ua_square\037info\037https://uk.wikipedia.org/w/index.php?search\nen search\000icon\037uk_square\037info\037https://en.wikipedia.org/wiki/Special:Search"
}

case $ROFI_RETV in
    # print banner on start and kb-custom-1 press
    0|10) banner;;
    # select line
    1)
        [ "$(printf '%s' "$ROFI_INFO" |\
            grep -oP "^https?:\/\/(en|uk)\.wikipedia\.org.+")" = "$ROFI_INFO" ] &&\
            setsid -f "$BROWSER" "$ROFI_INFO" >/dev/null 2>&1
    ;;
    # execute custom input
    2) [ -n "$1" ] && exec "$SCRIPTPATH/helper" "$1";;
    # kb-custom-2 - clear list rows
    11) printf "\000urgent\037true\n \000nonselectable\037true";;
esac

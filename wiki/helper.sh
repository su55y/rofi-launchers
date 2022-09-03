#!/usr/bin/env bash

SCRIPTPATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1 ; pwd -P)"
[[ ! -f "$SCRIPTPATH/ghelper" ]] && echo "go helper not found =(" && exit 0

# activate hotkeys
echo -en "\x00use-hot-keys\x1ftrue\n"

banner() {
    echo -en "ua wiki\x00icon\x1fwikipedia\x1finfo\x1fhttps://uk.wikipedia.org/\n"
    echo -en "en wiki\x00icon\x1fwikipedia\x1finfo\x1fhttps://en.wikipedia.org/\n"
    echo -en "ua search\x00icon\x1fua_square\x1finfo\x1fhttps://uk.wikipedia.org/w/index.php?search\n"
    echo -en "en search\x00icon\x1fuk_square\x1finfo\x1fhttps://en.wikipedia.org/wiki/Special:Search\n"
}

case $ROFI_RETV in
    # select line
    1)
        [[ "${ROFI_INFO}" =~ ^https\:\/\/(en|uk)\.wikipedia\.org.+$ ]] && {
            coproc { surf "${ROFI_INFO}"  >/dev/null 2>&1; }
            exec 1>&-
            exit;
        } && exit 0
    ;;
    # execute custom input
    2)
        [[ -n "$1" ]] && \
            res=$(exec "$SCRIPTPATH/helper" "$1")
        case $? in
            1) echo -en "$res\nNothing found :(\0nonselectable\x1ftrue\n" ;;
            0) echo -en "$res" ;;
        esac
    ;;
    # kb-custom-2 - clear list rows
    11) echo -en "\x00urgent\x1ftrue\n \x00nonselectable\x1ftrue" ;;
esac

# print banner on start and kb-custom-1 press
[[ "${ROFI_RETV}" -eq 0 || "${ROFI_RETV}" -eq 10 ]] && banner

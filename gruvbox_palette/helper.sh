#!/usr/bin/env bash

SCRIPTPATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1 ; pwd -P)"

# activate markup
echo -en "\x00markup-rows\x1ftrue\n"

palette() {
    [[ -f "$SCRIPTPATH/palette" ]] && {
        while IFS= read -r line; do
            color_name="${line% *}"
            color_hex="${line#* }"
            echo -e "<span background='$color_hex'>     </span> <span color='$color_hex'>$color_name</span>\x00info\x1f$color_hex"
        done < "$SCRIPTPATH/palette"
    }
}

case $ROFI_RETV in
    # select line
    1)
        [[ "${ROFI_INFO}" =~ ^#[0-9a-fA-F]{6}$ ]] && {
            echo -n "$ROFI_INFO" | xsel -ib
            exit 0
        }
        palette
    ;;
    # on start or custom
    *) 
        palette
    ;;
esac

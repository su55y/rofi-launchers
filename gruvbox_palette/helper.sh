#!/bin/sh

SCRIPTPATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1 ; pwd -P)"

# activate markup
printf "\000markup-rows\037true\n"

# print the palette
palette() {
    [ -f "$SCRIPTPATH/palette" ] && {
        while IFS= read -r line; do
            printf "<span background='%s'>\t</span> <span color='%s'>%s</span>\000info\037%s\n"\
                "${line#* }" "${line#* }" "${line% *}" "${line#* }"
        done < "$SCRIPTPATH/palette"
    }
}

case $ROFI_RETV in
    # select line
    1)
        [ "$(printf '%s' "$ROFI_INFO" |\
            grep -oP "^#[0-9a-fA-F]{6}$")" = "$ROFI_INFO" ] && {
            printf '%s' "$ROFI_INFO" | xsel -ib
            exit 0
        }
        palette
    ;;
    # on start or custom
    *) palette;;
esac

#!/bin/sh

printf '\000markup-rows\037true\n'
printf '\000use-hot-keys\037true\n'
printf '\000keep-selection\037true\n'

palette() {
    while IFS= read -r line; do
        printf "<span background='%s'>\t</span> <span color='%s'>%s</span>\000info\037%s\n" \
            "${line#* }" "${line#* }" "${line% *}" "${line#* }"
    done <"$PALETTE_PATH"
}

copy() {
    [ "$(printf '%s' "$1" |
        grep -oP "^#[0-9a-fA-F]{6}$")" = "$1" ] && {
        printf '%s' "$1" | xsel -ib
    }
}

case $ROFI_RETV in
1) copy "$ROFI_INFO" ;;
10)
    copy "$ROFI_INFO"
    printf '\000message\037%s\n' "$ROFI_INFO"
    palette
    ;;
*) palette ;;
esac

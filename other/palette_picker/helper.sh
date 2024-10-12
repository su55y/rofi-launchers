#!/bin/sh

SCRIPTPATH="$(
	cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
	pwd -P
)"

# activate markup
printf "\000markup-rows\037true\n"
# activate hotkeys
printf "\000use-hot-keys\037true\n"

# print the palette
palette() {
	[ -f "$SCRIPTPATH/palette" ] && {
		while IFS= read -r line; do
			printf "<span background='%s'>\t</span> <span color='%s'>%s</span>\000info\037%s\n" \
				"${line#* }" "${line#* }" "${line% *}" "${line#* }"
		done <"$SCRIPTPATH/palette"
	}
}

copy() {
	[ "$(printf '%s' "$1" |
		grep -oP "^#[0-9a-fA-F]{6}$")" = "$1" ] && {
		printf '%s' "$1" | xsel -ib
	}
}

case $ROFI_RETV in
# copy and exit
1) copy "$ROFI_INFO" ;;
# copy and print palette
10)
	copy "$ROFI_INFO"
	palette
	;;
*) palette ;;
esac

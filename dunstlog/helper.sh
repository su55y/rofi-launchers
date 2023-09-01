#!/bin/sh

SCRIPTPATH="$(
	cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
	pwd -P
)"
[ -f "$SCRIPTPATH/helper.py" ] || printf "\000message\037py helper not found\012"

printf "\000markup-rows\037true\012"

print_log() {
	python "${SCRIPTPATH}/helper.py"
}

case $ROFI_RETV in
0) print_log ;;
esac

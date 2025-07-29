#!/bin/sh

printf '\000markup-rows\037true\n'

case $ROFI_RETV in
1) [ -n "$ROFI_INFO" ] && eval "notify-send $ROFI_INFO" ;;
*) python "${HELPER_PY}" ;;
esac

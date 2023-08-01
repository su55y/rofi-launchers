#!/bin/sh

# inspired by https://github.com/sayan01/scripts/blob/master/yt

SCRIPTPATH="$(
	cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
	pwd -P
)"
CACHE_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}"
C_DIR="$CACHE_ROOT/yt_rofi"

clr() { printf '\000urgent\037true\n \000nonselectable\037true\n'; }
err_msg() {
	printf '\000message\037error: %s\n' "$1"
	clr
	exit 1
}
[ -d "$C_DIR" ] || {
	mkdir -p "$C_DIR" || err_msg "can't mkdir -p $C_DIR"
}

play() {
	[ "$(printf '%s' "$1" |
		grep -oP "^[0-9a-zA-Z_\-]{11}$")" = "$1" ] || return 1
	setsid -f mpv "https://youtu.be/$1" >/dev/null 2>&1
}

print_from_cache() {
	printf '\000data\037%s\n' "$1"
	printf '\000message\037from file at %s\n' "$(date +%T)"
	awk '{gsub(/\\000/, "\0"); gsub(/\\037/, "\037"); print}' "$1"
}

handle_query() {
	[ -n "$1" ] || exit 1
	query="$(printf '%s' "$1" | sed 's/\s/+/g')"
	results_cache="${C_DIR}/$(echo "$query" | base64)"
	[ -f "$results_cache" ] && {
		print_from_cache "$results_cache"
		return
	}

	response="$(curl -s "https://www.youtube.com/results?search_query=$query" |
		sed 's|\\.||g')"

	printf '%s' "$response" | grep -q "script" || err_msg "unable to grep results"

	vgrep='"videoRenderer":{"videoId":"\K.{11}".+?"text":".+?[^\\](?=")'
	THUMB_URLS=
	IFS=$(printf '\t')
	for line in $(printf '%s' "$response" |
		grep -oP "$vgrep" |
		awk -F\" '{printf "%s %s %s\t",$9,$NF,$1}'); do
		THUMB_URLS="$THUMB_URLS ${line%%\?*}"
		TITLE_AND_ID="${line#* }"
		# uncomment if you don't want to use the go downloader
		# [ ! -f "$C_DIR/${TITLE_AND_ID##* }" ] && curl -s "${line%%\?*}" -o "$C_DIR/${TITLE_AND_ID##* }"
		printf '%s\000info\037%s\037icon\037%s\n' \
			"${TITLE_AND_ID% *}" "${TITLE_AND_ID##* }" "$C_DIR/${TITLE_AND_ID##* }" |
			tee -a "$results_cache"
	done
	printf '\000data\037%s\n' "$results_cache"

	# download all previews in parallel
	"$SCRIPTPATH/downloader" -o "$C_DIR" -l "$THUMB_URLS"
}

# activate hotkeys
printf "\000use-hot-keys\037true\n"

case $ROFI_RETV in
# play selected and exit
1) play "$ROFI_INFO" ;;
# handle search query
2) handle_query "$@" ;;
# kb-custom-1 - clear rows
10) clr ;;
# kb-custom-2 - append selected to playlist and print last results
11)
	[ -n "$ROFI_INFO" ] || err_msg "empty query"
	playlist-ctl -a "https://youtu.be/$ROFI_INFO"
	[ -f "$ROFI_DATA" ] || err_msg "lasts results cache not found"
	print_from_cache "$ROFI_DATA"
	;;
# kb-custom-3 - play selected and print last results
12)
	[ -n "$ROFI_INFO" ] || err_msg "empty query"
	play "$ROFI_INFO"
	[ -f "$ROFI_DATA" ] || err_msg "lasts results cache not found"
	print_from_cache "$ROFI_DATA"
	;;
esac

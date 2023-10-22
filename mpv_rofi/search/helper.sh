#!/bin/sh

# inspired by https://github.com/sayan01/scripts/blob/master/yt

. "${SCRIPTPATH}/../mpv_rofi_utils"

C_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/yt_rofi"

[ -d "$C_DIR" ] || {
	mkdir -p "$C_DIR" || _err_msg "can't mkdir -p $C_DIR"
}
# activate hotkeys
printf "\000use-hot-keys\037true\n"

play() {
	[ "$(printf '%s' "$1" |
		grep -oP "^[0-9a-zA-Z_\-]{11}$")" = "$1" ] || _err_msg "invalid id '$1'"
	_play "https://youtu.be/$1"
}

print_from_cache() {
	[ -f "$1" ] || _err_msg "no recent results found in cache"
	printf '\000data\037%s\n' "$1"
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

	printf '%s' "$response" | grep -q "script" || _err_msg "unable to grep results"

	vgrep='"videoRenderer":{"videoId":"\K.{11}".+?"text":".+?[^\\](?=")'
	THUMB_URLS=
	IFS=$(printf '\t')
	for line in $(printf '%s' "$response" |
		grep -oP "$vgrep" |
		awk -F\" '{printf "%s %s %s\t",$9,$NF,$1}'); do

		THUMB_URLS="$THUMB_URLS ${line%%\?*}"
		TITLE_AND_ID="${line#* }"

		printf '%s\000info\037%s\037icon\037%s\n' \
			"${TITLE_AND_ID% *}" "${TITLE_AND_ID##* }" "$C_DIR/${TITLE_AND_ID##* }" |
			tee -a "$results_cache"
	done
	printf '\000data\037%s\n' "$results_cache"

	"$SCRIPTPATH/downloader" -o="$C_DIR" -l="$THUMB_URLS"
}

case $ROFI_RETV in
# play selected and exit
1) play "$ROFI_INFO" ;;
# handle search query
2) handle_query "$@" ;;
# kb-custom-1 - clear rows
10) printf '\000urgent\0370\n \000nonselectable\037true\n' ;;
# kb-custom-2 - append selected to playlist and print last results
11)
	_append "https://youtu.be/$ROFI_INFO"
	print_from_cache "$ROFI_DATA"
	;;
# kb-custom-3 - play selected and print last results
12)
	play "$ROFI_INFO"
	print_from_cache "$ROFI_DATA"
	;;
esac

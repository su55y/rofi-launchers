#!/bin/sh

SCRIPTPATH="$(
	cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
	pwd -P
)"

[ -f "$SCRIPTPATH/helper.sh" ] || {
	notify-send -i "rofi" -a "playlist-ctl" "playlist control helper script not found"
	exit 1
}

theme() {
	cat <<EOF
configuration {
  font: "NotoSans Nerd Font 18";
}
inputbar {
  children: ["textbox-prompt-colon","entry","num-filtered-rows","textbox-num-sep","num-rows","case-indicator"];
}
textbox-prompt-colon {
  str: "";
  padding: 3px;
}
EOF
}

rofi -i -show "playlist_ctl_py" \
	-modi "playlist_ctl_py:$SCRIPTPATH/helper.sh" \
	-no-config \
	-no-custom \
	-normal-window \
	-theme-str "$(theme)" \
	-kb-remove-char-back "BackSpace,Shift+BackSpace" \
	-kb-custom-1 "Ctrl+h"

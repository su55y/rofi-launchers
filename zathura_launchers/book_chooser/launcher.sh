#!/bin/sh

SCRIPTPATH="$(
	cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
	pwd -P
)"

[ -f "$SCRIPTPATH/helper.sh" ] || {
	notify-send -i "rofi" -a "book chooser" "helper script not found"
	exit 1
}

theme() {
	cat <<EOF
window {
  font: "BlexMono Nerd Font 20";
}
inputbar {
  children: ["textbox-prompt-colon","entry","case-indicator"];
}
textbox-prompt-colon {
  str: "";
  padding: 0 10px 0 5px;
}
EOF
}

rofi -i -show "books" -modi "books:${SCRIPTPATH}/helper.sh" \
	-no-config -no-custom -sort -theme-str "$(theme)"

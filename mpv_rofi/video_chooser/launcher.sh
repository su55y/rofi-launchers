#!/bin/sh

SCRIPTPATH="$(
	cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
	pwd -P
)"

[ -f "$SCRIPTPATH/helper.sh" ] || {
	notify-send -i "rofi" -a "video chooser" "helper script not found"
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
  str: "";
  padding: 0 10px 0 5px;
}
EOF
}

rofi -i -show "vchooser" -no-config \
	-modi "vchooser:$SCRIPTPATH/helper.sh" \
	-theme-str "$(theme)" \
	-sep='\x0a' -eh 2 -normal-window \
	-kb-move-front "Ctrl+i" -kb-custom-1 "Ctrl+a"

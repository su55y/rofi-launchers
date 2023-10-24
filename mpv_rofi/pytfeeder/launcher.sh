#!/bin/sh

SCRIPTPATH="$(
	cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
	pwd -P
)"

[ -f "$SCRIPTPATH/helper.sh" ] || {
	notify-send -i "rofi" -a "youtube feed" "helper script not found"
	exit 1
}

# theme string
theme() {
	cat <<EOF
configuration {
  font: "NotoSans Nerd Font 16";
}
window {
  height: 90%;
}
inputbar {
  children: ["textbox-prompt-colon","entry","num-filtered-rows","textbox-num-sep","num-rows","case-indicator"];
}
textbox-prompt-colon {
  str: "";
  text-color: #f00;
  padding: 0 5px;
}
EOF
}

SCRIPTPATH="$SCRIPTPATH" rofi -i -show "pytfeeder-rofi-launcher" \
	-modi "pytfeeder-rofi-launcher:$SCRIPTPATH/helper.sh" \
	-no-config -kb-custom-1 "Ctrl+s" \
	-kb-custom-2 "Ctrl+c" \
	-kb-custom-3 "Ctrl+x" \
	-kb-custom-4 "Ctrl+X" \
	-kb-move-front "" \
	-kb-custom-5 "Ctrl+a" \
	-kb-remove-char-forward "Delete" \
	-kb-custom-6 "Ctrl+d" \
	-theme-str "$(theme)" \
	-normal-window

#!/bin/sh

SCRIPTPATH="$(
	cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
	pwd -P
)"

[ -f "$SCRIPTPATH/helper.sh" ] || {
	notify-send -i "rofi" -a "dunstlog launcher" "helper script not found"
	exit 1
}

theme() {
	cat <<EOF
configuration {
  font: "NotoSans Nerd Font 14";
}
inputbar {
  children: ["textbox-prompt-colon","entry","num-filtered-rows","textbox-num-sep","num-rows","case-indicator"];
}
textbox-prompt-colon {
  str: "";
}
element {
  border:  0;
  padding: 2px;
  children: ["element-icon","element-text"];
}
element-icon {
  size: 36px;
  border: 0px;
  padding: 0 5px;
}
listview {
  fixed-height: true;
  lines: 8;
}
EOF
}

rofi -i -show "dunstlog" \
	-modi "dunstlog:$SCRIPTPATH/helper.sh" \
	-no-config \
	-theme-str "$(theme)" \
	-sep='\x0a' -eh 2 -normal-window

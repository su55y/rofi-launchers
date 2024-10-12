#!/bin/sh

SCRIPTPATH="$(
	cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
	pwd -P
)"

[ -f "$SCRIPTPATH/helper.sh" ] || {
	notify-send -i "rofi" -a "palette launcher" "helper script not found"
	exit 1
}

theme() {
	cat <<EOF
configuration {
  font: "NotoSans Nerd Font 18";
}
window {
  width: 200px;
  height: 100%;
  location: north west;
}
listview {
  scrollbar: false;
  border: none;
}
inputbar {
  children: ["textbox-prompt-colon","entry","num-filtered-rows","textbox-num-sep","num-rows","case-indicator"];
}
textbox-prompt-colon {
  str: "";
}
entry {
  placeholder: "";
}
EOF
}

rofi -i -no-config -theme-str "$(theme)" \
	-show palette -modi "palette:$SCRIPTPATH/helper.sh" \
	-kb-move-front "Ctrl+i" -kb-custom-1 "Ctrl+a"

#!/bin/sh

SCRIPTPATH="$(
	cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
	pwd -P
)"

[ -f "$SCRIPTPATH/helper.sh" ] || {
	notify-send -i "rofi" -a "wiki search" "wiki helper script not found"
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
  str: "";
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
/* hide element after clear */
element.selected.urgent {
  background-color: #00000000;
}
element.normal.urgent {
  background-color: #00000000;
}
element.alternate.urgent {
  background-color: #00000000;
}
element.selected.urgent {
  background-color: #00000000;
}
element.alternate.selected.urgent {
  background-color: #00000000;
}
EOF
}

rofi -i -show "wiki" \
	-modi "wiki:$SCRIPTPATH/helper.sh" \
	-no-config \
	-kb-custom-1 "Ctrl+c" \
	-kb-custom-2 "Ctrl+s" \
	-kb-row-select "Ctrl+9" \
	-kb-custom-3 "Ctrl+space" \
	-kb-custom-4 "Ctrl+r" \
	-theme-str "$(theme)" \
	-normal-window

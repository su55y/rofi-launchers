#!/bin/sh

SCRIPTPATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1 ; pwd -P)"

[ -f "$SCRIPTPATH/helper.sh" ] || {
    notify-send -i "rofi" -a "youtube search" "helper script not found"
    exit 1
}

# theme string
theme() { cat <<EOF
configuration {
  font: "NotoSans Nerd Font 18";
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
  padding: 0 10px 0 5px;
}
element {
  children: [element-text,element-icon];
  padding: -40px 0;
}
element-text {
  vertical-align: 0.5;
}
element-icon {
  size: 200px;
}
/* hide element after clear */
element.selected.urgent {
  background-color: #00000000;
}
EOF
}

rofi -i -show "yt_rofi" \
    -modi "yt_rofi:$SCRIPTPATH/helper.sh" \
    -no-config \
    -kb-custom-1 "Ctrl+c" \
    -theme-str "$(theme)"

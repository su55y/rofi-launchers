#!/bin/sh

SCRIPTPATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
    pwd -P
)"

[ -f "$SCRIPTPATH/helper.sh" ] || {
    notify-send -i rofi -a lxqtnotiflog 'helper script not found'
    exit 1
}

[ -f "$SCRIPTPATH/helper.py" ] || {
    notify-send -i rofi -a lxqtnotiflog 'helper.py script not found'
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

HELPER_PY="${SCRIPTPATH}/helper.py" rofi -i -no-custom -no-config \
    -show lxqtnotiflog -modi "lxqtnotiflog:$SCRIPTPATH/helper.sh" \
    -theme-str "$(theme)" -eh 2 -normal-window

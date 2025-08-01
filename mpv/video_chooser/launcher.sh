#!/bin/sh

SCRIPTPATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
    pwd -P
)"

[ -f "$SCRIPTPATH/helper.sh" ] || {
    notify-send -i rofi -a 'video chooser' 'helper script not found'
    exit 1
}

theme() {
    cat <<EOF
configuration {
  kb-move-front: "Ctrl+i";
  kb-row-select: "Ctrl+s";
  kb-custom-1: "Ctrl+a";
  kb-custom-2: "Ctrl+space";
  kb-custom-3: "Ctrl+r";
}
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
listview {
  fixed-height: true;
  lines: 8;
}
EOF
}

rofi -i -no-config -eh 2 \
    -show vchooser -modi "vchooser:$SCRIPTPATH/helper.sh" \
    -theme-str "$(theme)" -normal-window

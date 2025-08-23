#!/bin/sh

SCRIPTPATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
    pwd -P
)"

[ -f "$SCRIPTPATH/helper.sh" ] || {
    notify-send -i rofi -a 'man viewer' 'helper script not found'
    exit 1
}

theme() {
    cat <<EOF
configuration {
  font: "BlexMono Nerd Font 20";
  kb-row-select: "ctrl+s";
  kb-custom-1: "ctrl+space";
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

rofi -no-config -no-custom -i -sort \
    -show man_viewer -modi "man_viewer:${SCRIPTPATH}/helper.sh" \
    -theme-str "$(theme)"

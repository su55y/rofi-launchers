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
  font: "NotoSans Nerd Font 18";
  kb-move-front: "ctrl+A";
  kb-row-select: "ctrl+s";
  kb-accept-entry: "ctrl+J,ctrl+m,Return,KP_Enter";
  kb-remove-to-eol: "ctrl+K";
  kb-custom-1: "ctrl+a";
  kb-custom-2: "ctrl+space";
  kb-custom-3: "ctrl+r";
  kb-custom-4: "ctrl+o";
  kb-custom-5: "ctrl+j";
  kb-custom-6: "ctrl+k";
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

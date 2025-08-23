#!/bin/sh

SCRIPTPATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
    pwd -P
)"

: "${PALETTE_PATH:=$SCRIPTPATH/palette}"

[ -f "$PALETTE_PATH" ] || {
    notify-send -i rofi -a palette "$PALETTE_PATH not found"
    exit 1
}

[ -f "$SCRIPTPATH/helper.sh" ] || {
    notify-send -i rofi -a palette 'helper script not found'
    exit 1
}

theme() {
    cat <<EOF
configuration {
  font: "NotoSans Nerd Font 18";
  kb-secondary-copy: "ctrl+y,ctrl+C";
  kb-custom-1: "ctrl+c";
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

PALETTE_PATH="$PALETTE_PATH" rofi -i -no-config -no-custom \
    -show palette -modi "palette:$SCRIPTPATH/helper.sh" \
    -theme-str "$(theme)"

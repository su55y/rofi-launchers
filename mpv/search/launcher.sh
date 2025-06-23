#!/bin/sh

SCRIPTPATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
    pwd -P
)"

[ -f "$SCRIPTPATH/helper.sh" ] || {
    notify-send -i "rofi" -a "youtube search" "helper script not found"
    exit 1
}
[ -f "$SCRIPTPATH/downloader" ] || {
    notify-send -i "rofi" -a "youtube search" "downloader executable not found"
    exit 1
}

. "${SCRIPTPATH}/../mpv_rofi_utils"

_search_theme() {
    cat <<EOF
configuration {
  font: "NotoSans Nerd Font 18";
  kb-secondary-copy: "Ctrl+y";
  kb-move-front: "Ctrl+i";
  kb-row-select: "Ctrl+9";
  kb-remove-char-forward: "Delete";
  kb-remove-char-back: "BackSpace,Shift+BackSpace";
  kb-custom-1: "Ctrl+c";
  kb-custom-2: "Ctrl+a";
  kb-custom-3: "Ctrl+space";
  kb-custom-4: "Ctrl+d";
  kb-custom-5: "Ctrl+h";
  kb-custom-6: "Ctrl+o";
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

rofi -i -no-config \
    -show yt_search -modi "yt_search:$SCRIPTPATH/helper.sh" \
    -theme-str "$(_search_theme)" -normal-window

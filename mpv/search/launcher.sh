#!/bin/sh

MODENAME=yt_search

SCRIPTPATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
    pwd -P
)"

HELPER="$SCRIPTPATH/helper.sh"
if [ ! -f "$HELPER" ]; then
    printf '<b>%s</b>\n%s not found' "$MODENAME" "$HELPER" | rofi -markup -e -
    exit 1
fi

DOWNLOADER_PATH="$SCRIPTPATH/downloader"
if [ ! -f "$DOWNLOADER_PATH" ]; then
    printf '<b>%s</b>\ndownloader executable not found at %s' \
        "$MODENAME" "$DOWNLOADER_PATH" | rofi -markup -e -
    exit 1
fi

UTILS_PATH="$SCRIPTPATH/../common_utils"
if [ ! -f "$UTILS_PATH" ]; then
    printf '<b>%s</b>\n%s not found' "$MODENAME" "$UTILS_PATH" | rofi -markup -e -
fi

_search_theme() {
    cat <<EOF
configuration {
  font: "NotoSans Nerd Font 18";
  kb-secondary-copy: "ctrl+C";
  kb-move-front: "ctrl+A";
  kb-row-select: "ctrl+s";
  kb-remove-char-forward: "ctrl+D";
  kb-remove-char-back: "BackSpace,Shift+BackSpace,ctrl+H";
  kb-custom-1: "ctrl+c";
  kb-custom-2: "ctrl+a";
  kb-custom-3: "ctrl+space";
  kb-custom-4: "ctrl+d";
  kb-custom-5: "ctrl+h";
  kb-custom-6: "ctrl+o";
  kb-custom-7: "ctrl+r";
  kb-custom-8: "ctrl+x,Delete";
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

DOWNLOADER_PATH="$DOWNLOADER_PATH" UTILS_PATH="$UTILS_PATH" rofi -i -no-config \
    -show "$MODENAME" -modi "$MODENAME:$HELPER" \
    -theme-str "$(_search_theme)" -normal-window

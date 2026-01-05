#!/bin/sh

MODENAME=palette_picker

SCRIPTPATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
    pwd -P
)"

: "${PALETTE_PATH:=$SCRIPTPATH/palette}"

if [ ! -f "$PALETTE_PATH" ]; then
    printf '<b>%s</b>\n%s not found' "$MODENAME" "$PALETTE_PATH" | rofi -markup -e -
    exit 1
fi

HELPER="$SCRIPTPATH/helper.sh"
if [ ! -f "$HELPER" ]; then
    printf '<b>%s</b>\n%s not found' "$MODENAME" "$HELPER" | rofi -markup -e -
    exit 1
fi

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
    -show "$MODENAME" -modi "$MODENAME:$HELPER" \
    -theme-str "$(theme)"

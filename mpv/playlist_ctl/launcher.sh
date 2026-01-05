#!/bin/sh

MODENAME=playlist_ctl

SCRIPTPATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
    pwd -P
)"

UTILS_PATH="$SCRIPTPATH/../common_utils"
if [ ! -f "$UTILS_PATH" ]; then
    printf '<b>%s</b>\n%s not found' "$MODENAME" "$UTILS_PATH" | rofi -markup -e -
fi

HELPER="$SCRIPTPATH/helper.sh"
if [ ! -f "$HELPER" ]; then
    printf '<b>%s</b>\n%s not found' "$MODENAME" "$HELPER" | rofi -markup -e -
    exit 1
fi

if ! command -v playlist-ctl >/dev/null 2>&1; then
    printf '<b>%s</b>\nplaylist-ctl executable not in PATH' "$MODENAME" | rofi -markup -e -
    exit 1
fi

theme() {
    cat <<EOF
configuration {
  font: "NotoSans Nerd Font 18";
  kb-remove-char-back: "BackSpace,Shift+BackSpace,ctrl+H";
  kb-remove-char-forward: "ctrl+D";
  kb-move-front: "ctrl+A";
  kb-custom-1: "ctrl+h";
  kb-custom-2: "ctrl+a";
  kb-custom-3: "ctrl+d";
  kb-custom-4: "ctrl+r";
  kb-custom-5: "ctrl+o";
  kb-custom-6: "ctrl+x,Delete";
}
inputbar {
  children: ["textbox-prompt-colon","entry","num-filtered-rows","textbox-num-sep","num-rows","case-indicator"];
}
textbox-prompt-colon {
  str: "";
  padding: 3px;
}
EOF
}

UTILS_PATH="$UTILS_PATH" rofi -i -no-config -no-custom \
    -show "$MODENAME" -modi "$MODENAME:$HELPER" \
    -theme-str "$(theme)" -normal-window

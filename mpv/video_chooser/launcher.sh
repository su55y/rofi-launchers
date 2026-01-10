#!/bin/sh

MODENAME=video_chooser

SCRIPTPATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
    pwd -P
)"

HELPER="$SCRIPTPATH/helper.sh"
if [ ! -f "$HELPER" ]; then
    printf '<b>%s</b>\n%s not found' "$MODENAME" "$HELPER" | rofi -markup -e -
    exit 1
fi

PRINTER_PATH="$SCRIPTPATH/printer"
if [ ! -f "$PRINTER_PATH" ]; then
    printf '<b>%s</b>\n%s not found' "$MODENAME" "$PRINTER_PATH" | rofi -markup -e -
    exit 1
fi

UTILS_PATH="$SCRIPTPATH/../common_utils"
if [ ! -f "$UTILS_PATH" ]; then
    printf '<b>%s</b>\n%s not found' "$MODENAME" "$UTILS_PATH" | rofi -markup -e -
    exit 1
fi

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
  children: ["textbox-prompt-colon","entry","num-filtered-rows","textbox-num-sep","num-rows","case-indicator"];
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

PRINTER_PATH="$PRINTER_PATH" UTILS_PATH="$UTILS_PATH" rofi -i -no-config \
    -no-custom -eh 2 \
    -show "$MODENAME" -modi "$MODENAME:$HELPER" \
    -theme-str "$(theme)" -normal-window

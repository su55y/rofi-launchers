#!/bin/sh

MODENAME=dunstlog

SCRIPTPATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
    pwd -P
)"

HELPER="$SCRIPTPATH/helper.sh"
if [ ! -f "$HELPER" ]; then
    printf '<b>%s</b>\n%s not found' "$MODENAME" "$HELPER" | rofi -markup -e -
    exit 1
fi

: "${PY_HELPER:="$SCRIPTPATH/helper.py"}"
if [ ! -f "$PY_HELPER" ]; then
    printf '<b>%s</b>\n%s not found' "$MODENAME" "$PY_HELPER" | rofi -markup -e -
    exit 1
fi

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

PY_HELPER="$PY_HELPER" rofi -i -no-custom -no-config \
    -show "$MODENAME" -modi "$MODENAME:$HELPER" \
    -theme-str "$(theme)" -eh 2 -normal-window

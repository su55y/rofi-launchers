#!/bin/sh

MODENAME=wiki

SCRIPTPATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
    pwd -P
)"

HELPER="$SCRIPTPATH/helper.sh"
if [ ! -f "$HELPER" ]; then
    printf '<b>%s</b>\n%s not found' "$MODENAME" "$HELPER" | rofi -markup -e -
    exit 1
fi

GO_HELPER="$SCRIPTPATH/helper"
if [ ! -f "$HELPER" ]; then
    printf '<b>%s</b>\n%s not found' "$MODENAME" "$GO_HELPER" | rofi -markup -e -
    exit 1
fi

theme() {
    cat <<EOF
configuration {
  font: "NotoSans Nerd Font 18";
  kb-secondary-copy: "ctrl+y,ctrl+C";
  kb-remove-char-back: "BackSpace,Shift+BackSpace,ctrl+H";
  kb-remove-char-forward: "ctrl+d";
  kb-custom-1: "ctrl+c";
  kb-custom-2: "ctrl+s";
  kb-custom-3: "ctrl+r";
  kb-custom-4: "ctrl+h";
  kb-custom-5: "ctrl+x,Delete";
}
inputbar {
  children: ["textbox-prompt-colon","entry","num-filtered-rows","textbox-num-sep","num-rows","case-indicator"];
}
textbox-prompt-colon {
  str: "";
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
/* hide element after clear */
element.selected.urgent {
  background-color: #00000000;
}
EOF
}

GO_HELPER="$GO_HELPER" rofi -i -no-config \
    -show "$MODENAME" -modi "$MODENAME:$HELPER" \
    -theme-str "$(theme)" -normal-window

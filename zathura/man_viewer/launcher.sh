#!/bin/sh

MODENAME=man_viewer

SCRIPTPATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
    pwd -P
)"

HELPER="$SCRIPTPATH/helper.sh"
if [ ! -f "$HELPER" ]; then
    printf '<b>%s</b>\n%s not found' "$MODENAME" "$HELPER" | rofi -markup -e -
    exit 1
fi

theme() {
    cat <<EOF
configuration {
  font: "BlexMono Nerd Font 20";
  kb-row-select: "ctrl+s";
  kb-custom-1: "ctrl+space";
}
inputbar {
  children: ["textbox-prompt-colon","entry","num-filtered-rows","textbox-num-sep","num-rows","case-indicator"];
}
textbox-prompt-colon {
  str: "";
  padding: 0 10px 0 5px;
}
EOF
}

rofi -no-config -no-custom -i -sort \
    -show "$MODENAME" -modi "$MODENAME:$HELPER" \
    -theme-str "$(theme)"

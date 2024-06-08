#!/bin/sh

SCRIPTPATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1 ; pwd -P)"

[ -f "$SCRIPTPATH/helper.sh" ] || {
    notify-send -i "rofi" -a "arch wiki" "helper script not found"
    exit 1
}

theme() { cat <<EOF
configuration {
  font: "NotoSans Nerd Font 18";
}
inputbar {
  children: ["textbox-prompt-colon","entry","num-filtered-rows","textbox-num-sep","num-rows","case-indicator"];
}
textbox-prompt-colon {
  str: "";
}
EOF
}

rofi -i -show "wiki" \
    -modi "wiki:$SCRIPTPATH/helper.sh" \
    -no-config \
    -no-custom \
    -sort true \
    -kb-custom-1 "Ctrl+c" \
    -kb-row-select "" \
    -kb-custom-2 "Ctrl+space" \
    -theme-str "$(theme)" \
    -normal-window

#!/bin/sh

SCRIPTPATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
    pwd -P
)"

[ -f "$SCRIPTPATH/helper.sh" ] || {
    notify-send -i rofi -a 'arch wiki' 'helper script not found'
    exit 1
}

theme() {
    cat <<EOF
configuration {
  font: "NotoSans Nerd Font 18";
  kb-secondary-copy: "ctrl+y,ctrl+C";
  kb-row-select: "ctrl+s";
  kb-custom-1: "ctrl+c";
  kb-custom-2: "ctrl+space";
}
inputbar {
  children: ["textbox-prompt-colon","entry","num-filtered-rows","textbox-num-sep","num-rows","case-indicator"];
}
textbox-prompt-colon {
  str: "";
}
EOF
}

rofi -i -no-config -no-custom -sort true \
    -show arch_wiki -modi "arch_wiki:$SCRIPTPATH/helper.sh" \
    -theme-str "$(theme)" -normal-window

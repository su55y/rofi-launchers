#!/usr/bin/env bash

SCRIPTPATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1 ; pwd -P)"

[ -f "$SCRIPTPATH/helper.sh" ] || {
    notify-send -a "rofi" "helper script not found"
    exit 1
}

# yt logo: 
logo="$(printf '\uf16a')"

# theme string
theme() { cat <<EOF
* {
    font: "NotoSans Nerd Font 18";
}
window {
  height: 90%;
}
inputbar {
  children: [prompt,entry,num-filtered-rows,textbox-num-sep,num-rows];
}
prompt {
  padding: 0 10px 0 5px;
  text-color: #f00;
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

rofi -i -show "$logo" \
    -modi "$logo:$SCRIPTPATH/helper.sh" \
    -no-config \
    -show-icons \
    -normal-window \
    -kb-custom-1 "Ctrl+c" \
    -theme-str "$(theme)"

#!/bin/sh

SCRIPTPATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1 ; pwd -P)"

[ -f "$SCRIPTPATH/helper.sh" ] || {
    notify-send "gruvbox palette" "helper script not found"
    exit 1
}

logo="$(printf "\Ue22b") "

theme() { cat <<EOF
* {
    font: "NotoSans Nerd Font 18";
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
    spacing: 10px;
    children: [prompt,entry];
}
entry {
    placeholder: "";
}
EOF
}

rofi -i -show "$logo" \
    -modi "$logo:$SCRIPTPATH/helper.sh" \
    -no-config \
    -theme-str "$(theme)"

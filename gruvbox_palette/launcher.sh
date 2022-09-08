#!/bin/sh

SCRIPTPATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1 ; pwd -P)"

[ -f "$SCRIPTPATH/helper.sh" ] || {
    notify-send "gruvbox palette" "helper script not found"
    exit 1
}

# palette logo
logo="$(printf "\Ue22b") "
# if nerd fonts are installed and logo is not displayed, use this instead
# logo="$(printf $(printf '\\%o' $(printf %08x 0xe22b 0xA | sed 's/../0x& /g')) | iconv -f UTF-32BE -t UTF-8)"


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

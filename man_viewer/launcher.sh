#!/bin/sh

theme() { cat <<EOF
window {
  width: 20em;
  height: 100%;
  location: west;
  anchor: west;
}
inputbar {
  children:   [ "textbox-prompt-colon","entry","num-filtered-rows","textbox-num-sep","num-rows","case-indicator" ];
}
textbox-prompt-colon {
  str: "Man:";
}
entry {
  placeholder: "";
}
EOF
}

showall() {
    choice=$(man -k . |\
        awk '! /[_:.]/{print $1}' | sort |\
        rofi -i -dmenu -no-custom -no-config\
            -theme-str "$(theme)" "$@") || exit 1

    [ -n "$choice" ] && {
        exec man -Tpdf "$choice" | zathura -
    }
}
showall "$@"

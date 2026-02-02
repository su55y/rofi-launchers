#!/bin/sh

: "${BOOKS_DIR:=$HOME/books}"

theme() {
    cat <<EOF
window {
  font: "BlexMono Nerd Font 20";
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

print_all() {
    if command -v fd >/dev/null 2>&1; then
        fd . "$BOOKS_DIR" -aLt f \
            -e pdf -e djv -e djvu -e epub -e ps -e eps -e cbz -e cbr -e cbt \
            -x printf '%s\037%s\n' {/} {}
    else
        # '.*.\(pdf\|djv\|djvu\|epub\|ps\|eps\|cbz\|cbr\|cbt\)'
        find -L "$BOOKS_DIR" -type f -iregex '.*.\(pdf\|djvu\|epub\)' |
            awk '{split($0, a, "/"); printf "%s\037%s\n", a[length(a)], $0}'
    fi
}

choice="$(print_all |
    rofi -dmenu -i -no-config -no-custom -sort \
        -display-columns 1 -display-column-separator '\x1f' \
        -theme-str "$(theme)" -normal-window)"
if [ -z "$choice" ]; then
    exit 0
fi

choice="$(echo "$choice" | grep -aoP "\037\K${BOOKS_DIR}.+$")"
if [ ! -f "$choice" ]; then
    rofi -e "'$choice' not found"
    exit 1
fi

setsid -f zathura "$choice" >/dev/null 2>&1

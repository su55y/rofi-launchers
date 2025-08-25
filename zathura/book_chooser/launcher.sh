#!/bin/sh

: "${BOOKS_DIR:=$HOME/books}"

theme() {
    cat <<EOF
window {
  font: "BlexMono Nerd Font 20";
}
inputbar {
  children: ["textbox-prompt-colon","entry","case-indicator"];
}
textbox-prompt-colon {
  str: "";
  padding: 0 10px 0 5px;
}
EOF
}

print_all() {
    find "$BOOKS_DIR" -type f -name "*.pdf" | sort | while read -r file; do
        title="${file##*\/}"
        printf '%s\037%s\n' "$title" "$file"
    done
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

#!/bin/sh

MODENAME=palette_picker

SCRIPTPATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
    pwd -P
)"

: "${PALETTE_PATH:=$SCRIPTPATH/palette}"

if [ ! -f "$PALETTE_PATH" ]; then
    printf '<b>%s</b>\n%s not found' "$MODENAME" "$PALETTE_PATH" | rofi -markup -e -
    exit 1
fi

HELPER="$SCRIPTPATH/helper.sh"
if [ ! -f "$HELPER" ]; then
    printf '<b>%s</b>\n%s not found' "$MODENAME" "$HELPER" | rofi -markup -e -
    exit 1
fi

theme() {
    cat <<EOF
configuration {
  font: "NotoSans Nerd Font 18";
  kb-secondary-copy: "ctrl+y,ctrl+C";
  kb-custom-1: "ctrl+c";
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
  children: ["textbox-prompt-colon","entry","num-filtered-rows","textbox-num-sep","num-rows","case-indicator"];
}
textbox-prompt-colon {
  str: "";
}
entry {
  placeholder: "";
}
EOF
}

copy() {
    [ "$(printf '%s' "$1" |
        grep -oP "^#[0-9a-fA-F]{6}$")" = "$1" ] && {
        printf '%s' "$1" | xsel -ib
    }
}

print_palette() {
    awk '{printf "<span background=\047%s\047>\t</span> <span color=\047%s\047>%s</span>\037%s\n",$2,$2,$1,$2}' "$PALETTE_PATH"
}

choice=
while :; do
    if [ -n "$choice" ] && [ "$(echo "$choice" | grep -oP '^#[0-9a-fA-F]{6}$')" = "$choice" ]; then
        choice="$(
            print_palette |
                rofi -dmenu -i -no-config -no-custom -markup-rows -theme-str "$(theme)" \
                    -display-columns 1 -display-column-separator '\x1f' \
                    -mesg "<span color='$choice'>$choice</span>"
        )"
    else
        choice="$(
            print_palette |
                rofi -dmenu -i -no-config -no-custom -markup-rows -theme-str "$(theme)" \
                    -display-columns 1 -display-column-separator '\x1f'
        )"
    fi
    ret=$?
    case $ret in
    0 | 10)
        choice="$(echo "$choice" | grep -aoP "\037\K.+$")"
        [ -n "$choice" ] || exit 0
        copy "$choice"
        [ $ret -eq 10 ] && continue
        ;;
    esac
    exit 0
done

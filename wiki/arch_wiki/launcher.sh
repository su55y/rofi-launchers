#!/bin/sh

MODENAME=arch_wiki
: "${WIKIDIR:=/usr/share/doc/arch-wiki/html/en/}"

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

WIKIDIR="$WIKIDIR" rofi -i -no-config -no-custom \
    -show "$MODENAME" -modi "$MODENAME:$HELPER" \
    -theme-str "$(theme)" -normal-window

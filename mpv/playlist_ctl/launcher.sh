#!/bin/sh

SCRIPTPATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
    pwd -P
)"

ROFI_MPV_UTILS="${SCRIPTPATH}/../mpv_rofi_utils"
if [ ! -f "$ROFI_MPV_UTILS" ]; then
    notify-send -i rofi -a playlist-ctl "mpv_rofi_utils file not found in $ROFI_MPV_UTILS"
    exit 1
fi

if [ ! -f "$SCRIPTPATH/helper.sh" ]; then
    notify-send -i rofi -a playlist-ctl 'playlist control helper script not found'
    exit 1
fi

theme() {
    cat <<EOF
configuration {
  font: "NotoSans Nerd Font 18";
  kb-remove-char-back: "BackSpace,Shift+BackSpace,ctrl+H";
  kb-remove-char-forward: "Delete,ctrl+D";
  kb-move-front: "ctrl+A";
  kb-custom-1: "ctrl+h";
  kb-custom-2: "ctrl+a";
  kb-custom-3: "ctrl+d";
  kb-custom-4: "ctrl+r";
  kb-custom-5: "ctrl+o";
}
inputbar {
  children: ["textbox-prompt-colon","entry","num-filtered-rows","textbox-num-sep","num-rows","case-indicator"];
}
textbox-prompt-colon {
  str: "";
  padding: 3px;
}
EOF
}

ROFI_MPV_UTILS="$ROFI_MPV_UTILS" rofi -i -no-config -no-custom \
    -show playlist_ctl_py -modi "playlist_ctl_py:$SCRIPTPATH/helper.sh" \
    -theme-str "$(theme)" -normal-window

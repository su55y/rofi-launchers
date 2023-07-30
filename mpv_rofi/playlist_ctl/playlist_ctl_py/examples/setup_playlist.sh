#!/usr/bin/env bash

# ids=(
#     0WcrgvhO_mw
#     1lTfW32NT0Y
#     3KCyhltnz7w
#     3SfdCkQHYkU
#     44z5oLKM5uE
# )

ids=(
	4ZH9pobulDo
	4bzLzyKnLzc
	6OPNIKZKYoo
	7P-fktmZxts
	7SfDlR3vU3I
)

# ids=(
# 	notexists00
# )

# ids=(
#     0WcrgvhO_mw
#     1lTfW32NT0Y
#     3KCyhltnz7w
#     3SfdCkQHYkU
#     44z5oLKM5uE
#     4ZH9pobulDo
#     4bzLzyKnLzc
#     6OPNIKZKYoo
#     7P-fktmZxts
#     7SfDlR3vU3I
# )

SCRIPTPATH="$(
	cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
	pwd -P
)"
APPEND_SCRIPT="${SCRIPTPATH}/rofi/append_video.sh"
[ -f "$APPEND_SCRIPT" ] || {
	echo "$APPEND_SCRIPT not found"
	exit 1
}

for id in "${ids[@]}"; do
	"$APPEND_SCRIPT" "https://youtu.be/$id" &
	sleep 0.9
done

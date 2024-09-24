#!/bin/sh

while true; do
	inp="$(rofi -dmenu -p trans -theme-str 'listview {lines: 0;}')"
	[ -z "$inp" ] && exit 0
	rofi -e "$(trans -no-ansi :uk "$inp")"
done

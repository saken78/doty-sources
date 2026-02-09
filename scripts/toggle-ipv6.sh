#!/bin/bash

ACTION="${1:-disable}"

if [[ "$ACTION" == "disable" ]]; then
	VALUE=1
else
	VALUE=0
fi

kitty --title "IPv6 Toggle - Enter Password" sh -c "sudo sysctl -w net.ipv6.conf.all.disable_ipv6=$VALUE && sudo sysctl -w net.ipv6.conf.default.disable_ipv6=$VALUE && echo 'Done! Press Enter to close...' && read"

# Buka terminal dan jalankan sudo sysctl
if command -v xterm &>/dev/null; then
	xterm -title "IPv6 Toggle - Enter Password" -e "sudo sysctl -w net.ipv6.conf.all.disable_ipv6=$VALUE && sudo sysctl -w net.ipv6.conf.default.disable_ipv6=$VALUE && echo 'Done! Press Enter to close...' && read"
elif command -v gnome-terminal &>/dev/null; then
	gnome-terminal -- bash -c "sudo sysctl -w net.ipv6.conf.all.disable_ipv6=$VALUE && sudo sysctl -w net.ipv6.conf.default.disable_ipv6=$VALUE && echo 'Done! Press Enter to close...' && read"
elif command -v konsole &>/dev/null; then
	konsole -e bash -c "sudo sysctl -w net.ipv6.conf.all.disable_ipv6=$VALUE && sudo sysctl -w net.ipv6.conf.default.disable_ipv6=$VALUE && echo 'Done! Press Enter to close...' && read"
elif command -v xfce4-terminal &>/dev/null; then
	xfce4-terminal -x bash -c "sudo sysctl -w net.ipv6.conf.all.disable_ipv6=$VALUE && sudo sysctl -w net.ipv6.conf.default.disable_ipv6=$VALUE && echo 'Done! Press Enter to close...' && read"
else
	echo "No terminal found! Install xterm or use another terminal emulator."
	exit 1
fi

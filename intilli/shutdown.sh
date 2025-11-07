#!/bin/bash

echo -e "$fg_bold[cyan]Stopping Valet...$reset_color"
valet stop 2>/dev/null

echo -e "$fg_bold[cyan]Stopping PHP Monitor...$reset_color"
osascript -e 'quit app "PHP Monitor"' 2>/dev/null

#!/bin/bash

echo -e "$fg_bold[cyan]Stopping Docker...$reset_color"
osascript -e 'quit app "Docker Desktop"' 2>/dev/null

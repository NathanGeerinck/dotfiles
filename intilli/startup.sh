#!/bin/bash

echo -e "$fg_bold[cyan]Starting Valet...$reset_color"
valet start 2>/dev/null

echo -e "$fg_bold[cyan]Starting PHP Monitor...$reset_color"
open -a "PHP Monitor" 2>/dev/null

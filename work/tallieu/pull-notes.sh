echo -e "$fg_bold[cyan]Pulling notes...$reset_color"

PREV_DIR=$(pwd)

cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Intilli/Tallieu\ \&\ Tallieu

git pull

cd "$PREV_DIR"
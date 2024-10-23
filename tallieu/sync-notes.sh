echo -e "$fg_bold[magenta]Syncing notes...$reset_color"

PREV_DIR=$(pwd)

cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Intilli/Tallieu\ \&\ Tallieu

git pull

git add .

git commit -m "Add notes"

git push

cd "$PREV_DIR"
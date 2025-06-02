echo -e "$fg_bold[magenta]Syncing notes...$reset_color"

PREV_DIR=$(pwd)

cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Intilli/Tallieu\ \&\ Tallieu

git pull

git add .

if [ -n "$1" ]; then
    git commit -m "$1"
else
    git commit -m "Add notes"
fi

git push

cd "$PREV_DIR"
if [ -z "$1" ]; then
    echo -e "$fg_bold[red][✗] Error: project is required$reset_color"
    return
fi

echo -e "$fg_bold[magenta]Opening $1 in PhpStorm$reset_color"
open -a /Applications/PhpStorm.app ~/Development/tnt/$1
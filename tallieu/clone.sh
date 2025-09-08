cd ~/Development/tnt

if [ -z "$1" ]; then
    echo -e "$fg_bold[red][✗] Error: repository is required$reset_color"
    return
fi

if [[ $2 =~ ^(-gh|--github) ]]
then
  echo -e "$fg_bold[magenta]Cloning $1 into ~/Development/tnt/$1$reset_color"
  git clone https://github.com/TallieuTallieu/$1.git
  cd "$1"
elif [[ $1 =~ ^(-gh|--github) ]]
then
  echo -e "$fg_bold[magenta]Cloning $2 into ~/Development/tnt/$2$reset_color"
  git clone https://github.com/TallieuTallieu/$2.git
  cd "$2"
else
  echo -e "$fg_bold[magenta]Cloning $1 into ~/Development/tnt/$1$reset_color"
  git clone https://nathangeerincktnt@bitbucket.org/tallieu/$1.git
  cd "$1"
fi
cd ~/Development/tnt

if [[ $2 =~ ^(-gh|--github) ]]
then
  git clone https://github.com/TallieuTallieu/$1.git
  cd "$1"
elif [[ $1 =~ ^(-gh|--github) ]]
then
  git clone https://github.com/TallieuTallieu/$2.git
  cd "$2"
else
  git clone https://nathangeerincktnt@bitbucket.org/tallieu/$1.git
  cd "$1"
fi
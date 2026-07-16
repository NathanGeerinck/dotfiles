# Template for .env, which is gitignored. Every value is a 1Password secret
# reference, so the secrets live in the vault and never in this repo.
#
# Generate or refresh .env with:
#
#   op inject -f -i .env.tpl -o .env
#
# bin/install does this for you on a new machine. Rerun it yourself after
# rotating a token in 1Password.

# Intilli
NGROK_AUTHTOKEN_INTILLI="{{ op://Intilli/Ngrok/authtoken }}"

# Tallieu & Tallieu
# The vault is addressed by ID rather than name: "Tallieu & Tallieu" contains an
# "&", which op rejects as an illegal character in a secret reference.
NGROK_AUTHTOKEN_TNT="{{ op://enpwdmtwnekrxdbriapr3y6yw4/Ngrok/authtoken }}"
SHORTCUT_KEY_TNT="{{ op://enpwdmtwnekrxdbriapr3y6yw4/Shortcut/apikey }}"

# Template for .env, which is gitignored. Every value is a 1Password secret
# reference, so the secrets live in the vault and never in this repo.
#
# Generate or refresh .env with:
#
#   op inject -f -i .env.tpl -o .env
#
# bin/install does this for you on a new machine. Rerun it yourself after
# rotating a token in 1Password.

## Intilli
NGROK_AUTHTOKEN_INTILLI="{{ op://Intilli/Ngrok/authtoken }}"

# The Ploi CLI prefers this over the token it writes to ~/.ploi/config.php, so
# the token stays in 1Password and `ploi token` never has to run.
PLOI_API_TOKEN="{{ op://Intilli/ploi.io/api-token }}"

# Bearer token for the intilli.be Nodux MCP server. Referenced at runtime from
# ~/.claude.json as ${INTILLI_MCP_TOKEN}, so the value stays out of that file.
INTILLI_MCP_TOKEN="{{ op://Intilli/4noskpqknmotse7aacyt5k6fqi/mcp-token }}"

## Tallieu & Tallieu
# The vault is addressed by ID rather than name: "Tallieu & Tallieu" contains an
# "&", which op rejects as an illegal character in a secret reference.
NGROK_AUTHTOKEN_TNT="{{ op://enpwdmtwnekrxdbriapr3y6yw4/Ngrok/authtoken }}"
SHORTCUT_KEY_TNT="{{ op://enpwdmtwnekrxdbriapr3y6yw4/Shortcut/apikey }}"

# bin/bb authenticates with Basic auth, so it needs the Atlassian account email
# next to the token. Both come from one API Credential item, where `username`
# holds the email and `credential` the token. See the Bitbucket section of the
# readme for how to create it.
BITBUCKET_EMAIL_TNT="{{ op://enpwdmtwnekrxdbriapr3y6yw4/Bitbucket API Token/username }}"
BITBUCKET_TOKEN_TNT="{{ op://enpwdmtwnekrxdbriapr3y6yw4/Bitbucket API Token/credential }}"

## Personal
# The second Bitbucket account, used for LaraBug testing. bin/bb picks between
# the two by looking at the workspace in the git remote: tallieu gets the T&T
# token, everything else gets this one.
BITBUCKET_EMAIL_PERSONAL="{{ op://Personal/Bitbucket API Token/username }}"
BITBUCKET_TOKEN_PERSONAL="{{ op://Personal/Bitbucket API Token/credential }}"

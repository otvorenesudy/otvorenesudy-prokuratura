#!/usr/bin/env bash
# PreToolUse (Bash) hook: blocks a shell command that names a file holding secrets, so an agent never reads, prints,
# copies or decrypts one. In .claude/settings.json the Read and Edit deny rules keep Claude's file tools away from
# these files and sandbox.filesystem.denyRead keeps sandboxed commands away; this hook also covers commands that run
# outside the sandbox. Keep the three lists in sync. The same script guards every otvorenesudy repository:
#
#   .env, .env.*                  dotenv files (every repository): .env, .env.test, .env.local and .env.*.local hold
#                                 each machine's settings and aren't committed. Of the committed ones, .env.example
#                                 and .env.sample are fine; .env.test.example and CI's .env.ci hold no secrets but are
#                                 blocked like the rest, so a person edits them
#   config/configuration.yml      otvorenesudy's secrets; its .example and .travis templates are fine
#   secret_token.rb               otvorenesudy's session secret initializer, and the token in its history
#   config/credentials*, *.yml.enc, *.key, credentials:show and credentials:edit
#                                 Rails credentials and the keys that decrypt them (every repository)
#   *.pem, *.p12, *.pfx, id_rsa, *_rsa, *_ed25519, .netrc, .npmrc, .pgpass, .vault_pass*
#                                 certificates, private keys and logins
#   db-backup-<date>.gz           production database dumps
#   /tmp/<user>.pgpassword        database passwords otvorenesudy-server's postgresql role generates where it runs
#
# stdin: the hook's JSON, with .tool_input.command. Exit 2 blocks the command and tells the agent which name it found.
set -euo pipefail

command=$(jq -r '.tool_input.command // empty')

# Where a name starts and ends in a command: whitespace, a path separator, quotes, redirections and the like.
start='(^|[[:space:]/"'"'"'`=(:<>])'
end='($|[[:space:]"'"'"'`;|&)<>,:])'

patterns=(
  # .env and .env.<name>; not Rails.env or process.env, which follow a letter.
  "${start}\.env(\.[[:alnum:]_-]+)*${end}"
  # The file itself, not configuration.yml.example or .travis.
  "configuration\.yml${end}"
  "secret_token\.rb"
  "config/credentials"
  "\.yml\.enc${end}"
  "credentials:(show|edit)"
  # A file name ending in .key; not jq's .key or Ruby's hash.keys and key?, which don't follow a file name.
  "[[:alnum:]_*-]\.key${end}"
  "[[:alnum:]_*-]\.(pem|p12|pfx)${end}"
  "(id_rsa|[[:alnum:]_-]_rsa|[[:alnum:]_-]_ed25519)${end}"
  "${start}\.(netrc|npmrc|pgpass|vault_pass[[:alnum:]_.-]*)${end}"
  "db-backup-[0-9]"
  "[[:alnum:]_*-]\.pgpassword${end}"
)

for pattern in "${patterns[@]}"; do
  while IFS= read -r match; do
    [[ -z "$match" || "$match" =~ \.env\.(example|sample) ]] && continue
    echo "Blocked: this command names a file that holds secrets (${match//[[:space:]]/}). Agents never read, print," \
      "copy or decrypt them; ask the user to run it." >&2
    exit 2
  done < <(grep -oE -- "$pattern" <<<"$command" || true)
done

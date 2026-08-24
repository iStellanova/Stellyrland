{
  pkgs,
  curl,
  jq,
}:
pkgs.writeShellScript "nix-fleet-build-notify" ''
  set -euo pipefail
  report=$1
  . /run/secrets/hermes-discord.env
  channel=1540710403892453477

  send() {
    local content=$1
    ${curl} --fail-with-body -sS -X POST \
      -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
      -H 'Content-Type: application/json' \
      --retry 5 --retry-delay 10 --retry-max-time 120 \
      --data "$(${jq} -nc --arg content "$content" '{content:$content}')" \
      "https://discord.com/api/v10/channels/$channel/messages" >/dev/null
  }

  message=
  while IFS= read -r line || [ -n "$line" ]; do
    candidate=$line
    [ -z "$message" ] || candidate="$message
  $line"
    if [ ''${#candidate} -gt 1900 ] && [ -n "$message" ]; then
      send "$message"
      message=$line
    else
      message=$candidate
    fi
  done <"$report"
  [ -z "$message" ] || send "$message"
''

{
  pkgs,
  curl,
  jq,
  discordChannel,
}:
pkgs.writeShellScript "nix-fleet-build-notify" ''
    set -euo pipefail
    report=$1
    channel=${discordChannel}
    . /run/secrets/hermes-discord.env

    send() {
      local content=$1
      local payload
      payload=$(${jq} -nc --arg content "$content" '{content:$content}')
      ${curl} --fail-with-body -sS -X POST \
        -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
        -H 'Content-Type: application/json' \
        --data "$payload" \
        "https://discord.com/api/v10/channels/$channel/messages" >/dev/null
    }

    message=
    while IFS= read -r line || [ -n "$line" ]; do
      candidate=$line
      if [ -n "$message" ]; then
        candidate="$message
  $line"
      fi
      if [ ''${#candidate} -gt 1900 ] && [ -n "$message" ]; then
        send "$message"
        message=$line
      else
        message=$candidate
      fi
    done < "$report"
    [ -z "$message" ] || send "$message"
''

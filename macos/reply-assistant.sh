#!/bin/bash
# Reply Assistant for macOS - Quick Action (right-click → Services)
# Works in any app that supports macOS Services
#
# Setup:
#   1. Open Automator → New → Quick Action
#   2. Set "Workflow receives current" to "text" in "any application"
#   3. Add "Run Shell Script" action
#   4. Shell: /bin/bash, Pass input: "as arguments"
#   5. Paste this script (with your Gateway URL and Token)
#   6. Save as "Reply Assistant"
#
# Requires: jq (brew install jq)

export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# --- Configuration ---
GATEWAY_URL="${REPLY_ASSISTANT_GATEWAY_URL:-http://127.0.0.1:18789}"
GATEWAY_TOKEN="${REPLY_ASSISTANT_GATEWAY_TOKEN:-YOUR_TOKEN_HERE}"
MODEL="${REPLY_ASSISTANT_MODEL:-claude-sonnet-4-5-20250929}"
# ---------------------

SELECTED="$@"

if [ -z "$SELECTED" ]; then
  osascript -e 'display notification "No text selected" with title "Reply Assistant ❌"'
  exit 1
fi

PROMPT="以下のメッセージに対する返信文を作成してください。
相手のメッセージのトーンに合わせて自然な返信を書いてください。
返信文のみを出力してください。

---
${SELECTED}
---"

ESCAPED=$(printf '%s' "$PROMPT" | jq -Rs .)

RESPONSE=$(curl -s \
  -H "Authorization: Bearer ${GATEWAY_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"model\":\"${MODEL}\",\"messages\":[{\"role\":\"user\",\"content\":${ESCAPED}}]}" \
  "${GATEWAY_URL}/v1/chat/completions")

REPLY=$(echo "$RESPONSE" | jq -r '.choices[0].message.content')

if [ -z "$REPLY" ] || [ "$REPLY" = "null" ]; then
  osascript -e 'display notification "Failed to generate reply" with title "Reply Assistant ❌"'
  exit 1
fi

osascript -e "set the clipboard to \"$REPLY\""

afplay /System/Library/Sounds/Glass.aiff

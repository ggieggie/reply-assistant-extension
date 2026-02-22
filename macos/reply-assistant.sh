#!/bin/bash
# Reply Assistant for macOS - works in any app
# Usage: Assign this script to a global hotkey via macOS Shortcuts or Automator
#
# Setup:
#   1. Set REPLY_ASSISTANT_GATEWAY_URL and REPLY_ASSISTANT_GATEWAY_TOKEN below (or as env vars)
#   2. chmod +x reply-assistant.sh
#   3. Create a macOS Shortcut → "Run Shell Script" → path to this script
#   4. Assign a keyboard shortcut to the Shortcut (System Settings → Keyboard → Keyboard Shortcuts → Services)

GATEWAY_URL="${REPLY_ASSISTANT_GATEWAY_URL:-http://127.0.0.1:18789}"
GATEWAY_TOKEN="${REPLY_ASSISTANT_GATEWAY_TOKEN:-}"
TONE="${1:-normal}"  # normal, casual, formal

if [ -z "$GATEWAY_TOKEN" ]; then
  osascript -e 'display notification "Gateway Tokenが未設定です" with title "Reply Assistant ❌"'
  exit 1
fi

# Get selected text via AppleScript
SELECTED=$(osascript -e '
tell application "System Events"
  keystroke "c" using command down
  delay 0.3
end tell
the clipboard as text
')

if [ -z "$SELECTED" ]; then
  osascript -e 'display notification "テキストが選択されていません" with title "Reply Assistant ❌"'
  exit 1
fi

# Show processing notification
osascript -e 'display notification "返信を生成中..." with title "Reply Assistant ✨"'

# Tone instructions
case "$TONE" in
  casual)
    TONE_TEXT="カジュアルでフレンドリーなトーンで返信を書いてください。"
    ;;
  formal)
    TONE_TEXT="ビジネスにふさわしい丁寧な敬語で返信を書いてください。"
    ;;
  *)
    TONE_TEXT="相手のメッセージのトーンに合わせて自然な返信を書いてください。"
    ;;
esac

PROMPT="以下のメッセージに対する返信文を作成してください。
${TONE_TEXT}
返信文のみを出力してください（「返信：」などの接頭辞は不要）。

---
${SELECTED}
---"

# Escape for JSON
PROMPT_JSON=$(echo "$PROMPT" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')

# Call OpenClaw Gateway
RESPONSE=$(curl -s -X POST "${GATEWAY_URL}/v1/chat/completions" \
  -H "Authorization: Bearer ${GATEWAY_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"claude-sonnet-4-5-20250929\",
    \"messages\": [{\"role\": \"user\", \"content\": ${PROMPT_JSON}}],
    \"max_tokens\": 1000
  }")

# Extract reply
REPLY=$(echo "$RESPONSE" | python3 -c '
import sys, json
try:
    data = json.load(sys.stdin)
    print(data["choices"][0]["message"]["content"].strip())
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
')

if [ $? -ne 0 ] || [ -z "$REPLY" ]; then
  osascript -e 'display notification "返信の生成に失敗しました" with title "Reply Assistant ❌"'
  exit 1
fi

# Copy to clipboard
echo -n "$REPLY" | pbcopy

# Show success notification
osascript -e "display notification \"クリップボードにコピーしました\" with title \"Reply Assistant ✅\""

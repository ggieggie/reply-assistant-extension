#!/bin/bash
# Install Reply Assistant as a macOS Quick Action (right-click service)
# This creates a .workflow that appears in right-click → Services menu

WORKFLOW_DIR="$HOME/Library/Services"
WORKFLOW_NAME="Reply Assistant.workflow"
WORKFLOW_PATH="$WORKFLOW_DIR/$WORKFLOW_NAME"

GATEWAY_URL="${1:-http://100.95.221.64:18789}"
GATEWAY_TOKEN="${2:-}"

if [ -z "$GATEWAY_TOKEN" ]; then
  echo "Usage: ./install-service.sh <gateway-url> <gateway-token>"
  echo "Example: ./install-service.sh http://100.95.221.64:18789 your-token-here"
  exit 1
fi

# Remove old version
rm -rf "$WORKFLOW_PATH"
mkdir -p "$WORKFLOW_PATH/Contents"

# Create Info.plist
cat > "$WORKFLOW_PATH/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSServices</key>
	<array>
		<dict>
			<key>NSMenuItem</key>
			<dict>
				<key>default</key>
				<string>Reply Assistant</string>
			</dict>
			<key>NSMessage</key>
			<string>runWorkflowAsService</string>
			<key>NSSendTypes</key>
			<array>
				<string>NSStringPboardType</string>
			</array>
		</dict>
	</array>
</dict>
</plist>
PLIST

# Create the workflow document
cat > "$WORKFLOW_PATH/Contents/document.wflow" << WFLOW
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AMApplicationBuild</key>
	<string>523</string>
	<key>AMApplicationVersion</key>
	<string>2.10</string>
	<key>AMDocumentVersion</key>
	<string>2</string>
	<key>actions</key>
	<array>
		<dict>
			<key>action</key>
			<dict>
				<key>AMAccepts</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Optional</key>
					<true/>
					<key>Types</key>
					<array>
						<string>com.apple.cocoa.string</string>
					</array>
				</dict>
				<key>AMActionVersion</key>
				<string>2.0.3</string>
				<key>AMApplication</key>
				<array>
					<string>Automator</string>
				</array>
				<key>AMBundleIdentifier</key>
				<string>com.apple.RunShellScript</string>
				<key>AMCategory</key>
				<array>
					<string>AMCategoryUtilities</string>
				</array>
				<key>AMIconName</key>
				<string>Run Shell Script</string>
				<key>AMKeywords</key>
				<array>
					<string>Shell</string>
					<string>Script</string>
				</array>
				<key>AMName</key>
				<string>シェルスクリプトを実行</string>
				<key>AMProvides</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Types</key>
					<array>
						<string>com.apple.cocoa.string</string>
					</array>
				</dict>
				<key>AMRequiredResources</key>
				<array/>
				<key>ActionBundlePath</key>
				<string>/System/Library/Automator/Run Shell Script.action</string>
				<key>ActionName</key>
				<string>シェルスクリプトを実行</string>
				<key>ActionParameters</key>
				<dict>
					<key>COMMAND_STRING</key>
					<string>export REPLY_ASSISTANT_GATEWAY_URL="${GATEWAY_URL}"
export REPLY_ASSISTANT_GATEWAY_TOKEN="${GATEWAY_TOKEN}"

TONE="normal"
SELECTED="\$@"

if [ -z "\$SELECTED" ]; then
  osascript -e 'display notification "テキストが選択されていません" with title "Reply Assistant ❌"'
  exit 1
fi

osascript -e 'display notification "返信を生成中..." with title "Reply Assistant ✨"'

case "\$TONE" in
  casual) TONE_TEXT="カジュアルでフレンドリーなトーンで返信を書いてください。" ;;
  formal) TONE_TEXT="ビジネスにふさわしい丁寧な敬語で返信を書いてください。" ;;
  *) TONE_TEXT="相手のメッセージのトーンに合わせて自然な返信を書いてください。" ;;
esac

PROMPT="以下のメッセージに対する返信文を作成してください。
\${TONE_TEXT}
返信文のみを出力してください（「返信：」などの接頭辞は不要）。

---
\${SELECTED}
---"

PROMPT_JSON=\$(echo "\$PROMPT" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')

RESPONSE=\$(curl -s -X POST "\${REPLY_ASSISTANT_GATEWAY_URL}/v1/chat/completions" \
  -H "Authorization: Bearer \${REPLY_ASSISTANT_GATEWAY_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{
    \"model\": \"claude-sonnet-4-5-20250929\",
    \"messages\": [{\"role\": \"user\", \"content\": \${PROMPT_JSON}}],
    \"max_tokens\": 1000
  }")

REPLY=\$(echo "\$RESPONSE" | python3 -c '
import sys, json
try:
    data = json.load(sys.stdin)
    print(data["choices"][0]["message"]["content"].strip())
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
')

if [ \$? -ne 0 ] || [ -z "\$REPLY" ]; then
  osascript -e 'display notification "返信の生成に失敗しました" with title "Reply Assistant ❌"'
  exit 1
fi

echo -n "\$REPLY" | pbcopy
osascript -e 'display notification "クリップボードにコピーしました" with title "Reply Assistant ✅"'</string>
					<key>CheckedForUserDefaultShell</key>
					<true/>
					<key>inputMethod</key>
					<integer>1</integer>
					<key>shell</key>
					<string>/bin/bash</string>
					<key>source</key>
					<string></string>
				</dict>
				<key>BundleIdentifier</key>
				<string>com.apple.RunShellScript</string>
				<key>CFBundleVersion</key>
				<string>2.0.3</string>
				<key>CanShowSelectedItemsWhenRun</key>
				<false/>
				<key>CanShowWhenRun</key>
				<true/>
				<key>Category</key>
				<array>
					<string>AMCategoryUtilities</string>
				</array>
				<key>Class Name</key>
				<string>RunShellScriptAction</string>
				<key>InputUUID</key>
				<string>A1A1A1A1-A1A1-A1A1-A1A1-A1A1A1A1A1A1</string>
				<key>Keywords</key>
				<array>
					<string>Shell</string>
					<string>Script</string>
				</array>
				<key>OutputUUID</key>
				<string>B2B2B2B2-B2B2-B2B2-B2B2-B2B2B2B2B2B2</string>
				<key>UUID</key>
				<string>C3C3C3C3-C3C3-C3C3-C3C3-C3C3C3C3C3C3</string>
				<key>UnlocalizedApplications</key>
				<array>
					<string>Automator</string>
				</array>
				<key>arguments</key>
				<dict>
					<key>0</key>
					<dict>
						<key>default value</key>
						<string>/bin/bash</string>
						<key>name</key>
						<string>shell</string>
						<key>required</key>
						<string>YES</string>
						<key>type</key>
						<integer>8</integer>
					</dict>
					<key>1</key>
					<dict>
						<key>default value</key>
						<string></string>
						<key>name</key>
						<string>source</string>
						<key>required</key>
						<string>NO</string>
						<key>type</key>
						<integer>8</integer>
					</dict>
				</dict>
				<key>isViewVisible</key>
				<integer>1</integer>
				<key>location</key>
				<string>449.000000:620.000000</string>
				<key>nibPath</key>
				<string>/System/Library/Automator/Run Shell Script.action/Contents/Resources/Base.lproj/main.nib</string>
			</dict>
		</dict>
	</array>
	<key>connectors</key>
	<dict/>
	<key>workflowMetaData</key>
	<dict>
		<key>serviceInputTypeIdentifier</key>
		<string>com.apple.Automator.text</string>
		<key>serviceOutputTypeIdentifier</key>
		<string>com.apple.Automator.nothing</string>
		<key>serviceProcessesInput</key>
		<integer>0</integer>
		<key>workflowTypeIdentifier</key>
		<string>com.apple.Automator.servicesMenu</string>
	</dict>
</dict>
</plist>
WFLOW

echo "✅ Reply Assistant installed!"
echo "   Location: $WORKFLOW_PATH"
echo ""
echo "📌 Usage:"
echo "   1. Select text in any app"
echo "   2. Right-click → Services → Reply Assistant"
echo "   3. Wait for notification"
echo "   4. ⌘V to paste the reply"
echo ""
echo "🔑 To add a keyboard shortcut:"
echo "   System Settings → Keyboard → Keyboard Shortcuts → Services → Reply Assistant"

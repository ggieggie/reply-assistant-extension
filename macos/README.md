# Reply Assistant for macOS 🍎

Use AI-powered reply generation from **any app** via right-click → Services menu.

## Requirements

- macOS 12+
- [jq](https://jqlang.github.io/jq/) (`brew install jq`)
- An OpenAI-compatible API endpoint (e.g. OpenClaw Gateway)

## Setup

1. Open **Automator** (search in Spotlight)
2. **File → New → Quick Action**
3. Configure the top bar:
   - Workflow receives current: **text**
   - in: **any application**
4. From the left panel, drag **"Run Shell Script"** into the workflow
5. Set:
   - Shell: `/bin/bash`
   - Pass input: **as arguments**
6. Paste the contents of `reply-assistant.sh` into the script area
7. **Replace** `YOUR_TOKEN_HERE` with your actual API token
8. **Replace** your Gateway URL with your Gateway URL
9. **⌘S** to save, name it "Reply Assistant"

## Usage

1. Select text in any app
2. Right-click → **Services** → **Reply Assistant**
3. Wait for the 🔔 sound
4. **⌘V** to paste the generated reply

## Configuration

Edit these variables in the script:

| Variable | Description | Default |
|----------|-------------|---------|
| `GATEWAY_URL` | API endpoint base URL | your Gateway URL |
| `GATEWAY_TOKEN` | API authentication token | (required) |
| `MODEL` | Model to use | `claude-sonnet-4-5-20250929` |

> **Tip**: If accessing via Tailscale, use your Tailscale IP (e.g. `http://your-tailscale-ip:PORT`)

## Keyboard Shortcut (Optional)

1. **System Settings** → **Keyboard** → **Keyboard Shortcuts** → **Services**
2. Find "Reply Assistant"
3. Assign a shortcut (e.g. `⌘⇧R`)

## Key Learnings

- Automator's shell environment has a limited `PATH` — use `export PATH=...` at the top
- Use `jq` for JSON escaping (more reliable than python in Automator context)
- Use `osascript -e 'set the clipboard to ...'` instead of `pbcopy`
- Use `afplay` for completion sound instead of `display notification` (more reliable)

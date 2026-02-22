# Reply Assistant 💬

Select text → AI generates a reply → Paste it. That's it.

Works as a **Chrome Extension** (browser) and a **macOS Quick Action** (any desktop app).

Both use an OpenAI-compatible API endpoint (e.g. [OpenClaw](https://github.com/openclaw/openclaw) Gateway).

## Chrome Extension

### Requirements

- Google Chrome (or Chromium-based browser)
- An OpenAI-compatible API endpoint

### Installation

1. Open Chrome and go to `chrome://extensions/`
2. Enable **Developer mode** (toggle in the top right)
3. Click **"Load unpacked"**
4. Select this repository's root folder (the one containing `manifest.json`)
5. The Reply Assistant icon should appear in your toolbar

### Configuration

1. Click the Reply Assistant icon in the toolbar
2. Set your **Gateway URL** (e.g. `http://127.0.0.1:18789`)
3. Set your **Gateway Token**
4. Click Save

> **Tailscale users**: If accessing from another machine, use your Tailscale IP (e.g. `http://100.x.x.x:18789`) and add it to `host_permissions` in `manifest.json`:
> ```json
> "host_permissions": [
>   "http://127.0.0.1:18789/*",
>   "http://100.x.x.x:18789/*"
> ]
> ```

### Usage

1. Select text on any webpage
2. Right-click → **Reply Assistant** → Choose tone:
   - **返信を生成** (auto-match tone)
   - **返信を生成（カジュアル）** (casual)
   - **返信を生成（丁寧）** (formal)
3. A toast notification appears with the generated reply
4. The reply is automatically copied to your clipboard
5. **⌘V** (or Ctrl+V) to paste

---

## macOS Quick Action (Automator)

Use Reply Assistant from **any desktop app** — Slack, Mail, TextEdit, and more — via the right-click Services menu.

### Requirements

- macOS 12+
- [jq](https://jqlang.github.io/jq/) — install with `brew install jq`
- An OpenAI-compatible API endpoint

### Installation

#### Step 1: Install jq (if not already installed)

```bash
brew install jq
```

#### Step 2: Create the Quick Action in Automator

1. Open **Automator** (Spotlight → search "Automator")
2. Click **File → New** (or select **Quick Action** from the template chooser)
3. Configure the top bar:
   - **Workflow receives current**: `text`
   - **in**: `any application`
4. In the left panel, search for **"Run Shell Script"** and drag it into the workflow area
5. Set:
   - **Shell**: `/bin/bash`
   - **Pass input**: `as arguments`
6. Open `macos/reply-assistant.sh` from this repo, copy its entire contents
7. Paste into the script area in Automator, replacing the default `cat` command
8. **Edit the configuration** at the top of the script:
   - Replace `YOUR_TOKEN_HERE` with your actual API token
   - Replace `http://127.0.0.1:18789` with your Gateway URL
9. **⌘S** to save — name it **"Reply Assistant"**

#### Step 3: Grant permissions (if prompted)

- **System Settings → Privacy & Security → Accessibility** → Enable **Automator**
- If you see a notification prompt, click Allow

### Usage

1. Select text in any app
2. Right-click → **Services** → **Reply Assistant**
3. Wait for the 🔔 completion sound
4. **⌘V** to paste the generated reply

### Add a Keyboard Shortcut (Optional)

1. **System Settings** → **Keyboard** → **Keyboard Shortcuts** → **Services** → **Text**
2. Find **"Reply Assistant"** in the list
3. Click "none" and assign a shortcut (e.g. `⌘⇧R`)

Now you can select text and press `⌘⇧R` instead of right-clicking!

### Troubleshooting

| Problem | Solution |
|---------|----------|
| "Reply Assistant" doesn't appear in Services | Run `/System/Library/CoreServices/pbs -update` in Terminal, then restart the app |
| No sound / no response | Check that `jq` is installed: `which jq` |
| "Failed to generate reply" notification | Verify your Gateway URL and Token are correct |
| Works in some apps but not others | Electron apps (Slack desktop, VS Code) may not support macOS Services — use the browser version instead |

### Key Learnings

- Automator's shell has a limited `PATH` — the script exports common paths at the top
- `jq` is more reliable than `python3` for JSON escaping in the Automator context
- `osascript -e 'set the clipboard to ...'` works better than `pbcopy` in Automator
- `afplay` for completion sound is more reliable than `display notification`

---

## Configuration Reference

| Variable / Setting | Description | Default |
|---|---|---|
| `GATEWAY_URL` / Gateway URL | Your OpenAI-compatible API base URL | `http://127.0.0.1:18789` |
| `GATEWAY_TOKEN` / Gateway Token | API authentication token | (required) |
| `MODEL` | Model name (macOS version only) | `claude-sonnet-4-5-20250929` |

## Project Structure

```
reply-assistant-extension/
├── manifest.json        # Chrome extension manifest
├── background.js        # Chrome extension background script
├── popup.html           # Chrome extension settings UI
├── popup.js             # Chrome extension settings logic
├── icons/               # Extension icons
│   ├── icon16.png
│   ├── icon48.png
│   └── icon128.png
├── macos/               # macOS Automator version
│   ├── reply-assistant.sh   # Shell script for Quick Action
│   └── README.md            # macOS-specific docs
├── LICENSE              # MIT License
└── README.md            # This file
```

## License

MIT — see [LICENSE](LICENSE)

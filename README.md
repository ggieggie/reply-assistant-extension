# Reply Assistant ✉️

A Chrome extension that generates AI-powered replies from selected text.

Select text → Right-click → AI generates a reply → Copied to clipboard.

Works on Gmail, Slack, and any webpage.

## Features

- 🎯 **3 tone options**: Natural, Casual, Formal (business keigo)
- 📋 **Auto clipboard copy** with toast notification
- 🔒 **Privacy-first**: Communicates only with your local/self-hosted OpenClaw Gateway
- 🌐 **Multi-language**: Japanese (default), English, Chinese, Korean

## Setup

1. Clone this repo
2. Open `chrome://extensions` in Chrome
3. Enable "Developer mode" (top-right)
4. Click "Load unpacked" → select this folder
5. Click the extension icon → set your Gateway URL and Token

## Usage

1. Select the text you want to reply to
2. Right-click → "返信文を生成" (Generate Reply)
3. Toast notification appears → text is already in your clipboard
4. Paste with `Ctrl+V` / `Cmd+V`

## Requirements

- [OpenClaw](https://github.com/openclaw/openclaw) running with Gateway HTTP endpoint enabled
- Gateway Token (from your OpenClaw config)

## Configuration

| Field | Description | Example |
|-------|-------------|---------|
| Gateway URL | Your OpenClaw Gateway base URL | `http://127.0.0.1:18789` |
| Gateway Token | Bearer token for authentication | (from openclaw config) |
| Language | Reply language | Japanese / English / etc. |

> **Note**: If accessing via Tailscale, use your Tailscale IP (e.g. `http://100.x.x.x:18789`) and add the IP to `host_permissions` in `manifest.json`.

## How It Works

Uses OpenClaw Gateway's OpenAI-compatible `/v1/chat/completions` endpoint with Claude Sonnet.

## License

MIT

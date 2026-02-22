# Reply Assistant for macOS 🍎

Chrome拡張と同じ機能を **全アプリ** で使えるmacOS版。

Slack、LINE、メール、ターミナル…どのアプリでもテキスト選択→ホットキーでAI返信生成。

## セットアップ

### 1. 環境変数を設定

`~/.zshrc` に追加：

```bash
export REPLY_ASSISTANT_GATEWAY_URL="http://127.0.0.1:18789"
export REPLY_ASSISTANT_GATEWAY_TOKEN="your-token-here"
```

Tailscale経由の場合：
```bash
export REPLY_ASSISTANT_GATEWAY_URL="http://100.x.x.x:18789"
```

### 2. macOS ショートカットを作成

1. **ショートカット.app** を開く
2. 新規ショートカットを作成
3. 「シェルスクリプトを実行」アクションを追加
4. スクリプトに以下を入力：

```bash
/path/to/reply-assistant.sh normal
```

トーン別に3つ作るのがおすすめ：
- `reply-assistant.sh normal` → 自然
- `reply-assistant.sh casual` → カジュアル  
- `reply-assistant.sh formal` → 丁寧

### 3. キーボードショートカットを割り当て

1. **システム設定** → **キーボード** → **キーボードショートカット** → **サービス**
2. 作成したショートカットを探す
3. ホットキーを割り当て（例: `⌘⇧R`）

## 使い方

1. テキストを選択
2. ホットキー（`⌘⇧R`）を押す
3. 通知が表示 → クリップボードにコピー済み
4. `⌘V` で貼り付け

## 動作の仕組み

1. AppleScript で `⌘C` → 選択テキスト取得
2. OpenClaw Gateway API で返信生成
3. `pbcopy` でクリップボードにセット
4. macOS通知で完了を知らせる

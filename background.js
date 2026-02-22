// コンテキストメニュー登録
chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.create({
    id: 'generate-reply',
    title: '返信文を生成',
    contexts: ['selection'],
  });
  chrome.contextMenus.create({
    id: 'generate-reply-casual',
    title: '返信文を生成（カジュアル）',
    contexts: ['selection'],
  });
  chrome.contextMenus.create({
    id: 'generate-reply-formal',
    title: '返信文を生成（丁寧）',
    contexts: ['selection'],
  });
});

// コンテキストメニュークリック
chrome.contextMenus.onClicked.addListener(async (info, tab) => {
  if (!info.selectionText) return;

  let tone = 'normal';
  if (info.menuItemId === 'generate-reply-casual') tone = 'casual';
  if (info.menuItemId === 'generate-reply-formal') tone = 'formal';

  // ローディング通知を表示
  await chrome.scripting.executeScript({
    target: { tabId: tab.id },
    func: showLoading,
  });

  try {
    const reply = await generateReply(info.selectionText, tone);
    
    // クリップボードにコピー & 通知表示
    await chrome.scripting.executeScript({
      target: { tabId: tab.id },
      func: copyAndNotify,
      args: [reply],
    });
  } catch (e) {
    await chrome.scripting.executeScript({
      target: { tabId: tab.id },
      func: showError,
      args: [e.message],
    });
  }
});

// OpenClaw Gateway APIで返信文生成
async function generateReply(text, tone) {
  const config = await chrome.storage.sync.get({
    gatewayUrl: 'http://127.0.0.1:18789',
    gatewayToken: '',
    language: 'ja',
  });

  if (!config.gatewayToken) {
    throw new Error('Gateway Tokenが未設定です。拡張のポップアップから設定してください。');
  }

  const toneInstructions = {
    normal: '相手のメッセージのトーンに合わせて自然な返信を書いてください。',
    casual: 'カジュアルでフレンドリーなトーンで返信を書いてください。',
    formal: 'ビジネスにふさわしい丁寧な敬語で返信を書いてください。',
  };

  const prompt = `以下のメッセージに対する返信文を作成してください。
${toneInstructions[tone]}
返信文のみを出力してください（「返信：」などの接頭辞は不要）。

---
${text}
---`;

  const res = await fetch(`${config.gatewayUrl}/v1/chat/completions`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${config.gatewayToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'claude-sonnet-4-5-20250929',
      messages: [{ role: 'user', content: prompt }],
      max_tokens: 1000,
    }),
  });

  if (!res.ok) {
    const err = await res.text();
    throw new Error(`API Error: ${res.status} ${err}`);
  }

  const data = await res.json();
  return data.choices?.[0]?.message?.content?.trim() || '返信の生成に失敗しました';
}

// コンテンツスクリプト関数: ローディング表示
function showLoading() {
  // 既存の通知を削除
  document.querySelectorAll('.reply-assistant-toast').forEach(el => el.remove());
  
  const toast = document.createElement('div');
  toast.className = 'reply-assistant-toast';
  toast.innerHTML = '✨ 返信を生成中...';
  toast.style.cssText = `
    position: fixed; top: 20px; right: 20px; z-index: 999999;
    background: #1a1a2e; color: #e0e0e0; padding: 16px 24px;
    border-radius: 12px; font-size: 14px; font-family: -apple-system, sans-serif;
    box-shadow: 0 8px 32px rgba(0,0,0,0.3); border: 1px solid #333;
    animation: slideIn 0.3s ease;
  `;
  const style = document.createElement('style');
  style.textContent = `
    @keyframes slideIn { from { transform: translateX(100px); opacity: 0; } to { transform: translateX(0); opacity: 1; } }
    @keyframes slideOut { from { transform: translateX(0); opacity: 1; } to { transform: translateX(100px); opacity: 0; } }
  `;
  document.head.appendChild(style);
  document.body.appendChild(toast);
}

// コンテンツスクリプト関数: コピー & 通知
function copyAndNotify(text) {
  navigator.clipboard.writeText(text).then(() => {
    document.querySelectorAll('.reply-assistant-toast').forEach(el => el.remove());
    
    const toast = document.createElement('div');
    toast.className = 'reply-assistant-toast';
    toast.innerHTML = `
      <div style="font-weight:600;margin-bottom:8px;">✅ クリップボードにコピーしました</div>
      <div style="font-size:12px;color:#aaa;max-height:120px;overflow-y:auto;white-space:pre-wrap;">${text.replace(/</g, '&lt;').substring(0, 500)}</div>
    `;
    toast.style.cssText = `
      position: fixed; top: 20px; right: 20px; z-index: 999999;
      background: #1a1a2e; color: #e0e0e0; padding: 16px 24px;
      border-radius: 12px; font-size: 14px; font-family: -apple-system, sans-serif;
      box-shadow: 0 8px 32px rgba(0,0,0,0.3); border: 1px solid #2d7d46;
      max-width: 400px; animation: slideIn 0.3s ease; cursor: pointer;
    `;
    toast.onclick = () => {
      toast.style.animation = 'slideOut 0.3s ease';
      setTimeout(() => toast.remove(), 300);
    };
    document.body.appendChild(toast);
    
    // 5秒後に自動消去
    setTimeout(() => {
      if (toast.parentNode) {
        toast.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => toast.remove(), 300);
      }
    }, 5000);
  });
}

// コンテンツスクリプト関数: エラー表示
function showError(message) {
  document.querySelectorAll('.reply-assistant-toast').forEach(el => el.remove());
  
  const toast = document.createElement('div');
  toast.className = 'reply-assistant-toast';
  toast.innerHTML = `❌ ${message}`;
  toast.style.cssText = `
    position: fixed; top: 20px; right: 20px; z-index: 999999;
    background: #2e1a1a; color: #e0e0e0; padding: 16px 24px;
    border-radius: 12px; font-size: 14px; font-family: -apple-system, sans-serif;
    box-shadow: 0 8px 32px rgba(0,0,0,0.3); border: 1px solid #7d2d2d;
    animation: slideIn 0.3s ease; cursor: pointer;
  `;
  toast.onclick = () => toast.remove();
  document.body.appendChild(toast);
  setTimeout(() => toast.remove(), 5000);
}

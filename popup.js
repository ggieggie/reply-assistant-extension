// 保存済み設定を読み込み
chrome.storage.sync.get({
  gatewayUrl: 'http://127.0.0.1:18789',
  gatewayToken: '',
  language: 'ja',
}, (config) => {
  document.getElementById('gatewayUrl').value = config.gatewayUrl;
  document.getElementById('gatewayToken').value = config.gatewayToken;
  document.getElementById('language').value = config.language;
});

// 保存
document.getElementById('save').addEventListener('click', () => {
  const config = {
    gatewayUrl: document.getElementById('gatewayUrl').value.trim(),
    gatewayToken: document.getElementById('gatewayToken').value.trim(),
    language: document.getElementById('language').value,
  };
  
  chrome.storage.sync.set(config, () => {
    const status = document.getElementById('status');
    status.textContent = '✅ 保存しました';
    setTimeout(() => { status.textContent = ''; }, 2000);
  });
});

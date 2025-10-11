describe('CSS Text Segment Break Transformation', () => {
  it('should transform segment breaks to spaces for English text', async () => {
    const div = document.createElement('div');
    div.lang = 'en';
    div.style.width = '300px';
    div.innerHTML = `This is an English paragraph
that is broken into multiple lines
in the source code so that it can
be more easily read and edited.`;
    document.body.appendChild(div);

    await snapshot();
  });

  it('should remove segment breaks between Chinese characters', async () => {
    const div = document.createElement('div');
    div.lang = 'zh';
    div.style.width = '300px';
    div.innerHTML = `這個段落是那麼長，
在一行寫不行。最好
用三行寫。`;
    document.body.appendChild(div);

    await snapshot();
  });

  it('should handle Chinese text with quotation marks', async () => {
    const div = document.createElement('div');
    div.lang = 'zh';
    div.style.width = '300px';
    div.innerHTML = `他說：
"你好，
世界！"`;
    document.body.appendChild(div);

    await snapshot();
  });

  it('should handle mixed Chinese and English text', async () => {
    const div = document.createElement('div');
    div.lang = 'zh';
    div.style.width = '300px';
    div.innerHTML = `WebF 是一個
高性能的
cross-platform
渲染引擎。`;
    document.body.appendChild(div);

    await snapshot();
  });

  it('should remove segment breaks for Japanese text', async () => {
    const div = document.createElement('div');
    div.lang = 'ja';
    div.style.width = '300px';
    div.innerHTML = `これは日本語の
段落です。改行が
自動的に削除されます。`;
    document.body.appendChild(div);

    await snapshot();
  });

  it('should remove segment breaks for Korean text', async () => {
    const div = document.createElement('div');
    div.lang = 'ko';
    div.style.width = '300px';
    div.innerHTML = `이것은 한국어
단락입니다. 줄바꿈이
자동으로 제거됩니다.`;
    document.body.appendChild(div);

    await snapshot();
  });

  it('should preserve segment breaks with white-space: pre', async () => {
    const div = document.createElement('div');
    div.lang = 'zh';
    div.style.whiteSpace = 'pre';
    div.style.fontFamily = 'monospace';
    div.innerHTML = `這個段落
保留了
所有換行符。`;
    document.body.appendChild(div);

    await snapshot();
  });

  it('should preserve segment breaks with white-space: pre-line', async () => {
    const div = document.createElement('div');
    div.lang = 'zh';
    div.style.whiteSpace = 'pre-line';
    div.innerHTML = `這個段落保留了
換行符但是
空格被壓縮了。`;
    document.body.appendChild(div);

    await snapshot();
  });

  it('should handle ambiguous characters in CJK context', async () => {
    const div = document.createElement('div');
    div.lang = 'zh';
    div.style.width = '300px';
    div.innerHTML = `使用括號
（像這樣）
和引號
"像這樣"
都不會有多餘空格。`;
    document.body.appendChild(div);

    await snapshot();
  });

  it('should keep space for Hangul Jamo with other text', async () => {
    const div = document.createElement('div');
    div.lang = 'ko';
    div.style.width = '300px';
    div.innerHTML = `한글 자모 ᄀ
다른 텍스트`;
    document.body.appendChild(div);

    await snapshot();
  });
});

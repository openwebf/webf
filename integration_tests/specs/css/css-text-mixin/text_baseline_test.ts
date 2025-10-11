/**
 * Test specs for CSS text baseline selection based on locale
 * Tests the getTextBaseLine() method improvements
 */

describe('CSS Text Baseline Selection', () => {
  it('should use alphabetic baseline for Latin text by default', async (done) => {
    const container = document.createElement('div');
    container.innerHTML = '<p>Hello World</p>';
    document.body.appendChild(container);

    // Test that Latin text uses alphabetic baseline
    const p = container.querySelector('p') as HTMLElement;
    p.style.fontSize = '20px';
    p.style.lineHeight = '1.5';

    requestAnimationFrame(async () => {
      // Verify the text is rendered with alphabetic baseline
      const rect = p.getBoundingClientRect();
      expect(rect.height).toBeGreaterThan(0);
      expect(rect.width).toBeGreaterThan(0);
      
      await snapshot();
      document.body.removeChild(container);
      done();
    });
  });

  it('should use ideographic baseline for Chinese text with lang attribute', async (done) => {
    const container = document.createElement('div');
    container.setAttribute('lang', 'zh-CN');
    container.innerHTML = '<p>你好世界</p>';
    document.body.appendChild(container);

    const p = container.querySelector('p') as HTMLElement;
    p.style.fontSize = '20px';
    p.style.lineHeight = '1.5';

    requestAnimationFrame(async () => {
      // Verify Chinese text is rendered
      const rect = p.getBoundingClientRect();
      expect(rect.height).toBeGreaterThan(0);
      expect(rect.width).toBeGreaterThan(0);
      
      await snapshot();
      document.body.removeChild(container);
      done();
    });
  });

  it('should use ideographic baseline for Japanese text with lang attribute', async (done) => {
    const container = document.createElement('div');
    container.setAttribute('lang', 'ja');
    container.innerHTML = '<p>こんにちは世界</p>';
    document.body.appendChild(container);

    const p = container.querySelector('p') as HTMLElement;
    p.style.fontSize = '20px';
    p.style.lineHeight = '1.5';

    requestAnimationFrame(async () => {
      // Verify Japanese text is rendered
      const rect = p.getBoundingClientRect();
      expect(rect.height).toBeGreaterThan(0);
      expect(rect.width).toBeGreaterThan(0);
      
      await snapshot();
      document.body.removeChild(container);
      done();
    });
  });

  it('should use ideographic baseline for Korean text with lang attribute', async (done) => {
    const container = document.createElement('div');
    container.setAttribute('lang', 'ko');
    container.innerHTML = '<p>안녕하세요 세계</p>';
    document.body.appendChild(container);

    const p = container.querySelector('p') as HTMLElement;
    p.style.fontSize = '20px';
    p.style.lineHeight = '1.5';

    requestAnimationFrame(async () => {
      // Verify Korean text is rendered
      const rect = p.getBoundingClientRect();
      expect(rect.height).toBeGreaterThan(0);
      expect(rect.width).toBeGreaterThan(0);
      
      await snapshot();
      document.body.removeChild(container);
      done();
    });
  });

  it('should inherit lang attribute from ancestor elements', async (done) => {
    const container = document.createElement('div');
    container.setAttribute('lang', 'zh-CN');
    container.innerHTML = `
      <div>
        <section>
          <p>中文文本</p>
        </section>
      </div>
    `;
    document.body.appendChild(container);

    const p = container.querySelector('p') as HTMLElement;
    p.style.fontSize = '18px';

    requestAnimationFrame(async () => {
      // Verify nested element inherits lang attribute for baseline selection
      const rect = p.getBoundingClientRect();
      expect(rect.height).toBeGreaterThan(0);
      expect(rect.width).toBeGreaterThan(0);
      
      await snapshot();
      document.body.removeChild(container);
      done();
    });
  });

  it('should fall back to document lang attribute', async (done) => {
    // Set document lang
    const originalLang = document.documentElement.lang;
    document.documentElement.lang = 'ja';

    const container = document.createElement('div');
    container.innerHTML = '<p>日本語テキスト</p>';
    document.body.appendChild(container);

    const p = container.querySelector('p') as HTMLElement;
    p.style.fontSize = '18px';

    requestAnimationFrame(async () => {
      // Verify document lang fallback works
      const rect = p.getBoundingClientRect();
      expect(rect.height).toBeGreaterThan(0);
      expect(rect.width).toBeGreaterThan(0);
      
      await snapshot();
      document.body.removeChild(container);
      // Restore original lang
      document.documentElement.lang = originalLang;
      done();
    });
  });

  it('should handle mixed content with different baselines', async (done) => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div>
        <span lang="en">English</span>
        <span lang="zh">中文</span>
        <span lang="ja">日本語</span>
      </div>
    `;
    document.body.appendChild(container);

    const spans = container.querySelectorAll('span');
    spans.forEach(span => {
      (span as HTMLElement).style.fontSize = '16px';
      (span as HTMLElement).style.display = 'inline-block';
      (span as HTMLElement).style.margin = '0 5px';
    });

    requestAnimationFrame(async () => {
      // Verify all spans are rendered properly with their respective baselines
      spans.forEach(span => {
        const rect = span.getBoundingClientRect();
        expect(rect.height).toBeGreaterThan(0);
        expect(rect.width).toBeGreaterThan(0);
      });
      
      await snapshot();
      document.body.removeChild(container);
      done();
    });
  });

  it('should use alphabetic baseline for unknown language codes', async (done) => {
    const container = document.createElement('div');
    container.setAttribute('lang', 'unknown-lang');
    container.innerHTML = '<p>Unknown language text</p>';
    document.body.appendChild(container);

    const p = container.querySelector('p') as HTMLElement;
    p.style.fontSize = '18px';

    requestAnimationFrame(async () => {
      // Verify unknown languages fall back to alphabetic baseline
      const rect = p.getBoundingClientRect();
      expect(rect.height).toBeGreaterThan(0);
      expect(rect.width).toBeGreaterThan(0);
      
      await snapshot();
      document.body.removeChild(container);
      done();
    });
  });

  it('should handle complex locale formats correctly', async (done) => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div lang="zh-Hans-CN">简体中文</div>
      <div lang="zh-Hant-TW">繁體中文</div>
      <div lang="ja-JP">日本語</div>
      <div lang="ko-KR">한국어</div>
    `;
    document.body.appendChild(container);

    const divs = container.querySelectorAll('div');
    divs.forEach(div => {
      (div as HTMLElement).style.fontSize = '16px';
      (div as HTMLElement).style.margin = '5px 0';
    });

    requestAnimationFrame(async () => {
      // Verify complex locale formats are parsed correctly
      divs.forEach(div => {
        const rect = div.getBoundingClientRect();
        expect(rect.height).toBeGreaterThan(0);
        expect(rect.width).toBeGreaterThan(0);
      });
      
      await snapshot();
      document.body.removeChild(container);
      done();
    });
  });
});
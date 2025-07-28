/**
 * Test specs for CSS locale support
 * Tests the getLocale() method and lang attribute hierarchy
 */

describe('CSS Locale Support', () => {
  afterEach(() => {
    // Clean up any changes to document lang
    document.documentElement.removeAttribute('lang');
  });

  it('should extract locale from element lang attribute', async (done) => {
    const container = document.createElement('div');
    container.innerHTML = '<p lang="fr-FR">Bonjour le monde</p>';
    document.body.appendChild(container);

    const p = container.querySelector('p') as HTMLElement;
    p.style.fontSize = '18px';
    p.style.fontFamily = 'serif';

    requestAnimationFrame(async () => {
      // Verify French text is rendered
      const rect = p.getBoundingClientRect();
      expect(rect.height).toBeGreaterThan(0);
      expect(rect.width).toBeGreaterThan(0);
      
      await snapshot();
      document.body.removeChild(container);
      done();
    });
  });

  it('should inherit locale from parent elements', async (done) => {
    const container = document.createElement('div');
    container.setAttribute('lang', 'de-DE');
    container.innerHTML = `
      <article>
        <section>
          <p>Hallo Welt</p>
        </section>
      </article>
    `;
    document.body.appendChild(container);

    const p = container.querySelector('p') as HTMLElement;
    p.style.fontSize = '18px';
    p.style.fontFamily = 'sans-serif';

    requestAnimationFrame(async () => {
      // Verify German text inherits locale from ancestor
      const rect = p.getBoundingClientRect();
      expect(rect.height).toBeGreaterThan(0);
      expect(rect.width).toBeGreaterThan(0);
      
      await snapshot();
      document.body.removeChild(container);
      done();
    });
  });

  it('should override parent locale with closer lang attribute', async (done) => {
    const container = document.createElement('div');
    container.setAttribute('lang', 'en-US');
    container.innerHTML = `
      <div>
        <section lang="es-ES">
          <p>Hola mundo</p>
        </section>
      </div>
    `;
    document.body.appendChild(container);

    const p = container.querySelector('p') as HTMLElement;
    p.style.fontSize = '18px';
    p.style.fontFamily = 'sans-serif';

    requestAnimationFrame(async () => {
      // Verify Spanish text overrides English parent locale
      const rect = p.getBoundingClientRect();
      expect(rect.height).toBeGreaterThan(0);
      expect(rect.width).toBeGreaterThan(0);
      
      await snapshot();
      document.body.removeChild(container);
      done();
    });
  });

  it('should fall back to document root lang attribute', async (done) => {
    document.documentElement.setAttribute('lang', 'it-IT');
    
    const container = document.createElement('div');
    container.innerHTML = '<p>Ciao mondo</p>';
    document.body.appendChild(container);

    const p = container.querySelector('p') as HTMLElement;
    p.style.fontSize = '18px';
    p.style.fontFamily = 'serif';

    requestAnimationFrame(async () => {
      // Verify Italian text uses document root locale
      const rect = p.getBoundingClientRect();
      expect(rect.height).toBeGreaterThan(0);
      expect(rect.width).toBeGreaterThan(0);
      
      await snapshot();
      document.body.removeChild(container);
      done();
    });
  });

  it('should handle empty and invalid lang attributes gracefully', async (done) => {
    const container = document.createElement('div');
    container.innerHTML = `
      <p lang="">Empty lang</p>
      <p lang="invalid-">Invalid lang</p>
      <p>No lang attribute</p>
    `;
    document.body.appendChild(container);

    const paragraphs = container.querySelectorAll('p');
    paragraphs.forEach(p => {
      (p as HTMLElement).style.fontSize = '16px';
      (p as HTMLElement).style.margin = '5px 0';
    });

    requestAnimationFrame(async () => {
      // Verify all paragraphs render despite invalid lang attributes
      paragraphs.forEach(p => {
        const rect = p.getBoundingClientRect();
        expect(rect.height).toBeGreaterThan(0);
        expect(rect.width).toBeGreaterThan(0);
      });
      
      await snapshot();
      document.body.removeChild(container);
      done();
    });
  });

  it('should support complex locale hierarchies', async (done) => {
    const container = document.createElement('div');
    container.setAttribute('lang', 'en-US');
    container.innerHTML = `
      <article lang="zh-CN">
        <section>
          <h1>中文标题</h1>
          <div lang="ja-JP">
            <p>日本語の段落</p>
            <span lang="ko-KR">한국어 텍스트</span>
          </div>
        </section>
      </article>
    `;
    document.body.appendChild(container);

    const elements = container.querySelectorAll('h1, p, span');
    elements.forEach(el => {
      (el as HTMLElement).style.fontSize = '16px';
      (el as HTMLElement).style.display = 'block';
      (el as HTMLElement).style.margin = '5px 0';
    });

    requestAnimationFrame(async () => {
      // Verify complex locale hierarchy works correctly
      elements.forEach(el => {
        const rect = el.getBoundingClientRect();
        expect(rect.height).toBeGreaterThan(0);
        expect(rect.width).toBeGreaterThan(0);
      });
      
      await snapshot();
      document.body.removeChild(container);
      done();
    });
  });

  it('should handle locale-specific text rendering differences', async (done) => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="text-group">
        <p lang="ar" dir="rtl">مرحبا بالعالم</p>
        <p lang="he" dir="rtl">שלום עולם</p>
        <p lang="th">สวัสดีชาวโลก</p>
        <p lang="hi">नमस्ते दुनिया</p>
      </div>
    `;
    document.body.appendChild(container);

    const paragraphs = container.querySelectorAll('p');
    paragraphs.forEach(p => {
      (p as HTMLElement).style.fontSize = '18px';
      (p as HTMLElement).style.margin = '10px 0';
      (p as HTMLElement).style.padding = '5px';
      (p as HTMLElement).style.border = '1px solid #ccc';
    });

    requestAnimationFrame(async () => {
      // Verify different script systems render correctly
      paragraphs.forEach(p => {
        const rect = p.getBoundingClientRect();
        expect(rect.height).toBeGreaterThan(0);
        expect(rect.width).toBeGreaterThan(0);
      });
      
      await snapshot();
      document.body.removeChild(container);
      done();
    });
  });

  it('should maintain locale context across dynamic updates', async (done) => {
    const container = document.createElement('div');
    container.setAttribute('lang', 'ru-RU');
    container.innerHTML = '<p>Привет мир</p>';
    document.body.appendChild(container);

    const p = container.querySelector('p') as HTMLElement;
    p.style.fontSize = '18px';

    // First render
    requestAnimationFrame(async () => {
      const rect1 = p.getBoundingClientRect();
      expect(rect1.height).toBeGreaterThan(0);
      expect(rect1.width).toBeGreaterThan(0);

      // Change locale dynamically
      container.setAttribute('lang', 'pt-BR');
      p.textContent = 'Olá mundo';

      // Second render
      requestAnimationFrame(async () => {
        const rect2 = p.getBoundingClientRect();
        expect(rect2.height).toBeGreaterThan(0);
        expect(rect2.width).toBeGreaterThan(0);
        
        await snapshot();
        document.body.removeChild(container);
        done();
      });
    });
  });

  it('should parse locale components correctly', async (done) => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div lang="zh-Hans-CN">简体中文</div>
      <div lang="zh-Hant-HK">繁體中文</div>
      <div lang="en-US-x-private">English with private use</div>
      <div lang="sr-Cyrl-RS">Српски ћирилица</div>
      <div lang="sr-Latn-RS">Srpski latinica</div>
    `;
    document.body.appendChild(container);

    const divs = container.querySelectorAll('div');
    divs.forEach(div => {
      (div as HTMLElement).style.fontSize = '16px';
      (div as HTMLElement).style.margin = '5px 0';
      (div as HTMLElement).style.padding = '5px';
    });

    requestAnimationFrame(async () => {
      // Verify complex locale formats are handled correctly
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
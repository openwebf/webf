/**
 * Comprehensive test specs for all CSSTextMixin improvements
 * Tests the integration of baseline selection, locale support, color optimization, and text effects
 */

describe('CSS Text Comprehensive Integration', () => {
  it('should combine locale-based baselines with text effects', async (done) => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="multilingual-effects">
        <div lang="en" style="
          background: linear-gradient(45deg, #667eea, #764ba2);
          background-clip: text;
          -webkit-background-clip: text;
          color: transparent;
          font-size: 20px;
        ">
          English Gradient Text
        </div>
        
        <div lang="zh-CN" style="
          background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
          background-clip: text;
          -webkit-background-clip: text;
          color: transparent;
          font-size: 20px;
        ">
          中文渐变文字
        </div>
        
        <div lang="ja" style="
          background: linear-gradient(45deg, #a8edea, #fed6e3);
          background-clip: text;
          -webkit-background-clip: text;
          color: transparent;
          font-size: 20px;
        ">
          日本語グラデーション
        </div>
        
        <div lang="ar" dir="rtl" style="
          background: linear-gradient(45deg, #ffecd2, #fcb69f);
          background-clip: text;
          -webkit-background-clip: text;
          color: transparent;
          font-size: 20px;
        ">
          النص العربي المتدرج
        </div>
      </div>
    `;
    document.body.appendChild(container);

    const textElements = container.querySelectorAll('div > div');
    textElements.forEach(el => {
      (el as HTMLElement).style.margin = '10px 0';
      (el as HTMLElement).style.padding = '10px';
    });

    requestAnimationFrame(async () => {
      // Verify all multilingual text with effects renders correctly
      textElements.forEach(el => {
        const rect = el.getBoundingClientRect();
        expect(rect.height).toBeGreaterThan(0);
        expect(rect.width).toBeGreaterThan(0);
      });
      
      await snapshot();
      document.body.removeChild(container);
      done();
    });
  });

  xit('should handle currentColor with locale-specific text and gradients', async (done) => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div lang="ko" style="color: #ff4757;">
        <div style="
          border: 3px solid currentColor;
          text-decoration-color: currentColor;
          background: linear-gradient(90deg, currentColor, transparent);
          padding: 15px;
        ">
          <span style="
            background-clip: text;
            -webkit-background-clip: text;
            background: linear-gradient(45deg, #2ed573, #1e90ff);
            color: transparent;
            font-size: 18px;
          ">
            한국어 텍스트 효과
          </span>
          
          <p style="
            color: currentColor;
            font-size: 16px;
            margin: 10px 0;
          ">
            CurrentColor Korean text
          </p>
        </div>
      </div>
    `;
    document.body.appendChild(container);

    const outerDiv = container.querySelector('div') as HTMLElement;
    const span = container.querySelector('span') as HTMLElement;
    const p = container.querySelector('p') as HTMLElement;

    requestAnimationFrame(async () => {
      // Initial verification
      let spanRect = span.getBoundingClientRect();
      let pRect = p.getBoundingClientRect();
      
      expect(spanRect.height).toBeGreaterThan(0);
      expect(spanRect.width).toBeGreaterThan(0);
      expect(pRect.height).toBeGreaterThan(0);
      expect(pRect.width).toBeGreaterThan(0);

      // Change color to test currentColor optimization
      outerDiv.style.color = '#3742fa';
      
      requestAnimationFrame(async () => {
        // Verify elements still render after color change
        spanRect = span.getBoundingClientRect();
        pRect = p.getBoundingClientRect();
        
        expect(spanRect.height).toBeGreaterThan(0);
        expect(spanRect.width).toBeGreaterThan(0);
        expect(pRect.height).toBeGreaterThan(0);
        expect(pRect.width).toBeGreaterThan(0);
        
        await snapshot();
        document.body.removeChild(container);
        done();
      });
    });
  });

  it('should optimize performance with complex multilingual layouts', async (done) => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="performance-test" style="color: #2f3542;">
        ${['en', 'zh-CN', 'ja', 'ko', 'ar', 'th', 'hi', 'ru'].map((lang, i) => `
          <section lang="${lang}" style="
            border-color: currentColor;
            text-decoration-color: currentColor;
            border: 2px solid;
            margin: 5px 0;
            padding: 10px;
          ">
            <div style="
              background: linear-gradient(${45 * i}deg, 
                hsl(${i * 45}, 60%, 50%), 
                hsl(${(i * 45 + 90) % 360}, 60%, 70%)
              );
              background-clip: text;
              -webkit-background-clip: text;
              color: transparent;
              font-size: 16px;
              font-weight: 600;
            ">
              ${lang === 'en' ? 'English Text' :
                lang === 'zh-CN' ? '中文文本' :
                lang === 'ja' ? '日本語テキスト' :
                lang === 'ko' ? '한국어 텍스트' :
                lang === 'ar' ? 'النص العربي' :
                lang === 'th' ? 'ข้อความไทย' :
                lang === 'hi' ? 'हिंदी पाठ' :
                'Русский текст'}
            </div>
            <p style="
              color: currentColor;
              font-size: 14px;
              margin: 5px 0;
            ">
              Supporting text in ${lang}
            </p>
          </section>
        `).join('')}
      </div>
    `;
    document.body.appendChild(container);

    const performanceTest = container.querySelector('.performance-test') as HTMLElement;
    const sections = container.querySelectorAll('section');

    requestAnimationFrame(async () => {
      // Verify all sections render
      sections.forEach(section => {
        const gradientDiv = section.querySelector('div') as HTMLElement;
        const p = section.querySelector('p') as HTMLElement;
        
        const divRect = gradientDiv.getBoundingClientRect();
        const pRect = p.getBoundingClientRect();
        
        expect(divRect.height).toBeGreaterThan(0);
        expect(divRect.width).toBeGreaterThan(0);
        expect(pRect.height).toBeGreaterThan(0);
        expect(pRect.width).toBeGreaterThan(0);
      });

      // Test performance of color updates
      const startTime = performance.now();
      performanceTest.style.color = '#ff3838';
      
      requestAnimationFrame(async () => {
        const endTime = performance.now();
        const updateTime = endTime - startTime;
        
        // Should update efficiently (under 100ms for this complex test)
        expect(updateTime).toBeLessThan(100);
        
        // Verify all elements still render after update
        sections.forEach(section => {
          const gradientDiv = section.querySelector('div') as HTMLElement;
          const p = section.querySelector('p') as HTMLElement;
          
          const divRect = gradientDiv.getBoundingClientRect();
          const pRect = p.getBoundingClientRect();
          
          expect(divRect.height).toBeGreaterThan(0);
          expect(divRect.width).toBeGreaterThan(0);
          expect(pRect.height).toBeGreaterThan(0);
          expect(pRect.width).toBeGreaterThan(0);
        });
        
        await snapshot();
        document.body.removeChild(container);
        done();
      });
    });
  });

  it('should handle complex text inheritance hierarchies', async (done) => {
    const container = document.createElement('div');
    container.innerHTML = `
      <article lang="en" style="color: #2c2c54;">
        <header style="
          background: linear-gradient(135deg, #667eea, #764ba2);
          background-clip: text;
          -webkit-background-clip: text;
          color: transparent;
          font-size: 24px;
          font-weight: bold;
        ">
          Article Header
        </header>
        
        <section lang="zh-CN" style="border-color: currentColor; border: 2px solid; padding: 15px;">
          <h2 style="
            background: linear-gradient(90deg, #ff6b6b, #4ecdc4);
            background-clip: text;
            -webkit-background-clip: text;
            color: transparent;
            font-size: 20px;
          ">
            中文标题
          </h2>
          
          <div lang="ja" style="
            text-decoration-color: currentColor;
            text-decoration: underline;
            margin: 10px 0;
          ">
            <span style="
              background: linear-gradient(45deg, #a8edea, #fed6e3);
              background-clip: text;
              -webkit-background-clip: text;
              color: transparent;
              font-size: 16px;
            ">
              日本語の内容
            </span>
            
            <p style="color: currentColor; font-size: 14px;">
              Japanese supporting text
            </p>
          </div>
        </section>
        
        <footer style="
          background-color: currentColor;
          color: white;
          padding: 10px;
          margin-top: 15px;
        ">
          <small>Footer with inherited color background</small>
        </footer>
      </article>
    `;
    document.body.appendChild(container);

    const article = container.querySelector('article') as HTMLElement;
    const header = container.querySelector('header') as HTMLElement;
    const h2 = container.querySelector('h2') as HTMLElement;
    const span = container.querySelector('span') as HTMLElement;
    const p = container.querySelector('p') as HTMLElement;
    const footer = container.querySelector('footer') as HTMLElement;

    requestAnimationFrame(async () => {
      // Verify all nested elements render correctly
      [header, h2, span, p, footer].forEach(el => {
        const rect = el.getBoundingClientRect();
        expect(rect.height).toBeGreaterThan(0);
        expect(rect.width).toBeGreaterThan(0);
      });

      // Test inheritance updates
      article.style.color = '#ff4757';
      
      requestAnimationFrame(async () => {
        // Verify elements still render after inheritance change
        [header, h2, span, p, footer].forEach(el => {
          const rect = el.getBoundingClientRect();
          expect(rect.height).toBeGreaterThan(0);
          expect(rect.width).toBeGreaterThan(0);
        });
        
        await snapshot();
        document.body.removeChild(container);
        done();
      });
    });
  });

  it('should maintain text quality when changing text size', async (done) => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="dynamic-layout" lang="zh-CN" style="color: #2f3640;">
        <div class="text-content" style="
          background: linear-gradient(45deg, #ff9ff3, #f368e0);
          background-clip: text;
          -webkit-background-clip: text;
          color: transparent;
          font-size: 18px;
          transition: all 0.3s ease;
        ">
          动态布局中文文本
        </div>

        <div class="controls">
          <button class="size-btn" style="
            background-color: currentColor;
            color: white;
            border: none;
            padding: 8px 16px;
            margin: 5px;
            cursor: pointer;
          ">
            Change Size
          </button>

          <button class="color-btn" style="
            border: 2px solid currentColor;
            background: transparent;
            color: currentColor;
            padding: 8px 16px;
            margin: 5px;
            cursor: pointer;
          ">
            Change Color
          </button>
        </div>
      </div>
    `;
    document.body.appendChild(container);

    const dynamicLayout = container.querySelector('.dynamic-layout') as HTMLElement;
    const textContent = container.querySelector('.text-content') as HTMLElement;
    const sizeBtn = container.querySelector('.size-btn') as HTMLElement;
    const colorBtn = container.querySelector('.color-btn') as HTMLElement;

    dynamicLayout.style.padding = '20px';

    requestAnimationFrame(async () => {
      // Initial snapshot
      await snapshot();

      // Change text size
      textContent.style.fontSize = '24px';
      textContent.style.fontWeight = 'bold';

      requestAnimationFrame(async () => {
        // Verify all elements still render correctly
        const textRect = textContent.getBoundingClientRect();
        const sizeBtnRect = sizeBtn.getBoundingClientRect();
        const colorBtnRect = colorBtn.getBoundingClientRect();

        expect(textRect.height).toBeGreaterThan(0);
        expect(textRect.width).toBeGreaterThan(0);
        expect(sizeBtnRect.height).toBeGreaterThan(0);
        expect(sizeBtnRect.width).toBeGreaterThan(0);
        expect(colorBtnRect.height).toBeGreaterThan(0);
        expect(colorBtnRect.width).toBeGreaterThan(0);

        await snapshot();
        document.body.removeChild(container);
        done();
      });
    });
  });

  it('should maintain text quality when changing layout color', async (done) => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="dynamic-layout" lang="zh-CN" style="color: #2f3640;">
        <div class="text-content" style="
          background: linear-gradient(45deg, #ff9ff3, #f368e0);
          background-clip: text;
          -webkit-background-clip: text;
          color: transparent;
          font-size: 18px;
          transition: all 0.3s ease;
        ">
          动态布局中文文本
        </div>

        <div class="controls">
          <button class="size-btn" style="
            background-color: currentColor;
            color: white;
            border: none;
            padding: 8px 16px;
            margin: 5px;
            cursor: pointer;
          ">
            Change Size
          </button>

          <button class="color-btn" style="
            border: 2px solid currentColor;
            background: transparent;
            color: currentColor;
            padding: 8px 16px;
            margin: 5px;
            cursor: pointer;
          ">
            Change Color
          </button>
        </div>
      </div>
    `;
    document.body.appendChild(container);

    const dynamicLayout = container.querySelector('.dynamic-layout') as HTMLElement;
    const textContent = container.querySelector('.text-content') as HTMLElement;
    const sizeBtn = container.querySelector('.size-btn') as HTMLElement;
    const colorBtn = container.querySelector('.color-btn') as HTMLElement;

    dynamicLayout.style.padding = '20px';

    requestAnimationFrame(async () => {
      // Initial snapshot
      await snapshot();

      // Change layout color
      dynamicLayout.style.color = '#3c6382';

      requestAnimationFrame(async () => {
        // Verify all elements still render correctly
        const textRect = textContent.getBoundingClientRect();
        const sizeBtnRect = sizeBtn.getBoundingClientRect();
        const colorBtnRect = colorBtn.getBoundingClientRect();

        expect(textRect.height).toBeGreaterThan(0);
        expect(textRect.width).toBeGreaterThan(0);
        expect(sizeBtnRect.height).toBeGreaterThan(0);
        expect(sizeBtnRect.width).toBeGreaterThan(0);
        expect(colorBtnRect.height).toBeGreaterThan(0);
        expect(colorBtnRect.width).toBeGreaterThan(0);

        await snapshot(2);
        document.body.removeChild(container);
        done();
      });
    });
  });

  it('should maintain text quality when changing text gradient', async (done) => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="dynamic-layout" lang="zh-CN" style="color: #2f3640;">
        <div class="text-content" style="
          background: linear-gradient(45deg, #ff9ff3, #f368e0);
          background-clip: text;
          -webkit-background-clip: text;
          color: transparent;
          font-size: 18px;
          transition: all 0.3s ease;
        ">
          动态布局中文文本
        </div>

        <div class="controls">
          <button class="size-btn" style="
            background-color: currentColor;
            color: white;
            border: none;
            padding: 8px 16px;
            margin: 5px;
            cursor: pointer;
          ">
            Change Size
          </button>

          <button class="color-btn" style="
            border: 2px solid currentColor;
            background: transparent;
            color: currentColor;
            padding: 8px 16px;
            margin: 5px;
            cursor: pointer;
          ">
            Change Color
          </button>
        </div>
      </div>
    `;
    document.body.appendChild(container);

    const dynamicLayout = container.querySelector('.dynamic-layout') as HTMLElement;
    const textContent = container.querySelector('.text-content') as HTMLElement;
    const sizeBtn = container.querySelector('.size-btn') as HTMLElement;
    const colorBtn = container.querySelector('.color-btn') as HTMLElement;

    dynamicLayout.style.padding = '20px';

    requestAnimationFrame(async () => {
      // Initial snapshot
      await snapshot();

      // Change text gradient
      textContent.style.background = 'linear-gradient(90deg, #70a1ff, #5352ed)';

      requestAnimationFrame(async () => {
        // Verify all elements still render correctly
        const textRect = textContent.getBoundingClientRect();
        const sizeBtnRect = sizeBtn.getBoundingClientRect();
        const colorBtnRect = colorBtn.getBoundingClientRect();

        expect(textRect.height).toBeGreaterThan(0);
        expect(textRect.width).toBeGreaterThan(0);
        expect(sizeBtnRect.height).toBeGreaterThan(0);
        expect(sizeBtnRect.width).toBeGreaterThan(0);
        expect(colorBtnRect.height).toBeGreaterThan(0);
        expect(colorBtnRect.width).toBeGreaterThan(0);

        await snapshot(1);
        document.body.removeChild(container);
        done();
      });
    });
  });

  it('should maintain text quality when changing layout properties', async (done) => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="dynamic-layout" lang="zh-CN" style="color: #2f3640;">
        <div class="text-content" style="
          background: linear-gradient(45deg, #ff9ff3, #f368e0);
          background-clip: text;
          -webkit-background-clip: text;
          color: transparent;
          font-size: 18px;
          transition: all 0.3s ease;
        ">
          动态布局中文文本
        </div>

        <div class="controls">
          <button class="size-btn" style="
            background-color: currentColor;
            color: white;
            border: none;
            padding: 8px 16px;
            margin: 5px;
            cursor: pointer;
          ">
            Change Size
          </button>

          <button class="color-btn" style="
            border: 2px solid currentColor;
            background: transparent;
            color: currentColor;
            padding: 8px 16px;
            margin: 5px;
            cursor: pointer;
          ">
            Change Color
          </button>
        </div>
      </div>
    `;
    document.body.appendChild(container);

    const dynamicLayout = container.querySelector('.dynamic-layout') as HTMLElement;
    const textContent = container.querySelector('.text-content') as HTMLElement;
    const sizeBtn = container.querySelector('.size-btn') as HTMLElement;
    const colorBtn = container.querySelector('.color-btn') as HTMLElement;

    dynamicLayout.style.padding = '20px';

    requestAnimationFrame(async () => {
      // Initial snapshot
      await snapshot();

      // Change layout properties
      textContent.style.letterSpacing = '1px';
      textContent.style.lineHeight = '1.6';

      requestAnimationFrame(async () => {
        // Verify all elements still render correctly
        const textRect = textContent.getBoundingClientRect();
        const sizeBtnRect = sizeBtn.getBoundingClientRect();
        const colorBtnRect = colorBtn.getBoundingClientRect();

        expect(textRect.height).toBeGreaterThan(0);
        expect(textRect.width).toBeGreaterThan(0);
        expect(sizeBtnRect.height).toBeGreaterThan(0);
        expect(sizeBtnRect.width).toBeGreaterThan(0);
        expect(colorBtnRect.height).toBeGreaterThan(0);
        expect(colorBtnRect.width).toBeGreaterThan(0);

        await snapshot(1);
        document.body.removeChild(container);
        done();
      });
    });
  });
});
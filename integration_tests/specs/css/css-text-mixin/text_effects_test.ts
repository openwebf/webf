/**
 * Test specs for CSS text effects with background and foreground Paint support
 * Tests the getBackground() and getForeground() methods for text effects
 */

describe('CSS Text Effects with Paint Support', () => {
  it('should apply background-clip: text effect correctly', async (done) => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="gradient-text" style="
        background: linear-gradient(45deg, #ff6b6b, #4ecdc4, #45b7d1);
        background-clip: text;
        -webkit-background-clip: text;
        color: transparent;
        font-size: 24px;
        font-weight: bold;
      ">
        Gradient Text Effect
      </div>
    `;
    document.body.appendChild(container);

    const gradientText = container.querySelector('.gradient-text') as HTMLElement;
    gradientText.style.padding = '20px';

    requestAnimationFrame(async () => {
      // Verify gradient text is rendered
      const rect = gradientText.getBoundingClientRect();
      expect(rect.height).toBeGreaterThan(0);
      expect(rect.width).toBeGreaterThan(0);
      
      // Verify background-clip is applied
      const computedStyle = window.getComputedStyle(gradientText);
      expect(computedStyle.color).toBe('rgba(0, 0, 0, 0)');
      
      await snapshot();
      document.body.removeChild(container);
      done();
    });
  });

  it('should handle background Paint for text rendering', async (done) => {
    const container = document.createElement('div');
    container.innerHTML = `
      <p style="
        background-color: #ff4757;
        background-clip: text;
        -webkit-background-clip: text;
        color: transparent;
        font-size: 20px;
        font-weight: 600;
      ">
        Solid Color Background Text
      </p>
    `;
    document.body.appendChild(container);

    const p = container.querySelector('p') as HTMLElement;
    p.style.padding = '15px';

    requestAnimationFrame(async () => {
      // Verify text with background paint is rendered
      const rect = p.getBoundingClientRect();
      expect(rect.height).toBeGreaterThan(0);
      expect(rect.width).toBeGreaterThan(0);
      
      await snapshot();
      document.body.removeChild(container);
      done();
    });
  });

  it('should handle foreground Paint for text rendering', async (done) => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div style="
        background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
        background-clip: text;
        -webkit-background-clip: text;
        color: transparent;
        font-size: 18px;
      ">
        <span>Foreground gradient text</span>
      </div>
    `;
    document.body.appendChild(container);

    const div = container.querySelector('div') as HTMLElement;
    const span = container.querySelector('span') as HTMLElement;
    
    div.style.padding = '10px';
    span.style.display = 'block';

    requestAnimationFrame(async () => {
      // Verify foreground paint text is rendered
      const rect = span.getBoundingClientRect();
      expect(rect.height).toBeGreaterThan(0);
      expect(rect.width).toBeGreaterThan(0);
      
      await snapshot();
      document.body.removeChild(container);
      done();
    });
  });

  it('should combine background-clip with various text properties', async (done) => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="combined-effects">
        <h1 style="
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          background-clip: text;
          -webkit-background-clip: text;
          color: transparent;
          font-size: 32px;
          font-weight: bold;
          text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        ">
          Combined Text Effects
        </h1>
        
        <p style="
          background: radial-gradient(circle, #ff9a9e 0%, #fecfef 50%, #fecfef 100%);
          background-clip: text;
          -webkit-background-clip: text;
          color: transparent;
          font-size: 18px;
          font-style: italic;
          letter-spacing: 2px;
        ">
          Radial gradient with letter spacing
        </p>
      </div>
    `;
    document.body.appendChild(container);

    const h1 = container.querySelector('h1') as HTMLElement;
    const p = container.querySelector('p') as HTMLElement;
    
    h1.style.margin = '20px 0';
    p.style.margin = '15px 0';

    requestAnimationFrame(async () => {
      // Verify combined effects render correctly
      const h1Rect = h1.getBoundingClientRect();
      const pRect = p.getBoundingClientRect();
      
      expect(h1Rect.height).toBeGreaterThan(0);
      expect(h1Rect.width).toBeGreaterThan(0);
      expect(pRect.height).toBeGreaterThan(0);
      expect(pRect.width).toBeGreaterThan(0);
      
      await snapshot();
      document.body.removeChild(container);
      done();
    });
  });

  it('should handle dynamic background changes for text effects', async (done) => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="dynamic-text" style="
        background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
        background-clip: text;
        -webkit-background-clip: text;
        color: transparent;
        font-size: 22px;
        font-weight: 500;
      ">
        Dynamic Background Text
      </div>
    `;
    document.body.appendChild(container);

    const dynamicText = container.querySelector('.dynamic-text') as HTMLElement;
    dynamicText.style.padding = '15px';

    requestAnimationFrame(async () => {
      // Initial render
      const rect1 = dynamicText.getBoundingClientRect();
      expect(rect1.height).toBeGreaterThan(0);
      expect(rect1.width).toBeGreaterThan(0);

      // Change background gradient
      dynamicText.style.background = 'linear-gradient(90deg, #a8edea 0%, #fed6e3 100%)';
      
      requestAnimationFrame(async () => {
        // Verify text still renders with new background
        const rect2 = dynamicText.getBoundingClientRect();
        expect(rect2.height).toBeGreaterThan(0);
        expect(rect2.width).toBeGreaterThan(0);
        
        await snapshot();
        document.body.removeChild(container);
        done();
      });
    });
  });

  it('should handle multiple gradient text elements efficiently', async (done) => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="gradient-collection">
        ${Array.from({length: 8}, (_, i) => `
          <div class="gradient-item-${i}" style="
            background: linear-gradient(${45 * i}deg, 
              hsl(${i * 45}, 70%, 60%), 
              hsl(${(i * 45 + 120) % 360}, 70%, 60%)
            );
            background-clip: text;
            -webkit-background-clip: text;
            color: transparent;
            font-size: 16px;
            margin: 5px 0;
          ">
            Gradient Text ${i + 1}
          </div>
        `).join('')}
      </div>
    `;
    document.body.appendChild(container);

    const gradientItems = container.querySelectorAll('[class^="gradient-item-"]');

    requestAnimationFrame(async () => {
      // Verify all gradient texts render correctly
      gradientItems.forEach((item, index) => {
        const rect = item.getBoundingClientRect();
        expect(rect.height).toBeGreaterThan(0);
        expect(rect.width).toBeGreaterThan(0);
      });
      
      await snapshot();
      document.body.removeChild(container);
      done();
    });
  });

  it('should handle text effects with different writing modes', async (done) => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="writing-modes">
        <div style="
          writing-mode: horizontal-tb;
          background: linear-gradient(to right, #667eea, #764ba2);
          background-clip: text;
          -webkit-background-clip: text;
          color: transparent;
          font-size: 18px;
        ">
          Horizontal Text (LTR)
        </div>
        
        <div lang="ar" dir="rtl" style="
          writing-mode: horizontal-tb;
          background: linear-gradient(to left, #ffecd2, #fcb69f);
          background-clip: text;
          -webkit-background-clip: text;
          color: transparent;
          font-size: 18px;
        ">
          النص الأفقي (RTL)
        </div>
      </div>
    `;
    document.body.appendChild(container);

    const writingModes = container.querySelectorAll('div > div');
    writingModes.forEach(div => {
      (div as HTMLElement).style.margin = '10px';
      (div as HTMLElement).style.padding = '10px';
    });

    requestAnimationFrame(async () => {
      // Verify all writing modes with text effects render
      writingModes.forEach(div => {
        const rect = div.getBoundingClientRect();
        expect(rect.height).toBeGreaterThan(0);
        expect(rect.width).toBeGreaterThan(0);
      });
      
      await snapshot();
      document.body.removeChild(container);
      done();
    });
  });

  it('should maintain text effects during animations', async (done) => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="animated-text" style="
        background: linear-gradient(45deg, #ff6b6b, #4ecdc4, #45b7d1, #f9ca24);
        background-clip: text;
        -webkit-background-clip: text;
        color: transparent;
        font-size: 24px;
        font-weight: bold;
        transition: all 0.3s ease;
      ">
        Animated Gradient Text
      </div>
    `;
    document.body.appendChild(container);

    const animatedText = container.querySelector('.animated-text') as HTMLElement;
    animatedText.style.padding = '20px';

    let animationStep = 0;
    const animations = [
      () => { animatedText.style.fontSize = '28px'; },
      () => { animatedText.style.fontWeight = '900'; },
      () => { animatedText.style.letterSpacing = '2px'; },
      () => { animatedText.style.fontSize = '24px'; animatedText.style.letterSpacing = 'normal'; }
    ];

    const runAnimation = () => {
      if (animationStep < animations.length) {
        animations[animationStep]();
        animationStep++;
        
        setTimeout(() => {
          // Verify text still renders during animation
          const rect = animatedText.getBoundingClientRect();
          expect(rect.height).toBeGreaterThan(0);
          expect(rect.width).toBeGreaterThan(0);
          
          runAnimation();
        }, 100);
      } else {
        // Final verification
        requestAnimationFrame(async () => {
          await snapshot();
          document.body.removeChild(container);
          done();
        });
      }
    };

    requestAnimationFrame(async () => {
      // Initial verification
      const rect = animatedText.getBoundingClientRect();
      expect(rect.height).toBeGreaterThan(0);
      expect(rect.width).toBeGreaterThan(0);
      
      runAnimation();
    });
  });

  it('should handle fallback when background-clip is not supported', async (done) => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="fallback-text" style="
        background: linear-gradient(45deg, #667eea, #764ba2);
        background-clip: text;
        -webkit-background-clip: text;
        color: #333;
        font-size: 20px;
      ">
        Fallback Text Rendering
      </div>
    `;
    document.body.appendChild(container);

    const fallbackText = container.querySelector('.fallback-text') as HTMLElement;
    fallbackText.style.padding = '15px';

    requestAnimationFrame(async () => {
      // Should render whether background-clip is supported or not
      const rect = fallbackText.getBoundingClientRect();
      expect(rect.height).toBeGreaterThan(0);
      expect(rect.width).toBeGreaterThan(0);
      
      // Text should be visible in either case
      const computedStyle = window.getComputedStyle(fallbackText);
      expect(computedStyle.color).toBeTruthy();
      
      await snapshot();
      document.body.removeChild(container);
      done();
    });
  });
});
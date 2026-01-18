describe('CSS Cascade Layers: @media interaction', () => {
  const red = 'rgb(255, 0, 0)';
  const green = 'rgb(0, 128, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('media query inside a layer participates in cascade', async () => {
    await resizeViewport(300, 300);

    const style = appendStyle(`
      #target {
        width: 120px;
        height: 80px;
        line-height: 80px;
        display: inline-block;
        margin: 8px;
        text-align: center;
        background-color: currentColor;
      }
      @layer base { #target { color: ${red}; } }
      @layer utilities {
        @media (min-width: 500px) {
          #target { color: ${green}; }
        }
      }
    `);

    const target = document.createElement('div');
    target.id = 'target';
    target.textContent = 'target';
    document.body.appendChild(target);

    await snapshot();
    expect(getComputedStyle(target).color).toBe(red);

    await resizeViewport(500, 300);
    await snapshot();
    expect(getComputedStyle(target).color).toBe(green);

    style.remove();
    target.remove();
    await resizeViewport();
  });
});

describe('CSS Cascade Layers: WPT layer-media-query.html (non-import cases)', () => {
  const red = 'rgb(255, 0, 0)';
  const green = 'rgb(0, 128, 0)';

  beforeAll(async () => {
    await resizeViewport(200, 200);
  });

  afterAll(async () => {
    await resizeViewport();
  });

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  function appendTarget() {
    const target = document.createElement('target');
    target.textContent = 'target';
    document.body.appendChild(target);
    return target;
  }

  const baseStyle = `
    target {
      width: 120px;
      height: 80px;
      line-height: 80px;
      display: inline-block;
      margin: 8px;
      text-align: center;
      background-color: currentColor;
    }
  `;

  it('A1 Basic', async () => {
    await resizeViewport(300, 300);
    const style = appendStyle(`${baseStyle}
      @layer { target { color: red } }
      @media (min-width: 500px) {
        @layer {
          target { color: green; }
        }
      }
    `);
    const target = appendTarget();

    await snapshot();
    expect(getComputedStyle(target).color).toBe(red);

    await resizeViewport(500, 300);
    await snapshot();
    expect(getComputedStyle(target).color).toBe(green);

    style.remove();
    target.remove();
    await resizeViewport();
  });

  it('A2 Basic', async () => {
    await resizeViewport(300, 300);
    const style = appendStyle(`${baseStyle}
      @media (min-width: 500px) {
        @layer {
          target { color: green; }
        }
      }
      @media (max-width: 300px) {
        @layer {
          target { color: red; }
        }
      }
    `);
    const target = appendTarget();

    await snapshot();
    expect(getComputedStyle(target).color).toBe(red);

    await resizeViewport(500, 300);
    await snapshot();
    expect(getComputedStyle(target).color).toBe(green);

    style.remove();
    target.remove();
    await resizeViewport();
  });

  it('C1 Reordering', async () => {
    await resizeViewport(300, 300);
    const style = appendStyle(`${baseStyle}
      @media (max-width: 300px) {
        @layer B {
          target { color: green; }
        }
        @layer A {
          target { color: red; }
        }
      }
      @media (min-width: 500px) {
        @layer A {
          target { color: red; }
        }
        @layer B {
          target { color: green; }
        }
      }
    `);
    const target = appendTarget();

    await snapshot();
    expect(getComputedStyle(target).color).toBe(red);

    await resizeViewport(500, 300);
    await snapshot();
    expect(getComputedStyle(target).color).toBe(green);

    style.remove();
    target.remove();
    await resizeViewport();
  });

  it('C2 Reordering', async () => {
    await resizeViewport(300, 300);
    const style = appendStyle(`${baseStyle}
      @media (max-width: 300px) {
        @layer B { }
        @layer A { target { color: red; } }
      }
      @media (min-width: 500px) {
        @layer A { target { color: red; } }
        @layer B { }
      }
      @layer B {
        target { color: green; }
      }
    `);
    const target = appendTarget();

    await snapshot();
    expect(getComputedStyle(target).color).toBe(red);

    await resizeViewport(500, 300);
    await snapshot();
    expect(getComputedStyle(target).color).toBe(green);

    style.remove();
    target.remove();
    await resizeViewport();
  });

  it('C3 Reordering', async () => {
    await resizeViewport(300, 300);
    const style = appendStyle(`${baseStyle}
      @media (max-width: 300px) {
        @layer B, A;
      }
      @media (min-width: 500px) {
        @layer A, B;
      }
      @layer A {
        target { color: red; }
      }
      @layer B {
        target { color: green; }
      }
    `);
    const target = appendTarget();

    await snapshot();
    expect(getComputedStyle(target).color).toBe(red);

    await resizeViewport(500, 300);
    await snapshot();
    expect(getComputedStyle(target).color).toBe(green);

    style.remove();
    target.remove();
    await resizeViewport();
  });
});

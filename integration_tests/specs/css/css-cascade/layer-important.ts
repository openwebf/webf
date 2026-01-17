/**
 * CSS Cascade Layers: !important functionality
 * Based on WPT: css/css-cascade/layer-important.html
 *
 * Key behavior: !important reverses layer order
 * - For normal declarations: later layers win
 * - For !important declarations: earlier layers win
 */
describe('CSS Cascade Layers: !important', () => {
  const green = 'rgb(0, 128, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  function appendTargets() {
    const first = document.createElement('div') as HTMLDivElement;
    first.className = 'target first';
    first.textContent = 'first';

    const second = document.createElement('div') as HTMLDivElement;
    second.className = 'target second';
    second.textContent = 'second';

    document.body.appendChild(first);
    document.body.appendChild(second);

    return { first, second };
  }

  const baseStyle = `
    .target {
      width: 120px;
      height: 80px;
      line-height: 80px;
      display: inline-block;
      margin: 8px;
      text-align: center;
      background-color: currentColor;
    }
  `;

  // ========== Unlayered !important ==========

  it('A1 Unlayered !important style wins over normal', async () => {
    const style = appendStyle(`${baseStyle}
      .target { color: green !important; }
      .target { color: red; }
    `);
    const { first, second } = appendTargets();

    await snapshot();
    expect(getComputedStyle(first).color).toBe(green);
    expect(getComputedStyle(second).color).toBe(green);

    style.remove();
    first.remove();
    second.remove();
  });

  // ========== Layered !important vs Normal ==========

  it('B1 Same specificity: layered !important first wins', async () => {
    const style = appendStyle(`${baseStyle}
      @layer { .target { color: green !important; } }
      .target { color: red; }
    `);
    const { first, second } = appendTargets();

    await snapshot();
    expect(getComputedStyle(first).color).toBe(green);
    expect(getComputedStyle(second).color).toBe(green);

    style.remove();
    first.remove();
    second.remove();
  });

  it('C1 Same specificity: layered !important second wins', async () => {
    const style = appendStyle(`${baseStyle}
      .target { color: red; }
      @layer { .target { color: green !important; } }
    `);
    const { first, second } = appendTargets();

    await snapshot();
    expect(getComputedStyle(first).color).toBe(green);
    expect(getComputedStyle(second).color).toBe(green);

    style.remove();
    first.remove();
    second.remove();
  });

  // ========== All !important - Reversed Layer Order ==========

  it('D1 All !important: earlier layer wins (reversed order)', async () => {
    const style = appendStyle(`${baseStyle}
      @layer { .target { color: green !important; } }
      @layer { .target { color: red !important; } }
      .target { color: red !important; }
    `);
    const { first, second } = appendTargets();

    await snapshot();
    expect(getComputedStyle(first).color).toBe(green);
    expect(getComputedStyle(second).color).toBe(green);

    style.remove();
    first.remove();
    second.remove();
  });

  it('D2 All !important: first layer wins over unlayered and second layer', async () => {
    const style = appendStyle(`${baseStyle}
      @layer { .target { color: green !important; } }
      .target { color: red !important; }
      @layer { .target { color: red !important; } }
    `);
    const { first, second } = appendTargets();

    await snapshot();
    expect(getComputedStyle(first).color).toBe(green);
    expect(getComputedStyle(second).color).toBe(green);

    style.remove();
    first.remove();
    second.remove();
  });

  it('D3 All !important: first layer wins over unlayered before and second after', async () => {
    const style = appendStyle(`${baseStyle}
      .target { color: red !important; }
      @layer { .target { color: green !important; } }
      @layer { .target { color: red !important; } }
    `);
    const { first, second } = appendTargets();

    await snapshot();
    expect(getComputedStyle(first).color).toBe(green);
    expect(getComputedStyle(second).color).toBe(green);

    style.remove();
    first.remove();
    second.remove();
  });

  it('D4 All !important: with @layer statement order A wins over B', async () => {
    const style = appendStyle(`${baseStyle}
      @layer A, B;
      @layer B { .target { color: red !important; } }
      @layer A { .target { color: green !important; } }
      .target { color: red !important; }
    `);
    const { first, second } = appendTargets();

    await snapshot();
    expect(getComputedStyle(first).color).toBe(green);
    expect(getComputedStyle(second).color).toBe(green);

    style.remove();
    first.remove();
    second.remove();
  });

  // ========== Different Specificity + !important ==========

  it('E1 Different specificity: all !important, first layer wins', async () => {
    const style = appendStyle(`${baseStyle}
      @layer { .target { color: green !important; } }
      @layer { .target { color: red !important; } }
      .target.first { color: red !important; }
    `);
    const { first, second } = appendTargets();

    await snapshot();
    expect(getComputedStyle(first).color).toBe(green);
    expect(getComputedStyle(second).color).toBe(green);

    style.remove();
    first.remove();
    second.remove();
  });

  it('E2 Different specificity: higher specificity in second layer still loses to first', async () => {
    const style = appendStyle(`${baseStyle}
      @layer { .target { color: green !important; } }
      @layer { .target.first { color: red !important; } }
      .target { color: red !important; }
    `);
    const { first, second } = appendTargets();

    await snapshot();
    expect(getComputedStyle(first).color).toBe(green);
    expect(getComputedStyle(second).color).toBe(green);

    style.remove();
    first.remove();
    second.remove();
  });

  // ========== Mixed Normal and !important ==========

  it('F1 Mixed: normal in later layer vs !important in earlier layer', async () => {
    const style = appendStyle(`${baseStyle}
      @layer first { .target { color: green !important; } }
      @layer second { .target { color: red; } }
    `);
    const { first, second } = appendTargets();

    await snapshot();
    expect(getComputedStyle(first).color).toBe(green);
    expect(getComputedStyle(second).color).toBe(green);

    style.remove();
    first.remove();
    second.remove();
  });

  it('F2 Mixed: !important in later layer vs normal in earlier layer', async () => {
    const style = appendStyle(`${baseStyle}
      @layer first { .target { color: red; } }
      @layer second { .target { color: green !important; } }
    `);
    const { first, second } = appendTargets();

    await snapshot();
    expect(getComputedStyle(first).color).toBe(green);
    expect(getComputedStyle(second).color).toBe(green);

    style.remove();
    first.remove();
    second.remove();
  });

  it('F3 Mixed: nested layers with !important', async () => {
    const style = appendStyle(`${baseStyle}
      @layer A {
        @layer inner { .target { color: green !important; } }
      }
      @layer B {
        @layer inner { .target { color: red !important; } }
      }
    `);
    const { first, second } = appendTargets();

    await snapshot();
    expect(getComputedStyle(first).color).toBe(green);
    expect(getComputedStyle(second).color).toBe(green);

    style.remove();
    first.remove();
    second.remove();
  });

  it('F4 Mixed: dotted layer names with !important', async () => {
    const style = appendStyle(`${baseStyle}
      @layer A.inner { .target { color: green !important; } }
      @layer B.inner { .target { color: red !important; } }
    `);
    const { first, second } = appendTargets();

    await snapshot();
    expect(getComputedStyle(first).color).toBe(green);
    expect(getComputedStyle(second).color).toBe(green);

    style.remove();
    first.remove();
    second.remove();
  });
});

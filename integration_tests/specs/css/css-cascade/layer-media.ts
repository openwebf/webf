/**
 * CSS Cascade Layers: Media queries
 * Based on WPT: css/css-cascade/layer-media-query.html
 *
 * Tests @media nested inside @layer blocks
 * Key behavior: @media inside @layer should work correctly
 * - Rules inside @media in @layer are still part of that layer
 * - Layer order is preserved regardless of @media matching
 */
describe('CSS Cascade Layers: @media inside @layer', () => {
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

  it('A1 @media all inside @layer matches', async () => {
    const style = appendStyle(`${baseStyle}
      @layer {
        @media all {
          .target { color: green; }
        }
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

  it('A2 @media screen inside @layer matches', async () => {
    const style = appendStyle(`${baseStyle}
      @layer {
        @media screen {
          .target { color: green; }
        }
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

  it('B1 Later layer with @media wins', async () => {
    const style = appendStyle(`${baseStyle}
      @layer first {
        .target { color: red; }
      }
      @layer second {
        @media all {
          .target { color: green; }
        }
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

  it('B2 @media in earlier layer loses to later layer', async () => {
    const style = appendStyle(`${baseStyle}
      @layer first {
        @media all {
          .target { color: red; }
        }
      }
      @layer second {
        .target { color: green; }
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

  it('C1 @layer inside @media', async () => {
    const style = appendStyle(`${baseStyle}
      @media all {
        @layer first {
          .target { color: red; }
        }
        @layer second {
          .target { color: green; }
        }
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

  it('C2 @layer statement inside @media establishes order', async () => {
    const style = appendStyle(`${baseStyle}
      @media all {
        @layer A, B;
        @layer B {
          .target { color: red; }
        }
        @layer A {
          .target { color: red; }
        }
      }
      @layer B {
        .target { color: green; }
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

  it('D1 Nested @media inside @layer', async () => {
    const style = appendStyle(`${baseStyle}
      @layer {
        @media all {
          @media screen {
            .target { color: green; }
          }
        }
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

  it('E1 @media with !important inside @layer', async () => {
    const style = appendStyle(`${baseStyle}
      @layer first {
        @media all {
          .target { color: green !important; }
        }
      }
      @layer second {
        @media all {
          .target { color: red !important; }
        }
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

  it('F1 Mixed @media and non-@media in same layer', async () => {
    const style = appendStyle(`${baseStyle}
      @layer {
        .target { color: red; }
        @media all {
          .target { color: green; }
        }
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

  it('F2 Non-matching @media inside @layer does not apply', async () => {
    const style = appendStyle(`${baseStyle}
      @layer first {
        .target { color: green; }
      }
      @layer second {
        @media print {
          .target { color: red; }
        }
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
});

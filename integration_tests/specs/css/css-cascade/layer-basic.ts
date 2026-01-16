/**
 * CSS Cascade Layers: Basic functionality
 * Based on WPT: css/css-cascade/layer-basic.html
 */
describe('CSS Cascade Layers: basic', () => {
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

  // ========== Anonymous Layers ==========

  it('A1 Anonymous layers: empty layer does not affect unlayered', async () => {
    const style = appendStyle(`${baseStyle}
      @layer { }
      .target { color: green; }
    `);
    const { first, second } = appendTargets();

    await snapshot();
    expect(getComputedStyle(first).color).toBe(green);
    expect(getComputedStyle(second).color).toBe(green);

    style.remove();
    first.remove();
    second.remove();
  });

  it('A2 Anonymous layers: unlayered wins over earlier layer', async () => {
    const style = appendStyle(`${baseStyle}
      .target { color: green; }
      @layer {
        .target { color: red; }
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

  it('A3 Anonymous layers: unlayered wins over later layer', async () => {
    const style = appendStyle(`${baseStyle}
      @layer {
        .target { color: red; }
      }
      .target { color: green; }
    `);
    const { first, second } = appendTargets();

    await snapshot();
    expect(getComputedStyle(first).color).toBe(green);
    expect(getComputedStyle(second).color).toBe(green);

    style.remove();
    first.remove();
    second.remove();
  });

  it('A4 Anonymous layers: later layer wins', async () => {
    const style = appendStyle(`${baseStyle}
      @layer {
        .target { color: red; }
      }
      @layer {
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

  it('A5 Anonymous layers: outer wins over nested', async () => {
    const style = appendStyle(`${baseStyle}
      @layer {
        .target { color: green; }
        @layer {
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

  it('A6 Anonymous layers: outer wins over earlier nested', async () => {
    const style = appendStyle(`${baseStyle}
      @layer {
        @layer {
          .target { color: red; }
        }
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

  it('A7 Anonymous layers: later outer with nested wins', async () => {
    const style = appendStyle(`${baseStyle}
      @layer {
        @layer {
          .target { color: red; }
        }
        .target { color: red; }
      }
      @layer {
        @layer {
          .target { color: red; }
        }
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

  it('A8 Anonymous layers: deeply nested - later outer wins', async () => {
    const style = appendStyle(`${baseStyle}
      @layer {
        @layer {
          @layer {
            .target { color: red; }
          }
        }
        .target { color: red; }
      }
      @layer {
        @layer {
          .target { color: red; }
        }
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

  it('A9 Anonymous layers: deeply nested variant', async () => {
    const style = appendStyle(`${baseStyle}
      @layer {
        @layer {
          .target { color: red; }
        }
        .target { color: red; }
      }
      @layer {
        @layer {
          @layer {
            .target { color: red; }
          }
        }
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

  // ========== Named Layers ==========

  it('B1 Named layers: empty layer does not affect unlayered', async () => {
    const style = appendStyle(`${baseStyle}
      @layer A {
      }
      .target { color: green; }
    `);
    const { first, second } = appendTargets();

    await snapshot();
    expect(getComputedStyle(first).color).toBe(green);
    expect(getComputedStyle(second).color).toBe(green);

    style.remove();
    first.remove();
    second.remove();
  });

  it('B2 Named layers: unlayered wins over named layer', async () => {
    const style = appendStyle(`${baseStyle}
      @layer A {
        .target { color: red; }
      }
      .target { color: green; }
    `);
    const { first, second } = appendTargets();

    await snapshot();
    expect(getComputedStyle(first).color).toBe(green);
    expect(getComputedStyle(second).color).toBe(green);

    style.remove();
    first.remove();
    second.remove();
  });

  it('B3 Named layers: later rules in same layer win', async () => {
    const style = appendStyle(`${baseStyle}
      @layer A {
        .target { color: red; }
      }
      @layer A {
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

  it('B4 Named layers: layer order by first occurrence', async () => {
    const style = appendStyle(`${baseStyle}
      @layer A {
        .target { color: red; }
      }
      @layer B {
        .target { color: green; }
      }
      @layer A {
        .target { color: red; }
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

  it('B5 Named layers: outer wins over nested same name', async () => {
    const style = appendStyle(`${baseStyle}
      @layer A {
        .target { color: green; }
        @layer A {
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

  it('B6 Named layers: later nested occurrence wins', async () => {
    const style = appendStyle(`${baseStyle}
      @layer A {
        @layer A {
          .target { color: red; }
        }
      }
      @layer A {
        @layer A {
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

  it('B7 Named layers: B wins over A with nested', async () => {
    const style = appendStyle(`${baseStyle}
      @layer A {
        .target { color: red; }
        @layer A {
          .target { color: red; }
        }
      }
      @layer B {
        .target { color: green; }
      }
      @layer A {
        @layer A {
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

  it('B8 Named layers: B.A wins over A.A', async () => {
    const style = appendStyle(`${baseStyle}
      @layer A {
        @layer A {
          .target { color: red; }
        }
      }
      @layer B {
        @layer A {
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

  it('B9 Named layers: complex nested with classes', async () => {
    const style = appendStyle(`${baseStyle}
      @layer A {
        @layer A {
          .target { color: red; }
        }
      }
      @layer B {
        @layer A {
          .target.first { color: green; }
        }
      }
      @layer A {
        @layer A {
          .target.first { color: red; }
          .target.second { color: green; }
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

  it('B10 Named layers: complex nested A.A vs A.B', async () => {
    const style = appendStyle(`${baseStyle}
      @layer A {
        @layer A {
          .target { color: red; }
        }
      }
      @layer B {
        @layer A {
          .target.first { color: green; }
        }
      }
      @layer A {
        @layer B {
          .target.first { color: red; }
          .target.second { color: green; }
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

  // ========== Named Layers Shorthand (Dotted Names) ==========

  it('C1 Named layers shorthand: B.A wins over A.A', async () => {
    const style = appendStyle(`${baseStyle}
      @layer A.A {
        .target { color: red; }
      }
      @layer B.A {
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

  it('C2 Named layers shorthand: with class selectors', async () => {
    const style = appendStyle(`${baseStyle}
      @layer A.A {
        .target { color: red; }
      }
      @layer B.A {
        .target.first { color: green; }
      }
      @layer A.A {
        .target.first { color: red; }
        .target.second { color: green; }
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

  it('C3 Named layers shorthand: A.B vs B.A', async () => {
    const style = appendStyle(`${baseStyle}
      @layer A.A {
        .target { color: red; }
      }
      @layer B.A {
        .target.first { color: green; }
      }
      @layer A.B {
        .target.first { color: red; }
        .target.second { color: green; }
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

  it('C5 Named layers shorthand: nested vs dotted equivalence', async () => {
    const style = appendStyle(`${baseStyle}
      @layer A {
        @layer A {
          .target { color: red; }
        }
      }
      @layer B.A {
        .target { color: green; }
      }
      @layer A.B {
        .target { color: red; }
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

  // ========== Mixed Named and Anonymous Layers ==========

  it('D1 Mixed: anonymous wins over earlier named', async () => {
    const style = appendStyle(`${baseStyle}
      @layer A {
        .target { color: red; }
      }
      @layer {
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

  it('D2 Mixed: outer named wins over nested anonymous', async () => {
    const style = appendStyle(`${baseStyle}
      @layer A {
        @layer {
          .target { color: red; }
        }
      }
      @layer A {
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

  it('D3 Mixed: later anonymous in same named wins', async () => {
    const style = appendStyle(`${baseStyle}
      @layer A {
        @layer {
          .target { color: red; }
        }
      }
      @layer A {
        @layer {
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

  it('D4 Mixed: anonymous wins over named with nested anonymous', async () => {
    const style = appendStyle(`${baseStyle}
      @layer A {
        @layer {
          .target { color: red; }
        }
      }
      @layer {
        .target { color: green; }
      }
      @layer A {
        @layer {
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

  it('D5 Mixed: later anonymous wins over earlier with nested named', async () => {
    const style = appendStyle(`${baseStyle}
      @layer {
        @layer A {
          .target { color: red; }
        }
      }
      @layer {
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

  // ========== Statement Syntax ==========

  it('E1 Statement syntax: A, B, C order', async () => {
    const style = appendStyle(`${baseStyle}
      @layer A, B, C;
      @layer A {
        .target.first { color: red; }
        .target.second { color: red; }
      }
      @layer B {
        .target.first { color: red; }
      }
      @layer C {
        .target.first { color: green; }
        .target.second { color: green; }
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

  it('E2 Statement syntax: A, C, B order', async () => {
    const style = appendStyle(`${baseStyle}
      @layer A, C, B;
      @layer A {
        .target.first { color: red; }
        .target.second { color: red; }
      }
      @layer B {
        .target.first { color: green; }
      }
      @layer C {
        .target.first { color: red; }
        .target.second { color: green; }
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

  it('E3 Statement syntax: C, B, A order', async () => {
    const style = appendStyle(`${baseStyle}
      @layer C, B, A;
      @layer A {
        .target.first { color: green; }
        .target.second { color: green; }
      }
      @layer B {
        .target.first { color: red; }
      }
      @layer C {
        .target.first { color: red; }
        .target.second { color: red; }
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

  it('E4 Statement syntax: B, A.B, A.A order', async () => {
    const style = appendStyle(`${baseStyle}
      @layer B, A.B, A.A;
      @layer A {
        @layer A {
          .target.first { color: green; }
        }
        @layer B {
          .target.first { color: red; }
          .target.second { color: green; }
        }
      }
      @layer B {
        .target { color: red; }
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

  it('E5 Statement syntax: A.B, B, A.A order', async () => {
    const style = appendStyle(`${baseStyle}
      @layer A.B, B, A.A;
      @layer A {
        @layer A {
          .target.first { color: red; }
        }
        @layer B {
          .target.first { color: red; }
          .target.second { color: red; }
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
});

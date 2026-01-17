/**
 * CSS Cascade Layers: Layer vs Inline Style
 * Based on WPT: css/css-cascade/layer-vs-inline-style.html
 *
 * Key behavior:
 * - Normal inline style > normal layered style
 * - Normal inline style < important layered style
 * - Important inline style > normal layered style
 * - Important inline style > important layered style
 */
describe('CSS Cascade Layers: layer vs inline style', () => {
  const green = 'rgb(0, 128, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  const baseStyle = `
    #target, #reference {
      width: 100px;
      height: 100px;
      display: inline-block;
      margin: 8px;
    }
    #reference {
      background-color: green;
    }
  `;

  it('Normal inline style beats normal layered style', async () => {
    const style = appendStyle(`${baseStyle}
      @layer { #target { background-color: red; } }
    `);

    const target = document.createElement('div');
    target.id = 'target';
    target.style.backgroundColor = 'green';
    const reference = document.createElement('div');
    reference.id = 'reference';
    document.body.appendChild(target);
    document.body.appendChild(reference);

    await snapshot();
    expect(getComputedStyle(target).backgroundColor).toBe(green);
    expect(getComputedStyle(reference).backgroundColor).toBe(green);

    style.remove();
    target.remove();
    reference.remove();
  });

  it('Normal inline style loses to important layered style', async () => {
    const style = appendStyle(`${baseStyle}
      @layer { #target { background-color: green !important; } }
    `);

    const target = document.createElement('div');
    target.id = 'target';
    target.style.backgroundColor = 'red';
    const reference = document.createElement('div');
    reference.id = 'reference';
    document.body.appendChild(target);
    document.body.appendChild(reference);

    await snapshot();
    expect(getComputedStyle(target).backgroundColor).toBe(green);
    expect(getComputedStyle(reference).backgroundColor).toBe(green);

    style.remove();
    target.remove();
    reference.remove();
  });

  it('Important inline style beats normal layered style', async () => {
    const style = appendStyle(`${baseStyle}
      @layer { #target { background-color: red; } }
    `);

    const target = document.createElement('div');
    target.id = 'target';
    target.style.cssText = 'background-color: green !important';
    const reference = document.createElement('div');
    reference.id = 'reference';
    document.body.appendChild(target);
    document.body.appendChild(reference);

    await snapshot();
    expect(getComputedStyle(target).backgroundColor).toBe(green);
    expect(getComputedStyle(reference).backgroundColor).toBe(green);

    style.remove();
    target.remove();
    reference.remove();
  });

  it('Important inline style beats important layered style', async () => {
    const style = appendStyle(`${baseStyle}
      @layer { #target { background-color: red !important; } }
    `);

    const target = document.createElement('div');
    target.id = 'target';
    target.style.cssText = 'background-color: green !important';
    const reference = document.createElement('div');
    reference.id = 'reference';
    document.body.appendChild(target);
    document.body.appendChild(reference);

    await snapshot();
    expect(getComputedStyle(target).backgroundColor).toBe(green);
    expect(getComputedStyle(reference).backgroundColor).toBe(green);

    style.remove();
    target.remove();
    reference.remove();
  });

  it('Normal inline style beats unlayered normal style', async () => {
    const style = appendStyle(`${baseStyle}
      #target { background-color: red; }
    `);

    const target = document.createElement('div');
    target.id = 'target';
    target.style.backgroundColor = 'green';
    const reference = document.createElement('div');
    reference.id = 'reference';
    document.body.appendChild(target);
    document.body.appendChild(reference);

    await snapshot();
    expect(getComputedStyle(target).backgroundColor).toBe(green);
    expect(getComputedStyle(reference).backgroundColor).toBe(green);

    style.remove();
    target.remove();
    reference.remove();
  });

  it('Normal inline style beats multiple layered styles', async () => {
    const style = appendStyle(`${baseStyle}
      @layer first { #target { background-color: red; } }
      @layer second { #target { background-color: blue; } }
    `);

    const target = document.createElement('div');
    target.id = 'target';
    target.style.backgroundColor = 'green';
    const reference = document.createElement('div');
    reference.id = 'reference';
    document.body.appendChild(target);
    document.body.appendChild(reference);

    await snapshot();
    expect(getComputedStyle(target).backgroundColor).toBe(green);
    expect(getComputedStyle(reference).backgroundColor).toBe(green);

    style.remove();
    target.remove();
    reference.remove();
  });

  it('Important layered style from first layer beats normal inline', async () => {
    const style = appendStyle(`${baseStyle}
      @layer first { #target { background-color: green !important; } }
      @layer second { #target { background-color: red !important; } }
    `);

    const target = document.createElement('div');
    target.id = 'target';
    target.style.backgroundColor = 'blue';
    const reference = document.createElement('div');
    reference.id = 'reference';
    document.body.appendChild(target);
    document.body.appendChild(reference);

    await snapshot();
    expect(getComputedStyle(target).backgroundColor).toBe(green);
    expect(getComputedStyle(reference).backgroundColor).toBe(green);

    style.remove();
    target.remove();
    reference.remove();
  });

  it('Important inline style beats important layered style from any layer', async () => {
    const style = appendStyle(`${baseStyle}
      @layer first { #target { background-color: red !important; } }
      @layer second { #target { background-color: blue !important; } }
    `);

    const target = document.createElement('div');
    target.id = 'target';
    target.style.cssText = 'background-color: green !important';
    const reference = document.createElement('div');
    reference.id = 'reference';
    document.body.appendChild(target);
    document.body.appendChild(reference);

    await snapshot();
    expect(getComputedStyle(target).backgroundColor).toBe(green);
    expect(getComputedStyle(reference).backgroundColor).toBe(green);

    style.remove();
    target.remove();
    reference.remove();
  });
});

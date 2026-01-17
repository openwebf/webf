/**
 * CSS Cascade Layers: CSSOM layer mutations
 * Based on WPT: css/css-cascade/layer-cssom-order-reverse.html
 *
 * Tests that CSSOM mutations (insertRule/deleteRule) that affect
 * layer order trigger style invalidation and update computed styles.
 */
describe('CSS Cascade Layers: CSSOM mutations', () => {
  const green = 'rgb(0, 128, 0)';
  const red = 'rgb(255, 0, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  const baseStyle = `
    #target {
      width: 100px;
      height: 100px;
      display: inline-block;
      margin: 8px;
      background-color: currentColor;
    }
  `;

  it('Insert @layer statement changes layer order', async () => {
    const style1 = appendStyle('');
    const style2 = appendStyle(`${baseStyle}
      @layer first {
        #target { color: green; }
      }
      @layer second {
        #target { color: red; }
      }
    `);

    const target = document.createElement('div');
    target.id = 'target';
    document.body.appendChild(target);

    await snapshot();
    expect(getComputedStyle(target).color).toBe(red);

    style1.sheet!.insertRule('@layer second {}', 0);
    await snapshot();
    expect(getComputedStyle(target).color).toBe(green);

    style1.remove();
    style2.remove();
    target.remove();
  });

  it('Delete @layer statement changes layer order', async () => {
    const style1 = appendStyle('@layer second {}');
    const style2 = appendStyle(`${baseStyle}
      @layer first {
        #target { color: red; }
      }
      @layer second {
        #target { color: green; }
      }
    `);

    const target = document.createElement('div');
    target.id = 'target';
    document.body.appendChild(target);

    await snapshot();
    expect(getComputedStyle(target).color).toBe(red);

    style1.sheet!.deleteRule(0);
    await snapshot();
    expect(getComputedStyle(target).color).toBe(green);

    style1.remove();
    style2.remove();
    target.remove();
  });

  it('Insert @layer block changes layer order', async () => {
    const style1 = appendStyle('');
    const style2 = appendStyle(`${baseStyle}
      @layer first {
        #target { color: green; }
      }
      @layer second {
        #target { color: red; }
      }
    `);

    const target = document.createElement('div');
    target.id = 'target';
    document.body.appendChild(target);

    await snapshot();
    expect(getComputedStyle(target).color).toBe(red);

    style1.sheet!.insertRule('@layer second { }', 0);
    await snapshot();
    expect(getComputedStyle(target).color).toBe(green);

    style1.remove();
    style2.remove();
    target.remove();
  });

  it('Multiple @layer statements in inserted order', async () => {
    const style = appendStyle(`${baseStyle}
      @layer A {
        #target { color: red; }
      }
      @layer B {
        #target { color: red; }
      }
      @layer C {
        #target { color: green; }
      }
    `);

    const target = document.createElement('div');
    target.id = 'target';
    document.body.appendChild(target);

    await snapshot();
    expect(getComputedStyle(target).color).toBe(green);

    const style2 = appendStyle('');
    style2.sheet!.insertRule('@layer C, B, A;', 0);
    await snapshot();
    expect(getComputedStyle(target).color).toBe(green);

    style.remove();
    style2.remove();
    target.remove();
  });

  it('Insert rule into existing @layer block', async () => {
    const style = appendStyle(`${baseStyle}
      @layer first {
        #target { color: red; }
      }
      @layer second { }
    `);

    const target = document.createElement('div');
    target.id = 'target';
    document.body.appendChild(target);

    await snapshot();
    expect(getComputedStyle(target).color).toBe(red);

    const sheet = style.sheet!;
    const layerRule = sheet.cssRules[2] as CSSGroupingRule;
    layerRule.insertRule('#target { color: green; }', 0);
    await snapshot();
    expect(getComputedStyle(target).color).toBe(green);

    style.remove();
    target.remove();
  });

  it('Delete rule from @layer block', async () => {
    const style = appendStyle(`${baseStyle}
      @layer first {
        #target { color: green; }
      }
      @layer second {
        #target { color: red; }
      }
    `);

    const target = document.createElement('div');
    target.id = 'target';
    document.body.appendChild(target);

    await snapshot();
    expect(getComputedStyle(target).color).toBe(red);

    const sheet = style.sheet!;
    const layerRule = sheet.cssRules[2] as CSSGroupingRule;
    layerRule.deleteRule(0);
    await snapshot();
    expect(getComputedStyle(target).color).toBe(green);

    style.remove();
    target.remove();
  });

  it('Removing style element triggers recalculation', async () => {
    const style1 = appendStyle('@layer second {}');
    const style2 = appendStyle(`${baseStyle}
      @layer first {
        #target { color: green; }
      }
      @layer second {
        #target { color: red; }
      }
    `);

    const target = document.createElement('div');
    target.id = 'target';
    document.body.appendChild(target);

    await snapshot();
    expect(getComputedStyle(target).color).toBe(green);

    style1.remove();
    await snapshot();
    expect(getComputedStyle(target).color).toBe(red);

    style2.remove();
    target.remove();
  });

  it('Adding new style element with @layer affects existing layers', async () => {
    const style1 = appendStyle(`${baseStyle}
      @layer first {
        #target { color: green; }
      }
      @layer second {
        #target { color: red; }
      }
    `);

    const target = document.createElement('div');
    target.id = 'target';
    document.body.appendChild(target);

    await snapshot();
    expect(getComputedStyle(target).color).toBe(red);

    const style2 = document.createElement('style');
    style2.textContent = '@layer second {}';
    document.head.insertBefore(style2, style1);
    await snapshot();
    expect(getComputedStyle(target).color).toBe(green);

    style1.remove();
    style2.remove();
    target.remove();
  });
});

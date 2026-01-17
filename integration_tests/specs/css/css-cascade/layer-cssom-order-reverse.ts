describe('CSS Cascade Layers: CSSOM order changes', () => {
  const red = 'rgb(255, 0, 0)';
  const green = 'rgb(0, 128, 0)';

  function requireStyleSheets(): StyleSheetList {
    const sheets = document.styleSheets;
    if (sheets == null) {
      throw new Error('document.styleSheets is not available');
    }
    return sheets;
  }

  it('insertRule(@layer ...) changes layer order and invalidates style', async () => {
    const baseLength = requireStyleSheets().length;

    const style0 = document.createElement('style');
    style0.textContent = '/* sheet0 */';
    const style1 = document.createElement('style');
    style1.textContent = `
      #target, #reference {
        width: 120px;
        height: 80px;
        line-height: 80px;
        display: inline-block;
        margin: 8px;
        text-align: center;
        background-color: currentColor;
      }
      #reference { color: ${green}; }
      @layer first { #target { color: ${green}; } }
      @layer second { #target { color: ${red}; } }
    `;

    document.head.appendChild(style0);
    document.head.appendChild(style1);

    const sheets = requireStyleSheets();
    const sheet0 = sheets[baseLength] as CSSStyleSheet;

    const target = document.createElement('div');
    target.id = 'target';
    target.textContent = 'target';
    const reference = document.createElement('div');
    reference.id = 'reference';
    reference.textContent = 'ref';
    document.body.appendChild(target);
    document.body.appendChild(reference);

    await snapshot();
    expect(getComputedStyle(target).color).toBe(red);
    expect(getComputedStyle(reference).color).toBe(green);

    sheet0.insertRule('@layer second {}', 0);
    await nextFrames();

    await snapshot();
    expect(getComputedStyle(target).color).toBe(green);

    style0.remove();
    style1.remove();
    target.remove();
    reference.remove();
  });

  it('deleteRule(@layer ...) changes layer order and invalidates style', async () => {
    const baseLength = requireStyleSheets().length;

    const style0 = document.createElement('style');
    style0.textContent = '@layer second {}';
    const style1 = document.createElement('style');
    style1.textContent = `
      #target, #reference {
        width: 120px;
        height: 80px;
        line-height: 80px;
        display: inline-block;
        margin: 8px;
        text-align: center;
        background-color: currentColor;
      }
      #reference { color: ${green}; }
      @layer first { #target { color: ${red}; } }
      @layer second { #target { color: ${green}; } }
    `;

    document.head.appendChild(style0);
    document.head.appendChild(style1);

    const sheets = requireStyleSheets();
    const sheet0 = sheets[baseLength] as CSSStyleSheet;

    const target = document.createElement('div');
    target.id = 'target';
    target.textContent = 'target';
    const reference = document.createElement('div');
    reference.id = 'reference';
    reference.textContent = 'ref';
    document.body.appendChild(target);
    document.body.appendChild(reference);

    // With the extra earlier declaration of `second`, `first` becomes later.
    await snapshot();
    expect(getComputedStyle(target).color).toBe(red);

    sheet0.deleteRule(0);
    await nextFrames();

    await snapshot();
    expect(getComputedStyle(target).color).toBe(green);

    style0.remove();
    style1.remove();
    target.remove();
    reference.remove();
  });
});


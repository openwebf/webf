describe('document.styleSheets (Dart CSS engine)', () => {
  function requireStyleSheets(): any {
    const sheets = (document as any).styleSheets;
    if (sheets == null) {
      throw new Error('document.styleSheets is not available');
    }
    return sheets;
  }

  it('reflects <style> insertion/removal', async () => {
    const baseLength = requireStyleSheets().length;

    const style = document.createElement('style');
    style.textContent = '.webf-styleSheets-empty {}';
    document.head.appendChild(style);
    await waitForFrame();

    const sheets = requireStyleSheets();
    expect(Array.isArray(sheets)).toBeTrue();
    expect(sheets.length).toBe(baseLength + 1);

    style.remove();
    await waitForFrame();

    expect(requireStyleSheets().length).toBe(baseLength);
  });

  it('supports cssRules/insertRule/deleteRule', async () => {
    const baseLength = requireStyleSheets().length;

    const style = document.createElement('style');
    style.textContent = '/* cssRules */';
    document.head.appendChild(style);
    await waitForFrame();

    const sheet = requireStyleSheets()[baseLength];
    expect(sheet).toBeTruthy();

    expect(typeof sheet.insertRule).toBe('function');
    expect(typeof sheet.deleteRule).toBe('function');

    expect(sheet.cssRules.length).toBe(0);

    const index0 = sheet.insertRule('.rule-a { color: red; }', 0);
    expect(index0).toBe(0);
    expect(sheet.cssRules.length).toBe(1);
    expect(sheet.cssRules[0].cssText).toContain('.rule-a');
    expect(sheet.cssRules.item(0).cssText).toContain('.rule-a');

    sheet.insertRule('.rule-b { color: blue; }', 1);
    expect(sheet.cssRules.length).toBe(2);
    expect(sheet.cssRules.item(1).cssText).toContain('.rule-b');

    sheet.deleteRule(0);
    expect(sheet.cssRules.length).toBe(1);
    expect(sheet.cssRules[0].cssText).toContain('.rule-b');

    style.remove();
    await waitForFrame();
  });

  it('updates styles after insertRule and respects document order', async () => {
    const baseLength = requireStyleSheets().length;

    const styleA = document.createElement('style');
    const styleB = document.createElement('style');
    document.head.appendChild(styleA);
    document.head.appendChild(styleB);
    await waitForFrame();

    expect(requireStyleSheets().length).toBe(baseLength + 2);

    const sheetA = requireStyleSheets()[baseLength];
    const sheetB = requireStyleSheets()[baseLength + 1];

    sheetA.insertRule('.sheet-order-target { color: rgb(255, 0, 0); }', 0);
    sheetB.insertRule('.sheet-order-target { color: rgb(0, 128, 0); }', 0);

    const target = document.createElement('div');
    target.className = 'sheet-order-target';
    target.textContent = 'target';
    document.body.appendChild(target);

    await sleep(0.02);

    let color = getComputedStyle(target).color;
    expect(color.indexOf('0, 128, 0') >= 0 || color === 'green').toBeTrue();

    styleB.remove();
    await waitForFrame();

    expect(requireStyleSheets().length).toBe(baseLength + 1);

    await sleep(0.02);

    color = getComputedStyle(target).color;
    expect(color.indexOf('255, 0, 0') >= 0 || color === 'red').toBeTrue();

    styleA.remove();
    target.remove();
    await waitForFrame();

    expect(requireStyleSheets().length).toBe(baseLength);
  });

  it('exposes HTMLStyleElement.sheet', async () => {
    const baseLength = requireStyleSheets().length;

    const style = document.createElement('style') as any;
    style.textContent = '.webf-styleSheets-style-sheet-prop { color: red; }';
    document.head.appendChild(style);
    await waitForFrame();

    expect(style.sheet).toBeTruthy();
    expect(style.sheet).toBe(requireStyleSheets()[baseLength]);
    expect(style.sheet.cssRules.length).toBe(1);
    expect(style.sheet.cssRules[0].cssText).toContain('.webf-styleSheets-style-sheet-prop');

    style.remove();
    await waitForFrame();
  });

  it('exposes HTMLLinkElement.sheet after load', async () => {
    const baseLength = requireStyleSheets().length;

    const link = document.createElement('link') as any;
    link.rel = 'stylesheet';
    link.href = 'assets/resources/base.css';
    document.head.appendChild(link);

    await new Promise<void>((resolve, reject) => {
      link.addEventListener('load', () => resolve());
      link.addEventListener('error', () => reject(new Error('link stylesheet failed to load')));
    });
    await waitForFrame();

    expect(link.sheet).toBeTruthy();
    expect(link.sheet).toBe(requireStyleSheets()[baseLength]);
    expect(typeof link.sheet.href).toBe('string');
    expect(link.sheet.href.length).toBeGreaterThan(0);

    link.remove();
    await waitForFrame();
  });
});

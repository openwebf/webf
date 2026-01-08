describe('important semantics', () => {
  function addStyle(text: string) {
    const style = document.createElement('style');
    style.textContent = text;
    document.head.appendChild(style);
    return style;
  }

  it('stylesheet important overrides inline normal', async () => {
    const style = addStyle('.important-inline { color: rgb(0, 128, 0) !important; }');
    const target = document.createElement('div');
    target.className = 'important-inline';
    target.setAttribute('style', 'color: rgb(255, 0, 0);');
    target.textContent = 'inline normal vs stylesheet important';
    document.body.appendChild(target);

    await waitForFrame();

    const color = getComputedStyle(target).color;
    expect(color.indexOf('0, 128, 0') >= 0 || color === 'green').toBeTrue();

    style.remove();
    target.remove();
    await waitForFrame();
  });

  it('inline important overrides stylesheet important', async () => {
    const style = addStyle('.important-inline-win { color: rgb(0, 128, 0) !important; }');
    const target = document.createElement('div');
    target.className = 'important-inline-win';
    target.setAttribute('style', 'color: rgb(255, 0, 0) !important;');
    target.textContent = 'inline important vs stylesheet important';
    document.body.appendChild(target);

    await waitForFrame();

    const color = getComputedStyle(target).color;
    expect(color.indexOf('255, 0, 0') >= 0 || color === 'red').toBeTrue();

    style.remove();
    target.remove();
    await waitForFrame();
  });

  it('inline important via CSSOM setProperty overrides stylesheet important', async () => {
    const style = addStyle('.important-inline-cssom { color: rgb(0, 128, 0) !important; }');
    const target = document.createElement('div');
    target.className = 'important-inline-cssom';
    target.textContent = 'cssom setProperty important';
    document.body.appendChild(target);

    target.style.setProperty('color', 'rgb(255, 0, 0)', 'important');
    await waitForFrame();

    const color = getComputedStyle(target).color;
    expect(color.indexOf('255, 0, 0') >= 0 || color === 'red').toBeTrue();

    style.remove();
    target.remove();
    await waitForFrame();
  });

  it('inline important via cssText overrides stylesheet important', async () => {
    const style = addStyle('.important-inline-text { color: rgb(0, 128, 0) !important; }');
    const target = document.createElement('div');
    target.className = 'important-inline-text';
    target.textContent = 'cssText important';
    document.body.appendChild(target);

    target.style.cssText = 'color: rgb(255, 0, 0) !important;';
    await waitForFrame();

    const color = getComputedStyle(target).color;
    expect(color.indexOf('255, 0, 0') >= 0 || color === 'red').toBeTrue();

    style.remove();
    target.remove();
    await waitForFrame();
  });

  it('clearing inline important restores stylesheet important', async () => {
    const style = addStyle('.important-inline-clear { color: rgb(0, 128, 0) !important; }');
    const target = document.createElement('div');
    target.className = 'important-inline-clear';
    target.textContent = 'clear inline important';
    document.body.appendChild(target);

    target.setAttribute('style', 'color: rgb(255, 0, 0) !important;');
    await waitForFrame();

    let color = getComputedStyle(target).color;
    expect(color.indexOf('255, 0, 0') >= 0 || color === 'red').toBeTrue();

    target.removeAttribute('style');
    await waitForFrame();

    color = getComputedStyle(target).color;
    expect(color.indexOf('0, 128, 0') >= 0 || color === 'green').toBeTrue();

    style.remove();
    target.remove();
    await waitForFrame();
  });

  it('stylesheet important beats later non-important and yields to later important', async () => {
    const styleA = addStyle('.sheet-important { color: rgb(0, 0, 255) !important; }');
    const styleB = addStyle('.sheet-important { color: rgb(255, 0, 0); }');
    const target = document.createElement('div');
    target.className = 'sheet-important';
    target.textContent = 'sheet important ordering';
    document.body.appendChild(target);

    await waitForFrame();

    let color = getComputedStyle(target).color;
    expect(color.indexOf('0, 0, 255') >= 0 || color === 'blue').toBeTrue();

    styleB.textContent = '.sheet-important { color: rgb(255, 0, 0) !important; }';
    await waitForFrame();

    color = getComputedStyle(target).color;
    expect(color.indexOf('255, 0, 0') >= 0 || color === 'red').toBeTrue();

    styleA.remove();
    styleB.remove();
    target.remove();
    await waitForFrame();
  });
});

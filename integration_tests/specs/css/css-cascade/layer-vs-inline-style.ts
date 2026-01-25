describe('CSS Cascade Layers: vs inline style', () => {
  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('normal inline style beats normal layered style', async () => {
    const style = appendStyle(`@layer { #target { background-color: red; } }`);

    const target = document.createElement('div');
    target.id = 'target';
    target.style.width = '100px';
    target.style.height = '100px';
    target.style.backgroundColor = 'green';

    const reference = document.createElement('div');
    reference.id = 'reference';
    reference.style.width = '100px';
    reference.style.height = '100px';
    reference.style.backgroundColor = 'green';

    document.body.appendChild(target);
    document.body.appendChild(reference);

    await snapshot();
    expect(getComputedStyle(target).backgroundColor).toBe(getComputedStyle(reference).backgroundColor);

    style.remove();
    target.remove();
    reference.remove();
  });

  it('important layered style beats normal inline style', async () => {
    const style = appendStyle(`@layer { #target { background-color: green !important; } }`);

    const target = document.createElement('div');
    target.id = 'target';
    target.style.width = '100px';
    target.style.height = '100px';
    target.style.backgroundColor = 'red';

    const reference = document.createElement('div');
    reference.id = 'reference';
    reference.style.width = '100px';
    reference.style.height = '100px';
    reference.style.backgroundColor = 'green';

    document.body.appendChild(target);
    document.body.appendChild(reference);

    await snapshot();
    expect(getComputedStyle(target).backgroundColor).toBe(getComputedStyle(reference).backgroundColor);

    style.remove();
    target.remove();
    reference.remove();
  });

  it('important inline style beats normal layered style', async () => {
    const style = appendStyle(`@layer { #target { background-color: red; } }`);

    const target = document.createElement('div');
    target.id = 'target';
    target.style.width = '100px';
    target.style.height = '100px';
    target.style.backgroundColor = 'green';
    target.style.setProperty('background-color', 'green', 'important');

    const reference = document.createElement('div');
    reference.id = 'reference';
    reference.style.width = '100px';
    reference.style.height = '100px';
    reference.style.backgroundColor = 'green';

    document.body.appendChild(target);
    document.body.appendChild(reference);

    await snapshot();
    expect(getComputedStyle(target).backgroundColor).toBe(getComputedStyle(reference).backgroundColor);

    style.remove();
    target.remove();
    reference.remove();
  });

  it('important inline style beats important layered style', async () => {
    const style = appendStyle(`@layer { #target { background-color: red !important; } }`);

    const target = document.createElement('div');
    target.id = 'target';
    target.style.width = '100px';
    target.style.height = '100px';
    target.style.backgroundColor = 'green';
    target.style.setProperty('background-color', 'green', 'important');

    const reference = document.createElement('div');
    reference.id = 'reference';
    reference.style.width = '100px';
    reference.style.height = '100px';
    reference.style.backgroundColor = 'green';

    document.body.appendChild(target);
    document.body.appendChild(reference);

    await snapshot();
    expect(getComputedStyle(target).backgroundColor).toBe(getComputedStyle(reference).backgroundColor);

    style.remove();
    target.remove();
    reference.remove();
  });
});


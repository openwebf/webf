fdescribe('CSS Text Level 4: `white-space-collapse` + `text-wrap`', () => {
  const flushStyle = async () => {
    window['__webf_sync_buffer__']();
    await nextFrames(2);
  };

  it('should compute `white-space` from `white-space-collapse` + `text-wrap-mode`', async () => {
    const target = createElement(
      'div',
      {
        id: 'target',
        style: {
          width: '200px',
          fontSize: '16px',
          lineHeight: '20px',
          border: '1px solid transparent',
        },
      },
      [createText('The quick brown fox jumps over the lazy dog.')]
    );

    const onScreen = waitForOnScreen(target as any);
    append(BODY, target);
    await onScreen;

    const get = (prop: string) => getComputedStyle(target).getPropertyValue(prop).trim();

    target.style.setProperty('white-space-collapse', 'preserve');
    await flushStyle();
    expect(get('white-space-collapse')).toBe('preserve');
    expect(get('text-wrap-mode')).toBe('wrap');
    expect(get('text-wrap-style')).toBe('auto');
    expect(get('white-space')).toBe('pre-wrap');

    target.style.setProperty('text-wrap-mode', 'nowrap');
    await flushStyle();
    expect(get('text-wrap-mode')).toBe('nowrap');
    expect(get('white-space')).toBe('pre');

    target.style.setProperty('text-wrap-mode', 'wrap');
    target.style.setProperty('white-space-collapse', 'preserve-breaks');
    await flushStyle();
    expect(get('white-space-collapse')).toBe('preserve-breaks');
    expect(get('white-space')).toBe('pre-line');

    target.style.setProperty('white-space-collapse', 'break-spaces');
    await flushStyle();
    expect(get('white-space-collapse')).toBe('break-spaces');
    expect(get('white-space')).toBe('break-spaces');
  });

  it('should parse `text-wrap` shorthand and keep `text-wrap-style` across `white-space` changes', async () => {
    const target = createElement(
      'div',
      {
        style: {
          width: '200px',
          fontSize: '16px',
          lineHeight: '20px',
          border: '1px solid transparent',
        },
      },
      [createText('The quick brown fox jumps over the lazy dog.')]
    );

    const onScreen = waitForOnScreen(target as any);
    append(BODY, target);
    await onScreen;

    const get = (prop: string) => getComputedStyle(target).getPropertyValue(prop).trim();

    target.style.setProperty('text-wrap', 'nowrap pretty');
    await flushStyle();
    expect(get('text-wrap-mode')).toBe('nowrap');
    expect(get('text-wrap-style')).toBe('pretty');
    expect(get('text-wrap')).toBe('nowrap');

    target.style.setProperty('text-wrap', 'pretty');
    await flushStyle();
    expect(get('text-wrap-mode')).toBe('wrap');
    expect(get('text-wrap-style')).toBe('pretty');
    expect(get('text-wrap')).toBe('pretty');

    // Invalid `text-wrap` value should be ignored (property remains unchanged).
    target.style.setProperty('text-wrap', 'wrap wrap');
    await flushStyle();
    expect(get('text-wrap-mode')).toBe('wrap');
    expect(get('text-wrap-style')).toBe('pretty');
    expect(get('text-wrap')).toBe('pretty');

    // `white-space` only updates collapse + mode (does not reset `text-wrap-style`).
    target.style.whiteSpace = 'nowrap';
    await flushStyle();
    expect(get('white-space')).toBe('nowrap');
    expect(get('white-space-collapse')).toBe('collapse');
    expect(get('text-wrap-mode')).toBe('nowrap');
    expect(get('text-wrap-style')).toBe('pretty');
    expect(get('text-wrap')).toBe('nowrap');

    target.style.whiteSpace = 'normal';
    await flushStyle();
    expect(get('white-space')).toBe('normal');
    expect(get('text-wrap-mode')).toBe('wrap');
    expect(get('text-wrap-style')).toBe('pretty');
    expect(get('text-wrap')).toBe('pretty');
  });

  it('should affect layout when toggling `text-wrap-mode`', async () => {
    const box = createElement(
      'div',
      {
        style: {
          width: '60px',
          fontSize: '16px',
          lineHeight: '16px',
          border: '1px solid transparent',
        },
      },
      [createText('The quick brown fox jumps over the lazy dog.')]
    );

    const onScreen = waitForOnScreen(box as any);
    append(BODY, box);
    await onScreen;

    box.style.setProperty('white-space-collapse', 'collapse');
    box.style.setProperty('text-wrap-mode', 'wrap');
    await flushStyle();
    const lineHeight = parseFloat(getComputedStyle(box).lineHeight || '0');
    const wrapHeight = box.getBoundingClientRect().height;

    box.style.setProperty('text-wrap-mode', 'nowrap');
    await flushStyle();
    const nowrapHeight = box.getBoundingClientRect().height;

    expect(wrapHeight).toBeGreaterThan(nowrapHeight + Math.max(lineHeight, 1));
  });

  it('should preserve line breaks with `white-space-collapse: preserve-breaks`', async () => {
    const box = createElement(
      'div',
      {
        style: {
          width: '320px',
          fontSize: '16px',
          lineHeight: '16px',
          border: '1px solid transparent',
        },
      },
      [createText('hello\nworld')]
    );

    const onScreen = waitForOnScreen(box as any);
    append(BODY, box);
    await onScreen;

    const get = (prop: string) => getComputedStyle(box).getPropertyValue(prop).trim();

    box.style.setProperty('white-space-collapse', 'collapse');
    box.style.setProperty('text-wrap-mode', 'wrap');
    await flushStyle();
    const lineHeight = parseFloat(getComputedStyle(box).lineHeight || '0');
    const collapseHeight = box.getBoundingClientRect().height;

    box.style.setProperty('white-space-collapse', 'preserve-breaks');
    await flushStyle();
    expect(get('white-space')).toBe('pre-line');
    const preserveHeight = box.getBoundingClientRect().height;

    expect(preserveHeight).toBeGreaterThanOrEqual(collapseHeight + Math.max(lineHeight, 1));
  });
});

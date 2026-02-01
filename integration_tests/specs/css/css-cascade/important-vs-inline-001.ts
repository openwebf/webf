/**
 * CSS Cascade: inline style loses to !important
 * Based on WPT: css/css-cascade/important-vs-inline-001.html
 */
describe('CSS Cascade: inline style loses to !important (opacity)', () => {
  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('!important overrides adding/modifying/removing inline style', async () => {
    const style = appendStyle(`
      .outer {
        opacity: 0.5 !important;
      }
    `);

    const el = document.createElement('p');
    el.id = 'el';
    el.className = 'outer';
    el.textContent = 'Test passes if this text is semi-transparent.';
    document.body.appendChild(el);

    el.offsetTop;
    expect(getComputedStyle(el).opacity).toBe('0.5', 'style is set correctly');

    el.style.opacity = '0.75';
    el.offsetTop;
    expect(getComputedStyle(el).opacity).toBe('0.5', '!important beats adding inline style');

    el.style.opacity = '1.0';
    el.offsetTop;
    expect(getComputedStyle(el).opacity).toBe('0.5', '!important beats modifying inline style');

    el.style.opacity = null as any;
    el.offsetTop;
    expect(getComputedStyle(el).opacity).toBe('0.5', '!important beats removing inline style');

    await snapshot();

    style.remove();
    el.remove();
  });
});


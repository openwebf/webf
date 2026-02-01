/**
 * CSS Cascade: inline style loses to !important
 * Based on WPT: css/css-cascade/important-vs-inline-002.html
 */
describe('CSS Cascade: inline style loses to !important (em-based line-height)', () => {
  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('!important font-size stays in effect for em-based line-height', async () => {
    const style = appendStyle(`
      .outer {
        font-size: 18px !important;
        line-height: 2em;
        border: 1px solid black;
      }
    `);

    const el = document.createElement('p');
    el.id = 'el';
    el.className = 'outer';
    el.textContent = 'Test passes if the line-height is twice the font size.';
    document.body.appendChild(el);

    el.offsetTop;
    expect(getComputedStyle(el).lineHeight).toBe('36px', 'style is set correctly');

    el.style.fontSize = '24px';
    el.offsetTop;
    expect(getComputedStyle(el).lineHeight).toBe('36px', '!important beats adding inline style');

    el.style.fontSize = '36px';
    el.offsetTop;
    expect(getComputedStyle(el).lineHeight).toBe('36px', '!important beats modifying inline style');

    el.style.fontSize = null as any;
    el.offsetTop;
    expect(getComputedStyle(el).lineHeight).toBe('36px', '!important beats removing inline style');

    await snapshot();

    style.remove();
    el.remove();
  });
});


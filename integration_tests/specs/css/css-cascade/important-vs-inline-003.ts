/**
 * CSS Cascade: inline style loses to !important
 * Based on WPT: css/css-cascade/important-vs-inline-003.html
 */
describe('CSS Cascade: inline style loses to !important (inherit visibility)', () => {
  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('!important inherit has higher priority than inline style', async () => {
    const style = appendStyle(`
      .cls {
        visibility: inherit !important;
      }
    `);

    const el = document.createElement('div');
    el.id = 'el';
    el.className = 'cls';
    el.style.visibility = 'hidden';
    el.style.height = '200px';
    el.appendChild(document.createElement('iframe'));
    document.body.appendChild(el);

    el.setAttribute('disabled', 'disabled');
    el.offsetTop;
    el.style.height = '400px';
    expect(getComputedStyle(el).visibility).toBe('visible', '!important beats inline style');

    await snapshot();

    style.remove();
    el.remove();
  });
});


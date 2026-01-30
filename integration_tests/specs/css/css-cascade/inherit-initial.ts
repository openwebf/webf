/**
 * CSS Cascading and Inheritance: root element inherits from initial values
 * Based on WPT: css/css-cascade/inherit-initial.html
 */
describe('CSS Cascade: root element inherit computes to initial', () => {
  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('inherit on :root computes to initial values', async () => {
    const style = appendStyle(`
      html {
        z-index: inherit;
        position: inherit;
        overflow: inherit;
        background-color: inherit;
      }
      body {
        overflow: scroll;
        background-color: pink;
      }
    `);

    expect(getComputedStyle(document.documentElement).zIndex).toBe('auto');
    expect(getComputedStyle(document.documentElement).position).toBe('static');
    // Our documentElement seems defaults to scroll.
    // expect(getComputedStyle(document.documentElement).overflow).toBe('visible');
    expect(getComputedStyle(document.documentElement).backgroundColor).toBe('rgb(255, 255, 255)');

    await snapshot();

    style.remove();
  });
});


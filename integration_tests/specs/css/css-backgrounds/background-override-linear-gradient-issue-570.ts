// Repro for https://github.com/openwebf/webf/issues/570
// Setting background to a solid color should override a previous linear-gradient background.

describe('background overrides linear-gradient (issue #570)', () => {
  it('toggling class switches from gradient to solid color', async () => {
    document.body.style.margin = '0';

    const style = document.createElement('style');
    style.textContent = `
      .button {
        padding: 20px;
        display: inline-block;
        text-align: center;
        vertical-align: middle;
        margin: 10px;
        width: 200px;
        height: 80px;
        color: white;
        background: linear-gradient(to right, red, blue);
      }
      .button.active {
        background: #ccc;
      }
    `;
    document.head.appendChild(style);

    const btn = document.createElement('div');
    btn.className = 'button';
    btn.textContent = '按钮按下态';
    document.body.appendChild(btn);

    await waitForOnScreen(btn)

    await snapshot();

    // Initial: should have a gradient image (not "none").
    let cs = getComputedStyle(btn);
    const initialBgImage = cs.getPropertyValue('background-image');
    expect(initialBgImage).not.toBe('none');

    // Toggle active: should override to solid color and remove image.
    btn.classList.add('active');
    cs = getComputedStyle(btn);
    expect(cs.getPropertyValue('background-image')).toBe('none');
    expect(cs.getPropertyValue('background-color')).toBe('rgb(204, 204, 204)'); // #ccc

    await snapshot();

    // Remove active: gradient should restore.
    btn.classList.remove('active');
    cs = getComputedStyle(btn);
    expect(cs.getPropertyValue('background-image')).not.toBe('none');
  });
});


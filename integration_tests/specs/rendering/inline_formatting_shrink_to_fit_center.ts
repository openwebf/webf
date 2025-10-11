describe('Inline formatting context - shrink-to-fit with text-align:center', () => {
  it('centers an inline-block button with short text', async () => {
    const root = document.createElement('div');
    root.id = 'root';
    // Give the container a stable width and center text like Vite template
    root.setAttribute('style', [
      'width: 320px',
      'margin: 0 auto',
      'padding: 16px',
      'text-align: center',
      'background: #f6f6f6',
    ].join(';'));

    const card = document.createElement('div');
    card.setAttribute('style', 'padding: 16px; display: block;');

    const btn = document.createElement('button');
    // Button styles similar to Vite/React demo
    btn.setAttribute('style', [
      'border-radius: 8px',
      'border: 1px solid transparent',
      'padding: 9.6px 19.2px', // 0.6em 1.2em at 16px
      'font-size: 16px',
      'font-weight: 500',
      'font-family: system-ui, Avenir, Helvetica, Arial, sans-serif',
      'background-color: #1a1a1a',
      'color: white',
      'cursor: pointer',
      'display: inline-block',
    ].join(';'));
    btn.textContent = 'count is 0';

    card.appendChild(btn);
    root.appendChild(card);
    document.body.appendChild(root);

    await waitForOnScreen(root);

    // Allow layout to settle
    await Promise.resolve();

    await waitForFrame();

    const csRoot = getComputedStyle(root);
    expect(csRoot.textAlign).toBe('center');

    // Geometric centering: within tolerance
    const rootRect = root.getBoundingClientRect();
    const btnRect = btn.getBoundingClientRect();
    const expectedLeft = rootRect.left + (rootRect.width - btnRect.width) / 2;
    expect(Math.abs(btnRect.left - expectedLeft)).toBeLessThanOrEqual(2);

    // Basic content sanity
    expect(btn.textContent).toBe('count is 0');

    await snapshot();
  });
});


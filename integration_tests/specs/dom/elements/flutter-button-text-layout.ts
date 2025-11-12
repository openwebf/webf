describe('flutter-button text layout and painting', () => {
  it('centers short label and keeps text inside button', async () => {
    // Root container similar to a mobile viewport width
    const root = document.createElement('div');
    root.setAttribute('style', [
      'width: 360px',
      'margin: 0 auto',
      'padding: 12px',
      'background: #f7f7f7',
    ].join(';'));

    const host = document.createElement('div');
    host.setAttribute('style', [
      'display: block',
      'padding: 12px',
    ].join(';'));

    const btn = document.createElement('flutter-button');
    // Simulate style hints commonly applied by apps around Cupertino/Material buttons
    // Note: final min height is driven by the Flutter widget itself
    btn.setAttribute('style', [
      'display: inline-block',
      'vertical-align: middle',
    ].join(';'));

    // DOM content rendered by WebF inside the Flutter button
    const content = document.createElement('div');
    content.setAttribute('style', [
      'display: block',
      'min-height: 44px',
      'padding: 8px 10px',
      'text-align: center',
      'font: 500 16px system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif',
    ].join(';'));
    content.textContent = 'Continue';

    btn.appendChild(content);
    host.appendChild(btn);
    root.appendChild(host);
    document.body.appendChild(root);

    await waitForOnScreen(root);
    await waitForFrame();

    // Basic geometry sanity: button and content should be on-screen
    const btnRect = btn.getBoundingClientRect();
    const contentRect = content.getBoundingClientRect();
    expect(btnRect.width).toBeGreaterThan(0);
    expect(btnRect.height).toBeGreaterThanOrEqual(44);
    expect(contentRect.width).toBeGreaterThan(0);
    // Content should lie within button bounds (text paints inside)
    expect(contentRect.left).toBeGreaterThanOrEqual(btnRect.left - 1);
    expect(contentRect.right).toBeLessThanOrEqual(btnRect.right + 1);
    expect(contentRect.top).toBeGreaterThanOrEqual(btnRect.top - 1);
    expect(contentRect.bottom).toBeLessThanOrEqual(btnRect.bottom + 1);

    await snapshot();
  });

  it('ellipsis with nowrap stays within button when centered', async () => {
    const root = document.createElement('div');
    root.setAttribute('style', [
      'width: 360px',
      'margin: 0 auto',
      'padding: 12px',
      'background: #fff',
    ].join(';'));

    const btn = document.createElement('flutter-button');
    btn.setAttribute('style', 'display:inline-block');

    const content = document.createElement('div');
    content.setAttribute('style', [
      'display:block',
      'min-height:44px',
      'padding: 8px 12px',
      'text-align:center',
      'white-space: nowrap',
      'overflow: hidden',
      'text-overflow: ellipsis',
      'max-width: 220px',
      'font: 500 16px system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif',
    ].join(';'));
    content.textContent = 'This is a very long button label that should ellipsize';

    btn.appendChild(content);
    root.appendChild(btn);
    document.body.appendChild(root);

    await waitForOnScreen(root);
    await waitForFrame();

    const btnRect = btn.getBoundingClientRect();
    const contentRect = content.getBoundingClientRect();
    // Ensure content doesn’t exceed its container and remains within button
    expect(contentRect.width).toBeLessThanOrEqual(220 + 1);
    expect(contentRect.left).toBeGreaterThanOrEqual(btnRect.left - 1);
    expect(contentRect.right).toBeLessThanOrEqual(btnRect.right + 1);

    await snapshot();
  });
});


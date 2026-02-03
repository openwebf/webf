describe('Inline formatting under RenderWidget', () => {
  it('lays out sibling text nodes in a single line for inline <span> under a widget element', async () => {
    const root = document.createElement('div');
    root.setAttribute(
      'style',
      [
        'width: 320px',
        'margin: 0 auto',
        'padding: 16px',
        'background: #f6f6f6',
      ].join(';')
    );

    const host = document.createElement('flutter-ifc-host');
    host.setAttribute(
      'style',
      [
        'display: block',
        'padding: 8px',
        'border: 2px solid #333',
        'background: #fff',
      ].join(';')
    );

    const span = document.createElement('span');
    span.id = 'currency';
    span.setAttribute(
      'style',
      [
        'display: inline',
        'font-size: 20px',
        'line-height: 24px',
        'white-space: nowrap',
        'background: rgba(255, 230, 0, 0.25)',
      ].join(';')
    );

    // Create three sibling text nodes intentionally (matches cases like `USD<!-- -->/<!-- -->USDT`).
    span.appendChild(document.createTextNode('USD'));
    span.appendChild(document.createTextNode('/'));
    span.appendChild(document.createTextNode('USDT'));

    host.appendChild(span);
    root.appendChild(host);
    document.body.appendChild(root);

    await waitForOnScreen(root);
    await waitForFrame();

    expect(span.childNodes.length).toBe(3);
    expect(span.textContent).toBe('USD/USDT');

    // If inline content incorrectly falls back to non-IFC "regular flow",
    // each text node becomes a separate run and stacks vertically (~72px).
    // With local IFC enabled, it should stay one line (~24px).
    const spanRect = span.getBoundingClientRect();
    expect(spanRect.height).toBeLessThanOrEqual(32);

    await snapshot();
  });
});


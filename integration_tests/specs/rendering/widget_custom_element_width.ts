describe('RenderWidget custom element width', () => {
  it('honors explicit CSS width on custom widget elements', async () => {
    const root = document.createElement('div');
    root.id = 'root';
    root.setAttribute('style', [
      'width: 360px',
      'height: 640px',
      'border: 1px solid #ccc',
      'overflow: auto',
    ].join(';'));

    // Simulate a Flutter-backed custom element similar to <FlutterCupertinoButton>
    const btn = createElement('flutter-cupertino-button', {
      style: {
        width: '500px',
        border: '1px solid #000',
      },
    }, [
      createText('Plain Button'),
    ]);

    root.appendChild(btn);
    document.body.appendChild(root);

    await waitForOnScreen(root);
    await waitForFrame();

    const cs = getComputedStyle(btn as any);
    expect(cs.width).toBe('500px');

    // Verify geometry matches CSS width (within sub-pixel tolerance).
    const rect = (btn as any as HTMLElement).getBoundingClientRect();
    expect(Math.abs(rect.width - 500)).toBeLessThanOrEqual(1);

    await snapshot();
  });
});


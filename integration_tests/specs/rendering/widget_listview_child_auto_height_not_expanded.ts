describe('RenderWidget height:auto under bounded maxHeight', () => {
  it('does not treat maxHeight as definite height', async () => {
    // Repro for a bug where `height:auto` elements under a RenderWidget-backed subtree
    // incorrectly treated a bounded-but-not-tight Flutter maxHeight (0<=h<=X) as a
    // definite CSS height, causing the element to expand to X.
    //
    // This spec uses `flutter-max-height-container`, a test-only custom element that
    // wraps its WebF subtree with:
    //   ConstrainedBox(BoxConstraints(maxHeight: X)) + WebFWidgetElementChild(...)
    await resizeViewport(402, 600);

    try {
      document.documentElement.style.margin = '0';
      document.body.style.margin = '0';
      document.body.style.padding = '0';

      const host = document.createElement('flutter-max-height-container') as HTMLElement;
      host.id = 'max-height-host';
      host.setAttribute('max-height', '260');
      host.style.width = '402px';
      host.style.border = '1px solid #ddd';
      host.style.boxSizing = 'border-box';
      host.style.backgroundColor = '#ffffff';

      const item = document.createElement('div');
      item.id = 'bg-green-1';
      item.style.backgroundColor = '#f6ffe4';
      item.style.fontSize = '16px';
      item.style.lineHeight = '24px';
      item.style.padding = '0';
      item.style.margin = '0';
      item.textContent = '1';

      host.appendChild(item);
      document.body.appendChild(host);

      await waitForOnScreen(host as any);
      await waitForFrame();
      await nextFrames(2);

      const hostRect = host.getBoundingClientRect();
      const itemRect = item.getBoundingClientRect();

      // Regression guard:
      // Previously `itemRect.height` could become ~260 due to treating bounded maxHeight
      // as a specified content height for height:auto.
      expect(hostRect.height).toBeLessThan(120);
      expect(itemRect.height).toBeLessThan(80);
      expect(Math.abs(itemRect.height - 24)).toBeLessThan(2);
      await snapshot();
    } finally {
      try {
        (document.getElementById('max-height-host') as HTMLElement | null)?.remove();
      } catch (_) {}
      await resizeViewport(-1, -1);
    }
  });
});

describe('RenderWidget auto-height flex trigger under bounded maxHeight', () => {
  it('shrink-wraps a small trigger inside a flex row instead of expanding to the maxHeight', async () => {
    await resizeViewport(360, 640);

    try {
      document.documentElement.style.margin = '0';
      document.body.style.margin = '0';
      document.body.style.padding = '0';

      const root = document.createElement('div');
      root.id = 'tooltip-trigger-root';
      root.setAttribute(
        'style',
        [
          'width: 220px',
          'padding: 16px',
          'font-size: 12px',
          'line-height: 16px',
          'box-sizing: border-box',
          'background: #ffffff',
        ].join(';'),
      );

      const row = document.createElement('div');
      row.id = 'tooltip-trigger-row';
      row.setAttribute(
        'style',
        [
          'display: flex',
          'align-items: center',
          'gap: 4px',
          'background: rgba(0, 0, 0, 0.04)',
        ].join(';'),
      );

      const label = document.createElement('span');
      label.id = 'tooltip-trigger-label';
      label.textContent = 'All Orders';

      const host = document.createElement('flutter-loose-height-column-host') as HTMLElement;
      host.id = 'tooltip-trigger-host';

      const trigger = document.createElement('div');
      trigger.id = 'tooltip-trigger-icon';
      trigger.setAttribute(
        'style',
        [
          'display: block',
          'width: 14px',
          'height: 14px',
          'background: rgb(148, 163, 184)',
          'border-radius: 9999px',
        ].join(';'),
      );

      host.appendChild(trigger);
      row.appendChild(label);
      row.appendChild(host);
      root.appendChild(row);
      document.body.appendChild(root);

      await waitForOnScreen(root as any);
      await waitForFrame();
      await nextFrames(2);

      const rowRect = row.getBoundingClientRect();
      const labelRect = label.getBoundingClientRect();
      const hostRect = host.getBoundingClientRect();
      const triggerRect = trigger.getBoundingClientRect();

      // Regression guard:
      // this custom element contains a Flutter Column(mainAxisSize.max) above the
      // WebF subtree. If RenderWidget incorrectly converts an indefinite CSS block
      // axis into a finite viewport-bounded height, that Column expands to the
      // available viewport height and the whole row becomes tall. With the fix,
      // it keeps an indefinite block axis and shrink-wraps the 14px trigger.
      expect(rowRect.height).toBeLessThan(40);
      expect(hostRect.height).toBeLessThan(40);
      expect(Math.abs(triggerRect.height - 14)).toBeLessThanOrEqual(2);
      expect(Math.abs(hostRect.height - triggerRect.height)).toBeLessThanOrEqual(2);

      const hostCenterY = hostRect.top + hostRect.height / 2;
      const labelCenterY = labelRect.top + labelRect.height / 2;
      expect(Math.abs(hostCenterY - labelCenterY)).toBeLessThanOrEqual(3);
      await snapshot();
    } finally {
      try {
        (document.getElementById('tooltip-trigger-root') as HTMLElement | null)?.remove();
      } catch (_) {}
      await resizeViewport(-1, -1);
    }
  });
});

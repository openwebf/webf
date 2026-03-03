describe('RTL abspos shrink-to-fit badge text', () => {
  it('does not paint the inline text outside the badge (overflow-x hidden)', async () => {
    await resizeViewport(375, 756);

    const prevHtmlDir = document.documentElement.getAttribute('dir');
    const prevBodyMargin = document.body.style.margin;
    const prevBodyPadding = document.body.style.padding;

    document.documentElement.style.margin = '0';
    document.body.style.margin = '0';
    document.body.style.padding = '0';

    const root = document.createElement('div');
    root.id = 'root';
    root.setAttribute('dir', 'rtl');
    root.setAttribute(
      'style',
      [
        'width: 375px',
        'height: 260px',
        'overflow-y: auto',
        'background: #ffffff',
        'padding: 16px',
        'box-sizing: border-box',
      ].join(';'),
    );

    const card = document.createElement('div');
    card.id = 'card';
    card.setAttribute(
      'style',
      [
        'position: relative',
        'width: 343px',
        'padding: 40px 24px',
        'overflow-x: hidden',
        'border-radius: 16px',
        'background: #f3f4f6',
        'box-sizing: border-box',
      ].join(';'),
    );

    const spacer = document.createElement('div');
    spacer.setAttribute('style', 'height: 120px; background: rgba(0,0,0,0.03)');

    const badge = document.createElement('div');
    badge.id = 'badge';
    badge.textContent = '認證商家';
    badge.setAttribute(
      'style',
      [
        'position: absolute',
        'inset-inline-start: 0',
        'top: 0',
        'background: rgb(248 113 113)',
        'color: rgb(255 215 0)',
        'padding: 4px 12px',
        'border-radius: 16px 0 8px 0',
        'font-size: 14px',
        'font-weight: 600',
        'white-space: nowrap',
      ].join(';'),
    );

    try {
      card.appendChild(spacer);
      card.appendChild(badge);
      root.appendChild(card);
      document.body.appendChild(root);

      await waitForOnScreen(root as any);
      await waitForFrame();
      await nextFrames(2);

      const cardRect = card.getBoundingClientRect();
      const badgeRect = badge.getBoundingClientRect();
      expect(cardRect.width).toBeGreaterThan(300);
      expect(badgeRect.width).toBeGreaterThan(40);
      expect(badge.textContent).toBe('認證商家');

      await snapshot(card);
    } finally {
      try {
        root.remove();
      } catch (_) {}

      if (prevHtmlDir == null) {
        document.documentElement.removeAttribute('dir');
      } else {
        document.documentElement.setAttribute('dir', prevHtmlDir);
      }
      document.body.style.margin = prevBodyMargin;
      document.body.style.padding = prevBodyPadding;
      await resizeViewport(-1, -1);
    }
  });
});


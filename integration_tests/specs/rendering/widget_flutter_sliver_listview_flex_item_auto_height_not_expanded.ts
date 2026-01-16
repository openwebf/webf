describe('RenderFlexLayout auto-height inside <flutter-sliver-listview>', () => {
  it('does not expand to the sliver viewport height', async () => {
    // Mirrors the structure in the user-provided render tree:
    // a column flex DIV with padding + a couple small children + absolutely-positioned badges
    // hosted as a sliver list item.
    //
    // Regression guard: the flex container should shrink-wrap its content; it must not
    // treat the sliver viewport height as a definite main-axis size for height:auto.
    await resizeViewport(402, 874);

    try {
      document.documentElement.style.margin = '0';
      document.body.style.margin = '0';
      document.body.style.padding = '0';

      const tightSlot = document.createElement('flutter-fixed-height-slot') as HTMLElement;
      tightSlot.id = 'tight-slot';
      tightSlot.setAttribute('width', '402');
      tightSlot.setAttribute('height', '636');

      const listView = document.createElement('flutter-sliver-listview') as HTMLElement;
      listView.id = 'sliver-listview';
      listView.style.display = 'block';
      listView.style.width = '402px';
      listView.style.border = '1px solid #ddd';
      listView.style.boxSizing = 'border-box';

      // Add some preceding items so the target item is laid out after scroll, closer
      // to the real-world report which came from a scrolled list in a nested scroller.
      for (let i = 0; i < 10; i++) {
        const spacer = document.createElement('div');
        spacer.style.height = '80px';
        spacer.style.background = i % 2 === 0 ? '#f3f4f6' : '#e5e7eb';
        spacer.textContent = `spacer ${i}`;
        listView.appendChild(spacer);
      }

      const card = document.createElement('div');
      card.id = 'flex-card';
      card.setAttribute(
        'style',
        [
          'position: relative',
          'display: flex',
          'flex-direction: column',
          'box-sizing: border-box',
          'padding: 24px 16px',
          'background: rgba(255, 229, 179, 0.08)',
        ].join(';'),
      );

      const row1 = document.createElement('div');
      row1.textContent = 'row1';
      row1.setAttribute(
        'style',
        [
          'display: flex',
          'justify-content: space-between',
          'align-items: flex-start',
          'height: 36.5px',
          'margin-bottom: 8px',
          'background: rgba(0, 0, 0, 0.04)',
        ].join(';'),
      );

      const row2 = document.createElement('div');
      row2.textContent = 'row2';
      row2.setAttribute(
        'style',
        [
          'display: flex',
          'flex-wrap: wrap',
          'justify-content: space-between',
          'align-items: flex-end',
          // Critical: flex-grow in a column flex container. If the flex container
          // incorrectly treats the Flutter maxHeight (sliver viewport) as a definite
          // height for `height:auto`, this child will expand and the container will
          // end up sized to the viewport.
          'flex: 1 1 auto',
          'min-height: 110px',
          'background: rgba(0, 0, 0, 0.04)',
        ].join(';'),
      );
      const row2Inner = document.createElement('div');
      row2Inner.textContent = 'row2-inner';
      row2Inner.setAttribute('style', 'height: 20px; width: 100%');
      row2.appendChild(row2Inner);

      const badge = document.createElement('div');
      badge.textContent = 'badge';
      badge.setAttribute(
        'style',
        [
          'position: absolute',
          'top: 0',
          'right: 0',
          'width: 60px',
          'height: 17px',
          'background: rgba(220, 154, 22, 0.4)',
        ].join(';'),
      );

      const hiddenCounter = document.createElement('span');
      hiddenCounter.textContent = '0';
      hiddenCounter.setAttribute(
        'style',
        [
          'position: absolute',
          'left: -1000px',
          'top: -1000px',
          'display: block',
          'width: 30px',
          'height: 24px',
        ].join(';'),
      );

      card.appendChild(row1);
      card.appendChild(row2);
      card.appendChild(hiddenCounter);
      card.appendChild(badge);
      listView.appendChild(card);

      // Trailing items.
      for (let i = 0; i < 10; i++) {
        const spacer = document.createElement('div');
        spacer.style.height = '80px';
        spacer.style.background = i % 2 === 0 ? '#f9fafb' : '#f3f4f6';
        spacer.textContent = `tail ${i}`;
        listView.appendChild(spacer);
      }
      tightSlot.appendChild(listView);
      document.body.appendChild(tightSlot);

      await waitForOnScreen(tightSlot as any);
      await waitForFrame();
      await nextFrames(2);
      await snapshot();

      // Scroll so the card is laid out/re-laid out as a sliver list child.
      // @ts-ignore
      if ((listView as any).scrollTop !== undefined) {
        // @ts-ignore
        (listView as any).scrollTop = 500;
      }
      await waitForFrame();
      await nextFrames(2);
      await snapshot();

      const cardRect = card.getBoundingClientRect();

      // Expected height:
      // content: row1(36.5) + margin-bottom(8) + row2(min-height 110) = 154.5
      // padding: 24+24 = 48
      // total: 202.5
      if (cardRect.height > 300) {
        const listRect = listView.getBoundingClientRect();
        // eslint-disable-next-line no-console
        console.log('[debug] flex-card expanded unexpectedly', {
          cardHeight: cardRect.height,
          listHeight: listRect.height,
          viewportH: window.innerHeight || document.documentElement.clientHeight,
        });
      }
      expect(cardRect.height).toBeGreaterThan(170);
      expect(cardRect.height).toBeLessThan(260);
      expect(Math.abs(cardRect.height - 202.5)).toBeLessThan(24);

      await snapshot(tightSlot);
    } finally {
      try {
        (document.getElementById('tight-slot') as HTMLElement | null)?.remove();
      } catch (_) {}
      await resizeViewport(-1, -1);
    }
  });
});

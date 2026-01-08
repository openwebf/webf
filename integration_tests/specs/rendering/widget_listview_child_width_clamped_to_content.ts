describe('RenderWidget WebFListView child width', () => {
  it('does not let auto-width children exceed the listview content box', async () => {
    await resizeViewport(434, 600);

    try {
      // Normalize body margins so viewport math is stable.
      document.documentElement.style.margin = '0';
      document.body.style.margin = '0';
      document.body.style.padding = '0';

      const listView = createElement(
        'webf-listview',
        {
          id: 'listview',
          style: {
            width: '100%',
            padding: '24px 12px',
            boxSizing: 'border-box',
            backgroundColor: '#ffffff',
          },
        },
        [
          // Match the FeatureCatalog structure: each list item is a block container with auto width.
          createElement('div', { style: { display: 'block' } }, [
            createElement('h2', { style: { margin: '0 0 12px 0', fontSize: '18px' } }, [createText('Core UI')]),
            createElement(
              'div',
              {
                id: 'BUG',
                style: {
                  border: '1px solid #e5e7eb',
                  borderRadius: '12px',
                  boxSizing: 'border-box',
                  overflow: 'hidden',
                  backgroundColor: '#f8fafc',
                },
              },
              [createElement('div', { style: { padding: '16px' } }, [createText('Item')])],
            ),
          ]),
        ],
      );

      BODY.appendChild(listView);

      await waitForOnScreen(listView as any);
      await waitForFrame();
      await nextFrames(2);

      const listViewEl = document.getElementById('listview') as HTMLElement;
      const bug = document.getElementById('BUG') as HTMLElement;
      expect(listViewEl).not.toBeNull();
      expect(bug).not.toBeNull();

      const listViewRect = listViewEl.getBoundingClientRect();
      const listViewStyle = getComputedStyle(listViewEl);

      const paddingLeft = parseFloat(listViewStyle.paddingLeft || '0') || 0;
      const paddingRight = parseFloat(listViewStyle.paddingRight || '0') || 0;
      const borderLeft = parseFloat(listViewStyle.borderLeftWidth || '0') || 0;
      const borderRight = parseFloat(listViewStyle.borderRightWidth || '0') || 0;
      const contentWidth = listViewRect.width - paddingLeft - paddingRight - borderLeft - borderRight;

      const bugRect = bug.getBoundingClientRect();

      // Regression guard:
      // Previously, when WebFListView wrapped items, auto-width descendants could incorrectly
      // resolve against the outer widget constraints (viewport width) instead of the listview
      // content box (viewport minus horizontal padding), causing them to overflow.
      expect(bugRect.width).toBeLessThanOrEqual(contentWidth + 1);
      await snapshot();
    } finally {
      try {
        (document.getElementById('listview') as HTMLElement | null)?.remove();
      } catch (_) {}
      await resizeViewport(-1, -1);
    }
  });
});


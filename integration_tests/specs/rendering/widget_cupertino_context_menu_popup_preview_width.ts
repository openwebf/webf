describe('CupertinoContextMenu popup preview width', () => {
  it('lays out the preview using the popup constraints (not the original root constraints)', async () => {
    await resizeViewport(800, 600);

    try {
      document.body.style.margin = '0';
      document.body.style.padding = '0';
      (document.body.style as any).backgroundColor = '#ffffff';

      const root = createElement(
        'div',
        {
          id: 'root',
          style: {
            width: '640px',
            height: '360px',
            padding: '24px',
            boxSizing: 'border-box',
            border: '1px solid #e5e7eb',
            display: 'flex',
            alignItems: 'flex-start',
            justifyContent: 'flex-start',
          },
        },
        [],
      );

      const contextMenu = createElement('flutter-cupertino-context-menu', { id: 'menu' }, [
        createElement(
          'div',
          {
            id: 'bug',
            style: {
              backgroundColor: '#dbeafe',
              border: '2px solid #93c5fd',
              borderRadius: '12px',
              padding: '24px',
              boxSizing: 'border-box',
              fontFamily: 'system-ui, sans-serif',
              textAlign: 'center',
            },
          },
          [
            createElement('div', { style: { fontSize: '24px', marginBottom: '8px' } }, [createText('📄')]),
            createElement('div', { style: { fontSize: '16px', fontWeight: '700', color: '#1e3a8a' } }, [
              createText('Document.txt'),
            ]),
            createElement('div', { style: { fontSize: '12px', color: '#1d4ed8', marginTop: '6px' } }, [
              createText('Long-press for options'),
            ]),
          ],
        ),
      ]);

      // Ensure actions exist so the underlying Flutter CupertinoContextMenu is used.
      (contextMenu as any).setActions([
        { text: 'Open', event: 'open', default: true },
        { text: 'Delete', event: 'delete', destructive: true },
      ]);

      root.appendChild(contextMenu);
      document.body.appendChild(root);

      await waitForOnScreen(root);
      await waitForFrame();
      await nextFrames(2);

      const bug = document.getElementById('bug') as HTMLElement;
      expect(bug).not.toBeNull();

      const rect = bug.getBoundingClientRect();
      const x = rect.left + rect.width / 2;
      const y = rect.top + rect.height / 2;

      // Trigger the Flutter side CupertinoContextMenu open gesture.
      try {
        await simulatePointAdd(x, y, 1);
        await simulatePointDown(x, y, 1);
        await sleep(0.8);
      } finally {
        await simulatePointUp(x, y, 1);
        await simulatePointRemove(x, y, 1);
      }

      // Allow overlay animation to settle.
      await sleep(0.8);
      await nextFrames(8);

      // Use Flutter snapshot so the CupertinoContextMenu overlay is included.
      await snapshotFlutter();
    } finally {
      // Cleanup: try to dismiss the context menu overlay so it can't leak into
      // subsequent tests in the same runner process.
      // CupertinoContextMenu typically dismisses when tapping outside.
      try {
        await dismissFlutterOverlays();
      } catch (_) {}
      try {
        const root = document.getElementById('root');
        root?.remove();
      } catch (_) {}
      await resizeViewport(-1, -1);
    }
  });
});

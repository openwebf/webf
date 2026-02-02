describe('Portal Cupertino modal popup width', () => {
  it('does not clamp WidgetElement used width to the original 36px DOM containing block', async () => {
    await resizeViewport(370, 700);

    try {
      document.documentElement.style.margin = '0';
      document.body.style.margin = '0';
      document.body.style.padding = '0';
      (document.body.style as any).backgroundColor = '#ffffff';

      const wrapper = createElement(
        'div',
        {
          id: 'wrapper',
          style: {
            width: '36px',
            height: '36px',
            border: '1px solid #ef4444',
            boxSizing: 'border-box',
            overflow: 'hidden',
          },
        },
        [],
      );

      const popup = createElement(
        'flutter-cupertino-portal-modal-popup',
        { id: 'popup' },
        [
          createElement(
            'flutter-portal-popup-item',
            {
              id: 'item',
              style: {
                display: 'block',
                backgroundColor: '#dbeafe',
                border: '2px solid #93c5fd',
                borderRadius: '12px',
                padding: '16px',
                boxSizing: 'border-box',
                fontFamily: 'system-ui, sans-serif',
              },
            },
            [
              createElement('div', { style: { fontSize: '14px', fontWeight: '700', marginBottom: '8px' } }, [
                createText('Portal width probe'),
              ]),
              createElement('div', { style: { fontSize: '12px', color: '#1d4ed8' } }, [
                createText('Should expand to popup width, not 36px'),
              ]),
            ],
          ),
        ],
      );

      wrapper.appendChild(popup);
      document.body.appendChild(wrapper);

      await sleep(0.2);

      // Guard: fail fast when running against an old integration test binary
      // that does not include the Dart-side custom element registration.
      expect(typeof (popup as any).show).toBe('function');
      expect(typeof (popup as any).hide).toBe('function');

      (popup as any).show();

      // Wait for Cupertino modal animation + layout.
      await sleep(1.2);
      await nextFrames(4);

      const item = document.getElementById('item') as HTMLElement;
      expect(item).not.toBeNull();

      // Force layout.
      item.offsetHeight;
      await nextFrames(2);

      const rect = item.getBoundingClientRect();

      // Regression guard:
      // Previously this could become ~36 due to width:auto resolving against the
      // original DOM containing block instead of the popup viewport constraints.
      expect(rect.width).toBeGreaterThan(120);

      // Include Flutter overlay in snapshot for debugging.
      await snapshotFlutter();
    } finally {
      try {
        await dismissFlutterOverlays();
      } catch (_) {}
      try {
        const popup = document.getElementById('popup') as any;
        popup?.hide?.();
      } catch (_) {}
      try {
        document.getElementById('wrapper')?.remove();
      } catch (_) {}
      await resizeViewport(-1, -1);
    }
  });
});

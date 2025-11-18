describe('RenderWidget flex + modal popup inner width', () => {
  it('uses WebFWidgetElementChild constraints for inner HTML inside flex item modal popup', async () => {
    // Flex container similar to: <div class="flex"> <FlutterModalPopup>...</FlutterModalPopup> </div>
    const flex = document.createElement('div');
    flex.id = 'flex-root';
    flex.setAttribute(
      'style',
      [
        'display: flex',
        'flex-direction: row',
        'width: 300px',
        'height: 300px',
        'border: 1px solid #ccc',
      ].join(';'),
    );

    // Custom element backed by FlutterModalPopup (which uses WebFWidgetElementChild internally).
    const popup = createElement('flutter-modal-popup', {}, [
      createElement(
        'div',
        {
          id: 'bug',
          style: {
            backgroundColor: 'skyblue',
            border: '1px solid black',
          },
        },
        [createText('content')],
      ),
    ]);

    flex.appendChild(popup);
    document.body.appendChild(flex);

    await sleep(1);

    // Show the modal popup via the exposed sync method.
    (popup as any).show();

    await sleep(1);

    const bug = document.getElementById('bug');
    expect(bug).not.toBeNull();

    if (bug != null) {
      const rect = bug.getBoundingClientRect();

      // The inner HTML element should be sized by the WebFWidgetElementChild /
      // modal layout, not stretched to the full flex container width.
      // We just assert it is > 0 and <= flex width to catch regressions,
      // and rely on snapshot for precise visual/layout verification.
      expect(rect.width).toBeGreaterThan(0);
      expect(rect.width).toBeLessThanOrEqual(300);
    }

    await snapshot(bug);
  });
});

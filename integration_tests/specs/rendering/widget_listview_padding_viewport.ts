describe('RenderWidget WebFListView viewport height with padding', () => {
  it('keeps webf-listview border-box within viewport even with vertical padding', async () => {
    // Normalize body margins so viewport math is stable.
    document.documentElement.style.margin = '0';
    document.body.style.margin = '0';

    const listView = createElement(
      'webf-listview',
      {
        style: {
          width: '100%',
          padding: '24px 16px',
          borderBottom: '1px solid #ccc',
          boxSizing: 'border-box',
          backgroundColor: '#f5f5f5',
        },
      },
      [
        // Several very tall items to force large intrinsic content.
        ...Array.from({ length: 4 }).map((_, index) =>
          createElement(
            'div',
            {
              style: {
                width: '100%',
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center',
                marginTop: index === 0 ? '0' : '20px',
              },
            },
            [
              createElement(
                'div',
                {
                  style: {
                    height: '500px',
                    backgroundColor: index % 2 === 0 ? '#cce5ff' : '#e2f0cb',
                  },
                },
                [createText('AAA')],
              ),
            ],
          ),
        ),
        createElement('div', {}, [createText('End')]),
      ],
    );

    BODY.appendChild(listView);

    await waitForOnScreen(listView as any);
    await waitForFrame();

    const rect = (listView as any as HTMLElement).getBoundingClientRect();
    const viewportHeight = window.innerHeight || document.documentElement.clientHeight;

    // Ensure the host RenderWidget border-box (including padding and border)
    // does not exceed the visual viewport height. Previously, vertical padding
    // caused the border-box height to grow beyond the root viewport size.
    expect(rect.height).toBeLessThanOrEqual(viewportHeight + 1);

    // Snapshot for visual regression as well.
    await snapshot(listView);
  });
});


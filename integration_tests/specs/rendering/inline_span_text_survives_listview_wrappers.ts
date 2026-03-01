describe('Inline span text survives WebFListView wrappers', () => {
  afterEach(async () => {
    try {
      (document.getElementById('listview') as HTMLElement | null)?.remove();
    } catch (_) {}
    try {
      await resizeViewport(-1, -1);
    } catch (_) {}
  });

  it('does not collapse inline text to zero when wrapped by scroll/gesture render objects', async () => {
    await resizeViewport(375, 756);

    document.documentElement.style.margin = '0';
    document.body.style.margin = '0';
    document.body.style.padding = '0';

    const listview = createElement(
      'webf-listview',
      {
        id: 'listview',
        style: {
          width: '100%',
          height: '200px',
          padding: '20px',
          boxSizing: 'border-box',
          backgroundColor: '#ffffff',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              paddingBottom: '16px',
              boxSizing: 'border-box',
            },
          },
          [
            createElement(
              'div',
              {
                style: {
                  display: 'flex',
                  alignItems: 'center',
                  paddingTop: '8px',
                  paddingBottom: '8px',
                  boxSizing: 'border-box',
                },
              },
              [
                createElement(
                  'div',
                  {
                    style: {
                      width: '36px',
                      height: '36px',
                      flexShrink: '0',
                      display: 'inline-flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      borderRadius: '9999px',
                      backgroundColor: '#2563eb',
                      color: '#ffffff',
                      fontSize: '15px',
                      marginRight: '8px',
                      boxSizing: 'border-box',
                    },
                  },
                  [createText('JD')],
                ),
                createElement(
                  'div',
                  {
                    id: 'info',
                    style: {
                      height: '36px',
                      flex: '1 1 auto',
                      boxSizing: 'border-box',
                    },
                  },
                  [
                    createElement(
                      'span',
                      {
                        id: 'name',
                        style: {
                          display: 'inline',
                          fontSize: '16px',
                          lineHeight: '20px',
                          transform: 'translateY(-2px)',
                        },
                      },
                      [createText('JohnDoe123')],
                    ),
                    createElement(
                      'div',
                      {
                        id: 'meta',
                        style: {
                          border: '1px solid #e5e7eb',
                          color: '#6b7280',
                          fontSize: '12px',
                          lineHeight: '16px',
                          transform: 'translateY(-5px)',
                          boxSizing: 'border-box',
                        },
                      },
                      [createText('2024-01-15 | Bank Transfer')],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );

    BODY.appendChild(listview);

    await waitForOnScreen(listview as any);
    await waitForFrame();
    await nextFrames(2);

    const name = document.getElementById('name') as HTMLElement;
    const meta = document.getElementById('meta') as HTMLElement;

    expect(name).not.toBeNull();
    expect(meta).not.toBeNull();
    expect(name.textContent).toBe('JohnDoe123');

    // Regression guard:
    // Before the fix, InlineItemsBuilder failed to descend through wrapper render
    // objects (e.g. RenderLayoutBoxWrapper / gesture wrappers), producing an empty
    // IFC subtree and a zero-size inline span.
    const nameRect = name.getBoundingClientRect();
    expect(nameRect.width).toBeGreaterThan(1);
    expect(nameRect.height).toBeGreaterThan(1);

    // The following block should be laid out below the inline text, not at y=0.
    expect(meta.offsetTop).toBeGreaterThan(0);

    await snapshot();
  });
});


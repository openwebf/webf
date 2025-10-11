/*auto generated*/
describe('flex-auto-min-text-wrap', () => {
  it('flex item with block text should shrink and wrap (no overflow)', async () => {
    // Emulate a narrow viewport that would overflow if the flex item
    // refused to shrink below its (incorrect) max-content auto-min size.
    const viewport = createElement('div', {
      id: 'viewport',
      style: {
        width: '375px',
        height: '260px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        border: '1px solid #ddd',
        boxSizing: 'border-box',
        background: '#fafafa',
      },
    });

    const root = createElement(
      'div',
      {
        id: 'root',
        style: {
          // Matches the reported app’s CSS pattern
          maxWidth: '1280px',
          padding: '16px',
          backgroundColor: 'lightgreen',
          textAlign: 'center',
          boxSizing: 'border-box',
        },
      },
      [
        createElement('h1', {}, [createText('Vite + React')]),
        createElement('p', { class: 'read-the-docs' }, [
          createText('Click on the Vite and React lqweqweqwe ogos to learn more'),
        ]),
      ]
    );

    viewport.appendChild(root);
    BODY.appendChild(viewport);

    // Force layout
    document.body.offsetWidth;

    // Assert no horizontal overflow: scrollWidth must equal clientWidth
    expect(viewport.scrollWidth).toBe(viewport.clientWidth);
    // And the flex item should not exceed the viewport width
    expect(root.offsetWidth <= viewport.clientWidth).toBe(true);

    await snapshot();
  });
});


describe('CSS aspect-ratio property', () => {
  it('height fixed with aspect-ratio computes width', async () => {
    const el = createElementWithStyle(
      'div',
      {
        height: '100px',
        aspectRatio: '3 / 4',
        backgroundColor: '#9cf',
        color: '#123',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        border: '1px solid #246',
      },
      [createText('3:4')]
    );
    append(BODY, el);
    await snapshot();
  });

  it('width fixed with aspect-ratio computes height', async () => {
    const el = createElementWithStyle(
      'div',
      {
        width: '200px',
        aspectRatio: '2 / 1',
        backgroundColor: '#cfc',
        color: '#030',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        border: '1px solid #060',
      },
      [createText('2:1')]
    );
    append(BODY, el);
    await snapshot();
  });

  it('works inside flex container with fixed cross size', async () => {
    const item = createElementWithStyle(
      'div',
      {
        height: '100px',
        aspectRatio: '3 / 4',
        backgroundColor: '#f9c',
        color: '#402',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '8px',
        border: '1px solid #804',
      },
      [createText('3:4')]
    );

    const container = createElementWithStyle(
      'div',
      {
        display: 'flex',
        gap: '8px',
        backgroundColor: '#eee',
      },
      [item]
    );

    append(BODY, container);
    await snapshot();
  });
});


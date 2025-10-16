describe('Absolute layout with auto margins (issue #179)', () => {
  it('absolute child with top:0; bottom:0; right:0; margin:auto inside relative container', async () => {
    const container = createElement(
      'div',
      {
        className: 'container3',
        style: {
          width: '200px',
          height: '200px',
          background: 'rebeccapurple',
          position: 'relative',
        },
      }
    );

    const abs = createElement(
      'div',
      {
        style: {
          position: 'absolute',
          top: '0',
          bottom: '0',
          right: '0',
          margin: 'auto',
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          alignItems: 'center',
          background: 'aqua',
          padding: '8px',
        },
      },
      [createElement('span', {}, [createText('VVVV')])]
    );

    container.appendChild(abs);
    append(BODY, container);

    await snapshot(container);
  });
});


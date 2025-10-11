fdescribe('Text line-height with word-break: break-all (issue #107)', () => {
  it('applies 1.9em line-height to wrapped long text', async () => {
    const container = createElement(
      'div',
      {
        style: {
          margin: '64px 0 32px',
          textAlign: 'center',
          backgroundColor: '#ff2',
          height: '50px',
          width: '150px',
          lineHeight: '1.9em',
          whiteSpace: 'normal',
          wordBreak: 'break-all',
          fontSize: '16px',
        },
      },
      [
        createElement('span', {}, [createText('AAAAAAAA')]),
        createText('BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'),
      ]
    );

    append(BODY, container);
    await snapshot();
  });

  it('changing line-height impacts layout with break-all', async (done) => {
    const container = createElement(
      'div',
      {
        style: {
          textAlign: 'center',
          backgroundColor: '#ff2',
          height: '50px',
          width: '150px',
          lineHeight: '1.9em',
          whiteSpace: 'normal',
          wordBreak: 'break-all',
          fontSize: '16px',
        },
      },
      [
        createElement('span', {}, [createText('AAAAAAAA')]),
        createText('BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'),
      ]
    );

    append(BODY, container);
    await snapshot();

    requestAnimationFrame(async () => {
      container.style.lineHeight = '1.0em';
      requestAnimationFrame(async () => {
        await snapshot();
        done();
      });
    });
  });
});


describe('Text white-space in flex (issue #42)', () => {
  it('pre-line inside centered flex container should wrap and clip', async () => {
    const container = createElement(
      'div',
      {
        style: {
          background: 'blue',
          height: '300px',
          width: '300px',
          display: 'flex',
          flexDirection: 'column',
          'align-items': 'center',
          overflow: 'hidden',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'span',
          {
            style: {
              background: 'pink',
              overflow: 'hidden',
              'z-index': '0',
              'white-space': 'pre-line',
              height: '48px',
              'line-height': '24px',
              'font-size': '16px',
              color: 'rgba(15, 33, 40, 0.996)',
              'margin-left': '46px',
              'margin-right': '46px',
            },
          },
          [createText('获得1000粉丝，开启你在营地的星光进阶之旅！')]
        ),
      ]
    );

    append(BODY, container);
    await snapshot(container);
  });

  it('changing pre-line to pre should disable wrapping', async (done) => {
    const textSpan = createElement(
      'span',
      {
        style: {
          background: 'pink',
          overflow: 'hidden',
          'z-index': '0',
          'white-space': 'pre-line',
          height: '48px',
          'line-height': '24px',
          'font-size': '16px',
          color: 'rgba(15, 33, 40, 0.996)',
          'margin-left': '46px',
          'margin-right': '46px',
        },
      },
      [createText('获得1000粉丝，开启你在营地的星光进阶之旅！')]
    );

    const container = createElement(
      'div',
      {
        style: {
          background: 'blue',
          height: '300px',
          width: '300px',
          display: 'flex',
          flexDirection: 'column',
          'align-items': 'center',
          overflow: 'hidden',
          'box-sizing': 'border-box',
        },
      },
      [textSpan]
    );

    append(BODY, container);
    await snapshot(container);

    requestAnimationFrame(async () => {
      textSpan.style.whiteSpace = 'pre';
      requestAnimationFrame(async () => {
        await snapshot(container);
        done();
      });
    });
  });
});


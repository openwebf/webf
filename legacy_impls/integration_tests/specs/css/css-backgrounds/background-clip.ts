describe('Background-clip', () => {
  it('works with default value as border-box', async () => {
    const div = createElement(
      'div',
      {
        style: {},
      },
      [
        createElement('div', {
          style: {
            border: '5px solid rgba(0,0,0,0.3)',
            backgroundColor: '#f40',
            padding: '10px',
            backgroundRepeat: 'no-repeat',
            height: '50px',
            width: '100px',
          },
        }),
      ]
    );
    append(BODY, div);
    await snapshot();
  });

  it('works with border-box', async () => {
    const div = createElement(
      'div',
      {
        style: {},
      },
      [
        createElement('div', {
          style: {
            border: '5px solid rgba(0,0,0,0.3)',
            backgroundColor: '#f40',
            padding: '10px',
            backgroundRepeat: 'no-repeat',
            backgroundClip: 'border-box',
            height: '50px',
            width: '100px',
          },
        }),
      ]
    );
    append(BODY, div);
    await snapshot();
  });

  it('works with padding-box', async () => {
    const div = createElement(
      'div',
      {
        style: {},
      },
      [
        createElement('div', {
          style: {
            border: '5px solid rgba(0,0,0,0.3)',
            backgroundColor: '#f40',
            padding: '10px',
            backgroundRepeat: 'no-repeat',
            backgroundClip: 'padding-box',
            height: '50px',
            width: '100px',
          },
        }),
      ]
    );
    append(BODY, div);
    await snapshot();
  });

  it('works with content-box', async () => {
    const div = createElement(
      'div',
      {
        style: {},
      },
      [
        createElement('div', {
          style: {
            border: '5px solid rgba(0,0,0,0.3)',
            backgroundColor: '#f40',
            padding: '10px',
            backgroundRepeat: 'no-repeat',
            backgroundClip: 'content-box',
            height: '50px',
            width: '100px',
          },
        }),
      ]
    );
    append(BODY, div);
    await snapshot();
  });

  it('works with text 1', async () => {
    const p = createElement(
      'p',
      {
        style: {
          background: 'linear-gradient(60deg, red, yellow, red, yellow, red)',
          color: 'rgba(0, 0, 0, 0.5)',
          backgroundClip: 'text',
        },
      },
      [createText('1 The background is clipped to the foreground text.')]
    );
    append(BODY, p);
    await snapshot();
  });

  it('works with text 2', async (done) => {
    const p = createElement(
      'p',
      {
        style: {
          background: 'linear-gradient(60deg, red, yellow, red, yellow, red)',
          color: 'rgba(0, 0, 0, 0.5)',
          backgroundClip: '',
        },
      },
      [createText('2 The background is clipped to the foreground text.')]
    );
    append(BODY, p);
    await snapshot();
    requestAnimationFrame(async() => {
      p.style.backgroundClip = 'text';
      await snapshot();
      done();
    });
  });

  it('works with text 3', async (done) => {
    const p = createElement(
      'p',
      {
        style: {
          background: 'linear-gradient(60deg, red, yellow, red, yellow, red)',
          color: 'rgba(0, 0, 0, 0.5)',
          backgroundClip: 'text',
        },
      },
      [createText('3 The background is clipped to the foreground text.')]
    );
    append(BODY, p);
    await snapshot();
    requestAnimationFrame(async() => {
      p.style.backgroundClip = '';
      await snapshot();
      done();
    });
  });
});

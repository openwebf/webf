describe('Background-repeat advanced', () => {
  // Note: "space"/"round" are not yet enabled in base tests; keep skipped.

  xit('repeat space', async () => {
    const div = createElement('div', {
      style: {
        width: '220px',
        height: '140px',
        backgroundImage: 'url(assets/test-bl.png)',
        backgroundRepeat: 'space',
        backgroundColor: '#eee'
      }
    });
    append(BODY, div);
    await snapshot(div);
  });

  xit('repeat round', async () => {
    const div = createElement('div', {
      style: {
        width: '220px',
        height: '140px',
        backgroundImage: 'url(assets/test-bl.png)',
        backgroundRepeat: 'round',
        backgroundColor: '#eee'
      }
    });
    append(BODY, div);
    await snapshot(div);
  });

  xit('two-value pairs: round no-repeat', async () => {
    const div = createElement('div', {
      style: {
        width: '220px',
        height: '140px',
        backgroundImage: 'url(assets/test-bl.png)',
        backgroundRepeat: 'round no-repeat'
      }
    });
    append(BODY, div);
    await snapshot(div);
  });

  xit('two-value pairs: repeat space', async () => {
    const div = createElement('div', {
      style: {
        width: '220px',
        height: '140px',
        backgroundImage: 'url(assets/test-bl.png)',
        backgroundRepeat: 'repeat space'
      }
    });
    append(BODY, div);
    await snapshot(div);
  });
});


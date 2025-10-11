describe('Background-size with multiple layers', () => {
  // Multiple sizes mapped to multiple images; keep skipped until lists supported.
  xit('per-layer sizes with two images', async () => {
    const div = createElement('div', {
      style: {
        width: '240px',
        height: '160px',
        backgroundImage: 'url(assets/100x100-green.png), url(assets/cat.png)',
        backgroundRepeat: 'no-repeat, no-repeat',
        backgroundPosition: 'left top, right bottom',
        backgroundSize: 'contain, 60px 40px',
        backgroundColor: '#ddd'
      }
    });
    append(BODY, div);
    await snapshot(div);
  });
});


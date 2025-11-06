describe('Background multiple images with positions and sizes', () => {
  it('two urls with per-layer position and size', async () => {
    const url = 'assets/cat.png';
    const div = createElement('div', {
      style: {
        width: '220px',
        height: '120px',
        backgroundColor: '#fef3c7',
        backgroundImage: `url(${url}), url(${url})`,
        backgroundRepeat: 'no-repeat, no-repeat',
        backgroundPosition: 'left 10px top 10px, right 10px bottom 10px',
        backgroundSize: '50px 50px, 70px 70px'
      }
    });
    append(BODY, div);
    await snapshot(2);
  });
});


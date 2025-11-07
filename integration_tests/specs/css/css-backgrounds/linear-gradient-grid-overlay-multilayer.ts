describe('linear-gradient crossed grid overlay per-layer normalization', () => {
  it('two gradient layers 25px tiles in both axes', async () => {
    const div = createElement('div', {
      style: {
        width: '220px',
        height: '120px',
        backgroundColor: '#ffffff',
        backgroundImage:
          'linear-gradient(#0000 24px, rgba(0,0,0,0.15) 25px), ' +
          'linear-gradient(90deg, #0000 24px, rgba(0,0,0,0.15) 25px)',
        backgroundRepeat: 'repeat, repeat',
        backgroundPosition: 'top left, top left',
        backgroundSize: '25px 25px, 25px 25px',
        border: '1px dashed #bdbdbd'
      }
    });
    append(BODY, div);
    await snapshot(div);
  });
});


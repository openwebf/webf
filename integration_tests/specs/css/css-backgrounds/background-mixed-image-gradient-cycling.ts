describe('Mixed url + gradient layers with list cycling', () => {
  it('gradients on top, image under; size/repeat cycle across layers', async () => {
    // Order: gradients first (topmost), image last (underneath), so gradients are visible
    // regardless of image opacity.
    // Single background-size token is applied to all layers (list-cycling).
    // background-repeat has two tokens and cycles across 3 layers: no-repeat, repeat, no-repeat → image gets repeat.
    const div = createElement('div', {
      style: {
        width: '300px',
        height: '160px',
        backgroundImage:
          'linear-gradient(to bottom, green, pink), ' +
          'linear-gradient(to bottom left, red, yellow, blue), ' +
          'url(assets/100x100-green.png)',
        backgroundSize: '50px auto', // cycles → 50px for all 3 layers
        backgroundRepeat: 'no-repeat, repeat', // cycles → gradA:no-repeat, gradB:repeat, img: no-repeat→repeat via cycling
        backgroundColor: '#ffffff',
        border: '1px solid #000'
      }
    });
    append(BODY, div);
    await snapshot(div);
  });
});


describe('Mixed url + gradient layering (url topmost)', () => {
  it('url first; gradients underneath; size/repeat cycles', async () => {
    // Order: image first (topmost), then two gradients underneath.
    // background-size has a single token → applies to all layers via list cycling.
    // background-repeat has two tokens → cycles across 3 layers (url: repeat, gradA: no-repeat, gradB: repeat).
    const div = createElement('div', {
      style: {
        width: '300px',
        height: '100px',
        backgroundImage:
          'url(assets/bg_flower.gif), ' +
          'linear-gradient(to bottom, green, pink), ' +
          'linear-gradient(to bottom left, red, yellow, blue)',
        backgroundSize: '50px auto',
        backgroundRepeat: 'repeat, no-repeat',
        backgroundColor: '#ffffff',
        border: '1px dashed #bdbdbd'
      }
    });
    append(BODY, div);
    await snapshot(div);
  });
});


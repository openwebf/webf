describe('CSS gradients tiling per-tile with list-cycling', () => {
  it('two gradient layers: size list cycles; repeat restarts per tile', async () => {
    // Intent: verify that when background-size provides a single value, it
    // cycles across layers; and when a gradient layer repeats, the shader
    // aligns to each tile (i.e., restarts at tile origin), matching browsers.
    // Setup: two gradients, single background-size token, mixed repeat list.
    const div = createElement('div', {
      style: {
        width: '300px',
        height: '160px',
        // Top layer: vertical stripe, no-repeat (only first 50px strip)
        // Bottom layer: diagonal gradient, repeat (fills remaining tiles)
        backgroundImage:
          'linear-gradient(to bottom, rgba(0,128,0,1), rgba(255,192,203,1)),' +
          ' linear-gradient(to bottom left, red, yellow, blue)',
        backgroundSize: '50px auto', // cycles → 50px for both layers
        backgroundRepeat: 'no-repeat, repeat', // top:no-repeat, bottom:repeat
        backgroundColor: '#ffffff',
        border: '1px solid #000'
      }
    });
    append(BODY, div);
    await snapshot(div);
  });
});


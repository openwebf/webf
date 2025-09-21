describe('Background multiple layers', () => {
  // Multi-layer shorthand with url + gradient, separate per-layer lists.
  // Marked skipped until engine fully supports layered painting and lists.
  xit('two layers: url over gradient with per-layer position/size/repeat', async () => {
    const div = createElement('div', {
      style: {
        width: '240px',
        height: '160px',
        background:
          [
            // top layer: image, no-repeat, positioned
            "url(assets/cat.png) no-repeat 20px 30px / 80px 60px padding-box content-box",
            // bottom layer: gradient, repeats
            'linear-gradient(45deg, red, blue) repeat 0 0 / 40px 40px border-box border-box'
          ].join(', '),
        backgroundColor: 'yellow'
      }
    });
    append(BODY, div);
    await snapshot(div);
  });

  // Validate painting order: the first specified layer paints on top.
  xit('painting order: first listed layer is on top of later layers and color', async () => {
    const div = createElement('div', {
      style: {
        width: '200px',
        height: '120px',
        background:
          [
            'linear-gradient(to right, rgba(0,0,0,0.2), rgba(0,0,0,0.2)) no-repeat 0 0 / cover',
            'url(assets/100x100-green.png) no-repeat center / 80px 80px'
          ].join(', '),
        backgroundColor: 'red'
      }
    });
    append(BODY, div);
    await snapshot(div);
  });

  // Per-layer origin/clip lists alignment.
  xit('per-layer origin/clip lists alignment', async () => {
    const div = createElement('div', {
      style: {
        width: '220px',
        height: '140px',
        border: '10px solid rgba(0,0,0,0.3)',
        padding: '20px',
        backgroundImage: 'url(assets/cat.png), linear-gradient(90deg, orange, purple)',
        backgroundRepeat: 'no-repeat, repeat',
        backgroundSize: '80px 60px, 20px 20px',
        backgroundPosition: 'left 10px top 10px, 0 0',
        backgroundOrigin: 'content-box, border-box',
        backgroundClip: 'padding-box, border-box',
        backgroundColor: 'white'
      }
    });
    append(BODY, div);
    await snapshot(div);
  });
});


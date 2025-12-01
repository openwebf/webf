fdescribe('Canvas pattern styles', () => {
  it('fillStyle should round-trip a CanvasPattern created from a canvas', async () => {
    const canvas = document.createElement('canvas');
    canvas.width = 200;
    canvas.height = 200;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    if (!ctx) {
      throw new Error('canvas context is null');
    }

    const patternCanvas = document.createElement('canvas');
    patternCanvas.width = 50;
    patternCanvas.height = 50;
    const patternCtx = patternCanvas.getContext('2d');
    if (!patternCtx) {
      throw new Error('pattern canvas context is null');
    }

    // Draw something simple in the pattern source.
    patternCtx.fillStyle = '#fec';
    patternCtx.fillRect(0, 0, 50, 50);

    const pattern = ctx.createPattern(patternCanvas, 'repeat');
    expect(pattern).toBeDefined();

    ctx.fillStyle = pattern!;
    expect(ctx.fillStyle).toBe(pattern);

    // Sanity draw to ensure it can be used without throwing.
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    await snapshot(canvas);
  });

  it('strokeStyle should accept and return a CanvasPattern created from a canvas', async () => {
    const canvas = document.createElement('canvas');
    canvas.width = 200;
    canvas.height = 200;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    if (!ctx) {
      throw new Error('canvas context is null');
    }

    const patternCanvas = document.createElement('canvas');
    patternCanvas.width = 50;
    patternCanvas.height = 50;
    const patternCtx = patternCanvas.getContext('2d');
    if (!patternCtx) {
      throw new Error('pattern canvas context is null');
    }

    patternCtx.fillStyle = '#fec';
    patternCtx.beginPath();
    patternCtx.arc(25, 25, 20, 0, Math.PI * 2);
    patternCtx.fill();

    const pattern = ctx.createPattern(patternCanvas, 'repeat');
    expect(pattern).toBeDefined();

    ctx.strokeStyle = pattern!;
    expect(ctx.strokeStyle).toBe(pattern);

    // Use stroke APIs to ensure no runtime errors with pattern strokeStyle.
    ctx.lineWidth = 10;
    ctx.beginPath();
    ctx.rect(20, 20, 160, 160);
    ctx.stroke();
    await snapshot(canvas);
  });

  it('fillStyle should round-trip a CanvasPattern created from an image', async (done) => {
    const canvas = document.createElement('canvas');
    canvas.width = 200;
    canvas.height = 200;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    if (!ctx) {
      throw new Error('canvas context is null');
    }

    const img = new Image();
    img.src = 'assets/cat.png';
    img.onload = async () => {
      const pattern = ctx.createPattern(img, 'repeat');
      expect(pattern).toBeDefined();

      ctx.fillStyle = pattern!;
      expect(ctx.fillStyle).toBe(pattern);

      ctx.fillRect(0, 0, canvas.width, canvas.height);
      await snapshot(canvas);
      done();
    };
  });
});


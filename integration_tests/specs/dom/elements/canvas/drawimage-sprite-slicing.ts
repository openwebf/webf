describe('canvas drawImage sprite slicing (issue #37)', () => {
  fit('draws 1/47 slice when using img.width/endNum', async (done) => {
    const stripes = 47;
    const stripeWidth = 10;
    const height = 40;

    // Build a sprite-like source image with 47 vertical stripes.
    const srcCanvas = document.createElement('canvas');
    srcCanvas.width = stripes * stripeWidth;
    srcCanvas.height = height;
    const sctx = srcCanvas.getContext('2d')!;

    for (let i = 0; i < stripes; i++) {
      // Make the first stripe solid red to verify exact 1/47 crop.
      // Alternate colors for the remaining stripes to make errors visible.
      sctx.fillStyle = i === 0 ? '#ff0000' : (i % 2 === 0 ? '#00ff00' : '#0000ff');
      sctx.fillRect(i * stripeWidth, 0, stripeWidth, height);
    }

    const img = new Image();
    img.onload = async () => {
      // Target canvas draws only the first frame (1/47 of width).
      const canvas = document.createElement('canvas');
      canvas.width = stripeWidth;
      canvas.height = height;
      const ctx = canvas.getContext('2d')!;

      const endNum = stripes;
      const sWidth = img.width / endNum;
      const sHeight = img.height;

      // Use top-left slice of the sprite sheet.
      ctx.drawImage(img, 0, 0, sWidth, sHeight, 0, 0, canvas.width, canvas.height);

      document.body.appendChild(canvas);
      await snapshot();
      done();
    };

    img.src = 'assets/black96x96.png';
  });
});


fdescribe('canvas ImageData APIs', () => {
  it('putImageData draws solid red block', async () => {
    const canvas = document.createElement('canvas');
    canvas.width = 20;
    canvas.height = 20;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d') as CanvasRenderingContext2D;

    // Create a 10x10 red ImageData using the bridge-backed implementation.
    const img = ctx.createImageData(10, 10) as any;
    const data: Uint8ClampedArray = img.data;

    for (let y = 0; y < 10; y++) {
      for (let x = 0; x < 10; x++) {
        const i = (y * 10 + x) * 4;
        data[i + 0] = 255; // R
        data[i + 1] = 0;   // G
        data[i + 2] = 0;   // B
        data[i + 3] = 255; // A
      }
    }

    // Draw at (5, 5) so we have padding around the block.
    ctx.putImageData(img, 5, 5);

    await snapshot();

    document.body.removeChild(canvas);
  });
});


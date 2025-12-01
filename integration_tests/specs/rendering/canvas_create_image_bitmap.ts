describe('canvas createImageBitmap and drawImage', () => {
  it('can draw an ImageBitmap created from an Image', async () => {
    const img = new Image();
    img.src = 'assets/cat.png';

    await new Promise<void>((resolve, reject) => {
      img.onload = () => resolve();
      img.onerror = () => reject(new Error('image load error'));
    });

    const bitmap = await createImageBitmap(img);

    const canvas = document.createElement('canvas') as HTMLCanvasElement;
    canvas.width = 100;
    canvas.height = 100;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d') as CanvasRenderingContext2D;
    ctx.drawImage(bitmap, 0, 0);

    // We can't easily read pixels here, but reaching this point without
    // throwing means createImageBitmap + drawImage(imageBitmap, ..) is wired.
    expect(bitmap.width).toBeDefined();
    expect(bitmap.height).toBeDefined();

    // Cropped ImageBitmap should report the crop rect size.
    const cropped = await createImageBitmap(img, 10, 20, 30, 40);
    expect(cropped.width).toBe(30);
    expect(cropped.height).toBe(40);

    await snapshot();
  });
});

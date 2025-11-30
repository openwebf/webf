describe('Canvas globalAlpha and globalCompositeOperation', () => {
  it('should apply globalAlpha to subsequent drawing operations', async (done) => {
    const canvas = document.createElement('canvas');
    canvas.width = 200;
    canvas.height = 200;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d')!;

    // Solid red background.
    ctx.fillStyle = 'red';
    ctx.fillRect(0, 0, 200, 200);

    // Draw a semi-transparent blue square on top.
    ctx.globalAlpha = 0.5;
    ctx.fillStyle = 'blue';
    ctx.fillRect(50, 50, 100, 100);

    await snapshot(canvas);
    done();
  });

  it('should composite with source-over and destination-over correctly', async (done) => {
    const canvas = document.createElement('canvas');
    canvas.width = 240;
    canvas.height = 120;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d')!;

    // Left half: source-over (default).
    ctx.save();
    ctx.fillStyle = 'white';
    ctx.fillRect(0, 0, 240, 120);

    // Base: red rectangle.
    ctx.fillStyle = 'red';
    ctx.fillRect(10, 20, 80, 80);

    // Source-over green on top of red.
    ctx.globalAlpha = 0.7;
    ctx.globalCompositeOperation = 'source-over';
    ctx.fillStyle = 'green';
    ctx.fillRect(30, 40, 80, 80);
    ctx.restore();

    // Right half: destination-over.
    ctx.save();
    ctx.translate(120, 0);

    // Base: green rectangle (drawn first).
    ctx.fillStyle = 'green';
    ctx.fillRect(30, 40, 80, 80);

    // Destination-over red behind green.
    ctx.globalAlpha = 0.7;
    ctx.globalCompositeOperation = 'destination-over';
    ctx.fillStyle = 'red';
    ctx.fillRect(10, 20, 80, 80);

    ctx.restore();

    await snapshot(canvas);
    done();
  });

  it('should support multiply compositing', async (done) => {
    const canvas = document.createElement('canvas');
    canvas.width = 200;
    canvas.height = 200;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d')!;

    // Base: light gray.
    ctx.fillStyle = '#cccccc';
    ctx.fillRect(0, 0, 200, 200);

    // Multiply a blue square over gray.
    ctx.globalAlpha = 1.0;
    ctx.globalCompositeOperation = 'multiply';
    ctx.fillStyle = 'blue';
    ctx.fillRect(40, 40, 120, 120);

    await snapshot(canvas);
    done();
  });
});

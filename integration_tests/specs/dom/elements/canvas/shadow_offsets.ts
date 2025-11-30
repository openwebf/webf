describe('Canvas shadow offsets', () => {
  it('should render shadowOffsetX and shadowOffsetY for fillRect', async (done) => {
    const canvas = document.createElement('canvas');
    canvas.width = 200;
    canvas.height = 200;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d')!;

    // Base: light background so shadows are visible.
    ctx.fillStyle = '#ffffff';
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    ctx.fillStyle = 'red';
    ctx.shadowColor = 'rgba(0, 0, 0, 0.5)';
    ctx.shadowBlur = 4;
    ctx.shadowOffsetX = 10;
    ctx.shadowOffsetY = 10;
    ctx.fillRect(40, 40, 80, 80);

    await snapshot(canvas);
    done();
  });

  it('should render shadowOffsetX/Y for strokeRect', async (done) => {
    const canvas = document.createElement('canvas');
    canvas.width = 200;
    canvas.height = 200;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d')!;

    ctx.fillStyle = '#ffffff';
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    ctx.strokeStyle = 'blue';
    ctx.lineWidth = 4;
    ctx.shadowColor = 'rgba(0, 0, 0, 0.5)';
    ctx.shadowBlur = 4;
    ctx.shadowOffsetX = -8;
    ctx.shadowOffsetY = 6;
    ctx.strokeRect(60, 60, 60, 60);

    await snapshot(canvas);
    done();
  });
});


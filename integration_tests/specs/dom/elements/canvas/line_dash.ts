describe('Canvas line dash helpers', () => {
  it('should apply setLineDash and getLineDash', async (done) => {
    const canvas = document.createElement('canvas');
    canvas.width = 320;
    canvas.height = 80;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d')!;

    ctx.strokeStyle = 'black';
    ctx.lineWidth = 4;

    ctx.setLineDash([10, 5]);
    const pattern = ctx.getLineDash();
    expect(pattern).toEqual([10, 5]);

    ctx.beginPath();
    ctx.moveTo(10, 20);
    ctx.lineTo(310, 20);
    ctx.stroke();

    await snapshot(canvas);
    done();
  });

  it('should respect lineDashOffset', async (done) => {
    const canvas = document.createElement('canvas');
    canvas.width = 320;
    canvas.height = 120;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d')!;
    ctx.strokeStyle = 'black';
    ctx.lineWidth = 4;
    ctx.setLineDash([12, 6]);

    // First line: zero offset.
    ctx.lineDashOffset = 0;
    ctx.beginPath();
    ctx.moveTo(10, 30);
    ctx.lineTo(310, 30);
    ctx.stroke();

    // Second line: shifted pattern.
    ctx.lineDashOffset = 6;
    ctx.beginPath();
    ctx.moveTo(10, 80);
    ctx.lineTo(310, 80);
    ctx.stroke();

    await snapshot(canvas);
    done();
  });

  it('should reset line dash pattern on reset()', async (done) => {
    const canvas = document.createElement('canvas');
    canvas.width = 320;
    canvas.height = 140;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d')!;
    ctx.strokeStyle = 'black';
    ctx.lineWidth = 4;

    // Dashed line before reset.
    ctx.setLineDash([8, 4]);
    ctx.beginPath();
    ctx.moveTo(10, 30);
    ctx.lineTo(310, 30);
    ctx.stroke();

    // Reset should clear dash pattern.
    ctx.reset();
    expect(ctx.getLineDash()).toEqual([]);

    // Solid line after reset.
    ctx.beginPath();
    ctx.moveTo(10, 100);
    ctx.lineTo(310, 100);
    ctx.stroke();

    await snapshot(canvas);
    done();
  });
});


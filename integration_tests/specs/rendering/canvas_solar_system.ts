describe('canvas solar system shadow and scale', () => {
  it('matches browser rendering for sun/earth/moon with shadows', async () => {
    const canvas = document.createElement('canvas');
    canvas.width = 300;
    canvas.height = 200;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d')!;
    const dpr = window.devicePixelRatio || 1;

    // Hi-DPI setup (matches demo code)
    const rect = canvas.getBoundingClientRect();
    canvas.width = rect.width * dpr || 300 * dpr;
    canvas.height = rect.height * dpr || 200 * dpr;
    ctx.scale(dpr, dpr);

    function drawFrame(time: Date) {
      ctx.clearRect(0, 0, 300, 200);

      ctx.save();
      ctx.translate(80, 100);

      // Sun (no shadow on fill, shadow on stroke)
      ctx.beginPath();
      ctx.arc(0, 0, 20, 0, Math.PI * 2);
      ctx.fillStyle = 'yellow';
      ctx.fill();
      ctx.shadowBlur = 50;
      ctx.shadowColor = 'orange';
      ctx.stroke();

      // Earth orbit
      ctx.strokeStyle = 'rgba(0, 153, 255, 0.4)';
      ctx.beginPath();
      ctx.arc(0, 0, 70, 0, Math.PI * 2);
      ctx.stroke();

      // Earth
      ctx.rotate(
        ((2 * Math.PI) / 60) * time.getSeconds() +
          ((2 * Math.PI) / 60000) * time.getMilliseconds()
      );
      ctx.translate(70, 0);
      ctx.beginPath();
      ctx.arc(0, 0, 10, 0, Math.PI * 2);
      ctx.fillStyle = 'blue';
      ctx.fill();

      // Moon orbit
      ctx.strokeStyle = 'rgba(200, 200, 200, 0.4)';
      ctx.beginPath();
      ctx.arc(0, 0, 20, 0, Math.PI * 2);
      ctx.stroke();

      // Moon
      ctx.rotate(
        ((2 * Math.PI) / 6) * time.getSeconds() +
          ((2 * Math.PI) / 6000) * time.getMilliseconds()
      );
      ctx.translate(0, 20);
      ctx.beginPath();
      ctx.arc(0, 0, 4, 0, Math.PI * 2);
      ctx.fillStyle = 'gray';
      ctx.fill();

      ctx.restore();
    }

    // Use a fixed time so snapshot is deterministic.
    const fixedTime = new Date(0);
    drawFrame(fixedTime);

    await snapshot();
  });
});


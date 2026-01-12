describe('CSS Grid edge cases: minmax(0, 1fr)', () => {
  it('does not overflow with percent-sized replaced content', async () => {
    document.body.style.margin = '0';

    const svgRed =
      "data:image/svg+xml;utf8,%3Csvg%20xmlns%3D'http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg'%20width%3D'300'%20height%3D'224'%20viewBox%3D'0%200%20300%20224'%3E%3Crect%20width%3D'300'%20height%3D'224'%20fill%3D'red'%2F%3E%3C%2Fsvg%3E";
    const svgBlue =
      "data:image/svg+xml;utf8,%3Csvg%20xmlns%3D'http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg'%20width%3D'300'%20height%3D'224'%20viewBox%3D'0%200%20300%20224'%3E%3Crect%20width%3D'300'%20height%3D'224'%20fill%3D'blue'%2F%3E%3C%2Fsvg%3E";

    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.width = '200px';
    grid.style.gridTemplateColumns = 'repeat(2, minmax(0, 1fr))';
    grid.style.columnGap = '16px';
    grid.style.rowGap = '0';
    grid.style.background = '#fff';

    const makeCell = () => {
      const cell = document.createElement('div');
      cell.style.overflow = 'hidden';

      const viewport = document.createElement('div');
      viewport.style.height = '150px';
      viewport.style.background = '#000';

      const img = document.createElement('img');
      img.style.width = '100%';
      img.style.height = '150px';
      img.style.objectFit = 'contain';

      viewport.appendChild(img);
      cell.appendChild(viewport);

      return { cell, img };
    };

    const a = makeCell();
    const b = makeCell();

    await new Promise<void>((resolve, reject) => {
      let loaded = 0;
      const timeout = setTimeout(() => reject(new Error('image load timeout')), 8000);

      const onLoad = () => {
        loaded++;
        if (loaded >= 2) {
          clearTimeout(timeout);
          resolve();
        }
      };

      a.img.onload = onLoad;
      b.img.onload = onLoad;
      a.img.onerror = () => reject(new Error('red svg image load error'));
      b.img.onerror = () => reject(new Error('blue svg image load error'));

      grid.appendChild(a.cell);
      grid.appendChild(b.cell);
      document.body.appendChild(grid);

      a.img.src = svgRed;
      b.img.src = svgBlue;

      // If the engine marks the image as already complete, don't wait for events.
      if ((a.img as any).complete && (b.img as any).complete) {
        clearTimeout(timeout);
        resolve();
      }
    });

    await nextFrames(2);

    const gridRect = grid.getBoundingClientRect();
    const bRect = b.cell.getBoundingClientRect();
    const relativeBLeft = bRect.left - gridRect.left;

    // Each column should be (200 - 16) / 2 = 92px, so B starts at 92 + 16 = 108px.
    expect(Math.round(gridRect.width)).toBe(200);
    expect(Math.round(relativeBLeft)).toBe(108);

    // Regression: grid should not overflow horizontally.
    expect(grid.scrollWidth).toBeLessThanOrEqual(grid.clientWidth + 1);

    await snapshot();

    grid.remove();
  });
});

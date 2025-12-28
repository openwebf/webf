describe('CSS Grid writing modes', () => {
  xit('handles direction: rtl on grid container', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.direction = 'rtl';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f5f5f5';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${i * 45}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // In RTL, first item should be on the right
    const gridRight = grid.getBoundingClientRect().right;
    expect(items[0].getBoundingClientRect().right).toBe(gridRight);

    grid.remove();
  });

  xit('handles writing-mode: vertical-lr', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.writingMode = 'vertical-lr';
    grid.style.gridTemplateColumns = 'repeat(2, 80px)';
    grid.style.gridTemplateRows = 'repeat(3, 60px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e3f2fd';
    grid.style.height = '250px';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${200 + i * 25}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.writingMode = 'horizontal-tb'; // Reset for content
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Vertical writing mode affects grid flow
    expect(items.length).toBe(6);

    grid.remove();
  });

  xit('handles writing-mode: vertical-rl', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.writingMode = 'vertical-rl';
    grid.style.gridTemplateColumns = 'repeat(2, 80px)';
    grid.style.gridTemplateRows = 'repeat(3, 60px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#f3e5f5';
    grid.style.height = '250px';

    for (let i = 0; i < 6; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${280 + i * 15}, 70%, 60%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.writingMode = 'horizontal-tb';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(6);

    grid.remove();
  });

  xit('combines direction: rtl with vertical writing mode', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.writingMode = 'vertical-lr';
    grid.style.direction = 'rtl';
    grid.style.gridTemplateColumns = 'repeat(2, 80px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#fff3e0';
    grid.style.height = '200px';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `${i + 1}`;
      item.style.backgroundColor = `hsl(${40 + i * 20}, 70%, 65%)`;
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      item.style.writingMode = 'horizontal-tb';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(4);

    grid.remove();
  });

  xit('applies text-align in RTL grid items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.direction = 'rtl';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = 'repeat(2, 80px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e8f5e9';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `Item ${i + 1} with longer text`;
      item.style.backgroundColor = `hsl(${120 + i * 15}, 60%, 55%)`;
      item.style.color = 'white';
      item.style.textAlign = i % 2 === 0 ? 'start' : 'end';
      item.style.padding = '10px';
      item.style.fontSize = '12px';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(4);

    grid.remove();
  });

  it('handles unicode-bidi with grid layout', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = 'repeat(2, 70px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#ede7f6';

    for (let i = 0; i < 4; i++) {
      const item = document.createElement('div');
      item.textContent = `Grid ${i + 1}`;
      item.style.backgroundColor = `hsl(${260 + i * 20}, 70%, 65%)`;
      item.style.unicodeBidi = i % 2 === 0 ? 'normal' : 'embed';
      item.style.display = 'flex';
      item.style.alignItems = 'center';
      item.style.justifyContent = 'center';
      item.style.color = 'white';
      grid.appendChild(item);
    }

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(4);

    grid.remove();
  });
});

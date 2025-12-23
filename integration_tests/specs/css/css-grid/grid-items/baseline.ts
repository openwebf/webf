describe('CSS Grid baseline alignment', () => {
  it('aligns items to first baseline', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.alignItems = 'baseline';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    // Items with different font sizes
    const item1 = document.createElement('div');
    item1.textContent = 'Small';
    item1.style.fontSize = '12px';
    item1.style.backgroundColor = '#42A5F5';
    item1.style.padding = '5px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Medium';
    item2.style.fontSize = '16px';
    item2.style.backgroundColor = '#66BB6A';
    item2.style.padding = '5px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = 'Large';
    item3.style.fontSize = '24px';
    item3.style.backgroundColor = '#FFA726';
    item3.style.padding = '5px';
    item3.style.color = 'white';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Items should align their text baselines
    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(3);
    const r1 = items[0].getBoundingClientRect();
    const r2 = items[1].getBoundingClientRect();
    const r3 = items[2].getBoundingClientRect();
    // The largest text should sit highest; smaller text boxes are shifted down to match the baseline.
    expect(r1.top).toBeGreaterThan(r3.top);
    expect(r2.top).toBeGreaterThan(r3.top);

    grid.remove();
  });

  it('aligns items to last baseline', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '120px';
    grid.style.alignItems = 'last baseline';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    // Items with different heights
    const item1 = document.createElement('div');
    item1.textContent = 'Short content';
    item1.style.fontSize = '14px';
    item1.style.backgroundColor = '#2196F3';
    item1.style.padding = '5px';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Medium height content here';
    item2.style.fontSize = '14px';
    item2.style.backgroundColor = '#1E88E5';
    item2.style.padding = '5px';
    item2.style.color = 'white';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = 'Tall content with more text';
    item3.style.fontSize = '14px';
    item3.style.backgroundColor = '#1976D2';
    item3.style.padding = '5px';
    item3.style.color = 'white';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(3);
    const gridRect = grid.getBoundingClientRect();
    // With last-baseline alignment, items should sit near the end edge (bottom) of the row.
    items.forEach((it) => {
      expect(it.getBoundingClientRect().bottom).toBeCloseTo(gridRect.bottom, 0);
    });

    grid.remove();
  });

  xit('handles baseline with different font families', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.alignItems = 'baseline';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    const item1 = document.createElement('div');
    item1.textContent = 'Serif';
    item1.style.fontFamily = 'serif';
    item1.style.fontSize = '18px';
    item1.style.backgroundColor = '#BA68C8';
    item1.style.color = 'white';
    item1.style.padding = '5px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Sans';
    item2.style.fontFamily = 'sans-serif';
    item2.style.fontSize = '18px';
    item2.style.backgroundColor = '#AB47BC';
    item2.style.color = 'white';
    item2.style.padding = '5px';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = 'Mono';
    item3.style.fontFamily = 'monospace';
    item3.style.fontSize = '18px';
    item3.style.backgroundColor = '#9C27B0';
    item3.style.color = 'white';
    item3.style.padding = '5px';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(3);

    grid.remove();
  });

  it('aligns baseline with padding and borders', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.alignItems = 'baseline';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    const item1 = document.createElement('div');
    item1.textContent = 'Pad 5';
    item1.style.padding = '5px';
    item1.style.fontSize = '16px';
    item1.style.backgroundColor = '#FFB74D';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Pad 15';
    item2.style.padding = '15px';
    item2.style.fontSize = '16px';
    item2.style.backgroundColor = '#FFA726';
    item2.style.color = 'white';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = 'Border';
    item3.style.padding = '5px';
    item3.style.border = '3px solid #E65100';
    item3.style.fontSize = '16px';
    item3.style.backgroundColor = '#FF9800';
    item3.style.color = 'white';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(3);

    grid.remove();
  });

  it('handles baseline in column direction', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '150px';
    grid.style.gridTemplateRows = 'repeat(3, 80px)';
    grid.style.justifyItems = 'baseline';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    const item1 = document.createElement('div');
    item1.textContent = 'A';
    item1.style.fontSize = '16px';
    item1.style.backgroundColor = '#66BB6A';
    item1.style.color = 'white';
    item1.style.padding = '5px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'BB';
    item2.style.fontSize = '20px';
    item2.style.backgroundColor = '#4CAF50';
    item2.style.color = 'white';
    item2.style.padding = '5px';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = 'CCC';
    item3.style.fontSize = '24px';
    item3.style.backgroundColor = '#43A047';
    item3.style.color = 'white';
    item3.style.padding = '5px';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(3);
    const r1 = items[0].getBoundingClientRect();
    const r2 = items[1].getBoundingClientRect();
    const r3 = items[2].getBoundingClientRect();
    // Baseline is a non-stretch alignment; auto-sized items should shrink to fit content.
    expect(r1.width).toBeLessThan(150);
    expect(r2.width).toBeLessThan(150);
    expect(r3.width).toBeLessThan(150);
    expect(r3.width).toBeGreaterThan(r1.width);

    grid.remove();
  });

  it('handles self-alignment override for baseline', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.alignItems = 'start';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#ede7f6';

    const item1 = document.createElement('div');
    item1.textContent = 'Start';
    item1.style.fontSize = '14px';
    item1.style.backgroundColor = '#9575CD';
    item1.style.color = 'white';
    item1.style.padding = '5px';
    grid.appendChild(item1);

    // This item overrides to use baseline
    const item2 = document.createElement('div');
    item2.textContent = 'Baseline';
    item2.style.alignSelf = 'baseline';
    item2.style.fontSize = '20px';
    item2.style.backgroundColor = '#7E57C2';
    item2.style.color = 'white';
    item2.style.padding = '5px';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = 'Start';
    item3.style.fontSize = '14px';
    item3.style.backgroundColor = '#673AB7';
    item3.style.color = 'white';
    item3.style.padding = '5px';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(3);

    grid.remove();
  });

  it('aligns baseline with inline elements', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.alignItems = 'baseline';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e0f2f1';

    const item1 = document.createElement('div');
    item1.innerHTML = 'Text with <strong style="font-size: 20px;">bold</strong>';
    item1.style.fontSize = '14px';
    item1.style.backgroundColor = '#4DB6AC';
    item1.style.color = 'white';
    item1.style.padding = '5px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.innerHTML = 'Text with <em style="font-size: 18px;">italic</em>';
    item2.style.fontSize = '14px';
    item2.style.backgroundColor = '#26A69A';
    item2.style.color = 'white';
    item2.style.padding = '5px';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = 'Plain text';
    item3.style.fontSize = '14px';
    item3.style.backgroundColor = '#009688';
    item3.style.color = 'white';
    item3.style.padding = '5px';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(3);

    grid.remove();
  });

  xit('handles baseline with vertical writing mode', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = '120px';
    grid.style.alignItems = 'baseline';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fce4ec';

    const item1 = document.createElement('div');
    item1.textContent = 'Horizontal';
    item1.style.fontSize = '16px';
    item1.style.backgroundColor = '#F06292';
    item1.style.color = 'white';
    item1.style.padding = '5px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Vertical';
    item2.style.writingMode = 'vertical-rl';
    item2.style.fontSize = '16px';
    item2.style.backgroundColor = '#EC407A';
    item2.style.color = 'white';
    item2.style.padding = '5px';
    grid.appendChild(item2);

    const item3 = document.createElement('div');
    item3.textContent = 'Horizontal';
    item3.style.fontSize = '16px';
    item3.style.backgroundColor = '#E91E63';
    item3.style.color = 'white';
    item3.style.padding = '5px';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items.length).toBe(3);

    grid.remove();
  });
});

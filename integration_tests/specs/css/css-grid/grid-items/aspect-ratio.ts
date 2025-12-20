describe('CSS Grid item aspect ratio', () => {
  it('maintains aspect ratio with auto width', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 1fr)';
    grid.style.gridTemplateRows = '100px';
    grid.style.width = '300px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    // Item with 16:9 aspect ratio and fixed height
    const item1 = document.createElement('div');
    item1.textContent = '16:9';
    item1.style.aspectRatio = '16 / 9';
    item1.style.height = '90px';
    item1.style.backgroundColor = '#42A5F5';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // Item with 1:1 aspect ratio
    const item2 = document.createElement('div');
    item2.textContent = '1:1';
    item2.style.aspectRatio = '1';
    item2.style.height = '80px';
    item2.style.backgroundColor = '#66BB6A';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    // Item with 4:3 aspect ratio
    const item3 = document.createElement('div');
    item3.textContent = '4:3';
    item3.style.aspectRatio = '4 / 3';
    item3.style.height = '75px';
    item3.style.backgroundColor = '#FFA726';
    item3.style.display = 'flex';
    item3.style.alignItems = 'center';
    item3.style.justifyContent = 'center';
    item3.style.color = 'white';
    grid.appendChild(item3);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Item 1: 16:9 with height 90px → width ≈ 160px
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(160, 0);
    expect(items[0].getBoundingClientRect().height).toBeCloseTo(90, 0);

    // Item 2: 1:1 with height 80px → width = 80px
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(80, 0);
    expect(items[1].getBoundingClientRect().height).toBeCloseTo(80, 0);

    // Item 3: 4:3 with height 75px → width = 100px
    expect(items[2].getBoundingClientRect().width).toBeCloseTo(100, 0);
    expect(items[2].getBoundingClientRect().height).toBeCloseTo(75, 0);

    grid.remove();
  });

  it('maintains aspect ratio with auto height', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridTemplateRows = 'auto';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    // Item with 16:9 aspect ratio and fixed width
    const item1 = document.createElement('div');
    item1.textContent = '16:9';
    item1.style.aspectRatio = '16 / 9';
    item1.style.width = '96px';
    item1.style.backgroundColor = '#2196F3';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // Item with 3:4 aspect ratio
    const item2 = document.createElement('div');
    item2.textContent = '3:4';
    item2.style.aspectRatio = '3 / 4';
    item2.style.width = '90px';
    item2.style.backgroundColor = '#1E88E5';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Item 1: 16:9 with width 96px → height = 54px
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(96, 0);
    expect(items[0].getBoundingClientRect().height).toBeCloseTo(54, 0);

    // Item 2: 3:4 with width 90px → height = 120px
    expect(items[1].getBoundingClientRect().width).toBeCloseTo(90, 0);
    expect(items[1].getBoundingClientRect().height).toBeCloseTo(120, 0);

    grid.remove();
  });

  it('handles aspect ratio with no explicit dimensions', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 120px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    // Item with aspect ratio, will use grid area
    const item1 = document.createElement('div');
    item1.textContent = '2:1';
    item1.style.aspectRatio = '2 / 1';
    item1.style.backgroundColor = '#BA68C8';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // Item with square aspect ratio
    const item2 = document.createElement('div');
    item2.textContent = '1:1';
    item2.style.aspectRatio = '1 / 1';
    item2.style.backgroundColor = '#AB47BC';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Items should maintain aspect ratio within grid constraints
    const ratio1 = items[0].getBoundingClientRect().width / items[0].getBoundingClientRect().height;
    expect(ratio1).toBeCloseTo(2, 0.5);

    const ratio2 = items[1].getBoundingClientRect().width / items[1].getBoundingClientRect().height;
    expect(ratio2).toBeCloseTo(1, 0.5);

    grid.remove();
  });

  it('respects aspect ratio with min and max constraints', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = '120px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    // Item with aspect ratio and max-height
    const item1 = document.createElement('div');
    item1.textContent = '16:9 max';
    item1.style.aspectRatio = '16 / 9';
    item1.style.width = '100%';
    item1.style.maxHeight = '80px';
    item1.style.backgroundColor = '#FFB74D';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '10px';
    grid.appendChild(item1);

    // Item with aspect ratio and min-width
    const item2 = document.createElement('div');
    item2.textContent = '1:2 min';
    item2.style.aspectRatio = '1 / 2';
    item2.style.height = '100px';
    item2.style.minWidth = '70px';
    item2.style.backgroundColor = '#FFA726';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    item2.style.fontSize = '10px';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Item 1: constrained by max-height
    expect(items[0].getBoundingClientRect().height).toBeLessThanOrEqual(80);

    // Item 2: constrained by min-width
    expect(items[1].getBoundingClientRect().width).toBeGreaterThanOrEqual(70);

    grid.remove();
  });

  it('handles aspect ratio with spanning items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(4, 80px)';
    grid.style.gridTemplateRows = 'repeat(2, 100px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    // Item spanning 2 columns with aspect ratio
    const item1 = document.createElement('div');
    item1.textContent = '16:9 span 2';
    item1.style.gridColumn = 'span 2';
    item1.style.aspectRatio = '16 / 9';
    item1.style.width = '100%';
    item1.style.backgroundColor = '#66BB6A';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '10px';
    grid.appendChild(item1);

    // Item spanning 2 rows with aspect ratio
    const item2 = document.createElement('div');
    item2.textContent = '9:16 span 2';
    item2.style.gridRow = 'span 2';
    item2.style.aspectRatio = '9 / 16';
    item2.style.height = '100%';
    item2.style.backgroundColor = '#4CAF50';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    item2.style.fontSize = '10px';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Item 1: spans 2 columns (160px), maintains 16:9
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(160, 0);
    const height1 = items[0].getBoundingClientRect().height;
    const ratio1 = 160 / height1;
    expect(ratio1).toBeCloseTo(16/9, 0.5);

    // Item 2: spans 2 rows (200px), maintains 9:16
    expect(items[1].getBoundingClientRect().height).toBeCloseTo(200, 0);
    const width2 = items[1].getBoundingClientRect().width;
    const ratio2 = width2 / 200;
    expect(ratio2).toBeCloseTo(9/16, 0.5);

    grid.remove();
  });

  it('combines aspect ratio with percentage dimensions', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '200px 200px';
    grid.style.gridTemplateRows = '150px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#ede7f6';

    // Item with aspect ratio and percentage width
    const item1 = document.createElement('div');
    item1.textContent = '4:3 + 80%';
    item1.style.aspectRatio = '4 / 3';
    item1.style.width = '80%';
    item1.style.backgroundColor = '#9575CD';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '10px';
    grid.appendChild(item1);

    // Item with aspect ratio and percentage height
    const item2 = document.createElement('div');
    item2.textContent = '3:2 + 60%';
    item2.style.aspectRatio = '3 / 2';
    item2.style.height = '60%';
    item2.style.backgroundColor = '#7E57C2';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    item2.style.fontSize = '10px';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Item 1: 80% of 200px = 160px width, maintains 4:3
    expect(items[0].getBoundingClientRect().width).toBeCloseTo(160, 0);
    const ratio1 = items[0].getBoundingClientRect().width / items[0].getBoundingClientRect().height;
    expect(ratio1).toBeCloseTo(4/3, 0.1);

    // Item 2: 60% of 150px = 90px height, maintains 3:2
    expect(items[1].getBoundingClientRect().height).toBeCloseTo(90, 0);
    const ratio2 = items[1].getBoundingClientRect().width / items[1].getBoundingClientRect().height;
    expect(ratio2).toBeCloseTo(3/2, 0.1);

    grid.remove();
  });

  it('handles ultra-wide and ultra-tall aspect ratios', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = '100px 100px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e0f2f1';

    // Ultra-wide aspect ratio (21:9)
    const item1 = document.createElement('div');
    item1.textContent = '21:9';
    item1.style.aspectRatio = '21 / 9';
    item1.style.height = '90px';
    item1.style.backgroundColor = '#4DB6AC';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    // Ultra-tall aspect ratio (9:21)
    const item2 = document.createElement('div');
    item2.textContent = '9:21';
    item2.style.aspectRatio = '9 / 21';
    item2.style.width = '90px';
    item2.style.backgroundColor = '#26A69A';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];

    // Item 1: 21:9 with height 90px → width = 210px
    const ratio1 = items[0].getBoundingClientRect().width / items[0].getBoundingClientRect().height;
    expect(ratio1).toBeCloseTo(21/9, 0.5);

    // Item 2: 9:21 with width 90px → height = 210px
    const ratio2 = items[1].getBoundingClientRect().width / items[1].getBoundingClientRect().height;
    expect(ratio2).toBeCloseTo(9/21, 0.5);

    grid.remove();
  });

  it('applies aspect ratio with content', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 120px)';
    grid.style.gridTemplateRows = 'auto';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fce4ec';

    // Item with aspect ratio and text content
    const item1 = document.createElement('div');
    item1.textContent = 'Aspect ratio with content text that may wrap';
    item1.style.aspectRatio = '16 / 9';
    item1.style.width = '100%';
    item1.style.backgroundColor = '#F06292';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.padding = '10px';
    item1.style.fontSize = '10px';
    grid.appendChild(item1);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const item = grid.children[0] as HTMLElement;

    // Item should maintain aspect ratio despite content
    const ratio = item.getBoundingClientRect().width / item.getBoundingClientRect().height;
    expect(ratio).toBeGreaterThan(1); // Should be wider than tall (16:9)

    grid.remove();
  });
});

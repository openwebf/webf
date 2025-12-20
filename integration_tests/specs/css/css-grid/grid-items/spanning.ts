describe('CSS Grid spanning items', () => {
  it('spans multiple columns', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(4, 70px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    const item1 = document.createElement('div');
    item1.textContent = 'Span 2';
    item1.style.gridColumn = 'span 2';
    item1.style.backgroundColor = '#42A5F5';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Span 3';
    item2.style.gridColumn = 'span 3';
    item2.style.backgroundColor = '#66BB6A';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBe(140); // 70px * 2
    expect(items[1].getBoundingClientRect().width).toBe(210); // 70px * 3

    grid.remove();
  });

  it('spans multiple rows', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '100px';
    grid.style.gridTemplateRows = 'repeat(4, 50px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    const item1 = document.createElement('div');
    item1.textContent = 'Span 2 rows';
    item1.style.gridRow = 'span 2';
    item1.style.backgroundColor = '#2196F3';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    item1.style.fontSize = '11px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Span 3 rows';
    item2.style.gridRow = 'span 3';
    item2.style.backgroundColor = '#1E88E5';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    item2.style.fontSize = '11px';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().height).toBe(100); // 50px * 2
    // The second item spans into an implicit row; since the fixed tracks already
    // provide enough height for its contents, the implicit track can resolve to 0.
    expect(items[1].getBoundingClientRect().height).toBe(100); // 50px * 2

    grid.remove();
  });

  it('spans both columns and rows', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 80px)';
    grid.style.gridTemplateRows = 'repeat(3, 60px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    const item = document.createElement('div');
    item.textContent = '2x2';
    item.style.gridColumn = 'span 2';
    item.style.gridRow = 'span 2';
    item.style.backgroundColor = '#BA68C8';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    item.style.fontSize = '20px';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const itemRect = item.getBoundingClientRect();
    expect(itemRect.width).toBe(160); // 80px * 2
    expect(itemRect.height).toBe(120); // 60px * 2

    grid.remove();
  });

  it('handles spanning beyond explicit grid', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 80px)';
    grid.style.gridTemplateRows = 'repeat(2, 60px)';
    grid.style.gridAutoColumns = '70px';
    grid.style.gridAutoRows = '50px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    const item = document.createElement('div');
    item.textContent = 'Span 5';
    item.style.gridColumn = 'span 5';
    item.style.backgroundColor = '#FFB74D';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const itemRect = item.getBoundingClientRect();
    // 3 explicit (80px each) + 2 implicit (70px each) = 240 + 140 = 380px
    expect(itemRect.width).toBe(380);

    grid.remove();
  });

  it('handles spanning with gaps', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(4, 70px)';
    grid.style.gridTemplateRows = 'repeat(3, 60px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#e8f5e9';

    const item1 = document.createElement('div');
    item1.textContent = 'Span 2';
    item1.style.gridColumn = 'span 2';
    item1.style.backgroundColor = '#66BB6A';
    item1.style.display = 'flex';
    item1.style.alignItems = 'center';
    item1.style.justifyContent = 'center';
    item1.style.color = 'white';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Span 2';
    item2.style.gridRow = 'span 2';
    item2.style.backgroundColor = '#4CAF50';
    item2.style.display = 'flex';
    item2.style.alignItems = 'center';
    item2.style.justifyContent = 'center';
    item2.style.color = 'white';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    // Width: 70*2 + 10 (gap) = 150px
    expect(items[0].getBoundingClientRect().width).toBe(150);
    // Height: 60*2 + 10 (gap) = 130px
    expect(items[1].getBoundingClientRect().height).toBe(130);

    grid.remove();
  });

  it('handles spanning from specific start line', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(5, 60px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#ede7f6';

    const item = document.createElement('div');
    item.textContent = '2 / span 3';
    item.style.gridColumn = '2 / span 3';
    item.style.backgroundColor = '#9575CD';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    item.style.fontSize = '11px';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const itemRect = item.getBoundingClientRect();
    expect(itemRect.width).toBe(180); // 60px * 3
    expect(itemRect.left).toBe(grid.getBoundingClientRect().left + 60); // Starts at column 2

    grid.remove();
  });

  it('handles nested spanning items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(4, 70px)';
    grid.style.gridTemplateRows = 'repeat(3, 60px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e0f2f1';

    const item1 = document.createElement('div');
    item1.style.gridColumn = 'span 4';
    item1.style.gridRow = 'span 1';
    item1.style.backgroundColor = '#4DB6AC';
    item1.style.display = 'grid';
    item1.style.gridTemplateColumns = 'repeat(2, 1fr)';
    item1.style.gap = '5px';
    item1.style.padding = '5px';

    const nested1 = document.createElement('div');
    nested1.textContent = 'Nested 1';
    nested1.style.backgroundColor = '#26A69A';
    nested1.style.display = 'flex';
    nested1.style.alignItems = 'center';
    nested1.style.justifyContent = 'center';
    nested1.style.color = 'white';
    nested1.style.fontSize = '10px';
    item1.appendChild(nested1);

    const nested2 = document.createElement('div');
    nested2.textContent = 'Nested 2';
    nested2.style.backgroundColor = '#009688';
    nested2.style.display = 'flex';
    nested2.style.alignItems = 'center';
    nested2.style.justifyContent = 'center';
    nested2.style.color = 'white';
    nested2.style.fontSize = '10px';
    item1.appendChild(nested2);

    grid.appendChild(item1);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(item1.getBoundingClientRect().width).toBe(280); // 70px * 4

    grid.remove();
  });

  it('handles maximum span', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(6, 50px)';
    grid.style.gridTemplateRows = '60px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fce4ec';

    const item = document.createElement('div');
    item.textContent = 'Full width';
    item.style.gridColumn = 'span 6';
    item.style.backgroundColor = '#F06292';
    item.style.display = 'flex';
    item.style.alignItems = 'center';
    item.style.justifyContent = 'center';
    item.style.color = 'white';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(item.getBoundingClientRect().width).toBe(300); // 50px * 6

    grid.remove();
  });
});

describe('CSS Grid item overflow', () => {
  it('handles overflow visible (default)', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 100px)';
    grid.style.gridTemplateRows = '80px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f5f5f5';

    const item = document.createElement('div');
    item.textContent = 'This is long content that will overflow the grid item area';
    item.style.backgroundColor = '#42A5F5';
    item.style.color = 'white';
    item.style.padding = '5px';
    item.style.fontSize = '11px';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // With overflow visible, content overflows
    expect(item.getBoundingClientRect().width).toBeGreaterThan(0);

    grid.remove();
  });

  it('handles overflow hidden', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 120px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e3f2fd';

    const item1 = document.createElement('div');
    item1.textContent = 'This text will be clipped because overflow is hidden and content is too long';
    item1.style.overflow = 'hidden';
    item1.style.backgroundColor = '#2196F3';
    item1.style.color = 'white';
    item1.style.padding = '5px';
    item1.style.fontSize = '11px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Normal';
    item2.style.backgroundColor = '#1E88E5';
    item2.style.color = 'white';
    item2.style.padding = '5px';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBe(120);
    expect(items[0].getBoundingClientRect().height).toBe(100);

    grid.remove();
  });

  it('handles overflow scroll', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 150px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#f3e5f5';

    const item = document.createElement('div');
    item.textContent = 'This is long content that will create scrollbars. '.repeat(5);
    item.style.overflow = 'scroll';
    item.style.backgroundColor = '#BA68C8';
    item.style.color = 'white';
    item.style.padding = '5px';
    item.style.fontSize = '11px';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Item should have fixed dimensions with scrollbars
    expect(item.getBoundingClientRect().width).toBe(150);
    expect(item.getBoundingClientRect().height).toBe(100);

    grid.remove();
  });

  it('handles overflow auto', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 130px)';
    grid.style.gridTemplateRows = '90px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff3e0';

    const item1 = document.createElement('div');
    item1.textContent = 'Short content';
    item1.style.overflow = 'auto';
    item1.style.backgroundColor = '#FFB74D';
    item1.style.color = 'white';
    item1.style.padding = '5px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Very long content that will trigger auto overflow scrolling behavior because it exceeds the container size';
    item2.style.overflow = 'auto';
    item2.style.backgroundColor = '#FFA726';
    item2.style.color = 'white';
    item2.style.padding = '5px';
    item2.style.fontSize = '10px';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBe(130);
    expect(items[1].getBoundingClientRect().width).toBe(130);

    grid.remove();
  });

  it('handles overflow with text-overflow ellipsis', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 140px)';
    grid.style.gridTemplateRows = '80px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e8f5e9';

    const item = document.createElement('div');
    item.textContent = 'This is very long text that should show ellipsis';
    item.style.overflow = 'hidden';
    item.style.textOverflow = 'ellipsis';
    item.style.whiteSpace = 'nowrap';
    item.style.backgroundColor = '#66BB6A';
    item.style.color = 'white';
    item.style.padding = '5px';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    expect(item.getBoundingClientRect().width).toBe(140);

    grid.remove();
  });

  it('handles overflow-x and overflow-y separately', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '150px';
    grid.style.gridTemplateRows = 'repeat(2, 100px)';
    grid.style.gap = '10px';
    grid.style.backgroundColor = '#ede7f6';

    const item1 = document.createElement('div');
    item1.textContent = 'Horizontal scroll only: '.repeat(10);
    item1.style.overflowX = 'scroll';
    item1.style.overflowY = 'hidden';
    item1.style.backgroundColor = '#9575CD';
    item1.style.color = 'white';
    item1.style.padding = '5px';
    item1.style.fontSize = '10px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'Vertical scroll only. '.repeat(15);
    item2.style.overflowX = 'hidden';
    item2.style.overflowY = 'scroll';
    item2.style.backgroundColor = '#7E57C2';
    item2.style.color = 'white';
    item2.style.padding = '5px';
    item2.style.fontSize = '10px';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBe(150);
    expect(items[1].getBoundingClientRect().height).toBe(100);

    grid.remove();
  });

  it('handles overflow with large content', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 140px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#e0f2f1';

    const item = document.createElement('div');
    item.style.overflow = 'hidden';
    item.style.backgroundColor = '#4DB6AC';

    const largeContent = document.createElement('div');
    largeContent.textContent = 'Large content';
    largeContent.style.width = '300px';
    largeContent.style.height = '200px';
    largeContent.style.backgroundColor = '#26A69A';
    largeContent.style.color = 'white';
    largeContent.style.display = 'flex';
    largeContent.style.alignItems = 'center';
    largeContent.style.justifyContent = 'center';

    item.appendChild(largeContent);
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Grid item should clip the large content
    expect(item.getBoundingClientRect().width).toBe(140);
    expect(item.getBoundingClientRect().height).toBe(100);

    grid.remove();
  });

  it('handles overflow in spanning items', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 90px)';
    grid.style.gridTemplateRows = 'repeat(2, 80px)';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fce4ec';

    const item = document.createElement('div');
    item.textContent = 'Spanning item with lots of content that will overflow. '.repeat(5);
    item.style.gridColumn = 'span 2';
    item.style.gridRow = 'span 2';
    item.style.overflow = 'auto';
    item.style.backgroundColor = '#F06292';
    item.style.color = 'white';
    item.style.padding = '5px';
    item.style.fontSize = '10px';
    grid.appendChild(item);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    // Item spans 2x2 with overflow auto
    expect(item.getBoundingClientRect().width).toBe(180); // 90px * 2
    expect(item.getBoundingClientRect().height).toBe(160); // 80px * 2

    grid.remove();
  });

  it('handles word-break with overflow', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(2, 130px)';
    grid.style.gridTemplateRows = '100px';
    grid.style.gap = '0';
    grid.style.backgroundColor = '#fff9c4';

    const item1 = document.createElement('div');
    item1.textContent = 'VeryLongWordWithoutSpacesThatWillBreak';
    item1.style.overflow = 'hidden';
    item1.style.wordBreak = 'break-all';
    item1.style.backgroundColor = '#FFEB3B';
    item1.style.padding = '5px';
    item1.style.fontSize = '11px';
    grid.appendChild(item1);

    const item2 = document.createElement('div');
    item2.textContent = 'VeryLongWordWithoutSpacesThatWillNotBreak';
    item2.style.overflow = 'hidden';
    item2.style.wordBreak = 'normal';
    item2.style.backgroundColor = '#FDD835';
    item2.style.padding = '5px';
    item2.style.fontSize = '11px';
    grid.appendChild(item2);

    document.body.appendChild(grid);
    await waitForFrame();
    await snapshot();

    const items = Array.from(grid.children) as HTMLElement[];
    expect(items[0].getBoundingClientRect().width).toBe(130);
    expect(items[1].getBoundingClientRect().width).toBe(130);

    grid.remove();
  });
});

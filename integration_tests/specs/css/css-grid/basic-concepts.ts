describe('CSS Grid basic concepts', () => {
  it('lays out a simple 3x2 card grid', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = 'repeat(3, 100px)';
    grid.style.gridAutoRows = '80px';
    grid.style.gap = '12px';
    grid.style.padding = '12px';
    grid.style.backgroundColor = '#f3f4f6';
    grid.style.border = '1px solid #d1d5db';
    grid.style.borderRadius = '8px';

    const labels = ['One', 'Two', 'Three', 'Four', 'Five', 'Six'];
    labels.forEach((label, index) => {
      const card = document.createElement('div');
      card.textContent = label;
      card.style.display = 'flex';
      card.style.alignItems = 'center';
      card.style.justifyContent = 'center';
      card.style.borderRadius = '6px';
      card.style.fontWeight = '600';
      card.style.backgroundColor = [
        'rgba(59, 130, 246, 0.25)',
        'rgba(16, 185, 129, 0.25)',
        'rgba(234, 179, 8, 0.25)',
        'rgba(239, 68, 68, 0.25)',
        'rgba(129, 140, 248, 0.25)',
        'rgba(236, 72, 153, 0.25)',
      ][index];
      grid.appendChild(card);
    });

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    grid.remove();
  });

  it('positions items using line numbers and spans', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '120px 120px 120px';
    grid.style.gridTemplateRows = '80px 80px';
    grid.style.columnGap = '8px';
    grid.style.rowGap = '8px';
    grid.style.padding = '8px';
    grid.style.backgroundColor = '#f9fafb';
    grid.style.border = '1px solid #e5e7eb';

    const header = document.createElement('div');
    header.textContent = 'Header';
    header.style.gridColumn = '1 / 3';
    header.style.gridRow = '1';
    header.style.display = 'flex';
    header.style.alignItems = 'center';
    header.style.justifyContent = 'center';
    header.style.backgroundColor = 'rgba(59, 130, 246, 0.4)';
    grid.appendChild(header);

    const sidebar = document.createElement('div');
    sidebar.textContent = 'Sidebar';
    sidebar.style.gridColumn = '3';
    sidebar.style.gridRow = '1 / 3';
    sidebar.style.display = 'flex';
    sidebar.style.alignItems = 'center';
    sidebar.style.justifyContent = 'center';
    sidebar.style.backgroundColor = 'rgba(34, 197, 94, 0.4)';
    grid.appendChild(sidebar);

    const content = document.createElement('div');
    content.textContent = 'Content';
    content.style.gridColumn = '1 / 2';
    content.style.gridRow = '2';
    content.style.display = 'flex';
    content.style.alignItems = 'center';
    content.style.justifyContent = 'center';
    content.style.backgroundColor = 'rgba(234, 179, 8, 0.4)';
    grid.appendChild(content);

    const extra = document.createElement('div');
    extra.textContent = 'Extra';
    extra.style.gridColumn = '2';
    extra.style.gridRow = '2';
    extra.style.display = 'flex';
    extra.style.alignItems = 'center';
    extra.style.justifyContent = 'center';
    extra.style.backgroundColor = 'rgba(244, 63, 94, 0.4)';
    grid.appendChild(extra);

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    grid.remove();
  });
});


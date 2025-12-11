describe('CSS Grid shorthand `grid`', () => {
  it('applies template rows/columns from grid shorthand', async () => {
    const grid = document.createElement('div');
    grid.setAttribute(
      'style',
      'display:grid; grid: 40px 60px / 80px 40px;',
    );

    const cellA = document.createElement('div');
    cellA.textContent = 'A';
    cellA.style.backgroundColor = 'rgba(129, 199, 132, 0.5)';
    grid.appendChild(cellA);

    const cellB = document.createElement('div');
    cellB.textContent = 'B';
    cellB.style.backgroundColor = 'rgba(244, 143, 177, 0.5)';
    grid.appendChild(cellB);

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const computed = getComputedStyle(grid);
    expect(computed.gridTemplateRows).toEqual('40px 60px');
    expect(computed.gridTemplateColumns).toEqual('80px 40px');

    grid.remove();
  });
});

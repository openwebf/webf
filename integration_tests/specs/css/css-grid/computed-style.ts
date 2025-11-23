describe('CSS Grid computed style serialization', () => {
  it('serializes template tracks and placements', async () => {
    const grid = document.createElement('div');
    grid.id = 'grid';
    grid.style.display = 'grid';
    grid.style.width = '240px';
    grid.style.gridTemplateColumns = '40px 1fr auto';
    grid.style.gridTemplateRows = '40px 50px';
    grid.style.gridAutoFlow = 'column dense';
    grid.style.gridAutoRows = '60px auto';
    grid.style.gridAutoColumns = '80px auto';

    const child = document.createElement('div');
    child.id = 'child';
    child.style.height = '20px';
    child.style.gridColumn = '2 / span 2';
    child.style.gridRowStart = 'span 3';

    grid.appendChild(child);
    document.body.appendChild(grid);
    const gridComputed = getComputedStyle(grid);
    expect(gridComputed.gridTemplateColumns).toEqual('40px 1fr auto');
    expect(gridComputed.gridTemplateRows).toEqual('40px 50px');
    expect(gridComputed.gridAutoColumns).toEqual('80px auto');
    expect(gridComputed.gridAutoRows).toEqual('60px auto');
    expect(gridComputed.gridAutoFlow).toEqual('column dense');

    const childComputed = getComputedStyle(child);
    expect(childComputed.gridColumnStart).toEqual('2');
    expect(childComputed.gridColumnEnd).toEqual('span 2');
    expect(childComputed.gridColumn).toEqual('2 / span 2');
    expect(childComputed.gridRowStart).toEqual('span 3');
    expect(childComputed.gridRowEnd).toEqual('auto');
    expect(childComputed.gridRow).toEqual('span 3 / auto');

    grid.remove();
  });
});

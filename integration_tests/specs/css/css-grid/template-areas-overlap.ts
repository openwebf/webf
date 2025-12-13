describe('CSS Grid template areas overlap handling', () => {
  xit('treats overlapping template definitions as none', async () => {
    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = '80px 80px';
    grid.style.gridTemplateRows = '60px 60px';
    grid.style.gridTemplateAreas = '"alpha alpha" "alpha beta"';
    grid.style.gap = '8px';
    grid.style.padding = '8px';
    grid.style.background = '#fefaf4';
    grid.style.border = '1px solid #edd6a3';

    const alpha = document.createElement('div');
    alpha.textContent = 'alpha';
    alpha.style.gridArea = 'alpha';
    alpha.style.background = 'rgba(244, 143, 177, 0.5)';
    grid.appendChild(alpha);

    const beta = document.createElement('div');
    beta.textContent = 'beta';
    beta.style.gridArea = 'beta';
    beta.style.background = 'rgba(129, 199, 132, 0.5)';
    grid.appendChild(beta);

    document.body.appendChild(grid);

    await waitForFrame();
    await snapshot();

    const alphaRect = alpha.getBoundingClientRect();
    const betaRect = beta.getBoundingClientRect();
    const gridRect = grid.getBoundingClientRect();

    // Overlapping template definitions should invalidate the template,
    // so alpha sits at the first cell and beta follows auto-placement order.
    expect(Math.round(alphaRect.left - gridRect.left)).toBeGreaterThanOrEqual(8);
    expect(Math.round(alphaRect.top - gridRect.top)).toBeGreaterThanOrEqual(8);
    expect(Math.round(betaRect.top)).toBeCloseTo(Math.round(alphaRect.top), 0);
    expect(Math.round(betaRect.left - alphaRect.right)).toBeGreaterThanOrEqual(8);
    grid.remove();
  });
});

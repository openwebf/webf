describe('Input flex sizing', () => {
  it('flex: 1 input expands to container main size', async () => {
    const container = document.createElement('div');
    Object.assign(container.style, {
      display: 'flex',
      width: '300px',
      border: '1px solid #000',
      boxSizing: 'border-box',
    });

    const input = document.createElement('input');
    Object.assign(input.style, {
      flex: '1 1 0%',
      minWidth: '0',
    });
    container.appendChild(input);
    document.body.appendChild(container);

    await snapshot();
    expect(input.offsetWidth).toBeGreaterThanOrEqual(295);
  });
});


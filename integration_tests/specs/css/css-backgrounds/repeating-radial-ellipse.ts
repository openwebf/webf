describe('repeating-radial-gradient ellipse (px stops)', () => {
  it('ellipse at 40% 60%, 8px green + 8px light rings', async () => {
    const div = createElement('div', {
      style: {
        width: '180px',
        height: '80px',
        border: '1px solid #ccc',
        backgroundImage: 'repeating-radial-gradient(ellipse at 40% 60%, #16a34a 0 8px, #dcfce7 8px 16px)'
      },
    });
    append(BODY, div);
    await snapshot(div);
  });
});


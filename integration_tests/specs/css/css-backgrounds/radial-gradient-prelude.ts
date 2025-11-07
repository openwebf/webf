describe('Radial-gradient prelude and position parsing', () => {
  it('single-value position: at 100% (x=100%, y=center)', async () => {
    const div = createElement('div', {
      style: {
        width: '200px',
        height: '100px',
        border: '1px solid #ccc',
        backgroundImage:
          'radial-gradient(circle at 100%, #333, #333 50%, #eee 75%, #333 75%)',
      },
    });
    append(BODY, div);
    await snapshot(div);
  });

  it('keyword position: at right center', async () => {
    const div = createElement('div', {
      style: {
        width: '200px',
        height: '100px',
        border: '1px solid #ccc',
        backgroundImage:
          'radial-gradient(circle at right center, #333, #333 50%, #eee 75%, #333 75%)',
      },
    });
    append(BODY, div);
    await snapshot(div);
  });

  it('two-value percentage position: at 30% 60%', async () => {
    const div = createElement('div', {
      style: {
        width: '220px',
        height: '120px',
        border: '1px solid #ccc',
        backgroundImage:
          'radial-gradient(circle at 30% 60%, #333, #333 50%, #eee 75%, #333 75%)',
      },
    });
    append(BODY, div);
    await snapshot(div);
  });
});


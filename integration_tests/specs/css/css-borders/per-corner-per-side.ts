/*auto generated*/
describe('css-borders: per-corner radius with per-side colors', () => {
  it('solid uniform width + per-side colors + non-uniform corner radii', async () => {
    const div = createElement('div', {
      style: {
        width: '220px',
        height: '80px',
        backgroundColor: 'white',
        borderStyle: 'solid',
        borderWidth: '6px',
        borderColor: '#f59e0b #10b981 #ef4444 #3b82f6', // top right bottom left
        borderRadius: '10px 30px 60px 35px'
      }
    });

    append(BODY, div);

    await snapshot();
  });
});


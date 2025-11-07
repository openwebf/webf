describe('linear-gradient grid overlay normalized by background-size', () => {
  it('vertical 25px grid: rgba band at 24-25px repeats', async () => {
    const div = createElement('div', {
      style: {
        width: '220px',
        height: '120px',
        backgroundColor: '#ffffff',
        backgroundImage: 'linear-gradient(#0000 24px, rgba(0,0,0,0.15) 25px)',
        backgroundRepeat: 'repeat',
        backgroundPosition: 'top left',
        backgroundSize: '25px 25px',
        border: '1px dashed #bdbdbd'
      }
    });
    append(BODY, div);
    await snapshot(div);
  });

  it('horizontal 25px grid: rotate 90deg with same stops', async () => {
    const div = createElement('div', {
      style: {
        width: '220px',
        height: '120px',
        backgroundColor: '#ffffff',
        backgroundImage: 'linear-gradient(90deg, #0000 24px, rgba(0,0,0,0.15) 25px)',
        backgroundRepeat: 'repeat',
        backgroundPosition: 'top left',
        backgroundSize: '25px 25px',
        border: '1px dashed #bdbdbd'
      }
    });
    append(BODY, div);
    await snapshot(div);
  });
});


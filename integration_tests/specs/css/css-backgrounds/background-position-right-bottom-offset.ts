describe('Background-position with side+offset pairs', () => {
  it('right 20px bottom 10px with background-size 50x50 no-repeat', async () => {
    const div = createElement('div', {
      style: {
        width: '220px',
        height: '120px',
        backgroundColor: '#ffffff',
        backgroundImage: 'url(assets/cat.png)',
        backgroundSize: '50px 50px',
        backgroundRepeat: 'no-repeat',
        backgroundPosition: 'right 20px bottom 10px',
        border: '1px dashed #bdbdbd'
      }
    });
    append(BODY, div);
    await snapshot(div);
  });

  it('background shorthand with position and size slash', async () => {
    const div = createElement('div', {
      style: {
        width: '220px',
        height: '120px',
        background: 'url(assets/cat.png) no-repeat #fff right 20px bottom 10px / 50px 50px',
        border: '1px dashed #bdbdbd'
      }
    });
    append(BODY, div);
    await snapshot(div);
  });
});


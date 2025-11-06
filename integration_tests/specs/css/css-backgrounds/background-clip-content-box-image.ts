describe('Background-clip with image', () => {
  it('content-box clips positioned image (origin default padding-box)', async () => {
    const div = createElement('div', {
      style: {
        width: '220px',
        height: '120px',
        border: '10px solid #888',
        padding: '20px',
        backgroundColor: '#fff7ed',
        backgroundImage: 'url(assets/cat.png)',
        backgroundRepeat: 'no-repeat',
        backgroundPosition: 'top left',
        backgroundSize: '60px 60px',
        backgroundClip: 'content-box'
      }
    });
    append(BODY, div);
    await snapshot(div);
  });

  it('content-box + origin content-box positions and clips in content box', async () => {
    const div = createElement('div', {
      style: {
        width: '220px',
        height: '120px',
        border: '10px solid #888',
        padding: '20px',
        backgroundColor: '#fff7ed',
        backgroundImage: 'url(assets/cat.png)',
        backgroundRepeat: 'no-repeat',
        backgroundPosition: 'top left',
        backgroundSize: '60px 60px',
        backgroundOrigin: 'content-box',
        backgroundClip: 'content-box'
      }
    });
    append(BODY, div);
    await snapshot(div);
  });
});


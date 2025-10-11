describe('background-image dynamic update', () => {
  it('updates when linear-gradient colors change (issue #14)', async (done) => {
    const div = createElement('div', {
      style: {
        width: '120px',
        height: '120px',
        backgroundImage: 'linear-gradient(134deg, #FFFFFF 0%, #FFFFFF 100%)'
      }
    });

    BODY.appendChild(div);
    await snapshot(div);

    requestAnimationFrame(async () => {
      div.style.backgroundImage = 'linear-gradient(134deg, #FEC6F0 0%, #AEDEF2 100%)';

      requestAnimationFrame(async () => {
        await snapshot(div);
        done();
      });
    });
  });
});


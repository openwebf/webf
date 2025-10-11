describe('positioned scrollable size', () => {
  it('dynamic change the size of elements inside of positioned element can affect scrollable size', async (done) => {
    let overlay: any;

    const placeholders = Array(50).fill(0).map(() =>
      createElement('div', {
        style: {
          height: '50px',
          margin: '5px 0',
          border: '1px solid #000'
        }
      })
    );

    const container = createElement('div', {
      style: {
        position: 'absolute',
        width: '100px',
        height: '100px'
      }
    }, [
      (overlay = createElement('div', { style: {} })),
      ...placeholders,
      createText('bottom text')
    ]);

    BODY.appendChild(container);

    // Defer style mutation to the next frame to simulate dynamic change
    requestAnimationFrame(async () => {
      overlay.style.height = '100px';
      overlay.style.backgroundColor = 'red';

      await waitForFrame();

      window.scrollTo(0, 10000);
      await snapshot(1);
      done();
    });
  });
});


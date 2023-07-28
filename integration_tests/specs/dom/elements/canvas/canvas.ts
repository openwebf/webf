describe('Canvas Tag', () => {
  it('set backgroundColor', async () => {
    let canvas = createElementWithStyle('canvas', {
      width: '200px',
      height: '200px',
      backgroundColor: 'blue',
    });
    append(BODY, canvas);
    await snapshot(canvas);
  });

  it('behavior like inline element', async () => {
    let wrapper = createElementWithStyle('div', {
      width: '200px',
      height: '200px',
    });
    let canvas = createElementWithStyle('canvas', {
      width: '100px',
      height: '100px',
      backgroundColor: 'blue',
    });
    let text = createElementWithStyle('span', {}, document.createTextNode('12345'));
    append(wrapper, canvas);
    append(wrapper, text);
    append(BODY, wrapper);
    await snapshot(wrapper);
  });

  it('dynamic create multiple 2d context from single canvas element', async (done) => {
    let count = 1;
    const timer = setInterval(async () => {
      drawRect();
      await snapshot();
      count++;
      if (count == 5) {
        clearTimeout(timer);
        done();
      }
    }, 100);

    const myCanvas = document.createElement('canvas');
    document.body.appendChild(myCanvas);

    function drawRect() {
      const ctx = myCanvas.getContext("2d");
      ctx!.clearRect(0,0,200,200);
      ctx!.fillStyle = '#A0A00F';
      ctx!.fillRect(0, 0, 200, 10 * count);
    }
  });
});

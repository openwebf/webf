describe('Background-color', () => {
  it('red', async () => {
    const div = document.createElement('div');
    setElementStyle(div, {
      width: '200px',
      height: '200px',
      backgroundColor: 'red',
    });

    document.body.appendChild(div);
    await snapshot(div);
  });

  it('red with display none', async () => {
    const div = createElementWithStyle('div', {
      backgroundColor: 'red',
      display: 'none',
      width: '100px',
      height: '100px',
    });
    append(BODY, div);
    await snapshot();
  });

  // @TODO: window.onload will not be triggered in single test
  // cause all tests are placed in the same page.
  xit('red with display when window.onload', async (done) => {
    window.onload = async () => {
      div.style.display = 'none';
      await snapshot();
      done();
    };
    const div = createElementWithStyle('div', {
      backgroundColor: 'red',
      width: '100px',
      height: '100px',
    });
    append(BODY, div);
  });

  it('image overlay red', async () => {
    let red = createElementWithStyle('div', {
      width: '60px',
      height: '60px',
      backgroundColor: 'red',
    });
    let green = createElementWithStyle('div', {
      width: '100px',
      height: '100px',
      position: 'relative',
      bottom: '60px',
      backgroundImage:
        'url(assets/green-60-60.png)',
      backgroundRepeat: 'no-repeat',
    });
    append(BODY, red);
    append(BODY, green);
    await sleep(1);
    await snapshot();
  });

  it('can propagate to html from body element', async () => {
    document.documentElement.style.backgroundColor = 'transparent';
    document.body.style.width = '200px';
    document.body.style.height = '300px';
    document.body.style.backgroundColor = 'red';
    await snapshot();

    document.documentElement.style.backgroundColor = 'green';
    await snapshot();
  });

  it('red and remove', async (done) => {
    const div = document.createElement('div');
    setElementStyle(div, {
      width: '200px',
      height: '200px',
      backgroundColor: 'red',
    });
    document.body.appendChild(div);

    requestAnimationFrame(async () => {
      div.style.backgroundColor = '';
      await snapshot(div);
      done();
    });
  });

  it("computed", async (done) => {
    let target;
    target = createElement('div', {
      id: 'target',
      style: {
        color: 'lime',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(target);

    target.ononscreen = () => {
      test_computed_value('background-color', 'currentcolor', 'rgb(0, 255, 0)');

      test_computed_value('background-color', 'red', 'rgb(255, 0, 0)');
      test_computed_value('background-color', '#00FF00', 'rgb(0, 255, 0)');
      test_computed_value('background-color', 'rgb(0, 0, 255)');
      test_computed_value(
        'background-color',
        'rgb(100%, 100%, 0%)',
        'rgb(255, 255, 0)'
      );
      test_computed_value(
        'background-color',
        'hsl(120, 100%, 50%)',
        'rgb(0, 255, 0)'
      );
      test_computed_value('background-color', 'transparent', 'rgba(0, 0, 0, 0)');
      done();
    }

  })
});

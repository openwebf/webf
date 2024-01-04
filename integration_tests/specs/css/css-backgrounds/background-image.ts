describe('background image', function() {
  it('should work with image of png', async () => {
    let div;
    let image;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
        },
      },
      [
        image = createElement('div', {
          style: {
            width: '200px',
            height: '200px',
            backgroundRepeat: 'no-repeat',
            backgroundImage: 'url(assets/100x100-green.png)'
          }
        }),
      ]
    );
    BODY.appendChild(div);

    await snapshot(0.5);
  });

  it('should work when remove css host are not same with html host', async () => {
    const link = document.createElement('link');
    link.setAttribute('rel', 'stylesheet');
    link.setAttribute('href', `${location.protocol}//${location.hostname}:${parseInt(location.port) + 1}/public/assets/remote.css`);
    document.head.appendChild(link);

    console.log(`${location.protocol}//${location.hostname}:${parseInt(location.port) + 1}/public/assets/remote.css`);

    let div = document.createElement('div');
    div.className = 'container';
    div.textContent = 'helloworld';
    document.body.appendChild(div);
    await snapshot(1);
  });

  it('should work with image of base64', async () => {
    let div;
    let image;
    div = createElement(
      'div',
      {
        style: {
          display: 'flex',
        },
      },
      [
        image = createElement('div', {
          style: {
            width: '200px',
            height: '200px',
            backgroundRepeat: 'no-repeat',
            backgroundImage: 'url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGQAAABkAQMAAABKLAcXAAAAA1BMVEUAgACc+aWRAAAAE0lEQVR4AWOgKxgFo2AUjIJRAAAFeAABHs0ozQAAAABJRU5ErkJggg==)'
          }
        }),
      ]
    );
    BODY.appendChild(div);

    await snapshot(0.1);
  });

  it('should work with css vars', async () => {
    const style = `
      :root {
       --background-end-rgb: 255, 255, 255;
       --background-end-rgb-2: 0,0,0;
      }
      
      .box {
        width: 100px;
        height: 100px;
        background: linear-gradient(
            to bottom,
            rgb(var(--background-end-rgb)),
            rgb(var(--background-end-rgb-2)));
      }
    `;
    const styleEle = document.createElement('style');
    styleEle.innerHTML = style;
    document.head.appendChild(styleEle);

    const container = createElement('div', {
      className: 'box'
    });
    document.body.appendChild(container);
    await snapshot();
  });

  it("computed", async () => {
    let target;
    target = createElement('div', {
      id: 'target',
      style: {
        'font-size': '40px',
        'box-sizing': 'border-box',
      },
    });
    BODY.appendChild(target);

    test_computed_value('background-image', 'none');

    test_computed_value(
      'background-image',
      'linear-gradient(to left bottom, red, blue)',
      'linear-gradient(to left bottom, rgb(255, 0, 0), rgb(0, 0, 255))'
    );

    test_computed_value(
      'background-image',
      'radial-gradient(rgb(255, 0, 0), rgb(0, 0, 255))'
    );
    // test_computed_value(
    //   'background-image',
    //   'radial-gradient(at center, red, blue)',
    //   'radial-gradient(rgb(255, 0, 0), rgb(0, 0, 255))'
    // );
    test_computed_value(
      'background-image',
      'radial-gradient(at 50%, red, blue)',
      'radial-gradient(rgb(255, 0, 0), rgb(0, 0, 255))'
    );
    // test_computed_value(
    //   'background-image',
    //   'radial-gradient(at 10px 10px, rgb(255, 0, 0), rgb(0, 0, 255))'
    // );
    // test_computed_value(
    //   'background-image',
    //   'radial-gradient(farthest-side, rgb(255, 0, 0), rgb(0, 0, 255))'
    // );
    // test_computed_value(
    //   'background-image',
    //   'radial-gradient(farthest-side at 10px 10px, rgb(255, 0, 0), rgb(0, 0, 255))'
    // );
    // test_computed_value(
    //   'background-image',
    //   'radial-gradient(farthest-corner, red, blue)',
    //   'radial-gradient(rgb(255, 0, 0), rgb(0, 0, 255))'
    // );
    // test_computed_value(
    //   'background-image',
    //   'radial-gradient(farthest-corner at center, red, blue)',
    //   'radial-gradient(rgb(255, 0, 0), rgb(0, 0, 255))'
    // );
    // test_computed_value(
    //   'background-image',
    //   'radial-gradient(farthest-corner at 50%, red, blue)',
    //   'radial-gradient(rgb(255, 0, 0), rgb(0, 0, 255))'
    // );
    // test_computed_value(
    //   'background-image',
    //   'radial-gradient(farthest-corner at 10px 10px, red, blue)',
    //   'radial-gradient(at 10px 10px, rgb(255, 0, 0), rgb(0, 0, 255))'
    // );

    // test_computed_value(
    //   'background-image',
    //   'radial-gradient(10px at 20px 30px, rgb(255, 0, 0), rgb(0, 0, 255))'
    // );
    // test_computed_value(
    //   'background-image',
    //   'radial-gradient(circle calc(-0.5em + 10px) at calc(-1em + 10px) calc(-2em + 10px), red, blue)',
    //   'radial-gradient(0px at -30px -70px, rgb(255, 0, 0), rgb(0, 0, 255))'
    // );
    // test_computed_value(
    //   'background-image',
    //   'radial-gradient(ellipse calc(-0.5em + 10px) calc(0.5em + 10px) at 20px 30px, red, blue)',
    //   'radial-gradient(0px 30px at 20px 30px, rgb(255, 0, 0), rgb(0, 0, 255))'
    // );
    // test_computed_value(
    //   'background-image',
    //   'radial-gradient(ellipse calc(0.5em + 10px) calc(-0.5em + 10px) at 20px 30px, red, blue)',
    //   'radial-gradient(30px 0px at 20px 30px, rgb(255, 0, 0), rgb(0, 0, 255))'
    // );

    test_computed_value(
      'background-image',
      'conic-gradient(rgb(255, 0, 0), rgb(0, 0, 255))'
    );
    test_computed_value(
      'background-image',
      'conic-gradient(at center, red, blue)',
      'conic-gradient(rgb(255, 0, 0), rgb(0, 0, 255))'
    );
    test_computed_value(
      'background-image',
      'conic-gradient(at 50%, red, blue)',
      'conic-gradient(rgb(255, 0, 0), rgb(0, 0, 255))'
    );
    // test_computed_value(
    //   'background-image',
    //   'conic-gradient(at 10px 10px, rgb(255, 0, 0), rgb(0, 0, 255))'
    // );
    test_computed_value(
      'background-image',
      'conic-gradient(from 0deg, red, blue)',
      'conic-gradient(rgb(255, 0, 0), rgb(0, 0, 255))'
    );
    // test_computed_value(
    //   'background-image',
    //   'conic-gradient(from 0deg at center, red, blue)',
    //   'conic-gradient(rgb(255, 0, 0), rgb(0, 0, 255))'
    // );
    test_computed_value(
      'background-image',
      'conic-gradient(from 0deg at 50%, red, blue)',
      'conic-gradient(rgb(255, 0, 0), rgb(0, 0, 255))'
    );
    // test_computed_value(
    //   'background-image',
    //   'conic-gradient(from 0deg at 10px 10px, red, blue)',
    //   'conic-gradient(at 10px 10px, rgb(255, 0, 0), rgb(0, 0, 255))'
    // );
    test_computed_value(
      'background-image',
      'conic-gradient(from 45deg, rgb(255, 0, 0), rgb(0, 0, 255))'
    );
    // test_computed_value(
    //   'background-image',
    //   'conic-gradient(from 45deg at center, red, blue)',
    //   'conic-gradient(from 45deg, rgb(255, 0, 0), rgb(0, 0, 255))'
    // );
    test_computed_value(
      'background-image',
      'conic-gradient(from 45deg at 50%, red, blue)',
      'conic-gradient(from 45deg, rgb(255, 0, 0), rgb(0, 0, 255))'
    );
    // test_computed_value(
    //   'background-image',
    //   'conic-gradient(from 45deg at 10px 10px, red, blue)',
    //   'conic-gradient(from 45deg at 10px 10px, rgb(255, 0, 0), rgb(0, 0, 255))'
    // );
    test_computed_value(
      'background-image',
      'conic-gradient(from -45deg, rgb(255, 0, 0), rgb(0, 0, 255))'
    );
    // test_computed_value(
    //   'background-image',
    //   'conic-gradient(from -45deg at center, red, blue)',
    //   'conic-gradient(from -45deg, rgb(255, 0, 0), rgb(0, 0, 255))'
    // );
    test_computed_value(
      'background-image',
      'conic-gradient(from -45deg at 50%, red, blue)',
      'conic-gradient(from -45deg, rgb(255, 0, 0), rgb(0, 0, 255))'
    );
    // test_computed_value(
    //   'background-image',
    //   'conic-gradient(from -45deg at 10px 10px, red, blue)',
    //   'conic-gradient(from -45deg at 10px 10px, rgb(255, 0, 0), rgb(0, 0, 255))'
    // );

  })
});

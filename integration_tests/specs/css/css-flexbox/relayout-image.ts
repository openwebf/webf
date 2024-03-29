/*auto generated*/
describe('relayout-image', () => {
  it('load', async (done) => {
    let log;
    let p;
    let image;
    let flexbox;
    let test;
    log = createElement('div', {
      id: 'log',
      style: {
        'box-sizing': 'border-box',
      },
    });
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`Test passes if a green 100x100 image is rendered.`)]
    );
    test = createElement(
      'div',
      {
        id: 'test',
        class: 'flexbox',
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        (flexbox = createElement(
          'div',
          {
            class: 'flexbox',
            style: {
              'box-sizing': 'border-box',
            },
          },
          [
            (image = createElement('img', {
              'data-expected-width': '100',
              'data-expected-height': '100',
              id: 'image',
              onload: 'imageLoaded()',
              style: {
                'box-sizing': 'border-box',
              },
            })),
          ]
        )),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(p);
    BODY.appendChild(test);

    await snapshot();

    requestAnimationFrame(async () => {
      image.src = 'assets/100x100-green.png';
      requestAnimationFrame(async () => {
        await snapshot(0.5);
        done();
      });
    });
  });
});

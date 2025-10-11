/*auto generated*/
describe('abspos-025', () => {
  it('ref', async (done) => {
    let p;
    let div;
    let img;
    p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        createText(`Test passes if there is a green square and `),
        createElement(
          'strong',
          {
            style: {
              'line-height': '1',
            },
          },
          [createText(`no red`)]
        ),
        createText(`.`),
      ]
    );
    div = createElement(
      'div',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {},
      },
      [
        img = createElement('img', {
          src: 'assets/swatch-green.png',
          alt: 'Image download support must be enabled',
          style: {
            left: '56px',
            position: 'relative',
            top: '12px',
            'vertical-align': 'top',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(div);

    onImageLoad(img, async () => {
      await snapshot(0.1);
      done();
    });
  });
});

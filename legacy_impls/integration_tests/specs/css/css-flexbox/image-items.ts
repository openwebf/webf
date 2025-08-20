/*auto generated*/
describe('image-items', () => {
  it('flake-001', async (done) => {
    let p;
    let referenceOverlappedRed;
    let div;
    let img;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(`Test passes if there is a filled green square and `),
        createElement(
          'strong',
          {
            style: {
              'box-sizing': 'border-box',
            },
          },
          [createText(`no red`)]
        ),
        createText(`.`),
      ]
    );
    referenceOverlappedRed = createElement('div', {
      id: 'reference-overlapped-red',
      style: {
        position: 'absolute',
        'background-color': 'red',
        width: '100px',
        height: '100px',
        'z-index': '-1',
        'box-sizing': 'border-box',
      },
    });
    div = createElement(
      'div',
      {
        style: {
          'box-sizing': 'border-box',
          display: 'flex',
          'flex-direction': 'column',
          height: '5px',
        },
      },
      [
        img = createElement('img', {
          src: 'assets/200x200-green.png',
          style: {
            'box-sizing': 'border-box',
            width: '100px',
            height: '100px',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(referenceOverlappedRed);
    BODY.appendChild(div);

    img.addEventListener('load', async () => {
      await snapshot(0.1);
      done();
    });
  });
});

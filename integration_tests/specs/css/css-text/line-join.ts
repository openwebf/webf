describe('Text Line Join', () => {
  it('works with pre span', async () => {
    let p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          direction: 'ltr',
        },
      },
      [
        createElement(
        'String',
        {
          style: {},
        },
        [createText(`Begin `)]
        ),
        createText(` pre text.`)
      ]
    );
    document.body.appendChild(p);
    await snapshot();
  });

  it('works with pre span and second line break', async () => {
    let p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          direction: 'ltr',
        },
      },
      [
        createElement(
        'Strong',
        {
          style: {},
        },
        [createText(`pre text, `)]
        ),
        createText(`this is very long long long line to build break. `)
      ]
    );
    document.body.appendChild(p);
    await snapshot();
  });

  it('works with pre span and first line break', async () => {
    let p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          direction: 'ltr',
        },
      },
      [
        createElement(
        'Strong',
        {
          style: {},
        },
        [
          createText(`Begin, his is very long long long line to build break, `),
          createText(`pre text.`),
        ]
        ),
      ]
    );
    document.body.appendChild(p);
    await snapshot();
  });

  it('works with more text join', async () => {
    let p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          direction: 'ltr',
        },
      },
      [
        createElement(
        'Strong',
        {
          style: {},
        },
        [
          createText(`A text with `),
          createText(`B text.`),
          createText(`C text. Join next text.`),
          createText(`pre text.`)],
        ),
      ]
    );
    document.body.appendChild(p);
    await snapshot();
  });

  it('works with inlineBlock', async () => {
    let p = createElement(
      'p',
      {
        xmlns: 'http://www.w3.org/1999/xhtml',
        style: {
          direction: 'ltr',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'green',
            height: '20px',
            width: '20px',
            'box-sizing': 'border-box',
            display: 'inline-block'
          },
        }),
        createElement (
        'Strong',
        {
          style: {},
        },
        [
          createText(`A text with `),
          createText(`B text.`),
          createText(`pre text.`)],
        ),
      ]
    );
    document.body.appendChild(p);
    await snapshot();
  });

  it('works with join two inline element', async () => {
    let div = createElement(
      'div',
      {
        style: {
          width: '100px',
          backgroundColor:'#ff2'
        },
      },
      [
        createElement('span', {
          style: {
          },
        },[createText(`ffffffffffff`)]),
        createElement('span', {
          style: {
          },
        },[createText(`In this article`),]),
      ]
    );
    document.body.appendChild(div);
    await snapshot();
  });

  it('works with join two inline element and img', async () => {
    let div = createElement(
      'div',
      {
        style: {
          width: '100px',
          backgroundColor:'#ff2'
        },
      },
      [
        createElement('span', {
          style: {
          },
        },[createText(`A`)]),
        createElement('span', {
          style: {
          },
        },[
          createElement('img', {
            src: 'assets/blue15x15.png',
            width: '15',
            height: '15',
            style: {
            },
          }),
          createText(`In this article`),
        ]),
      ]
    );
    document.body.appendChild(div);
    await snapshot();
  });

  it('works with join two inline element and img and more text', async () => {
    let div = createElement(
      'div',
      {
        style: {
          width: '100px',
          backgroundColor:'#ff2'
        },
      },
      [
        createElement('span', {
          style: {
          },
        },[createText(`AAA`)]),
        createElement('span', {
          style: {
          },
        },[
          createElement('img', {
            src: 'assets/blue15x15.png',
            width: '15',
            height: '15',
            style: {
            },
          }),
          createText(`In this article`),
        ]),
      ]
    );
    document.body.appendChild(div);
    await snapshot();
  });

  it('works with join two inline element and img and more text', async () => {
    let div = createElement(
      'div',
      {
        style: {
          width: '100px',
          backgroundColor:'#ff2'
        },
      },
      [
        createElement('span', {
          style: {
          },
        },[createText(`AAA`)]),
        createElement('span', {
          style: {
          },
        },[
          createText(`pre text`),
          createElement('img', {
            src: 'assets/blue15x15.png',
            width: '15',
            height: '15',
            style: {
            },
          }),
          createText(`In this article, test of in the picture`),
        ]),
      ]
    );
    document.body.appendChild(div);
    await snapshot();
  });

  it('works with join two inline element and block', async () => {
    let div = createElement(
      'div',
      {
        style: {
          width: '100px',
          backgroundColor:'#ff2'
        },
      },
      [
        createElement('span', {
          style: {
          },
        },[createText(`AAA`)]),
        createElement('span', {
          style: {
          },
        },[
          createText(`pre text`),
          createElement('div', {
            width: '15',
            height: '15',
            style: {
            },
          }),
          createText(`In this article, test of in the picture`),
        ]),
      ]
    );
    document.body.appendChild(div);
    await snapshot();
  });
});

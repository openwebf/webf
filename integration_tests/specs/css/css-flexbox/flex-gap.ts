/*auto generated*/
describe('css-flexbox gap', () => {
  it('gap-basic-row-direction', async () => {
    let p;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there are two blue rectangles separated by a 20px gap in a row layout.`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          display: 'flex',
          'flex-direction': 'row',
          gap: '20px',
          width: '300px',
          height: '100px',
          'background-color': '#f0f0f0',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'blue',
            width: '50px',
            height: '50px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'blue',
            width: '50px',
            height: '50px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    await snapshot();
  });

  it('gap-basic-column-direction', async () => {
    let p;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there are two blue rectangles separated by a 20px gap in a column layout.`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          gap: '20px',
          width: '100px',
          height: '200px',
          'background-color': '#f0f0f0',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'blue',
            width: '50px',
            height: '50px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'blue',
            width: '50px',
            height: '50px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    await snapshot();
  });

  it('gap-shorthand-different-values', async () => {
    let p;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there are four rectangles in a 2x2 grid with 30px vertical gap and 10px horizontal gap.`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          display: 'flex',
          'flex-direction': 'row',
          'flex-wrap': 'wrap',
          gap: '30px 10px', // row-gap column-gap
          width: '150px',
          height: '200px',
          'background-color': '#f0f0f0',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'red',
            width: '60px',
            height: '60px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            width: '60px',
            height: '60px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'blue',
            width: '60px',
            height: '60px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'yellow',
            width: '60px',
            height: '60px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    await snapshot();
  });

  it('row-gap-column-gap-separate', async () => {
    let p;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there are four rectangles in a 2x2 grid with 25px vertical gap and 15px horizontal gap.`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          display: 'flex',
          'flex-direction': 'row',
          'flex-wrap': 'wrap',
          'row-gap': '25px',
          'column-gap': '15px',
          width: '170px',
          height: '200px',
          'background-color': '#f0f0f0',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'red',
            width: '70px',
            height: '70px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            width: '70px',
            height: '70px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'blue',
            width: '70px',
            height: '70px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'yellow',
            width: '70px',
            height: '70px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    await snapshot();
  });

  it('gap-with-justify-content-center', async () => {
    let p;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there are three blue rectangles centered with 15px gaps between them.`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          display: 'flex',
          'flex-direction': 'row',
          'justify-content': 'center',
          gap: '15px',
          width: '300px',
          height: '100px',
          'background-color': '#f0f0f0',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'blue',
            width: '40px',
            height: '40px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'blue',
            width: '40px',
            height: '40px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'blue',
            width: '40px',
            height: '40px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    await snapshot();
  });

  it('gap-with-flex-grow', async () => {
    let p;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there are three rectangles with gaps, where the middle one expands to fill available space.`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          display: 'flex',
          'flex-direction': 'row',
          gap: '10px',
          width: '300px',
          height: '100px',
          'background-color': '#f0f0f0',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'red',
            width: '50px',
            height: '50px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            'flex-grow': '1',
            height: '50px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'blue',
            width: '50px',
            height: '50px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    await snapshot();
  });

  it('gap-zero-value', async () => {
    let p;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there are two blue rectangles touching each other (no gap).`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          display: 'flex',
          'flex-direction': 'row',
          gap: '0px',
          width: '200px',
          height: '100px',
          'background-color': '#f0f0f0',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'blue',
            width: '50px',
            height: '50px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'blue',
            width: '50px',
            height: '50px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    await snapshot();
  });

  it('gap-multiline-wrap', async () => {
    let p;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there are six rectangles in a 3x2 grid layout with proper gaps.`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          display: 'flex',
          'flex-direction': 'row',
          'flex-wrap': 'wrap',
          gap: '10px',
          width: '200px',
          height: '150px',
          'background-color': '#f0f0f0',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'red',
            width: '60px',
            height: '60px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            width: '60px',
            height: '60px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'blue',
            width: '60px',
            height: '60px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'yellow',
            width: '60px',
            height: '60px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'purple',
            width: '60px',
            height: '60px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'orange',
            width: '60px',
            height: '60px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    await snapshot();
  });

  it('gap-with-margins', async () => {
    let p;
    let flexbox;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if there are two blue rectangles with both gap and margin spacing.`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          display: 'flex',
          'flex-direction': 'row',
          gap: '20px',
          width: '300px',
          height: '100px',
          'background-color': '#f0f0f0',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'blue',
            width: '50px',
            height: '50px',
            margin: '10px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'blue',
            width: '50px',
            height: '50px',
            margin: '10px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    await snapshot();
  });
});
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

  it('inline-flex-height-with-gap', async () => {
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
          `Test passes if inline-flex container height includes gap spacing (height should be 150px total).`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          display: 'inline-flex',
          'flex-direction': 'column',
          gap: '20px',
          'background-color': '#e0e0e0',
          border: '1px solid red',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'blue',
            width: '80px',
            height: '50px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            width: '80px',
            height: '50px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'orange',
            width: '80px',
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

  it('flex-height-with-row-gap', async () => {
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
          `Test passes if flex container height includes row-gap spacing (height should be 170px total).`
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
          'row-gap': '15px',
          'background-color': '#d0d0d0',
          border: '2px solid blue',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'red',
            width: '100px',
            height: '40px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'purple',
            width: '100px',
            height: '40px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'cyan',
            width: '100px',
            height: '40px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'yellow',
            width: '100px',
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

  it('inline-flex-width-with-column-gap', async () => {
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
          `Test passes if inline-flex container width includes column-gap spacing (width should be 215px total).`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          display: 'inline-flex',
          'flex-direction': 'row',
          'column-gap': '25px',
          'background-color': '#c0c0c0',
          border: '1px solid green',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'blue',
            width: '60px',
            height: '70px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'red',
            width: '60px',
            height: '70px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            width: '60px',
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

  it('multiline-flex-with-cross-axis-gap', async () => {
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
          `Test passes if multiline flex includes cross-axis gap (height should be 100px: 40+20+40).`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          display: 'inline-flex',
          'flex-wrap': 'wrap',
          width: '150px',
          gap: '20px 10px', // row-gap column-gap
          'background-color': '#b0b0b0',
          border: '1px solid purple',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'blue',
            width: '60px',
            height: '40px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'red',
            width: '60px',
            height: '40px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            width: '60px',
            height: '40px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'yellow',
            width: '60px',
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

  it('gap-with-padding-height-calculation', async () => {
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
          `Test passes if flex container height includes both gap and padding (total height: 10+30+15+30+15+30+10=140px).`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          display: 'inline-flex',
          'flex-direction': 'column',
          gap: '15px',
          padding: '10px',
          'background-color': '#a0a0a0',
          border: '1px solid orange',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'red',
            width: '80px',
            height: '30px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'blue',
            width: '80px',
            height: '30px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'green',
            width: '80px',
            height: '30px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox);

    await snapshot();
  });

  it('gap-single-item-no-effect', async () => {
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
          `Test passes if single item container height equals item height (50px) despite large gap value.`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          display: 'inline-flex',
          'flex-direction': 'column',
          gap: '100px', // Large gap should have no effect
          'background-color': '#909090',
          border: '1px solid red',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'navy',
            width: '100px',
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

  it('gap-with-different-units', async () => {
    let p;
    let flexbox1;
    let flexbox2;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [
        createText(
          `Test passes if containers show proper heights with em and rem gap units.`
        ),
      ]
    );
    flexbox1 = createElement(
      'div',
      {
        id: 'flexbox1',
        style: {
          display: 'inline-flex',
          'flex-direction': 'column',
          gap: '1em', // 20px with font-size: 20px
          'font-size': '20px',
          'background-color': '#808080',
          border: '1px solid blue',
          'margin-right': '20px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'indigo',
            width: '90px',
            height: '35px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'violet',
            width: '90px',
            height: '35px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    flexbox2 = createElement(
      'div',
      {
        id: 'flexbox2',
        style: {
          display: 'inline-flex',
          'flex-direction': 'column',
          gap: '2rem', // 32px with root font-size: 16px
          'background-color': '#707070',
          border: '1px solid green',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'lime',
            width: '90px',
            height: '30px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'aqua',
            width: '90px',
            height: '30px',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(flexbox1);
    BODY.appendChild(flexbox2);

    await snapshot();
  });

  it('explicit-height-overrides-content-with-gap', async () => {
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
          `Test passes if container respects explicit height (200px) even with gap that would make content smaller.`
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
          gap: '15px',
          height: '200px', // Explicit height
          width: '120px',
          'background-color': '#606060',
          border: '2px solid black',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'teal',
            width: '100px',
            height: '40px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'olive',
            width: '100px',
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

  it('negative-gap-treated-as-zero', async () => {
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
          `Test passes if negative gap is treated as zero (height should be 90px: 45+45).`
        ),
      ]
    );
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          display: 'inline-flex',
          'flex-direction': 'column',
          gap: '-20px', // Negative gap should be treated as 0
          'background-color': '#505050',
          border: '1px solid cyan',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          style: {
            'background-color': 'gold',
            width: '80px',
            height: '45px',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          style: {
            'background-color': 'silver',
            width: '80px',
            height: '45px',
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
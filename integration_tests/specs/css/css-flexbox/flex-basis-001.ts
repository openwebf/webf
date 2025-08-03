describe('CSS Flexbox flex-basis', () => {
  // Test 1: Basic flex-basis functionality
  it('001-flex-basis-basic', async () => {
    let container;
    let item1, item2, item3;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        (item1 = createElement('div', {
          style: {
            'flex-basis': '100px',
            height: '100px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('100px')])),
        (item2 = createElement('div', {
          style: {
            'flex-basis': '150px',
            height: '100px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('150px')])),
        (item3 = createElement('div', {
          style: {
            'flex-basis': '50px',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('50px')])),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 2: flex-basis auto
  it('002-flex-basis-auto', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '350px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            'flex-basis': 'auto',
            padding: '0 20px',
            height: '100px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('auto content')]),
        createElement('div', {
          style: {
            'flex-basis': 'auto',
            padding: '0 30px',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('longer auto content here')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 3: flex-basis with percentage
  it('003-flex-basis-percentage', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            'flex-basis': '30%',
            height: '100px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('30%')]),
        createElement('div', {
          style: {
            'flex-basis': '40%',
            height: '100px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('40%')]),
        createElement('div', {
          style: {
            'flex-basis': '30%',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('30%')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 4: flex-basis in column direction
  it('004-flex-basis-column', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '200px',
          height: '300px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '100%',
            'flex-basis': '100px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('100px')]),
        createElement('div', {
          style: {
            width: '100%',
            'flex-basis': '150px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '150px',
          },
        }, [createText('150px')]),
        createElement('div', {
          style: {
            width: '100%',
            'flex-basis': '50px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '50px',
          },
        }, [createText('50px')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 5: flex-basis 0
  it('005-flex-basis-zero', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            'flex-basis': '0',
            'flex-grow': '1',
            height: '100px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('basis-0')]),
        createElement('div', {
          style: {
            'flex-basis': '0',
            'flex-grow': '2',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('basis-0-grow-2')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 6: flex-basis with min/max constraints
  it('006-flex-basis-min-max', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '350px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            'flex-basis': '100px',
            'min-width': '120px',
            height: '100px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('min-120')]),
        createElement('div', {
          style: {
            'flex-basis': '150px',
            'max-width': '100px',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('max-100')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 7: flex-basis with content keyword
  it('007-flex-basis-content', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '350px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            'flex-basis': 'content',
            padding: '0 10px',
            height: '100px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('content')]),
        createElement('div', {
          style: {
            'flex-basis': 'content',
            padding: '0 10px',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('longer content text')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 8: flex-basis with flex-grow
  xit('008-flex-basis-with-grow', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '350px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            'flex-basis': '50px',
            'flex-grow': '1',
            height: '100px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('50-grow')]),
        createElement('div', {
          style: {
            'flex-basis': '100px',
            'flex-grow': '1',
            height: '100px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('100-grow')]),
        createElement('div', {
          style: {
            'flex-basis': '50px',
            'flex-grow': '0',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('50-no-grow')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 9: flex-basis with flex-shrink
  xit('009-flex-basis-with-shrink', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '200px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            'flex-basis': '150px',
            'flex-shrink': '1',
            height: '100px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('150-shrink')]),
        createElement('div', {
          style: {
            'flex-basis': '100px',
            'flex-shrink': '2',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('100-shrink-2')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 10: flex-basis with wrapped items
  it('010-flex-basis-wrap', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '200px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            'flex-basis': '120px',
            height: '80px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('120px')]),
        createElement('div', {
          style: {
            'flex-basis': '120px',
            height: '80px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('120px')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 11: flex-basis dynamic changes
  it('011-flex-basis-dynamic', async () => {
    let container;
    let item1, item2;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        (item1 = createElement('div', {
          style: {
            'flex-basis': '100px',
            height: '100px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('dynamic')])),
        (item2 = createElement('div', {
          style: {
            'flex-basis': '100px',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('static')])),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
    
    // Change flex-basis
    item1.style['flex-basis'] = '150px';
    await snapshot();
  });

  // Test 12: flex-basis with box-sizing
  xit('012-flex-basis-box-sizing', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            'flex-basis': '100px',
            padding: '0 10px',
            border: '5px solid darkred',
            'box-sizing': 'border-box',
            height: '100px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '70px',
          },
        }, [createText('border-box')]),
        createElement('div', {
          style: {
            'flex-basis': '100px',
            padding: '0 10px',
            border: '5px solid darkblue',
            'box-sizing': 'content-box',
            height: '80px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '80px',
          },
        }, [createText('content')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 13: flex-basis with negative margins
  it('013-flex-basis-negative-margins', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            'flex-basis': '100px',
            'margin-right': '-20px',
            height: '100px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('100px')]),
        createElement('div', {
          style: {
            'flex-basis': '100px',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('100px')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 14: flex-basis with calc()
  it('014-flex-basis-calc', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            'flex-basis': 'calc(50% - 20px)',
            height: '100px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('calc')]),
        createElement('div', {
          style: {
            'flex-basis': 'calc(50% + 20px)',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('calc')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 15: flex-basis with gap
  it('015-flex-basis-with-gap', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          gap: '20px',
          width: '320px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            'flex-basis': '100px',
            height: '100px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('100px')]),
        createElement('div', {
          style: {
            'flex-basis': '100px',
            height: '100px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('100px')]),
        createElement('div', {
          style: {
            'flex-basis': '80px',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('80px')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 16: flex-basis with align-self
  it('016-flex-basis-align-self', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'align-items': 'flex-start',
          width: '300px',
          height: '150px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            'flex-basis': '100px',
            height: '50px',
            'align-self': 'stretch',
            'background-color': 'red',
            'text-align': 'center',
          },
        }, [createText('stretch')]),
        createElement('div', {
          style: {
            'flex-basis': '100px',
            height: '50px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '50px',
          },
        }, [createText('normal')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 17: flex-basis with replaced elements
  xit('017-flex-basis-replaced', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('img', {
          src: 'assets/100x100-green.png',
          style: {
            'flex-basis': '80px',
            height: '80px',
          },
        }),
        createElement('div', {
          style: {
            'flex-basis': '150px',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('150px')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 18: flex-basis with overflow
  xit('018-flex-basis-overflow', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '200px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            'flex-basis': '150px',
            'flex-shrink': '0',
            height: '100px',
            overflow: 'hidden',
            'background-color': 'red',
            padding: '10px',
            'box-sizing': 'border-box',
          },
        }, [createText('This is some text that might overflow')]),
        createElement('div', {
          style: {
            'flex-basis': '100px',
            'flex-shrink': '0',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('100px')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 19: flex-basis with different units
  it('019-flex-basis-units', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '350px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
          'font-size': '16px',
        },
      },
      [
        createElement('div', {
          style: {
            'flex-basis': '5em',
            height: '100px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('5em')]),
        createElement('div', {
          style: {
            'flex-basis': '10rem',
            height: '100px',
            'background-color': 'green',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('10rem')]),
        createElement('div', {
          style: {
            'flex-basis': '15vw',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('15vw')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test 20: flex-basis priority over width
  it('020-flex-basis-vs-width', async () => {
    let container;
    container = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': '#f0f0f0',
          border: '1px solid black',
        },
      },
      [
        createElement('div', {
          style: {
            width: '200px',
            'flex-basis': '100px',
            height: '100px',
            'background-color': 'red',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('basis-100')]),
        createElement('div', {
          style: {
            width: '50px',
            'flex-basis': '150px',
            height: '100px',
            'background-color': 'blue',
            'text-align': 'center',
            'line-height': '100px',
          },
        }, [createText('basis-150')]),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });
});
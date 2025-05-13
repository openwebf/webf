/*auto generated*/
describe('flex-margin', () => {
  it('no-collapse', async () => {
    let p;
    let redBox;
    let box1;
    let box2;
    let container;
    p = createElement(
      'p',
      {
        style: {
          'box-sizing': 'border-box',
        },
      },
      [createText(`The test passes if there are two green boxes and no red.`)]
    );
    redBox = createElement('div', {
      id: 'red-box',
      style: {
        position: 'absolute',
        top: '350px',
        left: '10px',
        width: '100px',
        height: '100px',
        'background-color': 'red',
        'box-sizing': 'border-box',
      },
    });
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          position: 'absolute',
          top: '100px',
          left: '10px',
          width: '200px',
          height: '300px',
          'box-sizing': 'border-box',
        },
      },
      [
        (box1 = createElement('div', {
          id: 'box1',
          class: 'box',
          style: {
            width: '100px',
            height: '100px',
            'background-color': 'green',
            flex: 'none',
            margin: '50px 0',
            'box-sizing': 'border-box',
          },
        })),
        (box2 = createElement('div', {
          id: 'box2',
          class: 'box',
          style: {
            width: '100px',
            height: '100px',
            'background-color': 'green',
            flex: 'none',
            margin: '50px 0',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(p);
    BODY.appendChild(redBox);
    BODY.appendChild(container);

    await snapshot();
  });

  it('margin-auto-centering', async () => {
    let box;
    let container;
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          background: '#f0f0f0',
          margin: '10px',
          'box-sizing': 'border-box',
        },
      },
      [
        (box = createElement('div', {
          id: 'box',
          style: {
            width: '100px',
            height: '60px',
            background: '#007bff',
            margin: 'auto',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });

  it('horizontal-margin-distribution', async () => {
    let box1;
    let box2;
    let box3;
    let container;
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          display: 'flex',
          width: '400px',
          height: '100px',
          background: '#f0f0f0',
          margin: '10px',
          'box-sizing': 'border-box',
        },
      },
      [
        (box1 = createElement('div', {
          id: 'box1',
          style: {
            width: '80px',
            height: '60px',
            background: '#007bff',
            margin: '20px 10px',
            'box-sizing': 'border-box',
          },
        })),
        (box2 = createElement('div', {
          id: 'box2',
          style: {
            width: '80px',
            height: '60px',
            background: '#28a745',
            margin: '20px 15px',
            'box-sizing': 'border-box',
          },
        })),
        (box3 = createElement('div', {
          id: 'box3',
          style: {
            width: '80px',
            height: '60px',
            background: '#dc3545',
            margin: '20px 10px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });

  it('margin-and-flex-grow', async () => {
    let box1;
    let box2;
    let container;
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          display: 'flex',
          width: '400px',
          height: '100px',
          background: '#f0f0f0',
          margin: '10px',
          'box-sizing': 'border-box',
        },
      },
      [
        (box1 = createElement('div', {
          id: 'box1',
          style: {
            width: '100px',
            height: '60px',
            background: '#007bff',
            margin: '20px 10px',
            flex: '1',
            'box-sizing': 'border-box',
          },
        })),
        (box2 = createElement('div', {
          id: 'box2',
          style: {
            width: '100px',
            height: '60px',
            background: '#28a745',
            margin: '20px 10px',
            flex: '2',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });

  it('negative-margins', async () => {
    let box1;
    let box2;
    let box3;
    let container;
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          display: 'flex',
          width: '400px',
          height: '100px',
          background: '#f0f0f0',
          margin: '10px',
          'box-sizing': 'border-box',
        },
      },
      [
        (box1 = createElement('div', {
          id: 'box1',
          style: {
            width: '100px',
            height: '60px',
            background: '#007bff',
            margin: '20px -10px',
            'box-sizing': 'border-box',
          },
        })),
        (box2 = createElement('div', {
          id: 'box2',
          style: {
            width: '100px',
            height: '60px',
            background: '#28a745',
            margin: '20px -10px',
            'box-sizing': 'border-box',
          },
        })),
        (box3 = createElement('div', {
          id: 'box3',
          style: {
            width: '100px',
            height: '60px',
            background: '#dc3545',
            margin: '20px 10px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });

  it('column-direction-margins', async () => {
    let box1;
    let box2;
    let box3;
    let container;
    container = createElement(
      'div',
      {
        id: 'container',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '200px',
          height: '400px',
          background: '#f0f0f0',
          margin: '10px',
          'box-sizing': 'border-box',
        },
      },
      [
        (box1 = createElement('div', {
          id: 'box1',
          style: {
            width: '100px',
            height: '60px',
            background: '#007bff',
            margin: '10px 20px',
            'box-sizing': 'border-box',
          },
        })),
        (box2 = createElement('div', {
          id: 'box2',
          style: {
            width: '100px',
            height: '60px',
            background: '#28a745',
            margin: '15px 20px',
            'box-sizing': 'border-box',
          },
        })),
        (box3 = createElement('div', {
          id: 'box3',
          style: {
            width: '100px',
            height: '60px',
            background: '#dc3545',
            margin: '10px 20px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });
});

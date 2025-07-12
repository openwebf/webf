/*auto generated*/
describe('css-flexbox order', () => {

  it('basic-order-reordering', async () => {
    let flexbox;
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          display: 'flex',
          'flex-direction': 'row',
          width: '300px',
          height: '100px',
          'background-color': '#f0f0f0',
        },
      },
      [
        createElement('div', {
          style: {
            order: '3',
            width: '80px',
            height: '80px',
            'background-color': 'blue',
          },
        }, [createText('First')]),
        createElement('div', {
          style: {
            order: '1',
            width: '80px',
            height: '80px',
            'background-color': 'red',
          },
        }, [createText('Second')]),
        createElement('div', {
          style: {
            order: '2',
            width: '80px',
            height: '80px',
            'background-color': 'green',
          },
        }, [createText('Third')]),
      ]
    );

    BODY.appendChild(flexbox);

    await snapshot();
  });

  it('negative-order-values', async () => {
    let flexbox;
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          display: 'flex',
          'flex-direction': 'row',
          width: '250px',
          height: '80px',
          'background-color': '#e0e0e0',
        },
      },
      [
        createElement('div', {
          style: {
            order: '0',
            width: '60px',
            height: '60px',
            'background-color': 'orange',
          },
        }, [createText('A')]),
        createElement('div', {
          style: {
            order: '-1',
            width: '60px',
            height: '60px',
            'background-color': 'purple',
          },
        }, [createText('B')]),
        createElement('div', {
          style: {
            order: '-2',
            width: '60px',
            height: '60px',
            'background-color': 'cyan',
          },
        }, [createText('C')]),
      ]
    );

    BODY.appendChild(flexbox);

    await snapshot();
  });

  it('order-with-column-direction', async () => {
    let flexbox;
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '120px',
          height: '280px',
          'background-color': '#d0d0d0',
        },
      },
      [
        createElement('div', {
          style: {
            order: '3',
            width: '100px',
            height: '70px',
            'background-color': 'lightblue',
          },
        }, [createText('Top')]),
        createElement('div', {
          style: {
            order: '1',
            width: '100px',
            height: '70px',
            'background-color': 'lightcoral',
          },
        }, [createText('Middle')]),
        createElement('div', {
          style: {
            order: '2',
            width: '100px',
            height: '70px',
            'background-color': 'lightgreen',
          },
        }, [createText('Bottom')]),
      ]
    );

    BODY.appendChild(flexbox);

    await snapshot();
  });

  it('order-with-flex-wrap', async () => {
    let flexbox;
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          display: 'flex',
          'flex-wrap': 'wrap',
          width: '200px',
          height: '180px',
          'background-color': '#f5f5f5',
        },
      },
      [
        createElement('div', {
          style: {
            order: '4',
            width: '90px',
            height: '70px',
            'background-color': 'red',
          },
        }, [createText('1')]),
        createElement('div', {
          style: {
            order: '2',
            width: '90px',
            height: '70px',
            'background-color': 'green',
          },
        }, [createText('2')]),
        createElement('div', {
          style: {
            order: '1',
            width: '90px',
            height: '70px',
            'background-color': 'blue',
          },
        }, [createText('3')]),
        createElement('div', {
          style: {
            order: '3',
            width: '90px',
            height: '70px',
            'background-color': 'yellow',
          },
        }, [createText('4')]),
      ]
    );

    BODY.appendChild(flexbox);

    await snapshot();
  });

  it('order-with-same-values', async () => {
    let flexbox;
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          display: 'flex',
          'flex-direction': 'row',
          width: '320px',
          height: '90px',
          'background-color': '#eeeeee',
        },
      },
      [
        createElement('div', {
          style: {
            order: '1',
            width: '70px',
            height: '70px',
            'background-color': 'mediumorchid',
          },
        }, [createText('First')]),
        createElement('div', {
          style: {
            order: '1',
            width: '70px',
            height: '70px',
            'background-color': 'mediumseagreen',
          },
        }, [createText('Second')]),
        createElement('div', {
          style: {
            order: '1',
            width: '70px',
            height: '70px',
            'background-color': 'mediumpurple',
          },
        }, [createText('Third')]),
      ]
    );

    BODY.appendChild(flexbox);

    await snapshot();
  });

  it('order-with-large-values', async () => {
    let flexbox;
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          display: 'flex',
          'flex-direction': 'row',
          width: '220px',
          height: '80px',
          'background-color': '#dddddd',
        },
      },
      [
        createElement('div', {
          style: {
            order: '999',
            width: '60px',
            height: '60px',
            'background-color': 'crimson',
          },
        }, [createText('A')]),
        createElement('div', {
          style: {
            order: '-999',
            width: '60px',
            height: '60px',
            'background-color': 'darkcyan',
          },
        }, [createText('B')]),
        createElement('div', {
          style: {
            order: '0',
            width: '60px',
            height: '60px',
            'background-color': 'gold',
          },
        }, [createText('C')]),
      ]
    );

    BODY.appendChild(flexbox);

    await snapshot();
  });

  it('order-with-flex-grow', async () => {
    let flexbox;
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          display: 'flex',
          'flex-direction': 'row',
          width: '400px',
          height: '100px',
          'background-color': '#fafafa',
        },
      },
      [
        createElement('div', {
          style: {
            order: '2',
            'flex-grow': '2',
            height: '80px',
            'background-color': 'lightpink',
          },
        }, [createText('Grows 2x')]),
        createElement('div', {
          style: {
            order: '1',
            'flex-grow': '1',
            height: '80px',
            'background-color': 'lightsteelblue',
          },
        }, [createText('Grows 1x')]),
        createElement('div', {
          style: {
            order: '3',
            width: '100px',
            height: '80px',
            'background-color': 'lightyellow',
          },
        }, [createText('Fixed')]),
      ]
    );

    BODY.appendChild(flexbox);

    await snapshot();
  });

  it('order-mixed-with-default', async () => {
    let flexbox;
    flexbox = createElement(
      'div',
      {
        id: 'flexbox',
        style: {
          display: 'flex',
          'flex-direction': 'row',
          width: '350px',
          height: '100px',
          'background-color': '#f8f8f8',
        },
      },
      [
        createElement('div', {
          style: {
            order: '1',
            width: '80px',
            height: '80px',
            'background-color': 'coral',
          },
        }, [createText('Order 1')]),
        createElement('div', {
          style: {
            // No order specified (default 0)
            width: '80px',
            height: '80px',
            'background-color': 'khaki',
          },
        }, [createText('Default')]),
        createElement('div', {
          style: {
            order: '-1',
            width: '80px',
            height: '80px',
            'background-color': 'plum',
          },
        }, [createText('Order -1')]),
      ]
    );

    BODY.appendChild(flexbox);

    await snapshot();
  });
});
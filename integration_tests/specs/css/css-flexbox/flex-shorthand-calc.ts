describe('flex shorthand with calc()', () => {
  it('should accept calc() as flex-basis in flex shorthand', async () => {
    let flexbox;
    let item1;
    let item2;
    flexbox = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': 'red',
          'box-sizing': 'border-box',
        },
      },
      [
        (item1 = createElement('div', {
          style: {
            flex: '0 1 calc(100% - 100px)',
            height: '100px',
            'background-color': 'green',
            'box-sizing': 'border-box',
          },
        })),
        (item2 = createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            'background-color': 'blue',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(flexbox);

    await snapshot();
  });

  it('should accept calc() with px values as flex-basis', async () => {
    let flexbox;
    let item1;
    let item2;
    flexbox = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': 'red',
          'box-sizing': 'border-box',
        },
      },
      [
        (item1 = createElement('div', {
          style: {
            flex: '0 0 calc(150px + 50px)',
            height: '100px',
            'background-color': 'green',
            'box-sizing': 'border-box',
          },
        })),
        (item2 = createElement('div', {
          style: {
            flex: '0 0 calc(150px - 50px)',
            height: '100px',
            'background-color': 'blue',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(flexbox);

    await snapshot();
  });

  it('should accept calc() with grow and shrink in flex shorthand', async () => {
    let flexbox;
    let item1;
    let item2;
    flexbox = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '300px',
          height: '100px',
          'background-color': 'red',
          'box-sizing': 'border-box',
        },
      },
      [
        (item1 = createElement('div', {
          style: {
            flex: '1 1 calc(50% - 10px)',
            height: '100px',
            'background-color': 'green',
            'box-sizing': 'border-box',
          },
        })),
        (item2 = createElement('div', {
          style: {
            flex: '1 1 calc(50% - 10px)',
            height: '100px',
            'background-color': 'blue',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(flexbox);

    await snapshot();
  });

  it('should layout correctly with flex calc basis in column direction', async () => {
    let flexbox;
    let item1;
    let item2;
    flexbox = createElement(
      'div',
      {
        style: {
          display: 'flex',
          'flex-direction': 'column',
          width: '100px',
          height: '300px',
          'background-color': 'red',
          'box-sizing': 'border-box',
        },
      },
      [
        (item1 = createElement('div', {
          style: {
            flex: '0 0 calc(100% - 100px)',
            width: '100px',
            'background-color': 'green',
            'box-sizing': 'border-box',
          },
        })),
        (item2 = createElement('div', {
          style: {
            width: '100px',
            height: '100px',
            'background-color': 'blue',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );
    BODY.appendChild(flexbox);

    await snapshot();
  });
});

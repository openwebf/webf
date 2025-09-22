/*auto generated*/
describe('overfow-outside', () => {
  it('padding htb', async () => {
    const container = createElement(
      'div',
      {
        class: 'container htb',
        style: {
          position: 'relative',
          display: 'inline-block',
          border: 'rgba(0,0,0,0.5) solid 5px',
          'border-width': '0px 0px 50px 80px',
          overflow: 'auto',
          width: '200px',
          height: '200px',
          background: 'gray',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          class: 'target',
          style: {
            position: 'absolute',
            width: '1000px',
            height: '1000px',
            background: 'red',
            'box-sizing': 'border-box',
            top: '-1000px',
          },
        }),
        createText('htb'),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  it('padding htb rtl', async () => {
    const container = createElement(
      'div',
      {
        class: 'container htb rtl',
        style: {
          position: 'relative',
          display: 'inline-block',
          border: 'rgba(0,0,0,0.5) solid 5px',
          'border-width': '0px 0px 50px 80px',
          overflow: 'auto',
          width: '200px',
          height: '200px',
          background: 'gray',
          direction: 'rtl',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          class: 'target',
          style: {
            position: 'absolute',
            width: '1000px',
            height: '1000px',
            background: 'red',
            'box-sizing': 'border-box',
            right: '-1000px',
          },
        }),
        createText('htb rtl'),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  it('padding vrl', async () => {
    const container = createElement(
      'div',
      {
        class: 'container vrl',
        style: {
          position: 'relative',
          display: 'inline-block',
          border: 'rgba(0,0,0,0.5) solid 5px',
          'border-width': '0px 0px 50px 80px',
          overflow: 'auto',
          width: '200px',
          height: '200px',
          background: 'gray',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          class: 'target',
          style: {
            position: 'absolute',
            width: '1000px',
            height: '1000px',
            background: 'red',
            'box-sizing': 'border-box',
            top: '-1000px',
          },
        }),
        createText('vrl'),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  it('padding vrl rtl', async () => {
    const container = createElement(
      'div',
      {
        class: 'container vrl rtl',
        style: {
          position: 'relative',
          display: 'inline-block',
          border: 'rgba(0,0,0,0.5) solid 5px',
          'border-width': '0px 0px 50px 80px',
          overflow: 'auto',
          width: '200px',
          height: '200px',
          background: 'gray',
          direction: 'rtl',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          class: 'target',
          style: {
            position: 'absolute',
            width: '1000px',
            height: '1000px',
            background: 'red',
            'box-sizing': 'border-box',
            bottom: '-1000px',
          },
        }),
        createText('vrl rtl'),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  it('padding vlr', async () => {
    const container = createElement(
      'div',
      {
        class: 'container vlr',
        style: {
          position: 'relative',
          display: 'inline-block',
          border: 'rgba(0,0,0,0.5) solid 5px',
          'border-width': '0px 0px 50px 80px',
          overflow: 'auto',
          width: '200px',
          height: '200px',
          background: 'gray',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          class: 'target',
          style: {
            position: 'absolute',
            width: '1000px',
            height: '1000px',
            background: 'red',
            'box-sizing': 'border-box',
            top: '-1000px',
          },
        }),
        createText('vlr'),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  it('padding vlr rtl', async () => {
    const container = createElement(
      'div',
      {
        class: 'container vlr rtl',
        style: {
          position: 'relative',
          display: 'inline-block',
          border: 'rgba(0,0,0,0.5) solid 5px',
          'border-width': '0px 0px 50px 80px',
          overflow: 'auto',
          width: '200px',
          height: '200px',
          background: 'gray',
          direction: 'rtl',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          class: 'target',
          style: {
            position: 'absolute',
            width: '1000px',
            height: '1000px',
            background: 'red',
            'box-sizing': 'border-box',
            left: '-1000px',
          },
        }),
        createText('vlr rtl'),
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });
});

/*auto generated*/
describe('flex algotithm', () => {
  it('001', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      {
        class: 'flexbox',
        style: { display: 'flex', width: '600px', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box' },
      },
      [
        createElement('div', { 'data-expected-width': '100', class: 'flex1-0-0', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1 0 0px', 'box-sizing': 'border-box', 'max-width': '100px' } }),
        createElement('div', { 'data-expected-width': '250', class: 'flex1-0-0', style: { height: '20px', border: '0', 'background-color': 'green', flex: '1 0 0px', 'box-sizing': 'border-box' } }),
        createElement('div', { 'data-expected-width': '250', class: 'flex1-0-0', style: { height: '20px', border: '0', 'background-color': 'red', flex: '1 0 0px', 'box-sizing': 'border-box' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('002', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      {
        class: 'flexbox',
        style: { display: 'flex', width: '600px', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box' },
      },
      [
        createElement('div', { 'data-expected-width': '50', class: 'flex1-0-0', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1 0 0px', 'box-sizing': 'border-box', 'max-width': '50px' } }),
        createElement('div', { 'data-expected-width': '300', style: { height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box', flex: '4 0 0', 'max-width': '300px' } }),
        createElement('div', { 'data-expected-width': '250', style: { height: '20px', border: '0', 'background-color': 'red', 'box-sizing': 'border-box', flex: '1 0 0' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('003', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      {
        class: 'flexbox',
        style: { display: 'flex', width: '600px', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box' },
      },
      [
        createElement('div', { 'data-expected-width': '100', class: 'flex1-0-0', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1 0 0px', 'box-sizing': 'border-box', 'max-width': '100px' } }),
        createElement('div', { 'data-expected-width': '300', style: { height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box', flex: '1 0 200px', 'max-width': '300px' } }),
        createElement('div', { 'data-expected-width': '200', class: 'flex1-0-0', style: { height: '20px', border: '0', 'background-color': 'red', flex: '1 0 0px', 'box-sizing': 'border-box' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('004', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      {
        class: 'flexbox',
        style: { display: 'flex', width: '600px', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box' },
      },
      [
        createElement('div', { 'data-expected-width': '350', style: { height: '20px', border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', flex: '1 1 400px', 'min-width': '350px' } }),
        createElement('div', { 'data-expected-width': '250', style: { height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box', flex: '1 1 400px' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('005', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      {
        class: 'flexbox',
        style: { display: 'flex', width: '600px', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box' },
      },
      [
        createElement('div', { 'data-expected-width': '350', style: { height: '20px', border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', flex: '1 1 400px', 'min-width': '350px' } }),
        createElement('div', { 'data-expected-width': '300', style: { height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box', flex: '2 0 300px', 'max-width': '300px' } }),
        createElement('div', { 'data-expected-width': '0', class: 'flex1-0-0', style: { height: '20px', border: '0', 'background-color': 'red', flex: '1 0 0px', 'box-sizing': 'border-box' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('006', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      {
        class: 'flexbox',
        style: { display: 'flex', width: '600px', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box' },
      },
      [
        createElement('div', { 'data-expected-width': '100', 'data-offset-x': '0', class: 'flex1-0-0', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1 0 0px', 'box-sizing': 'border-box', margin: '0 auto', 'max-width': '100px' } }),
        createElement('div', { 'data-expected-width': '333', 'data-offset-x': '100', style: { height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box', flex: '2 0 0' } }),
        createElement('div', { 'data-expected-width': '167', 'data-offset-x': '433', class: 'flex1-0-0', style: { height: '20px', border: '0', 'background-color': 'red', flex: '1 0 0px', 'box-sizing': 'border-box' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('007', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      {
        class: 'flexbox',
        style: { display: 'flex', width: '600px', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box' },
      },
      [
        createElement('div', { 'data-expected-width': '500', class: 'flex1-0-0', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1 0 0px', 'box-sizing': 'border-box', 'min-width': '300px' } }),
        createElement('div', { 'data-expected-width': '100', style: { height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box', flex: '1 0 50%', 'max-width': '100px' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('008', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '200px', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '150', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1', 'box-sizing': 'border-box', 'min-width': '150px' } }),
        createElement('div', { 'data-expected-width': '50', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'green', flex: '1', 'box-sizing': 'border-box', 'max-width': '90px' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('009', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '200px', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '150', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1', 'box-sizing': 'border-box', 'min-width': '120px' } }),
        createElement('div', { 'data-expected-width': '50', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'green', flex: '1', 'box-sizing': 'border-box', 'max-width': '50px' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('010', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '200px', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '100', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1', 'box-sizing': 'border-box', 'min-width': '100px' } }),
        createElement('div', { 'data-expected-width': '100', class: 'flex3', style: { height: '20px', border: '0', 'background-color': 'green', flex: '3', 'box-sizing': 'border-box' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('011', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '200px', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '150', style: { height: '20px', border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', flex: '1 50px', 'min-width': '100px' } }),
        createElement('div', { 'data-expected-width': '50', style: { height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box', flex: '1 100px', 'max-width': '50px' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('012', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '80', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1', 'box-sizing': 'border-box' } }),
        createElement('div', { 'data-expected-width': '160', class: 'flex2', style: { height: '20px', border: '0', 'background-color': 'green', flex: '2', 'box-sizing': 'border-box' } }),
        createElement('div', { 'data-expected-width': '360', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'red', flex: '1', 'box-sizing': 'border-box', 'min-width': '360px' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  // with-margins series
  it('013', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '200', class: 'flex1-0-0', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1 0 0px', 'box-sizing': 'border-box' } }),
        createElement('div', { 'data-expected-width': '100', 'data-offset-x': '250', class: 'flex-none', style: { '-webkit-flex': 'none', flex: 'none', height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box', width: '100px', margin: '0 50px' } }),
        createElement('div', { 'data-expected-width': '200', 'data-offset-x': '400', class: 'flex1-0-0', style: { height: '20px', border: '0', 'background-color': 'red', flex: '1 0 0px', 'box-sizing': 'border-box' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('014', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { 'data-expected-height': '120', class: 'flexbox', style: { display: 'flex', width: '600px', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '200', 'data-offset-y': '50', class: 'flex1-0-0', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1 0 0px', 'box-sizing': 'border-box', margin: '50px 0' } }),
        createElement('div', { 'data-expected-width': '100', 'data-offset-x': '250', class: 'flex-none', style: { '-webkit-flex': 'none', flex: 'none', height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box', width: '100px', margin: '0 50px' } }),
        createElement('div', { 'data-expected-width': '200', 'data-offset-x': '400', class: 'flex1-0-0', style: { height: '20px', border: '0', 'background-color': 'red', flex: '1 0 0px', 'box-sizing': 'border-box' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('015', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '200', class: 'flex1-0-0', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1 0 0px', 'box-sizing': 'border-box' } }),
        createElement('div', { 'data-expected-width': '200', 'data-offset-x': '200', class: 'flex-none', style: { '-webkit-flex': 'none', flex: 'none', height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box', width: '200px', margin: '0 auto' } }),
        createElement('div', { 'data-expected-width': '200', 'data-offset-x': '400', class: 'flex1-0-0', style: { height: '20px', border: '0', 'background-color': 'red', flex: '1 0 0px', 'box-sizing': 'border-box' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('016', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '100', class: 'flex1-0-0', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1 0 0px', 'box-sizing': 'border-box' } }),
        createElement('div', { 'data-expected-width': '300', 'data-offset-x': '100', style: { height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box', flex: '2 0 100px', 'margin-left': 'auto' } }),
        createElement('div', { 'data-expected-width': '100', 'data-offset-x': '400', class: 'flex1-0-0', style: { height: '20px', border: '0', 'background-color': 'red', flex: '1 0 0px', 'box-sizing': 'border-box', 'margin-right': '100px' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('017', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '150', style: { height: '20px', border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', flex: '1 1 300px' } }),
        createElement('div', { 'data-expected-width': '300', 'data-offset-x': '150', style: { height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box', flex: '1 0 300px', margin: '0 auto' } }),
        createElement('div', { 'data-expected-width': '150', 'data-offset-x': '450', style: { height: '20px', border: '0', 'background-color': 'red', 'box-sizing': 'border-box', flex: '1 1 300px' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('018', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '300', 'data-offset-x': '150', style: { height: '20px', border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', flex: '0 0 300px', margin: '0 auto' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('019', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '700', 'data-offset-x': '0', style: { height: '20px', border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', flex: '0 0 700px', margin: '0 auto' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('020', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '600', 'data-offset-x': '0', style: { height: '20px', border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', flex: '1 0 300px', margin: '0 auto' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('021', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box' } },
      [
        createElement(
          'div',
          { 'data-expected-width': '600', 'data-offset-x': '0', class: 'flex4', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '4', 'box-sizing': 'border-box', margin: '0 auto' } },
          [
            createElement('div', { style: { height: '100%', border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', width: '100px' } }),
          ]
        ),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('022', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box', margin: '100px' } },
      [
        createElement('div', { 'data-expected-width': '300', 'data-offset-x': '0', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1', 'box-sizing': 'border-box', margin: '0 auto' } }),
        createElement('div', { 'data-expected-width': '300', 'data-offset-x': '300', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'green', flex: '1', 'box-sizing': 'border-box', margin: '0 auto' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('023', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box', padding: '100px' } },
      [
        createElement('div', { 'data-expected-width': '300', 'data-offset-x': '100', style: { height: '20px', border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', flex: '1 0 0px', margin: '0 auto' } }),
        createElement('div', { 'data-expected-width': '300', 'data-offset-x': '400', style: { height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box', flex: '1 0 0px', margin: '0 auto' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  xit('024', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '75', 'data-offset-x': '0', class: 'flex1-0-0', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1 0 0px', 'box-sizing': 'border-box', margin: '0 auto' } }),
        createElement('div', { 'data-expected-width': '350', 'data-offset-x': '75', class: 'flex2-0-0', style: { height: '20px', border: '0', 'background-color': 'green', flex: '2 0 0px', 'box-sizing': 'border-box', padding: '0 100px' } }),
        createElement('div', { 'data-expected-width': '75', 'data-offset-x': '525', class: 'flex1-0-0', style: { height: '20px', border: '0', 'background-color': 'red', flex: '1 0 0px', 'box-sizing': 'border-box', 'margin-left': '100px' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  // algorithm series
  it('025', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '200', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1', 'box-sizing': 'border-box' } }),
        createElement('div', { 'data-expected-width': '200', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'green', flex: '1', 'box-sizing': 'border-box' } }),
        createElement('div', { 'data-expected-width': '200', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'red', flex: '1', 'box-sizing': 'border-box' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('026', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '200', style: { height: '20px', border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', flex: '.5' } }),
        createElement('div', { 'data-expected-width': '200', style: { height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box', flex: '.5' } }),
        createElement('div', { 'data-expected-width': '200', style: { height: '20px', border: '0', 'background-color': 'red', 'box-sizing': 'border-box', flex: '.5' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('027', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '300', class: 'flex3', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '3', 'box-sizing': 'border-box' } }),
        createElement('div', { 'data-expected-width': '200', class: 'flex2', style: { height: '20px', border: '0', 'background-color': 'green', flex: '2', 'box-sizing': 'border-box' } }),
        createElement('div', { 'data-expected-width': '100', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'red', flex: '1', 'box-sizing': 'border-box' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('028', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '250', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1', 'box-sizing': 'border-box' } }),
        createElement('div', { 'data-expected-width': '250', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'green', flex: '1', 'box-sizing': 'border-box' } }),
        createElement('div', { 'data-expected-width': '100', class: 'flex-none', style: { '-webkit-flex': 'none', flex: 'none', height: '20px', border: '0', 'background-color': 'red', 'box-sizing': 'border-box', width: '100px' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('029', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '150', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1', 'box-sizing': 'border-box' } }),
        createElement('div', { 'data-expected-width': '150', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'green', flex: '1', 'box-sizing': 'border-box' } }),
        createElement('div', { 'data-expected-width': '300', class: 'flex-none', style: { '-webkit-flex': 'none', flex: 'none', height: '20px', border: '0', 'background-color': 'red', 'box-sizing': 'border-box', width: '50%' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('030', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '150', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1', 'box-sizing': 'border-box' } }),
        createElement('div', { 'data-expected-width': '350', style: { height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box', flex: '1 200px' } }),
        createElement('div', { 'data-expected-width': '100', class: 'flex-none', style: { '-webkit-flex': 'none', flex: 'none', height: '20px', border: '0', 'background-color': 'red', 'box-sizing': 'border-box', width: '100px' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('031', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '100', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1', 'box-sizing': 'border-box' } }),
        createElement('div', { 'data-expected-width': '400', style: { height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box', flex: '2 33.333333%' } }),
        createElement('div', { 'data-expected-width': '100', class: 'flex-none', style: { '-webkit-flex': 'none', flex: 'none', height: '20px', border: '0', 'background-color': 'red', 'box-sizing': 'border-box', width: '100px' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('032', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '200', style: { height: '20px', border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', flex: '1 1 300px' } }),
        createElement('div', { 'data-expected-width': '200', style: { height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box', flex: '2 1 300px' } }),
        createElement('div', { 'data-expected-width': '200', style: { height: '20px', border: '0', 'background-color': 'red', 'box-sizing': 'border-box', flex: '3 1 300px' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('033', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '250', style: { height: '20px', border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', flex: '1 1 300px' } }),
        createElement('div', { 'data-expected-width': '150', style: { height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box', flex: '2 3 300px' } }),
        createElement('div', { 'data-expected-width': '200', class: 'flex-none', style: { '-webkit-flex': 'none', flex: 'none', height: '20px', border: '0', 'background-color': 'red', 'box-sizing': 'border-box', width: '200px' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('034', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '50', style: { height: '20px', border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', flex: '1 1 100px' } }),
        createElement('div', { 'data-expected-width': '250', style: { height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box', flex: '1 1 500px' } }),
        createElement('div', { 'data-expected-width': '300', class: 'flex-none', style: { '-webkit-flex': 'none', flex: 'none', height: '20px', border: '0', 'background-color': 'red', 'box-sizing': 'border-box', width: '300px' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('035', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '50', style: { height: '20px', border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', flex: '1 1 100px' } }),
        createElement('div', { 'data-expected-width': '250', style: { height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box', flex: '1 1 500px', 'margin-right': '300px' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('036', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '50', style: { height: '20px', border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', flex: '1 1 100px' } }),
        createElement('div', { 'data-expected-width': '550', style: { height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box', flex: '1 1 500px', 'padding-left': '300px' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  xit('037', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '50', style: { height: '20px', border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', flex: '1 1 100px' } }),
        createElement('div', { 'data-expected-width': '550', style: { height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box', flex: '1 1 500px', 'border-left': '200px dashed orange', 'border-right': '100px dashed orange' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  xit('038', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '600', style: { height: '20px', border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', flex: '0 100000000000000000000000000000000000000 600px' } }),
        createElement('div', { 'data-expected-width': '600', style: { height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box', flex: '0 100000000000000000000000000000000000000 600px' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('039', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '600', style: { height: '20px', border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', flex: '100000000000000000000000000000000000000 0 600px' } }),
        createElement('div', { 'data-expected-width': '600', style: { height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box', flex: '0 100000000000000000000000000000000000000 600px' } }),
        createElement('div', { 'data-expected-width': '33554428', style: { height: '20px', border: '0', 'background-color': 'red', 'box-sizing': 'border-box', flex: '1 1 100000000000000000000000000000000000000px' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  xit('040', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '250', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1', 'box-sizing': 'border-box', 'border-left': '150px solid black' } }),
        createElement('div', { 'data-expected-width': '250', class: 'flex1-0-0', style: { height: '20px', border: '0', 'background-color': 'green', flex: '1 0 0px', 'box-sizing': 'border-box', 'border-right': '150px solid orange' } }),
        createElement('div', { 'data-expected-width': '100', class: 'flex1-0-0', style: { height: '20px', border: '0', 'background-color': 'red', flex: '1 0 0px', 'box-sizing': 'border-box' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('041', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '300', style: { height: '20px', border: '100px solid black', 'background-color': 'blue', 'box-sizing': 'border-box', width: '100px', flex: 'none' } }),
        createElement('div', { 'data-expected-width': '200', class: 'flex2', style: { height: '20px', border: '0', 'background-color': 'green', flex: '2', 'box-sizing': 'border-box' } }),
        createElement('div', { 'data-expected-width': '100', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'red', flex: '1', 'box-sizing': 'border-box' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  xit('042', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '250', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1', 'box-sizing': 'border-box', 'padding-left': '150px' } }),
        createElement('div', { 'data-expected-width': '250', class: 'flex1-0-0', style: { height: '20px', border: '0', 'background-color': 'green', flex: '1 0 0px', 'box-sizing': 'border-box', 'padding-right': '150px' } }),
        createElement('div', { 'data-expected-width': '100', class: 'flex1-0-0', style: { height: '20px', border: '0', 'background-color': 'red', flex: '1 0 0px', 'box-sizing': 'border-box' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('043', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '300', class: 'flex-none', style: { '-webkit-flex': 'none', flex: 'none', height: '20px', border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', width: '100px', padding: '100px' } }),
        createElement('div', { 'data-expected-width': '200', class: 'flex2', style: { height: '20px', border: '0', 'background-color': 'green', flex: '2', 'box-sizing': 'border-box' } }),
        createElement('div', { 'data-expected-width': '100', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'red', flex: '1', 'box-sizing': 'border-box' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  xit('044', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '200', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1', 'box-sizing': 'border-box', 'padding-left': '25%' } }),
        createElement('div', { 'data-expected-width': '150', class: 'flex3', style: { height: '20px', border: '0', 'background-color': 'green', flex: '3', 'box-sizing': 'border-box' } }),
        createElement('div', { 'data-expected-width': '250', class: 'flex-none', style: { '-webkit-flex': 'none', flex: 'none', height: '20px', border: '0', 'background-color': 'red', 'box-sizing': 'border-box', width: '100px', 'padding-right': '25%' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  xit('045', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-width': '200', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1', 'box-sizing': 'border-box', 'padding-left': '50px', 'border-right': '50px solid black' } }),
        createElement('div', { 'data-expected-width': '250', class: 'flex2', style: { height: '20px', border: '0', 'background-color': 'green', flex: '2', 'box-sizing': 'border-box', 'border-right': '50px solid orange' } }),
        createElement('div', { 'data-expected-width': '150', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'red', flex: '1', 'box-sizing': 'border-box', 'padding-right': '50px' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('046', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box' } },
      [
        createElement(
          'div',
          { 'data-expected-width': '120', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1', 'box-sizing': 'border-box' } },
          [
            createElement('div', { style: { height: '100%', border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', width: '100px' } }),
          ]
        ),
        createElement('div', { 'data-expected-width': '240', class: 'flex2', style: { height: '20px', border: '0', 'background-color': 'green', flex: '2', 'box-sizing': 'border-box' } }),
        createElement('div', { 'data-expected-width': '240', class: 'flex2', style: { height: '20px', border: '0', 'background-color': 'red', flex: '2', 'box-sizing': 'border-box' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('047', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box' } },
      [
        createElement(
          'div',
          { 'data-expected-width': '200', class: 'flex1-0-0', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1 0 0px', 'box-sizing': 'border-box' } },
          [
            createElement('div', { style: { height: '100%', border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', width: '100px' } }),
          ]
        ),
        createElement('div', { 'data-expected-width': '200', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'green', flex: '1', 'box-sizing': 'border-box' } }),
        createElement('div', { 'data-expected-width': '200', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'red', flex: '1', 'box-sizing': 'border-box' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('048', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box' } },
      [
        createElement(
          'div',
          { 'data-expected-width': '200', class: 'flex-auto', style: { '-webkit-flex': 'auto', flex: 'auto', height: '20px', border: '0', 'background-color': 'blue', 'box-sizing': 'border-box' } },
          [
            createElement('div', { style: { height: '20px', border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', width: '100px' } }),
          ]
        ),
        createElement('div', { 'data-expected-width': '100', class: 'flex-auto', style: { '-webkit-flex': 'auto', flex: 'auto', height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box' } }),
        createElement(
          'div',
          { 'data-expected-width': '300', class: 'flex-auto', style: { '-webkit-flex': 'auto', flex: 'auto', height: '20px', border: '0', 'background-color': 'red', 'box-sizing': 'border-box' } },
          [
            createElement('div', { style: { height: '20px', border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', width: '200px' } }),
          ]
        ),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('049', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box', height: '60px', 'flex-flow': 'row wrap', position: 'relative' } },
      [
        createElement('div', { 'data-offset-x': '0', 'data-offset-y': '0', style: { height: '20px', border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', position: 'absolute' } }),
        createElement('div', { 'data-offset-x': '0', 'data-offset-y': '0', style: { height: '20px', border: '0', 'background-color': 'green', 'box-sizing': 'border-box', width: '700px' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('050', async () => {
    let log;
    let wrapper;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    wrapper = createElement(
      'div',
      { 'data-expected-width': '830', style: { 'box-sizing': 'border-box', border: '1px 10px solid', display: 'inline-block' } },
      [
        createElement(
          'div',
          { 'data-expected-width': '700', class: 'flexbox', style: { display: 'flex', width: '600px', 'box-sizing': 'border-box', 'padding-left': '10px', 'padding-right': '20px', 'border-left': '1px 30px solid', 'border-right': '1px 40px solid', 'margin-left': '50px', 'margin-right': '60px' } },
          [
            createElement('div', { 'data-offset-x': '100', 'data-expected-width': '200', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'blue', flex: '1', 'box-sizing': 'border-box' } }),
            createElement('div', { 'data-offset-x': '300', 'data-expected-width': '200', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'green', flex: '1', 'box-sizing': 'border-box' } }),
            createElement('div', { 'data-offset-x': '500', 'data-expected-width': '200', class: 'flex1', style: { height: '20px', border: '0', 'background-color': 'red', flex: '1', 'box-sizing': 'border-box' } }),
          ]
        ),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(wrapper);
    await snapshot();
  });

});

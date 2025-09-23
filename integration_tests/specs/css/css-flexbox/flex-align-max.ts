/*auto generated*/
describe('flex-align', () => {
  it('max-001', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox', style: { display: 'flex', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box' } },
      [
        createElement('div', { 'data-expected-height': '50', style: { border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', flex: '1 0 0', 'max-height': '100px' } }),
        createElement('div', { 'data-expected-height': '50', style: { border: '0', 'background-color': 'green', 'box-sizing': 'border-box', flex: '1 0 0', height: '50px' } }),
        createElement('div', { 'data-expected-height': '25', style: { border: '0', 'background-color': 'red', 'box-sizing': 'border-box', flex: '1 0 0', 'max-height': '25px' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('max-002', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox column', style: { display: 'flex', '-webkit-flex-direction': 'column', 'flex-direction': 'column', 'background-color': '#aaa', position: 'relative', 'box-sizing': 'border-box', width: '200px' } },
      [
        createElement('div', { 'data-expected-width': '150', style: { border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', flex: '1 0 20px', 'max-width': '150px' } }),
        createElement('div', { 'data-expected-width': '100', style: { border: '0', 'background-color': 'green', 'box-sizing': 'border-box', flex: '1 0 20px', width: '100px' } }),
        createElement('div', { 'data-expected-width': '200', style: { border: '0', 'background-color': 'red', 'box-sizing': 'border-box', flex: '1 0 20px' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  it('max-003', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox vertical-rl', style: { display: 'flex', 'background-color': '#aaa', position: 'relative', 'writing-mode': 'vertical-rl', 'box-sizing': 'border-box', height: '60px' } },
      [
        createElement('div', { 'data-expected-width': '100', style: { border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', flex: '1 0 20px', 'max-width': '110px' } }),
        createElement('div', { 'data-expected-width': '100', style: { border: '0', 'background-color': 'green', 'box-sizing': 'border-box', flex: '1 0 20px', width: '100px' } }),
        createElement('div', { 'data-expected-width': '50', style: { border: '0', 'background-color': 'red', 'box-sizing': 'border-box', flex: '1 0 20px', 'max-width': '50px' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });

  xit('max-004', async () => {
    let log;
    let flex;
    log = createElement('div', { id: 'log', style: { 'box-sizing': 'border-box' } });
    flex = createElement(
      'div',
      { class: 'flexbox column vertical-rl', style: { display: 'flex', '-webkit-flex-direction': 'column', 'flex-direction': 'column', 'background-color': '#aaa', position: 'relative', 'writing-mode': 'vertical-rl', 'box-sizing': 'border-box', height: '50px' } },
      [
        createElement('div', { 'data-expected-height': '50', style: { border: '0', 'background-color': 'blue', 'box-sizing': 'border-box', flex: '1 0 100px', 'max-height': '100px' } }),
        createElement('div', { 'data-expected-height': '50', style: { border: '0', 'background-color': 'green', 'box-sizing': 'border-box', flex: '1 0 100px', height: '50px' } }),
        createElement('div', { 'data-expected-height': '25', style: { border: '0', 'background-color': 'red', 'box-sizing': 'border-box', flex: '1 0 100px', 'max-height': '25px' } }),
      ]
    );
    BODY.appendChild(log);
    BODY.appendChild(flex);
    await snapshot();
  });
});

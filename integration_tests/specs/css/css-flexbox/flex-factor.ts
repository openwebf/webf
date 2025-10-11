/*auto generated*/
describe('flex-factor', () => {
  it('factor-0', async () => {
    const c = createElement('div', {
      class: 'flexbox container',
      style: { display: 'flex', height: '100px', width: '100px', border: '1px solid black', 'box-sizing': 'border-box' },
    }, [
      createElement('div', { class: 'child-flex-grow-0-5', 'data-expected-width': '50', style: { 'background-color': 'green', 'flex-grow': '0.5', 'box-sizing': 'border-box' } }),
    ]);
    BODY.appendChild(c);
    await snapshot();
  });

  it('factor-1', async () => {
    const c = createElement('div', {
      class: 'flexbox container',
      style: { display: 'flex', height: '100px', width: '100px', border: '1px solid black', 'box-sizing': 'border-box' },
    }, [
      createElement('div', { class: 'child-flex-grow-0-5', 'data-expected-width': '50', style: { 'background-color': 'green', 'flex-grow': '0.5', 'box-sizing': 'border-box' } }),
      createElement('div', { class: 'child-flex-grow-0-25', 'data-expected-width': '25', style: { 'background-color': 'red', 'flex-grow': '0.25', 'box-sizing': 'border-box' } }),
    ]);
    BODY.appendChild(c);
    await snapshot();
  });

  it('factor-2', async () => {
    const c = createElement('div', {
      class: 'flexbox container column',
      style: { display: 'flex', '-webkit-flex-direction': 'column', 'flex-direction': 'column', height: '100px', width: '100px', border: '1px solid black', 'box-sizing': 'border-box' },
    }, [
      createElement('div', { class: 'child-flex-grow-0-5', 'data-expected-height': '50', style: { 'background-color': 'green', 'flex-grow': '0.5', 'box-sizing': 'border-box' } }),
      createElement('div', { class: 'child-flex-grow-0-25', 'data-expected-height': '25', style: { 'background-color': 'red', 'flex-grow': '0.25', 'box-sizing': 'border-box' } }),
    ]);
    BODY.appendChild(c);
    await snapshot();
  });

  it('factor-3', async () => {
    const c = createElement('div', {
      class: 'flexbox container column vertical',
      style: { display: 'flex', '-webkit-flex-direction': 'column', 'flex-direction': 'column', height: '100px', width: '100px', border: '1px solid black', 'writing-mode': 'vertical-rl', 'box-sizing': 'border-box' },
    }, [
      createElement('div', { class: 'child-flex-grow-0-5 ', 'data-expected-width': '50', style: { 'background-color': 'green', 'flex-grow': '0.5', 'box-sizing': 'border-box' } }),
      createElement('div', { class: 'child-flex-grow-0-25 ', 'data-expected-width': '25', style: { 'background-color': 'red', 'flex-grow': '0.25', 'box-sizing': 'border-box' } }),
    ]);
    BODY.appendChild(c);
    await snapshot();
  });

  xit('factor-4', async () => {
    const c = createElement('div', {
      class: 'flexbox container vertical',
      style: { display: 'flex', height: '100px', width: '100px', border: '1px solid black', 'writing-mode': 'vertical-rl', 'box-sizing': 'border-box' },
    }, [
      createElement('div', { class: 'child-flex-grow-0-5 ', 'data-expected-height': '50', style: { 'background-color': 'green', 'flex-grow': '0.5', 'box-sizing': 'border-box' } }),
      createElement('div', { class: 'child-flex-grow-0-25 ', 'data-expected-height': '25', style: { 'background-color': 'red', 'flex-grow': '0.25', 'box-sizing': 'border-box' } }),
    ]);
    BODY.appendChild(c);
    await snapshot();
  });

  it('factor-5', async () => {
    const c = createElement('div', {
      class: 'flexbox container',
      style: { display: 'flex', height: '100px', width: '100px', border: '1px solid black', 'box-sizing': 'border-box' },
    }, [
      createElement('div', { class: 'child-flex-grow-0-5 basis', 'data-expected-width': '50', style: { 'background-color': 'green', 'flex-grow': '0.5', 'flex-basis': '30px', 'box-sizing': 'border-box' } }),
      createElement('div', { class: 'child-flex-grow-0-25 basis', 'data-expected-width': '40', style: { 'background-color': 'red', 'flex-grow': '0.25', 'flex-basis': '30px', 'box-sizing': 'border-box' } }),
    ]);
    BODY.appendChild(c);
    await snapshot();
  });

  it('factor-6', async () => {
    const c = createElement('div', {
      class: 'flexbox container column',
      style: { display: 'flex', '-webkit-flex-direction': 'column', 'flex-direction': 'column', height: '100px', width: '100px', border: '1px solid black', 'box-sizing': 'border-box' },
    }, [
      createElement('div', { class: 'child-flex-grow-0-5 basis', 'data-expected-height': '50', style: { 'background-color': 'green', 'flex-grow': '0.5', 'flex-basis': '30px', 'box-sizing': 'border-box' } }),
      createElement('div', { class: 'child-flex-grow-0-25 basis', 'data-expected-height': '40', style: { 'background-color': 'red', 'flex-grow': '0.25', 'flex-basis': '30px', 'box-sizing': 'border-box' } }),
    ]);
    BODY.appendChild(c);
    await snapshot();
  });

  it('factor-7', async () => {
    const c = createElement('div', {
      class: 'flexbox container vertical',
      style: { display: 'flex', height: '100px', width: '100px', border: '1px solid black', 'writing-mode': 'vertical-rl', 'box-sizing': 'border-box' },
    }, [
      createElement('div', { class: 'child-flex-grow-0-5 basis', 'data-expected-height': '50', style: { 'background-color': 'green', 'flex-grow': '0.5', 'flex-basis': '30px', 'box-sizing': 'border-box' } }),
      createElement('div', { class: 'child-flex-grow-0-25 basis', 'data-expected-height': '40', style: { 'background-color': 'red', 'flex-grow': '0.25', 'flex-basis': '30px', 'box-sizing': 'border-box' } }),
    ]);
    BODY.appendChild(c);
    await snapshot();
  });

  it('factor-8', async () => {
    const c = createElement('div', {
      class: 'flexbox container column vertical',
      style: { display: 'flex', '-webkit-flex-direction': 'column', 'flex-direction': 'column', height: '100px', width: '100px', border: '1px solid black', 'writing-mode': 'vertical-rl', 'box-sizing': 'border-box' },
    }, [
      createElement('div', { class: 'child-flex-grow-0-5 basis ', 'data-expected-width': '50', style: { 'background-color': 'green', 'flex-grow': '0.5', 'flex-basis': '30px', 'box-sizing': 'border-box' } }),
      createElement('div', { class: 'child-flex-grow-0-25 basis ', 'data-expected-width': '40', style: { 'background-color': 'red', 'flex-grow': '0.25', 'flex-basis': '30px', 'box-sizing': 'border-box' } }),
    ]);
    BODY.appendChild(c);
    await snapshot();
  });

  it('factor-9', async () => {
    const c = createElement('div', {
      class: 'flexbox container',
      style: { display: 'flex', height: '100px', width: '100px', border: '1px solid black', 'box-sizing': 'border-box' },
    }, [
      createElement('div', { class: 'child-flex-shrink-0-5', 'data-expected-width': '150', style: { 'background-color': 'green', 'flex-shrink': '0.5', width: '200px', height: '200px', 'box-sizing': 'border-box' } }),
    ]);
    BODY.appendChild(c);
    await snapshot();
  });

  it('factor-10', async () => {
    const c = createElement('div', {
      class: 'flexbox container',
      style: { display: 'flex', height: '100px', width: '100px', border: '1px solid black', 'box-sizing': 'border-box' },
    }, [
      createElement('div', { class: 'child-flex-shrink-0-5', 'data-expected-width': '50', style: { 'background-color': 'green', 'flex-shrink': '0.5', width: '200px', height: '200px', 'box-sizing': 'border-box' } }),
      createElement('div', { class: 'child-flex-shrink-0-25', 'data-expected-width': '125', style: { 'background-color': 'red', 'flex-shrink': '0.25', width: '200px', height: '200px', 'box-sizing': 'border-box' } }),
    ]);
    BODY.appendChild(c);
    await snapshot();
  });

  it('factor-11', async () => {
    const c = createElement('div', {
      class: 'flexbox container column',
      style: { display: 'flex', '-webkit-flex-direction': 'column', 'flex-direction': 'column', height: '100px', width: '100px', border: '1px solid black', 'box-sizing': 'border-box' },
    }, [
      createElement('div', { class: 'child-flex-shrink-0-5', 'data-expected-height': '50', style: { 'background-color': 'green', 'flex-shrink': '0.5', width: '200px', height: '200px', 'box-sizing': 'border-box' } }),
      createElement('div', { class: 'child-flex-shrink-0-25', 'data-expected-height': '125', style: { 'background-color': 'red', 'flex-shrink': '0.25', width: '200px', height: '200px', 'box-sizing': 'border-box' } }),
    ]);
    BODY.appendChild(c);
    await snapshot();
  });

  it('factor-12', async () => {
    const c = createElement('div', {
      class: 'flexbox container column vertical',
      style: { display: 'flex', '-webkit-flex-direction': 'column', 'flex-direction': 'column', height: '100px', width: '100px', border: '1px solid black', 'writing-mode': 'vertical-rl', 'box-sizing': 'border-box' },
    }, [
      createElement('div', { class: 'child-flex-shrink-0-5 ', 'data-expected-width': '50', style: { 'background-color': 'green', 'flex-shrink': '0.5', width: '200px', height: '200px', 'box-sizing': 'border-box' } }),
      createElement('div', { class: 'child-flex-shrink-0-25 ', 'data-expected-width': '125', style: { 'background-color': 'red', 'flex-shrink': '0.25', width: '200px', height: '200px', 'box-sizing': 'border-box' } }),
    ]);
    BODY.appendChild(c);
    await snapshot();
  });

  it('factor-13', async () => {
    const c = createElement('div', {
      class: 'flexbox container vertical',
      style: { display: 'flex', height: '100px', width: '100px', border: '1px solid black', 'writing-mode': 'vertical-rl', 'box-sizing': 'border-box' },
    }, [
      createElement('div', { class: 'child-flex-shrink-0-5 ', 'data-expected-height': '50', style: { 'background-color': 'green', 'flex-shrink': '0.5', width: '200px', height: '200px', 'box-sizing': 'border-box' } }),
      createElement('div', { class: 'child-flex-shrink-0-25 ', 'data-expected-height': '125', style: { 'background-color': 'red', 'flex-shrink': '0.25', width: '200px', height: '200px', 'box-sizing': 'border-box' } }),
    ]);
    BODY.appendChild(c);
    await snapshot();
  });

  it('factor-14', async () => {
    const c = createElement('div', {
      class: 'flexbox container',
      style: { display: 'flex', height: '100px', width: '100px', border: '1px solid black', 'box-sizing': 'border-box' },
    }, [
      createElement('div', { class: 'child-flex-shrink-0-5 basis-big', 'data-expected-width': '50', style: { 'background-color': 'green', 'flex-shrink': '0.5', width: '200px', height: '200px', 'flex-basis': '100px', 'box-sizing': 'border-box' } }),
      createElement('div', { class: 'child-flex-shrink-0-25 basis-big', 'data-expected-width': '75', style: { 'background-color': 'red', 'flex-shrink': '0.25', width: '200px', height: '200px', 'flex-basis': '100px', 'box-sizing': 'border-box' } }),
    ]);
    BODY.appendChild(c);
    await snapshot();
  });

  it('factor-15', async () => {
    const c = createElement('div', {
      class: 'flexbox container column',
      style: { display: 'flex', '-webkit-flex-direction': 'column', 'flex-direction': 'column', height: '100px', width: '100px', border: '1px solid black', 'box-sizing': 'border-box' },
    }, [
      createElement('div', { class: 'child-flex-shrink-0-5 basis-big', 'data-expected-height': '50', style: { 'background-color': 'green', 'flex-shrink': '0.5', width: '200px', height: '200px', 'flex-basis': '100px', 'box-sizing': 'border-box' } }),
      createElement('div', { class: 'child-flex-shrink-0-25 basis-big', 'data-expected-height': '75', style: { 'background-color': 'red', 'flex-shrink': '0.25', width: '200px', height: '200px', 'flex-basis': '100px', 'box-sizing': 'border-box' } }),
    ]);
    BODY.appendChild(c);
    await snapshot();
  });

  it('factor-16', async () => {
    const c = createElement('div', {
      class: 'flexbox container vertical',
      style: { display: 'flex', height: '100px', width: '100px', border: '1px solid black', 'writing-mode': 'vertical-rl', 'box-sizing': 'border-box' },
    }, [
      createElement('div', { class: 'child-flex-shrink-0-5 basis-big ', 'data-expected-height': '50', style: { 'background-color': 'green', 'flex-shrink': '0.5', width: '200px', height: '200px', 'flex-basis': '100px', 'box-sizing': 'border-box' } }),
      createElement('div', { class: 'child-flex-shrink-0-25 basis-big ', 'data-expected-height': '75', style: { 'background-color': 'red', 'flex-shrink': '0.25', width: '200px', height: '200px', 'flex-basis': '100px', 'box-sizing': 'border-box' } }),
    ]);
    BODY.appendChild(c);
    await snapshot();
  });

  it('factor-17', async () => {
    const c = createElement('div', {
      class: 'flexbox container column vertical',
      style: { display: 'flex', '-webkit-flex-direction': 'column', 'flex-direction': 'column', height: '100px', width: '100px', border: '1px solid black', 'writing-mode': 'vertical-rl', 'box-sizing': 'border-box' },
    }, [
      createElement('div', { class: 'child-flex-shrink-0-5 basis-big ', 'data-expected-width': '50', style: { 'background-color': 'green', 'flex-shrink': '0.5', width: '200px', height: '200px', 'flex-basis': '100px', 'box-sizing': 'border-box' } }),
      createElement('div', { class: 'child-flex-shrink-0-25 basis-big ', 'data-expected-width': '75', style: { 'background-color': 'red', 'flex-shrink': '0.25', width: '200px', height: '200px', 'flex-basis': '100px', 'box-sizing': 'border-box' } }),
    ]);
    BODY.appendChild(c);
    await snapshot();
  });

  xit('factor-18', async () => {
    const c = createElement('div', {
      class: 'flexbox container',
      style: { display: 'flex', height: '100px', width: '100px', border: '1px solid black', 'box-sizing': 'border-box' },
    }, [
      createElement('div', { class: 'child-flex-grow-0-5 basis-0', 'data-expected-width': '10', style: { 'background-color': 'green', 'flex-grow': '0.5', 'flex-basis': '0', 'box-sizing': 'border-box' } }),
      createElement('div', { class: 'child-flex-grow-0-75 basis-0', 'data-expected-width': '90', style: { 'background-color': 'lime', 'flex-grow': '0.75', 'flex-basis': '0', 'box-sizing': 'border-box' } }, [
        createElement('div', { style: { 'box-sizing': 'border-box', width: '90px' } }),
      ]),
    ]);
    BODY.appendChild(c);
    await snapshot();
  });

  it('factor-19', async () => {
    const c = createElement('div', {
      class: 'flexbox container justify-content-center',
      style: { display: 'flex', '-webkit-justify-content': 'center', 'justify-content': 'center', height: '100px', width: '100px', border: '1px solid black', 'box-sizing': 'border-box' },
    }, [
      createElement('div', { class: 'child-flex-grow-0-5', 'data-expected-width': '50', 'data-offset-x': '26', style: { 'background-color': 'green', 'flex-grow': '0.5', 'box-sizing': 'border-box' } }),
    ]);
    BODY.appendChild(c);
    await snapshot();
  });

  it('factor-20', async () => {
    const c = createElement('div', {
      class: 'flexbox container justify-content-space-around',
      style: { display: 'flex', '-webkit-justify-content': 'space-around', 'justify-content': 'space-around', height: '100px', width: '100px', border: '1px solid black', 'box-sizing': 'border-box' },
    }, [
      createElement('div', { class: 'child-flex-grow-0-5', 'data-expected-width': '50', 'data-offset-x': '26', style: { 'background-color': 'green', 'flex-grow': '0.5', 'box-sizing': 'border-box' } }),
    ]);
    BODY.appendChild(c);
    await snapshot();
  });

  it('factor-21', async () => {
    const c = createElement('div', {
      class: 'flexbox container justify-content-flex-end',
      style: { display: 'flex', '-webkit-justify-content': 'flex-end', 'justify-content': 'flex-end', height: '100px', width: '100px', border: '1px solid black', 'box-sizing': 'border-box' },
    }, [
      createElement('div', { class: 'child-flex-grow-0-5', 'data-expected-width': '50', 'data-offset-x': '51', style: { 'background-color': 'green', 'flex-grow': '0.5', 'box-sizing': 'border-box' } }),
    ]);
    BODY.appendChild(c);
    await snapshot();
  });
});

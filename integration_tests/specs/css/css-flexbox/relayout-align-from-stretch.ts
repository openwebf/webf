/*auto generated*/
describe('relayout-align', () => {
  it('from stretch to flex-end', async (done) => {
    let fromStretch;
    let alignSelfAuto;
    let alignSelfFlexStart;
    let alignSelfFlexEnd;
    let alignSelfCenter;
    let alignSelfBaseline;
    let alignSelfStretch;

    fromStretch = createElement(
      'div',
      {
        id: 'from-stretch',
        class: 'flexbox',
        style: {
          display: 'flex',
          height: '100px',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-height': '10',
          'data-offset-y': '90',
          style: {
            border: '5px solid green',
            width: '50px',
            'box-sizing': 'border-box',
          },
        }),
        (alignSelfAuto = createElement('div', {
          'data-expected-height': '10',
          'data-offset-y': '90',
          class: 'align-self-auto',
          style: {
            '-webkit-align-self': 'auto',
            'align-self': 'auto',
            border: '5px solid green',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
        (alignSelfFlexStart = createElement('div', {
          'data-expected-height': '10',
          'data-offset-y': '0',
          class: 'align-self-flex-start',
          style: {
            '-webkit-align-self': 'flex-start',
            'align-self': 'flex-start',
            border: '5px solid green',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
        (alignSelfFlexEnd = createElement('div', {
          'data-expected-height': '10',
          'data-offset-y': '90',
          class: 'align-self-flex-end',
          style: {
            '-webkit-align-self': 'flex-end',
            'align-self': 'flex-end',
            border: '5px solid green',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
        (alignSelfCenter = createElement('div', {
          'data-expected-height': '10',
          'data-offset-y': '45',
          class: 'align-self-center',
          style: {
            '-webkit-align-self': 'center',
            'align-self': 'center',
            border: '5px solid green',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
        (alignSelfBaseline = createElement('div', {
          'data-expected-height': '10',
          'data-offset-y': '0',
          class: 'align-self-baseline',
          style: {
            '-webkit-align-self': 'baseline',
            'align-self': 'baseline',
            border: '5px solid green',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
        (alignSelfStretch = createElement('div', {
          'data-expected-height': '100',
          'data-offset-y': '0',
          class: 'align-self-stretch',
          style: {
            '-webkit-align-self': 'stretch',
            'align-self': 'stretch',
            border: '5px solid green',
            width: '50px',
            'box-sizing': 'border-box',
          },
        })),
      ]
    );

    BODY.appendChild(fromStretch);

    await snapshot();

    requestAnimationFrame(async () => {
      fromStretch.style.alignItems = 'flex-end';
      await snapshot();
      done();
    });
  });
});

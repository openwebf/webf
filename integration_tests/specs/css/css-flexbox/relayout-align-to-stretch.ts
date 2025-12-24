/*auto generated*/
describe('relayout-align', () => {
  it('from flex-start to stretch', async (done) => {
    let toStretch;
    let alignSelfAuto;
    let alignSelfFlexStart;
    let alignSelfFlexEnd;
    let alignSelfCenter;
    let alignSelfBaseline;
    let alignSelfStretch;

    toStretch = createElement(
      'div',
      {
        id: 'to-stretch',
        class: 'flexbox align-items-flex-start',
        style: {
          display: 'flex',
          '-webkit-align-items': 'flex-start',
          height: '100px',
          position: 'relative',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-height': '100',
          'data-offset-y': '0',
          style: {
            border: '5px solid green',
            width: '50px',
            'box-sizing': 'border-box',
          },
        }),
        (alignSelfAuto = createElement('div', {
          'data-expected-height': '100',
          'data-offset-y': '0',
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

    BODY.appendChild(toStretch);

    await snapshot();

    requestAnimationFrame(async () => {
      toStretch.style.alignItems = 'stretch';
      await snapshot();
      done();
    });
  });
});

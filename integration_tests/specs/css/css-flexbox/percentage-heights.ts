/*auto generated*/
describe('percentage', () => {
  // Group 1: Basic Column Wrap Heights
  it("basic column wrap heights", async () => {
    let log;
    let flexbox;

    log = createElement('div', {
      id: 'log',
      style: {
        'box-sizing': 'border-box',
      },
    });

    flexbox = createElement(
      'div',
      {
        class: 'flexbox column',
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-flow': 'column wrap',
          width: '100px',
          height: '100px',
          'align-content': 'flex-start',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-height': '40',
          'data-offset-x': '0',
          'data-offset-y': '0',
          style: {
            'background-color': 'blue',
            width: '40%',
            height: '40%',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          'data-expected-height': '40',
          'data-offset-x': '0',
          'data-offset-y': '40',
          style: {
            'background-color': 'green',
            width: '40%',
            height: '40%',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          'data-expected-height': '40',
          'data-offset-x': '40',
          'data-offset-y': '0',
          style: {
            'background-color': 'red',
            width: '40%',
            height: '40%',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );

    BODY.appendChild(log);
    BODY.appendChild(flexbox);
    await snapshot();
  });

  // Group 2: Column Wrap with Margins
  it("column wrap with margins", async () => {
    let log;
    let flexbox_1;

    log = createElement('div', {
      id: 'log',
      style: {
        'box-sizing': 'border-box',
      },
    });

    flexbox_1 = createElement(
      'div',
      {
        class: 'flexbox column',
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-flow': 'column wrap',
          width: '100px',
          height: '100px',
          'align-content': 'flex-start',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-height': '40',
          'data-offset-x': '0',
          'data-offset-y': '0',
          style: {
            'background-color': 'blue',
            width: '40%',
            height: '40%',
            'box-sizing': 'border-box',
            'margin-bottom': '10%',
          },
        }),
        createElement('div', {
          'data-expected-height': '40',
          'data-offset-x': '40',
          'data-offset-y': '0',
          style: {
            'background-color': 'green',
            width: '40%',
            height: '40%',
            'box-sizing': 'border-box',
            'margin-bottom': '20%',
          },
        }),
        createElement('div', {
          'data-expected-height': '40',
          'data-offset-x': '40',
          'data-offset-y': '60',
          style: {
            'background-color': 'red',
            width: '40%',
            height: '40%',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );

    BODY.appendChild(log);
    BODY.appendChild(flexbox_1);
    await snapshot();
  });

  // Group 3: Column Wrap with Flex Properties
  it("column wrap with flex properties", async () => {
    let log;
    let flexbox_2;

    log = createElement('div', {
      id: 'log',
      style: {
        'box-sizing': 'border-box',
      },
    });

    flexbox_2 = createElement(
      'div',
      {
        class: 'flexbox column',
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-flow': 'column wrap',
          width: '100px',
          height: '100px',
          'align-content': 'flex-start',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement('div', {
          'data-expected-height': '20',
          'data-offset-x': '0',
          'data-offset-y': '0',
          style: {
            'background-color': 'blue',
            width: '40%',
            height: '40%',
            'box-sizing': 'border-box',
            flex: '1',
            'min-height': '0',
            'max-height': '20%',
          },
        }),
        createElement('div', {
          'data-expected-height': '40',
          'data-offset-x': '0',
          'data-offset-y': '20',
          style: {
            'background-color': 'green',
            width: '40%',
            height: '40%',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          'data-expected-height': '40',
          'data-offset-x': '0',
          'data-offset-y': '60',
          style: {
            'background-color': 'red',
            width: '40%',
            height: '40%',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );

    BODY.appendChild(log);
    BODY.appendChild(flexbox_2);
    await snapshot();
  });

  // Group 4: Vertical Writing Mode Basic
  it("vertical writing mode basic column wrap", async () => {
    let log;
    let flexbox_3;

    log = createElement('div', {
      id: 'log',
      style: {
        'box-sizing': 'border-box',
      },
    });

    flexbox_3 = createElement(
      'div',
      {
        class: 'flexbox column',
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-flow': 'column wrap',
          width: '100px',
          height: '100px',
          'align-content': 'flex-start',
          'box-sizing': 'border-box',
          'writing-mode': 'vertical-rl',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '40',
          'data-offset-x': '60',
          'data-offset-y': '0',
          style: {
            'background-color': 'blue',
            width: '40%',
            height: '40%',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          'data-expected-width': '40',
          'data-offset-x': '20',
          'data-offset-y': '0',
          style: {
            'background-color': 'green',
            width: '40%',
            height: '40%',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          'data-expected-width': '40',
          'data-offset-x': '60',
          'data-offset-y': '40',
          style: {
            'background-color': 'red',
            width: '40%',
            height: '40%',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );

    BODY.appendChild(log);
    BODY.appendChild(flexbox_3);
    await snapshot();
  });

  // Group 5: Vertical Writing Mode with Margins
  it("vertical writing mode with margins", async () => {
    let log;
    let flexbox_4;

    log = createElement('div', {
      id: 'log',
      style: {
        'box-sizing': 'border-box',
      },
    });

    flexbox_4 = createElement(
      'div',
      {
        class: 'flexbox column',
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-flow': 'column wrap',
          width: '100px',
          height: '100px',
          'align-content': 'flex-start',
          'box-sizing': 'border-box',
          'writing-mode': 'vertical-rl',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '40',
          'data-offset-x': '60',
          'data-offset-y': '0',
          style: {
            'background-color': 'blue',
            width: '40%',
            height: '40%',
            'box-sizing': 'border-box',
            'margin-bottom': '10%',
          },
        }),
        createElement('div', {
          'data-expected-width': '40',
          'data-offset-x': '20',
          'data-offset-y': '0',
          style: {
            'background-color': 'green',
            width: '40%',
            height: '40%',
            'box-sizing': 'border-box',
            'margin-bottom': '20%',
          },
        }),
        createElement('div', {
          'data-expected-width': '40',
          'data-offset-x': '60',
          'data-offset-y': '60',
          style: {
            'background-color': 'red',
            width: '40%',
            height: '40%',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );

    BODY.appendChild(log);
    BODY.appendChild(flexbox_4);
    await snapshot();
  });

  // Group 6: Vertical Writing Mode with Flex Properties
  it("vertical writing mode with flex properties", async () => {
    let log;
    let flexbox_5;

    log = createElement('div', {
      id: 'log',
      style: {
        'box-sizing': 'border-box',
      },
    });

    flexbox_5 = createElement(
      'div',
      {
        class: 'flexbox column',
        style: {
          display: 'flex',
          'background-color': '#aaa',
          position: 'relative',
          'flex-flow': 'column wrap',
          width: '100px',
          height: '100px',
          'align-content': 'flex-start',
          'box-sizing': 'border-box',
          'writing-mode': 'vertical-rl',
        },
      },
      [
        createElement('div', {
          'data-expected-width': '20',
          'data-offset-x': '80',
          'data-offset-y': '0',
          style: {
            'background-color': 'blue',
            width: '40%',
            height: '40%',
            'box-sizing': 'border-box',
            flex: '1',
            'min-width': '0',
            'max-width': '20%',
          },
        }),
        createElement('div', {
          'data-expected-width': '40',
          'data-offset-x': '40',
          'data-offset-y': '0',
          style: {
            'background-color': 'green',
            width: '40%',
            height: '40%',
            'box-sizing': 'border-box',
          },
        }),
        createElement('div', {
          'data-expected-width': '40',
          'data-offset-x': '0',
          'data-offset-y': '0',
          style: {
            'background-color': 'red',
            width: '40%',
            height: '40%',
            'box-sizing': 'border-box',
          },
        }),
      ]
    );

    BODY.appendChild(log);
    BODY.appendChild(flexbox_5);
    await snapshot();
  });
});

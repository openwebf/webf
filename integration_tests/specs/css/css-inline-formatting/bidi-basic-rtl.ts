/*auto generated*/
describe('Bidirectional Text', () => {
  it('should render RTL text correctly', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          direction: 'rtl',
          width: '300px',
          border: '1px solid black',
          padding: '10px',
          fontSize: '16px',
        },
      },
      [
        createText('مرحبا بك في WebF')
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('should align RTL text to the right by default', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          direction: 'rtl',
          width: '300px',
          border: '1px solid black',
          padding: '10px',
          fontSize: '16px',
          backgroundColor: '#f0f0f0',
        },
      },
      [
        createText('النص العربي يبدأ من اليمين')
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('should handle mixed LTR and RTL text', async () => {
    let div;
    div = createElement(
      'div',
      {
        style: {
          width: '400px',
          border: '1px solid black',
          padding: '10px',
          fontSize: '16px',
        },
      },
      [
        createText('Hello مرحبا World عالم!')
      ]
    );
    BODY.appendChild(div);

    await snapshot();
  });

  it('should respect unicode-bidi embed property', async () => {
    let container = createElement(
      'div',
      {
        style: {
          width: '400px',
          border: '1px solid black',
          padding: '10px',
          fontSize: '16px',
        },
      },
      [
        createElement('span', {
          style: {
            unicodeBidi: 'embed',
            direction: 'rtl',
            backgroundColor: 'yellow',
          },
        }, [
          createText('RTL text')
        ]),
        createText(' in LTR context')
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });

  fit('should handle nested direction changes', async () => {
    let container = createElement(
      'div',
      {
        style: {
          direction: 'rtl',
          width: '300px',
          border: '1px solid black',
          padding: '10px',
          fontSize: '16px',
        },
      },
      [
        createText('RTL: مرحبا '),
        createElement('span', {
          style: {
            direction: 'ltr',
            unicodeBidi: 'embed',
            backgroundColor: 'lightblue',
          },
        }, [
          createText('LTR: Hello')
        ]),
        createText(' عالم')
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });

  it('should handle bidi text with inline formatting', async () => {
    let container = createElement(
      'div',
      {
        style: {
          width: '400px',
          border: '1px solid black',
          padding: '10px',
          fontSize: '16px',
        },
      },
      [
        createText('English '),
        createElement('strong', {}, [
          createText('bold')
        ]),
        createText(' text مع '),
        createElement('em', {}, [
          createText('نص عربي')
        ]),
        createText(' مائل')
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });

  it('should support unicode-bidi isolate', async () => {
    let container = createElement(
      'div',
      {
        style: {
          width: '400px',
          border: '1px solid black',
          padding: '10px',
          fontSize: '16px',
        },
      },
      [
        createText('User '),
        createElement('span', {
          style: {
            unicodeBidi: 'isolate',
            backgroundColor: 'yellow',
          },
        }, [
          createText('اسم:محمد')
        ]),
        createText(' (ID: 123)')
      ]
    );
    BODY.appendChild(container);

    await snapshot();
  });
});

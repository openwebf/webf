/* auto translated from flex-grow2.html */
describe('flex-grow2', () => {
  it('three vertical areas with fixed heads and scrollable list', async () => {
    const chat = createElement(
      'div',
      {
        class: 'chat',
        style: {
          display: 'flex',
          overflowX: 'hidden',
          width: '100%',
          flexDirection: 'column',
        },
      },
      [
        // head (50vh)
        createElement('div', {
          class: 'head',
          style: {
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            height: '50vh',
            backgroundColor: '#333',
            color: '#fff',
          },
        }, [createText('Header')]),

        // list (50vh scroll)
        createElement(
          'div',
          {
            class: 'list',
            style: {
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              height: '50vh',
              overflow: 'scroll',
              backgroundColor: '#f1f1f1',
            },
          },
          Array.from({ length: 17 }).map((_, i) =>
            createElement(
              'div',
              {
                class: 'list-item',
                style: {
                  margin: '10px',
                  padding: '10px',
                  border: '1px solid #ccc',
                  backgroundColor: '#fff',
                  width: '100%',
                  maxWidth: '500px',
                  boxSizing: 'border-box',
                },
              },
              [createText(`Item ${i + 1}`)]
            )
          )
        ),

        // footer (50vh)
        createElement(
          'div',
          {
            class: 'footer',
            style: {
              display: 'flex',
              justifyContent: 'center',
              alignItems: 'center',
              height: '50vh',
              backgroundColor: '#333',
              color: '#fff',
              gap: '8px',
            },
          },
          [
            createElement('input', {
              class: 'input',
              placeholder: 'Enter your message...',
              style: {
                display: 'flex',
                padding: '10px',
                fontSize: '16px',
                border: 'none',
                borderRadius: '0',
                backgroundColor: '#f1f1f1',
                boxSizing: 'border-box',
                outline: 'none',
              },
            }),
            createElement('button', {
              class: 'button',
              style: {
                backgroundColor: '#4CAF50',
                color: '#fff',
                padding: '10px',
                fontSize: '16px',
                border: 'none',
                borderRadius: '0',
              },
            }, [createText('Send')]),
          ]
        ),
      ]
    );

    BODY.appendChild(chat);
    await snapshot();
  });
});


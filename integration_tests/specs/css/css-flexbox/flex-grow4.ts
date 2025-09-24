/* auto translated from flex-grow4.html */
describe('flex-grow4', () => {
  it('chat layout with wrapper and scrollable list', async () => {
    const chat = createElement(
      'div',
      {
        class: 'chat',
        style: {
          display: 'flex',
          overflowX: 'hidden',
          width: '100%',
          height: '100vh',
          flexDirection: 'column',
        },
      },
      [
        // wrapper with overflow hidden
        createElement(
          'div',
          { style: { overflow: 'hidden', width: '100%' } },
          [
            createElement(
              'div',
              {
                class: 'list',
                style: {
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  overflow: 'scroll',
                  backgroundColor: '#f1f1f1',
                  height: '100%',
                },
              },
              [
                createElement('div', { class: 'list-item', style: { margin: '30px', padding: '50px', border: '1px solid #ccc', backgroundColor: '#fff', width: '100%', maxWidth: '500px', boxSizing: 'border-box' } }, [createText('Item 1')]),
                createElement('div', { class: 'list-item', style: { margin: '30px', padding: '50px', border: '1px solid #ccc', backgroundColor: '#fff', width: '100%', maxWidth: '500px', boxSizing: 'border-box' } }, [createText('Item 2')]),
                createElement('div', { class: 'list-item', style: { margin: '30px', padding: '50px', border: '1px solid #ccc', backgroundColor: '#fff', width: '100%', maxWidth: '500px', boxSizing: 'border-box' } }, [createText('Item 3')]),
                createElement('div', { class: 'list-item', style: { margin: '30px', padding: '50px', border: '1px solid #ccc', backgroundColor: '#fff', width: '100%', maxWidth: '500px', boxSizing: 'border-box' } }, [createText('Item 4')]),
                createElement('div', { class: 'list-item', style: { margin: '30px', padding: '50px', border: '1px solid #ccc', backgroundColor: '#fff', width: '100%', maxWidth: '500px', boxSizing: 'border-box' } }, [createText('Item 5')]),
              ]
            ),
          ]
        ),
        // footer
        createElement(
          'div',
          {
            class: 'footer',
            style: {
              display: 'flex',
              justifyContent: 'center',
              alignItems: 'center',
              backgroundColor: '#333',
              color: '#fff',
              gap: '8px',
              padding: '8px',
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


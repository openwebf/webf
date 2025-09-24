/* auto translated from flex-grow3.html */
describe('flex-grow3', () => {
  it('tall scroll area with footer', async () => {
    const root = createElement(
      'div',
      { style: { display: 'flex', flexDirection: 'column', height: '100vh' } },
      [
        createElement(
          'div',
          {
            class: 'list',
            style: {
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              height: '90vh',
              overflowX: 'hidden',
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

    BODY.appendChild(root);
    await snapshot();
  });
});


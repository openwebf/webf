describe('width: fit-content on flex button with text+icon', () => {
  it('sizes to include inline text content', async () => {
    const container = createElement(
      'div',
      {
        style: {
          padding: '20px',
          backgroundColor: '#fff',
          width: '300px',
          border: '1px dashed #ddd',
          fontFamily: 'sans-serif'
        }
      },
      [
        createElement(
          'button',
          {
            style: {
              whiteSpace: 'nowrap',
              fontWeight: '500',
              fontSize: '14px',
              minHeight: '32px',
              width: 'fit-content',
              overflow: 'hidden',
              padding: '5px 12px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              borderRadius: '16px',
              border: '1px solid #222',
              backgroundColor: '#f5f5f5',
              color: '#111'
            }
          },
          [
            createElement('span', {}, [createText('限制限制')]),
            createElement(
              'span',
              {
                style: {
                  marginLeft: '4px',
                  display: 'inline-block',
                  width: '16px',
                  height: '16px',
                  backgroundColor: '#ff4d4f'
                }
              },
              []
            )
          ]
        )
      ]
    );

    BODY.appendChild(container);
    await snapshot();
  });

  it('sizes to include inline text content with replaced <img>', async () => {
    const container = createElement(
      'div',
      {
        style: {
          padding: '20px',
          backgroundColor: '#fff',
          width: '300px',
          border: '1px dashed #ddd',
          fontFamily: 'sans-serif'
        }
      },
      [
        createElement(
          'button',
          {
            style: {
              whiteSpace: 'nowrap',
              fontWeight: '500',
              fontSize: '14px',
              minHeight: '32px',
              width: 'fit-content',
              overflow: 'hidden',
              padding: '5px 12px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              borderRadius: '16px',
              border: '1px solid #222',
              backgroundColor: '#f5f5f5',
              color: '#111'
            }
          },
          [
            createElement('span', {}, [createText('限制限制')]),
            createElement(
              'span',
              {
                style: {
                  marginLeft: '4px',
                  display: 'inline-block',
                  width: '16px',
                  height: '16px'
                }
              },
              [
                createElement('img', {
                  src: 'assets/1x1-green.png',
                  style: {
                    width: '100%',
                    height: '100%'
                  }
                })
              ]
            )
          ]
        )
      ]
    );

    BODY.appendChild(container);
    await snapshot();
  });
});

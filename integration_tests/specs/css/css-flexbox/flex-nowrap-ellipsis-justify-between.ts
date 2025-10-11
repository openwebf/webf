describe('flex nowrap + ellipsis + justify-between', () => {
  it('nowrap middle item should not shrink below its max-content width and first item truncates', async () => {
    const container = createElement('div', {
      style: {
        display: 'flex',
        width: '200px',
        justifyContent: 'space-between',
        alignItems: 'center',
        border: '1px solid #ccc',
        padding: '4px'
      }
    }, [
      // Left item: truncation via overflow hidden + ellipsis + nowrap
      createElement('span', {
        style: {
          marginRight: '20px', // similar to mr-5
          overflow: 'hidden',
          textOverflow: 'ellipsis',
          whiteSpace: 'nowrap',
          border: '1px solid #000'
        }
      }, [
        createText('An Overflowed Text An Overflowed Text An Overflowed Text')
      ]),

      // Middle item: nowrap text that must not shrink below its max-content width
      createElement('span', {
        style: {
          whiteSpace: 'nowrap'
        }
      }, [
        createText('Hello World')
      ]),

      // Right side: raw text node as in the original example
      createText('1111')
    ]);

    BODY.appendChild(container);
    await snapshot();
  });
});


describe('flex: truncate + nowrap + third wraps', () => {
  it('left truncates with ellipsis, middle keeps max-content, right can wrap', async () => {
    const container = createElement('div', {
      style: {
        display: 'flex',
        width: '200px',
        justifyContent: 'space-between',
        // Default align-items is stretch in CSS; omit to match real behavior.
        backgroundColor: '#f7f7f7'
      }
    }, [
      // Left item: Tailwind-like "truncate" behavior
      createElement('span', {
        style: {
          marginRight: '20px', // mr-5
          overflow: 'hidden',
          textOverflow: 'ellipsis',
          whiteSpace: 'nowrap',
          border: '1px solid #000'
        }
      }, [
        createText('An Overflowed Text An Overflowed Text An Overflowed Text')
      ]),

      // Middle item: nowrap text (should not shrink below max-content)
      createElement('span', {
        style: {
          whiteSpace: 'nowrap',
          backgroundColor: 'lightgreen'
        }
      }, [
        createText('Hello World')
      ]),

      // Right item: spaces allow wrapping; expect to wrap when left truncates + middle keeps width
      createElement('span', {
        id: 'bug'
      }, [
        createText('111 222 333')
      ])
    ]);

    BODY.appendChild(container);
    await snapshot();
  });
});


describe('Line-height with fontSize inheritance scenarios', () => {
  it('child inherits line-height but uses parent fontSize', async () => {
    const container = createElement(
      'div',
      {
        style: {
          lineHeight: '1.5',
          fontSize: '28px',
          padding: '20px',
          border: '1px solid #ccc',
          backgroundColor: '#f5f5f5',
        },
      },
      [
        createElement('div', {
          style: {
            fontSize: '14px',
            color: '#666',
            marginBottom: '10px'
          }
        }, [
          createText('Expected: line-height = 42px (28px * 1.5)')
        ]),
        createElement(
          'span',
          {
            id: 'child',
            style: {
              border: '1px solid black',
            },
          },
          [createText('Zoo 中国')]
        )
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  it('child inherits line-height with numeric value and uses parent fontSize', async () => {
    const container = createElement(
      'div',
      {
        style: {
          lineHeight: '2',
          fontSize: '24px',
          padding: '20px',
          border: '1px solid #ccc',
          backgroundColor: '#f5f5f5',
        },
      },
      [
        createElement('div', {
          style: {
            fontSize: '14px',
            color: '#666',
            marginBottom: '10px'
          }
        }, [
          createText('Expected: line-height = 48px (24px * 2)')
        ]),
        createElement(
          'span',
          {
            id: 'child',
            style: {
              display: 'inline-block',
              border: '1px solid black',
            },
          },
          [createText('Zoo 中国')]
        )
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  it('child inherits line-height with px value and uses parent fontSize', async () => {
    const container = createElement(
      'div',
      {
        style: {
          lineHeight: '60px', // Explicitly setting pixel value
          fontSize: '30px',
          padding: '20px',
          border: '1px solid #ccc',
          backgroundColor: '#f5f5f5',
        },
      },
      [
        createElement('div', {
          style: {
            fontSize: '14px',
            color: '#666',
            marginBottom: '10px'
          }
        }, [
          createText('Expected: line-height = exactly 60px (absolute pixel value)')
        ]),
        createElement(
          'span',
          {
            id: 'child',
            style: {
              display: 'inline-block',
              border: '1px solid black',
            },
          },
          [createText('Zoo 中国')]
        )
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  it('child has own fontSize but inherits line-height', async () => {
    const container = createElement(
      'div',
      {
        style: {
          lineHeight: '1.5',
          fontSize: '28px',
          padding: '20px',
          border: '1px solid #ccc',
          backgroundColor: '#f5f5f5',
        },
      },
      [
        createElement('div', {
          style: {
            fontSize: '14px',
            color: '#666',
            marginBottom: '10px'
          }
        }, [
          createText('Expected: line-height = 21px (14px * 1.5), using child\'s font size')
        ]),
        createElement(
          'span',
          {
            id: 'child',
            style: {
              border: '1px solid black',
              display: 'inline-block',
              fontSize: '14px', // Child has its own font size
            },
          },
          [createText('Zoo 中国')]
        )
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  it('multi-level inheritance of line-height with different fontSizes', async () => {
    const container = createElement(
      'div',
      {
        style: {
          lineHeight: '1.5',
          fontSize: '28px',
          padding: '20px',
          border: '1px solid #ccc',
          backgroundColor: '#f5f5f5',
        },
      },
      [
        createElement('div', {
          style: {
            fontSize: '14px',
            color: '#666',
            marginBottom: '10px'
          }
        }, [
          createText('Expected: grandchild line-height = 30px (20px * 1.5)')
        ]),
        createElement(
          'div',
          {
            style: {
              fontSize: '20px', // Middle level with different font size
              border: '1px solid blue',
              padding: '10px',
              backgroundColor: '#e0e0ff',
            },
          },
          [
            createElement(
              'span',
              {
                id: 'grandchild',
                style: {
                  display: 'inline-block',
                  border: '1px solid black',
                },
              },
              [createText('Zoo 中国')]
            )
          ]
        )
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  it('child with em-based line-height inherits from parent fontSize', async () => {
    const container = createElement(
      'div',
      {
        style: {
          fontSize: '20px',
          padding: '20px',
          border: '1px solid #ccc',
          backgroundColor: '#f5f5f5',
        },
      },
      [
        createElement('div', {
          style: {
            fontSize: '14px',
            color: '#666',
            marginBottom: '10px'
          }
        }, [
          createText('Expected: line-height = 30px (20px * 1.5em)')
        ]),
        createElement(
          'span',
          {
            id: 'child',
            style: {
              border: '1px solid black',
              display: 'inline-block',
              lineHeight: '1.5em', // Using em unit
            },
          },
          [createText('Zoo 中国')]
        )
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  it('child with percentage line-height inherits from parent fontSize', async () => {
    const container = createElement(
      'div',
      {
        style: {
          fontSize: '24px',
          padding: '20px',
          border: '1px solid #ccc',
          backgroundColor: '#f5f5f5',
        },
      },
      [
        createElement('div', {
          style: {
            fontSize: '14px',
            color: '#666',
            marginBottom: '10px'
          }
        }, [
          createText('Expected: line-height = 36px (24px * 150%)')
        ]),
        createElement(
          'span',
          {
            id: 'child',
            style: {
              border: '1px solid black',
              display: 'inline-block',
              lineHeight: '150%', // Using percentage
            },
          },
          [createText('Zoo 中国')]
        )
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  it('nested text with mixed content inherits line-height correctly', async () => {
    const container = createElement(
      'div',
      {
        style: {
          lineHeight: '1.8',
          fontSize: '28px',
          padding: '20px',
          border: '1px solid #ccc',
          backgroundColor: '#f5f5f5',
          width: '300px',
        },
      },
      [
        createElement('div', {
          style: {
            fontSize: '14px',
            color: '#666',
            marginBottom: '10px'
          }
        }, [
          createText('Expected: Regular & red border = 50.4px (28px * 1.8), blue border = 25.2px (14px * 1.8)')
        ]),
        createText('Text before '),
        createElement(
          'span',
          {
            id: 'child1',
            style: {
            },
          },
          [createText('Zoo 中国')]
        ),
        createText(' and '),
        createElement(
          'span',
          {
            id: 'child2',
            style: {
              display: 'inline-block',
              fontSize: '14px', // Different font size
            },
          },
          [createText('smaller Zoo 中国')]
        ),
        createText(' text after')
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Recreate the exact example from the user
  it('recreates the specific example provided', async () => {
    const container = createElement(
      'div',
      {
        className: 'numeric mb-5 mt-5 flex items-center',
        style: {
          fontSize: '28px',
        },
      },
      [
        createElement('div', {
          style: {
            fontSize: '14px',
            color: '#666',
            marginBottom: '10px'
          }
        }, [
          createText('Expected: line-height uses default (~1.2) with 28px font = ~33.6px')
        ]),
        createElement(
          'span',
          {
            id: 'chinese',
            className: 'border',
            style: {
              display: 'inline-block',
              border: '1px solid black',
            },
          },
          [createText('Zoo 中国 ')]
        )
      ]
    );
    BODY.appendChild(container);
    await snapshot();
  });

  // Test updating the line-height and fontSize dynamically
  it('updates correctly when line-height changes after rendering', async (done) => {
    const container = createElement(
      'div',
      {
        style: {
          lineHeight: '1.2',
          fontSize: '24px',
          padding: '20px',
          border: '1px solid #ccc',
          backgroundColor: '#f5f5f5',
        },
      },
      [
        createElement('div', {
          style: {
            fontSize: '14px',
            color: '#666',
            marginBottom: '10px'
          }
        }, [
          createText('First snapshot: line-height = 28.8px (24px * 1.2)')
        ]),
        createElement(
          'span',
          {
            id: 'dynamic-child',
            style: {
              display: 'inline-block',
              border: '1px solid black',
            },
          },
          [createText('Zoo 中国')]
        )
      ]
    );
    BODY.appendChild(container);

    await snapshot();

    requestAnimationFrame(async () => {
      createElement('div', {
        style: {
          fontSize: '14px',
          color: '#666',
          marginBottom: '10px',
          marginTop: '20px'
        }
      }, [
        createText('Second snapshot: line-height = 60px (24px * 2.5)')
      ]);
      container.style.lineHeight = '2.5';
      await snapshot();
      done();
    });
  });
});

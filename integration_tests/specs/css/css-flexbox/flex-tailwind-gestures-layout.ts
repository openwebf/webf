/*auto generated*/
describe('flex tailwind gestures layout', () => {
  it('bugA-bugB-flex-wrap-tailwind', async () => {
    const flex = createElement(
      'div',
      {
        style: {
          display: 'flex',
          width: '360px',
          // Tailwind gap-4 ≈ 16px
          columnGap: '16px',
          rowGap: '16px',
          flexWrap: 'wrap',
          alignItems: 'stretch',
          boxSizing: 'border-box',
          backgroundColor: '#f5f5f5',
          padding: '8px',
        },
      },
      []
    );

    const bugA = createElement(
      'div',
      {
        id: 'bugA',
        style: {
          flex: '1 1 0%',
          minWidth: '100px',
          maxWidth: '100%',
          boxSizing: 'border-box',
          border: '2px solid #60a5fa',
          borderRadius: '12px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          overflow: 'hidden',
          background: 'linear-gradient(135deg,#eff6ff,#f5f3ff,#fdf2f8)',
        },
      },
      []
    );

    const bugAText = createElement(
      'div',
      {
        style: {
          textAlign: 'center',
          padding: '24px',
          boxSizing: 'border-box',
          fontFamily: 'system-ui, sans-serif',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              fontSize: '18px',
              fontWeight: '700',
              color: '#2563eb',
              marginBottom: '12px',
            },
          },
          [createText('👆 Touch Here to Test Gestures')]
        ),
        createElement(
          'div',
          {
            style: {
              fontSize: '12px',
              color: '#4b5563',
              marginBottom: '12px',
              lineHeight: '1.4',
            },
          },
          [
            createElement(
              'div',
              {},
              [createText('Tap • Double Tap • Long Press')]
            ),
            createElement(
              'div',
              {},
              [createText('Pan (Drag) • Pinch • Rotate')]
            ),
          ]
        ),
        createElement(
          'div',
          {
            style: {
              fontSize: '10px',
              color: '#6b7280',
              fontStyle: 'italic',
            },
          },
          [createText('This entire colored area is interactive')]
        ),
      ]
    );

    bugA.appendChild(bugAText);

    const bugB = createElement(
      'div',
      {
        id: 'bugB',
        style: {
          flex: '1 1 0%',
          minWidth: '120px',
          maxWidth: '100%',
          padding: '16px',
          boxSizing: 'border-box',
          backgroundColor: '#ffffff',
          border: '1px solid #e5e7eb',
          borderRadius: '12px',
          display: 'flex',
          flexDirection: 'column',
          rowGap: '16px',
        },
      },
      []
    );

    // Tap Gestures section
    const tapSection = createElement(
      'div',
      {},
      [
        createElement(
          'div',
          {
            style: {
              fontSize: '10px',
              fontWeight: '700',
              color: '#111827',
              marginBottom: '8px',
              textTransform: 'uppercase',
              letterSpacing: '0.08em',
            },
          },
          [createText('Tap Gestures')]
        ),
        createElement(
          'div',
          {
            style: {
              display: 'flex',
              columnGap: '8px',
            },
          },
          ['1', '2', '3'].map((label, index) =>
            createElement(
              'div',
              {
                style: {
                  flex: '1 1 0%',
                  backgroundColor: '#f3f4f6',
                  borderRadius: '8px',
                  padding: '8px',
                  textAlign: 'center',
                  boxSizing: 'border-box',
                },
              },
              [
                createElement(
                  'div',
                  {
                    style: {
                      fontSize: '20px',
                      fontWeight: '700',
                      color: '#2563eb',
                    },
                  },
                  [createText(label)]
                ),
                createElement(
                  'div',
                  {
                    style: {
                      fontSize: '10px',
                      color: '#6b7280',
                      marginTop: '2px',
                    },
                  },
                  [
                    createText(
                      index === 0
                        ? 'Tap'
                        : index === 1
                        ? 'Double'
                        : 'Long Press'
                    ),
                  ]
                ),
              ]
            )
          )
        ),
      ]
    );

    // Pan Gestures section
    const panSection = createElement(
      'div',
      {},
      [
        createElement(
          'div',
          {
            style: {
              fontSize: '10px',
              fontWeight: '700',
              color: '#111827',
              marginBottom: '8px',
              textTransform: 'uppercase',
              letterSpacing: '0.08em',
            },
          },
          [createText('Pan Gestures')]
        ),
        createElement(
          'div',
          {},
          [
            createElement(
              'div',
              {
                style: {
                  backgroundColor: '#f3f4f6',
                  borderRadius: '8px',
                  padding: '8px',
                  boxSizing: 'border-box',
                },
              },
              [createText('111')]
            ),
          ]
        ),
      ]
    );

    bugB.appendChild(tapSection);
    bugB.appendChild(panSection);

    flex.appendChild(bugA);
    flex.appendChild(bugB);

    BODY.appendChild(flex);

    await snapshot();
  });
}
);

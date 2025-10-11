describe('flex-listview-flex-parent', () => {
  it('should render WebFListView inside a flex column container with min-h-0 constraints', async () => {
    const root = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          height: '100vh',
          gap: '12px',
          backgroundColor: '#f3f4f6',
          padding: '12px',
          'box-sizing': 'border-box',
        },
      },
      [
        createElement(
          'div',
          {
            style: {
              fontSize: '18px',
              fontWeight: '600',
              color: '#1f2937',
            },
          },
          [createText('WebFListView in Flex Parent')]
        ),
        createElement(
          'div',
          {
            style: {
              display: 'flex',
              flex: '1',
              minHeight: '0',
              borderRadius: '8px',
              border: '1px solid #e5e7eb',
              backgroundColor: '#ffffff',
              'box-sizing': 'border-box',
            },
          },
          [
            createElement(
              'webf-listview',
              {
                id: 'flex-list-view',
                style: {
                  display: 'flex',
                  flexDirection: 'column',
                  flex: '1',
                  width: '100%',
                  minHeight: '0',
                  'box-sizing': 'border-box',
                },
              },
              Array.from({ length: 100 }, (_, i) =>
                createElement(
                  'div',
                  {
                    style: {
                      borderBottom: '1px solid #f3f4f6',
                      padding: '12px 16px',
                      color: '#111827',
                      'box-sizing': 'border-box',
                    },
                  },
                  [createText(`Item ${i + 1}`)]
                )
              )
            ),
          ]
        ),
      ]
    );

    BODY.appendChild(root);
    await snapshot();
  });
});

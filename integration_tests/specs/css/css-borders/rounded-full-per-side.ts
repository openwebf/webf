/*auto generated*/
describe('css-borders: rounded-full per-side colors', () => {
  it('rounded-full circle with top-only color', async () => {
    // Simulate Tailwind-like utilities
    const style = createElement('style', {}, [
      createText(`
        .w-12 { width: 48px; }
        .h-12 { height: 48px; }
        .rounded-full { border-radius: 9999px; }
        .border-2 { border-width: 2px; border-style: solid; }
        .border-line { border-color: #e5e7eb; }
      `)
    ]);
    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const div = createElement('div', {
      className: 'w-12 h-12 rounded-full border-2 border-line',
      style: {
        borderTopColor: 'red',
        backgroundColor: 'white'
      }
    });

    append(BODY, div);

    await snapshot();
  });

  it('rounded-full circle with per-side different colors', async () => {
    // Ensure utilities are present for this test as well
    const style = createElement('style', {}, [
      createText(`
        .w-12 { width: 48px; }
        .h-12 { height: 48px; }
        .rounded-full { border-radius: 9999px; }
        .border-2 { border-width: 2px; border-style: solid; }
      `)
    ]);
    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);
    const div = createElement('div', {
      className: 'w-12 h-12 rounded-full border-2',
      style: {
        borderTopColor: 'red',
        borderRightColor: 'green',
        borderBottomColor: 'blue',
        borderLeftColor: 'purple',
        borderStyle: 'solid',
        backgroundColor: 'white'
      }
    });

    append(BODY, div);

    await snapshot();
  });
});

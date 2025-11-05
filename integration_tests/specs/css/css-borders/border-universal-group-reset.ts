describe('css-borders: universal reset with grouped pseudos', () => {
  it('baseline: universal * reset works for normal elements', async () => {
    const style = createElement('style', {}, [
      createText(`
        * { box-sizing: border-box; border-width: 0; border-style: solid; border-color: #e5e7eb; }
        .border-b { border-bottom-width: 1px; }
        .border-dashed { border-style: dashed; }
        .border-line { border-color: black; }
      `)
    ]);
    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const div = createElement('div', {
      className: 'border-b border-dashed border-line',
      style: {
        width: '240px',
        height: '60px',
        backgroundColor: 'pink',
        margin: '8px'
      }
    }, [
      createText('expect only bottom border visible (baseline)')
    ]);

    append(BODY, div);

    await snapshot();
  });

  it('applies border-width:0 from "*,::before,::after" to normal elements', async () => {
    const style = createElement('style', {}, [
      createText(`
        /* Simulate Tailwind preflight reset */
        *,::before,::after{ box-sizing: border-box; border-width: 0; border-style: solid; border-color: #e5e7eb; }
        /* Utility-esque helpers */
        .border-b { border-bottom-width: 1px; }
        .border-dashed { border-style: dashed; }
        .border-line { border-color: black; }
      `)
    ]);
    const head = document.head || document.getElementsByTagName('head')[0];
    head.appendChild(style);

    const div = createElement('div', {
      className: 'border-b border-dashed border-line',
      style: {
        width: '240px',
        height: '60px',
        backgroundColor: 'red',
        margin: '8px'
      }
    }, [
      createText('border-b + dashed; expect only bottom border visible')
    ]);

    append(BODY, div);

    await snapshot();
  });
});

describe('Flexbox place-items', () => {
  function makeRowContainer(placeItemsValue: string, extra?: Partial<CSSStyleDeclaration>) {
    const cont = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'row',
          width: '200px',
          height: '100px',
          border: '1px solid #000',
          backgroundColor: '#f5f5f5',
          'place-items': placeItemsValue,
          ...(extra || {} as any),
        } as any,
      },
      [
        createElement('div', {
          style: {
            width: '60px',
            height: '20px',
            backgroundColor: '#3b82f6',
          }
        }),
        createElement('div', {
          style: {
            width: '40px',
            height: '30px',
            backgroundColor: '#22c55e',
          }
        }),
      ]
    );
    return cont as HTMLDivElement;
  }

  function makeColumnContainer(placeItemsValue: string) {
    const cont = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'column',
          width: '200px',
          height: '120px',
          border: '1px solid #000',
          backgroundColor: '#f5f5f5',
          'place-items': placeItemsValue,
        } as any,
      },
      [
        createElement('div', {
          style: {
            width: '50px',
            height: '40px',
            backgroundColor: '#ef4444',
          }
        }),
        createElement('div', {
          style: {
            width: '80px',
            height: '20px',
            backgroundColor: '#f59e0b',
          }
        }),
      ]
    );
    return cont as HTMLDivElement;
  }

  it('maps single-value center to align-items:center on row flex containers', async () => {
    const cont = makeRowContainer('center');
    BODY.appendChild(cont);
    await snapshot();

    const child = cont.children[0] as HTMLElement;
    const cr = cont.getBoundingClientRect();
    const ir = child.getBoundingClientRect();
    const expectedTop = cr.top + cont.clientTop + (cont.clientHeight - child.offsetHeight) / 2;
    expect(Math.abs(ir.top - expectedTop)).toBeLessThan(1.0);
  });

  it('supports flex-start and flex-end via place-items on row flex containers', async () => {
    // flex-start
    const contStart = makeRowContainer('flex-start');
    BODY.appendChild(contStart);
    await snapshot();
    const c0 = contStart.children[0] as HTMLElement;
    let cr = contStart.getBoundingClientRect();
    let ir = c0.getBoundingClientRect();
    expect(Math.abs(ir.top - (cr.top + contStart.clientTop))).toBeLessThan(1.0);

    // flex-end
    const contEnd = makeRowContainer('flex-end');
    BODY.appendChild(contEnd);
    await snapshot();
    const c1 = contEnd.children[0] as HTMLElement;
    cr = contEnd.getBoundingClientRect();
    ir = c1.getBoundingClientRect();
    const expectedBottom = cr.top + contEnd.clientTop + contEnd.clientHeight;
    expect(Math.abs((ir.top + c1.offsetHeight) - expectedBottom)).toBeLessThan(1.0);

    await snapshot();
  });

  it('stretches items when place-items: stretch and cross-size is auto', async () => {
    const cont = createElement(
      'div',
      {
        style: {
          display: 'flex',
          flexDirection: 'row',
          width: '220px',
          height: '90px',
          border: '1px solid #000',
          backgroundColor: '#eee',
          'place-items': 'stretch',
          gap: '10px',
        } as any,
      },
      [
        createElement('div', { style: { width: '60px', backgroundColor: '#60a5fa' } }),
        createElement('div', { style: { width: '60px', backgroundColor: '#34d399' } }),
      ]
    ) as HTMLDivElement;
    BODY.appendChild(cont);
    await snapshot();

    const a = cont.children[0] as HTMLElement;
    const b = cont.children[1] as HTMLElement;
    // Stretch fills the container's content box cross-size.
    expect(a.offsetHeight).toBe(cont.clientHeight);
    expect(b.offsetHeight).toBe(cont.clientHeight);
  });

  it('two-value syntax: place-items: center end (justify-items ignored in flex) keeps main-axis at start', async () => {
    const cont = makeRowContainer('center end');
    BODY.appendChild(cont);
    await snapshot();

    const first = cont.children[0] as HTMLElement;
    const cr = cont.getBoundingClientRect();
    const ir = first.getBoundingClientRect();

    // Cross-axis centered
    const expectedTop = cr.top + cont.clientTop + (cont.clientHeight - first.offsetHeight) / 2;
    expect(Math.abs(ir.top - expectedTop)).toBeLessThan(1.0);

    // Main-axis should remain default (flex-start) since justify-items is ignored in flexbox
    expect(Math.abs(ir.left - (cr.left + cont.clientLeft))).toBeLessThan(1.0);
  });

  it('works for column direction (horizontal centering via place-items:center)', async () => {
    const cont = makeColumnContainer('center');
    BODY.appendChild(cont);
    await snapshot();

    const child = cont.children[0] as HTMLElement;
    const cr = cont.getBoundingClientRect();
    const ir = child.getBoundingClientRect();
    const expectedLeft = cr.left + cont.clientLeft + (cont.clientWidth - child.offsetWidth) / 2;
    expect(Math.abs(ir.left - expectedLeft)).toBeLessThan(1.0);
  });

  it('updates when place-items changes dynamically', async (done) => {
    const cont = makeRowContainer('flex-start');
    BODY.appendChild(cont);
    await snapshot();

    requestAnimationFrame(async () => {
      cont.style.setProperty('place-items', 'center');
      await snapshot();

      const child = cont.children[0] as HTMLElement;
      const cr = cont.getBoundingClientRect();
      const ir = child.getBoundingClientRect();
      const expectedTop = cr.top + cont.clientTop + (cont.clientHeight - child.offsetHeight) / 2;
      expect(Math.abs(ir.top - expectedTop)).toBeLessThan(1.0);
      done();
    });
  });
});

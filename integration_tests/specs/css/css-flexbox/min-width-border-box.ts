describe('flex item min-width with border-box', () => {
  it('min-width should apply to border-box without adding padding/border', async () => {
    const container = createElement('div', {
      style: {
        display: 'flex',
        backgroundColor: '#eee',
        padding: '8px'
      }
    });

    const item = createElement('div', {
      style: {
        display: 'flex',
        height: '32px',
        minWidth: '80px',
        paddingLeft: '16px',
        paddingRight: '16px',
        border: '10px solid #000',
        backgroundColor: '#ccc',
        boxSizing: 'border-box'
      }
    }, [
      createText('1')
    ]);

    container.appendChild(item);
    BODY.appendChild(container);

    await snapshot();
  });

  it('min-width with padding only (no border)', async () => {
    const container = createElement('div', { style: { display: 'flex', backgroundColor: '#eef' } });
    const item = createElement('div', {
      style: {
        display: 'flex',
        minWidth: '120px',
        height: '32px',
        padding: '24px',
        boxSizing: 'border-box',
        backgroundColor: '#ccd'
      }
    }, [ createText('padding only') ]);
    container.appendChild(item);
    BODY.appendChild(container);
    await snapshot();
  });

  it('min-width with border only (no padding)', async () => {
    const container = createElement('div', { style: { display: 'flex', backgroundColor: '#efe' } });
    const item = createElement('div', {
      style: {
        display: 'flex',
        minWidth: '100px',
        height: '32px',
        border: '20px solid #666',
        boxSizing: 'border-box',
        backgroundColor: '#ded'
      }
    }, [ createText('border only') ]);
    container.appendChild(item);
    BODY.appendChild(container);
    await snapshot();
  });

  it('width smaller than min-width should clamp to min-width (with padding+border)', async () => {
    const container = createElement('div', { style: { display: 'flex', backgroundColor: '#ffe' } });
    const item = createElement('div', {
      style: {
        display: 'flex',
        width: '50px',
        minWidth: '120px',
        height: '32px',
        padding: '16px',
        border: '8px solid #333',
        boxSizing: 'border-box',
        backgroundColor: '#eed'
      }
    }, [ createText('clamp') ]);
    container.appendChild(item);
    BODY.appendChild(container);
    await snapshot();
  });

  it('percentage min-width on flex item uses border-box (row)', async () => {
    const root = createElement('div', { style: { display: 'flex', width: '240px', backgroundColor: '#f6f6f6' } });
    const item = createElement('div', {
      style: {
        display: 'flex',
        minWidth: '50%', // 120px border-box
        height: '32px',
        paddingLeft: '12px',
        paddingRight: '12px',
        border: '6px solid #999',
        boxSizing: 'border-box',
        backgroundColor: '#ddd'
      }
    }, [ createText('50%') ]);
    root.appendChild(item);
    BODY.appendChild(root);
    await snapshot();
  });

  it('min-width respected in column flex (cross-axis width)', async () => {
    const root = createElement('div', { style: { display: 'flex', flexDirection: 'column', backgroundColor: '#eef' } });
    const item = createElement('div', {
      style: {
        display: 'flex',
        minWidth: '140px',
        height: '40px',
        padding: '10px',
        border: '10px solid #444',
        boxSizing: 'border-box',
        backgroundColor: '#ddd'
      }
    }, [ createText('column min-width') ]);
    root.appendChild(item);
    BODY.appendChild(root);
    await snapshot();
  });

  it('max-width should also be border-box (no double-count)', async () => {
    const root = createElement('div', { style: { display: 'flex', backgroundColor: '#fdf' } });
    // Try to make inner wider than its max-width via width
    const item = createElement('div', {
      style: {
        display: 'flex',
        width: '240px',
        maxWidth: '120px',
        height: '32px',
        paddingLeft: '16px',
        paddingRight: '16px',
        border: '10px solid #000',
        boxSizing: 'border-box',
        backgroundColor: '#ccc'
      }
    }, [ createText('max clamp') ]);
    root.appendChild(item);
    BODY.appendChild(root);
    await snapshot();
  });
});

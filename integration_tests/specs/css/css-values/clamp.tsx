describe('clamp()', () => {
  it('width: clamp(min, preferred%, max) within bounds', async () => {
    const container = createElement('div', {
      style: {
        width: '320px',
        padding: '8px',
        border: '1px dashed #ccc',
        background: '#f8f8f8'
      }
    });

    const box = createElement('div', {
      style: {
        background: '#bada55',
        border: '1px solid #999',
        padding: '8px',
        color: '#333',
        width: 'clamp(140px, 50%, 280px)'
      }
    }, [createText('width: clamp(140px, 50%, 280px)')]);

    container.appendChild(box);
    BODY.appendChild(container);
    await snapshot();
  });

  it('clamps up to min when preferred < min', async () => {
    // 50% of 200px is 100px, so clamp to min 140px
    const container = createElement('div', {
      style: { width: '200px', padding: '8px', background: '#f0f0f0' }
    });
    const box = createElement('div', {
      style: {
        background: 'orange',
        width: 'clamp(140px, 50%, 280px)',
        height: '24px'
      }
    }, [createText('min clamp to 140px')]);
    container.appendChild(box);
    BODY.appendChild(container);
    await snapshot();
  });

  it('clamps down to max when preferred > max', async () => {
    // 50% of 800px is 400px, so clamp to max 280px
    const container = createElement('div', {
      style: { width: '800px', padding: '8px', background: '#f0f0f0' }
    });
    const box = createElement('div', {
      style: {
        background: 'lightblue',
        width: 'clamp(140px, 50%, 280px)',
        height: '24px'
      }
    }, [createText('max clamp to 280px')]);
    container.appendChild(box);
    BODY.appendChild(container);
    await snapshot();
  });
});


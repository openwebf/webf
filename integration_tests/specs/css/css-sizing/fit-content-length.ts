describe('width: fit-content(<length-percentage>)', () => {
  it('block element clamps to argument while shrinking to content', async () => {
    const container = createElement('div', {
      style: {
        'box-sizing': 'border-box',
        'padding': '12px',
        'background-color': '#f5f5f5',
      }
    }, [
      createElement('div', {
        style: {
          'box-sizing': 'border-box',
          'background-color': '#ffecb3',
          'border': '1px solid #ddd',
          'border-radius': '6px',
          'padding': '8px',
          // target under test
          'width': 'fit-content(200px)'
        }
      }, [
        createText('fit-content(200px) caps width to 200px based on content')
      ])
    ]);

    BODY.appendChild(container);
    await snapshot();
  });

  it('inside flex container behaves like width:auto with max-width cap', async () => {
    const flex = createElement('div', {
      style: {
        'box-sizing': 'border-box',
        'display': 'flex',
        'flex-wrap': 'wrap',
        'align-items': 'flex-start',
        'gap': '8px',
        'padding': '12px',
        'background-color': '#eef2ff',
        'width': '360px'
      }
    }, [
      createElement('div', {
        style: {
          'box-sizing': 'border-box',
          'background-color': '#fde68a',
          'border': '1px solid #ddd',
          'border-radius': '4px',
          'padding': '8px',
          // target under test
          'width': 'fit-content(200px)'
        }
      }, [
        createText('fit-content(200px) within flex should not collapse to 0; it should wrap text and cap near 200px')
      ])
    ]);

    BODY.appendChild(flex);
    await snapshot();
  });

  it('inline-block with fit-content(length) clamps intrinsic width', async () => {
    const host = createElement('div', {
      style: {
        'box-sizing': 'border-box',
        'padding': '10px',
        'background-color': '#fafafa'
      }
    }, [
      createElement('div', {
        style: {
          'display': 'inline-block',
          'box-sizing': 'border-box',
          'background-color': '#bbf7d0',
          'padding': '6px',
          'width': 'fit-content(140px)'
        }
      }, [
        createText('This is a long inline-block text that should wrap and not exceed 140px width.')
      ])
    ]);

    BODY.appendChild(host);
    await snapshot();
  });

  it('fit-content(50%) resolves percentage argument against containing block', async () => {
    const outer = createElement('div', {
      style: {
        'box-sizing': 'border-box',
        'width': '320px',
        'padding': '8px',
        'background-color': '#f0f9ff'
      }
    }, [
      createElement('div', {
        style: {
          'box-sizing': 'border-box',
          'background-color': '#e9d5ff',
          'padding': '6px',
          'width': 'fit-content(50%)'
        }
      }, [
        createText('Percentage argument should cap near half of 320px container width')
      ])
    ]);

    BODY.appendChild(outer);
    await snapshot();
  });
});


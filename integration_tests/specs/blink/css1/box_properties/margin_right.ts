describe('CSS1 margin-right', () => {
  it('margin-right 0 with silver background and text-align right', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.zero {background-color: silver; margin-right: 0; text-align: right;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const p_1 = createElement('p', {
      class: 'zero',
      style: {
        'background-color': 'silver',
        'margin-right': '0',
        'text-align': 'right',
        'box-sizing': 'border-box',
      }
    }, createText('This element has a class of zero.'));
    
    const body = createElement('body', {
      style: {
        'overflow': 'hidden',
        'box-sizing': 'border-box',
      }
    }, [p, pre, hr, p_1]);
    BODY.append(body);

    await snapshot();
  });

  it('margin-right 0.5in with aqua background and text-align right', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.one {margin-right: 0.5in; text-align: right; background-color: aqua;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const p_2 = createElement('p', {
      class: 'one',
      style: {
        'margin-right': '0.5in',
        'text-align': 'right',
        'background-color': 'aqua',
        'box-sizing': 'border-box',
      }
    }, createText('This sentence should have a right margin of half an inch.'));
    
    const body = createElement('body', {
      style: {
        'overflow': 'hidden',
        'box-sizing': 'border-box',
      }
    }, [p, pre, hr, p_2]);
    BODY.append(body);

    await snapshot();
  });

  it('margin-right 25px with aqua background and text-align right', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.two {margin-right: 25px; text-align: right; background-color: aqua;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const p_3 = createElement('p', {
      class: 'two',
      style: {
        'margin-right': '25px',
        'text-align': 'right',
        'background-color': 'aqua',
        'box-sizing': 'border-box',
      }
    }, createText('This sentence should have a right margin of 25 pixels.'));
    
    const body = createElement('body', {
      style: {
        'overflow': 'hidden',
        'box-sizing': 'border-box',
      }
    }, [p, pre, hr, p_3]);
    BODY.append(body);

    await snapshot();
  });

  it('margin-right 5em with aqua background and text-align right', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.three {margin-right: 5em; text-align: right; background-color: aqua;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const p_4 = createElement('p', {
      class: 'three',
      style: {
        'margin-right': '5em',
        'text-align': 'right',
        'background-color': 'aqua',
        'box-sizing': 'border-box',
      }
    }, createText('This sentence should have a right margin of 5 em.'));
    
    const body = createElement('body', {
      style: {
        'overflow': 'hidden',
        'box-sizing': 'border-box',
      }
    }, [p, pre, hr, p_4]);
    BODY.append(body);

    await snapshot();
  });

  it('margin-right 25% with aqua background and text-align right', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.four {margin-right: 25%; text-align: right; background-color: aqua;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const p_5 = createElement('p', {
      class: 'four',
      style: {
        'margin-right': '25%',
        'text-align': 'right',
        'background-color': 'aqua',
        'box-sizing': 'border-box',
      }
    }, createText('This sentence should have a right margin of 25%, which is calculated with respect to the width of the parent element.'));
    
    const body = createElement('body', {
      style: {
        'overflow': 'hidden',
        'box-sizing': 'border-box',
      }
    }, [p, pre, hr, p_5]);
    BODY.append(body);

    await snapshot();
  });

  it('margin-right 25px on ul with list items', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.two {margin-right: 25px; text-align: right; background-color: aqua;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const li = createElement('li', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The right margin on this unordered list has been set to 25 pixels, and the background color has been set to gray.'));
    const li_1 = createElement('li', {
      class: 'two',
      style: {
        'margin-right': '25px',
        'text-align': 'right',
        'background-color': 'white',
        'box-sizing': 'border-box',
      }
    }, createText('Another list item might not be such a bad idea, either, considering that such things do need to be double-checked.  This list item has its right margin also set to 25 pixels, which should combine with the list\'s margin to make 50 pixels of margin, and its background-color has been set to white.'));
    const li_2 = createElement('li', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('This is an unclassed list item'));
    const ul = createElement('ul', {
      class: 'two',
      style: {
        'margin-right': '25px',
        'text-align': 'right',
        'background-color': 'gray',
        'box-sizing': 'border-box',
      }
    }, [li, li_1, li_2]);
    
    const body = createElement('body', {
      style: {
        'overflow': 'hidden',
        'box-sizing': 'border-box',
      }
    }, [p, pre, hr, ul]);
    BODY.append(body);

    await snapshot();
  });

  it('margin-right 0 after ul', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.zero {background-color: silver; margin-right: 0; text-align: right;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const p_6 = createElement('p', {
      class: 'zero',
      style: {
        'background-color': 'silver',
        'margin-right': '0',
        'text-align': 'right',
        'box-sizing': 'border-box',
      }
    }, createText('This element has a class of zero.'));
    
    const body = createElement('body', {
      style: {
        'overflow': 'hidden',
        'box-sizing': 'border-box',
      }
    }, [p, pre, hr, p_6]);
    BODY.append(body);

    await snapshot();
  });

  it('margin-right -10px with aqua background', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.five {margin-right: -10px; background-color: aqua;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const p_7 = createElement('p', {
      class: 'five',
      style: {
        'margin-right': '-10px',
        'background-color': 'aqua',
        'box-sizing': 'border-box',
      }
    }, createText('This paragraph has a right margin of -10px, which should cause it to be wider than it might otherwise be, and it has a light blue background.  In all other respects, however, the element should be normal.  No styles have been applied to it besides the negative right margin and the background color.'));
    
    const body = createElement('body', {
      style: {
        'overflow': 'hidden',
        'box-sizing': 'border-box',
      }
    }, [p, pre, hr, p_7]);
    BODY.append(body);

    await snapshot();
  });
});
describe('CSS1 margin-top', () => {
  it('margin-top 0 with silver background first element', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.zero {background-color: silver; margin-top: 0;}
P, UL {margin-bottom: 0;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const p_1 = createElement('p', {
      class: 'zero',
      style: {
        'background-color': 'silver',
        'margin-top': '0',
        'margin-bottom': '0',
        'box-sizing': 'border-box',
      }
    }, createText('This element has a class of zero.'));
    
    const body = createElement('body', {
      style: {
        'box-sizing': 'border-box',
      }
    }, [p, pre, hr, p_1]);
    BODY.append(body);

    await snapshot();
  });

  it('margin-top 0 with silver background second element', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.zero {background-color: silver; margin-top: 0;}
P, UL {margin-bottom: 0;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const p_2 = createElement('p', {
      class: 'zero',
      style: {
        'background-color': 'silver',
        'margin-top': '0',
        'margin-bottom': '0',
        'box-sizing': 'border-box',
      }
    }, createText('This element also has a class of zero.'));
    
    const body = createElement('body', {
      style: {
        'box-sizing': 'border-box',
      }
    }, [p, pre, hr, p_2]);
    BODY.append(body);

    await snapshot();
  });

  it('margin-top 0.5in with aqua background', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.one {margin-top: 0.5in; background-color: aqua;}
P, UL {margin-bottom: 0;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const p_3 = createElement('p', {
      class: 'one',
      style: {
        'margin-top': '0.5in',
        'background-color': 'aqua',
        'margin-bottom': '0',
        'box-sizing': 'border-box',
      }
    }, createText(`This element should have a top margin of half an inch, which will require extra text in order to make sure that the margin isn't applied to each line.`));
    
    const body = createElement('body', {
      style: {
        'box-sizing': 'border-box',
      }
    }, [p, pre, hr, p_3]);
    BODY.append(body);

    await snapshot();
  });

  it('margin-top 25px with aqua background', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.two {margin-top: 25px; background-color: aqua;}
P, UL {margin-bottom: 0;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const p_4 = createElement('p', {
      class: 'two',
      style: {
        'margin-top': '25px',
        'background-color': 'aqua',
        'margin-bottom': '0',
        'box-sizing': 'border-box',
      }
    }, createText(`This element should have a top margin of 25 pixels, which will require extra text in order to make sure that the margin isn't applied to each line.`));
    
    const body = createElement('body', {
      style: {
        'box-sizing': 'border-box',
      }
    }, [p, pre, hr, p_4]);
    BODY.append(body);

    await snapshot();
  });

  it('margin-top 5em with aqua background', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.three {margin-top: 5em; background-color: aqua;}
P, UL {margin-bottom: 0;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const p_5 = createElement('p', {
      class: 'three',
      style: {
        'margin-top': '5em',
        'background-color': 'aqua',
        'margin-bottom': '0',
        'box-sizing': 'border-box',
      }
    }, createText(`This element should have a top margin of 5 em, which will require extra text in order to make sure that the margin isn't applied to each line.`));
    
    const body = createElement('body', {
      style: {
        'box-sizing': 'border-box',
      }
    }, [p, pre, hr, p_5]);
    BODY.append(body);

    await snapshot();
  });

  it('margin-top 25% with aqua background', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.four {margin-top: 25%; background-color: aqua;}
P, UL {margin-bottom: 0;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const p_6 = createElement('p', {
      class: 'four',
      style: {
        'margin-top': '25%',
        'background-color': 'aqua',
        'margin-bottom': '0',
        'box-sizing': 'border-box',
      }
    }, createText('This element should have a top margin of 25%, which is calculated with respect to the width of the parent element.  This will require extra text in order to test.'));
    
    const body = createElement('body', {
      style: {
        'box-sizing': 'border-box',
      }
    }, [p, pre, hr, p_6]);
    BODY.append(body);

    await snapshot();
  });

  it('margin-top 25px on ul with list items', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.two {margin-top: 25px; background-color: aqua;}
.five {margin-top: 25px;}
P, UL {margin-bottom: 0;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const li = createElement('li', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('This list has a margin-top of 25px, and a light blue background.'));
    const li_1 = createElement('li', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('Therefore, it ought to have such a margin.'));
    const li_2 = createElement('li', {
      class: 'five',
      style: {
        'margin-top': '25px',
        'box-sizing': 'border-box',
      }
    }, createText('This list item has a top margin of 25px, which should cause it to be offset in some fashion.'));
    const li_3 = createElement('li', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('This list item has no special styles applied to it.'));
    const ul = createElement('ul', {
      class: 'two',
      style: {
        'margin-top': '25px',
        'background-color': 'aqua',
        'margin-bottom': '0',
        'box-sizing': 'border-box',
      }
    }, [li, li_1, li_2, li_3]);
    
    const body = createElement('body', {
      style: {
        'box-sizing': 'border-box',
      }
    }, [p, pre, hr, ul]);
    BODY.append(body);

    await snapshot();
  });

  it('margin-top 0 after ul', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.zero {background-color: silver; margin-top: 0;}
P, UL {margin-bottom: 0;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const p_7 = createElement('p', {
      class: 'zero',
      style: {
        'background-color': 'silver',
        'margin-top': '0',
        'margin-bottom': '0',
        'box-sizing': 'border-box',
      }
    }, createText('This element has a class of zero.'));
    
    const body = createElement('body', {
      style: {
        'box-sizing': 'border-box',
      }
    }, [p, pre, hr, p_7]);
    BODY.append(body);

    await snapshot();
  });

  it('margin-top -10px with aqua background', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.six {margin-top: -10px; background-color: aqua;}
P, UL {margin-bottom: 0;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const p_8 = createElement('p', {
      class: 'six',
      style: {
        'margin-top': '-10px',
        'background-color': 'aqua',
        'margin-bottom': '0',
        'box-sizing': 'border-box',
      }
    }, createText('This element has a top margin of -10px, which should cause it to be shifted "upward" on the page, and no bottom margin.  No other styles have been applied to it besides a light blue background color.  In all other respects, the element should be normal.'));
    
    const body = createElement('body', {
      style: {
        'box-sizing': 'border-box',
      }
    }, [p, pre, hr, p_8]);
    BODY.append(body);

    await snapshot();
  });
});
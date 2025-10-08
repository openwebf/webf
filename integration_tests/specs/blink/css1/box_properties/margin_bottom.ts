describe('CSS1 margin-bottom', () => {
  it('margin-bottom 0 with silver background', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.zero {background-color: silver; margin-bottom: 0;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const p_1 = createElement('p', {
      class: 'zero',
      style: {
        'background-color': 'silver',
        'margin-bottom': '0',
        'margin-top': '0',
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

  it('margin-bottom 0.5in with aqua background', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.one {margin-bottom: 0.5in; background-color: aqua;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const p_2 = createElement('p', {
      class: 'one',
      style: {
        'margin-bottom': '0.5in',
        'background-color': 'aqua',
        'margin-top': '0',
        'box-sizing': 'border-box',
      }
    }, createText(`This sentence should have a bottom margin of half an inch, which will require extra text in order to make sure that the margin isn't applied to each line.`));
    
    const body = createElement('body', {
      style: {
        'box-sizing': 'border-box',
      }
    }, [p, pre, hr, p_2]);
    BODY.append(body);

    await snapshot();
  });

  it('margin-bottom 25px with aqua background', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.two {margin-bottom: 25px; background-color: aqua;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const p_3 = createElement('p', {
      class: 'two',
      style: {
        'margin-bottom': '25px',
        'background-color': 'aqua',
        'margin-top': '0',
        'box-sizing': 'border-box',
      }
    }, createText(`This sentence should have a bottom margin of 25 pixels, which will require extra text in order to make sure that the margin isn't applied to each line.`));
    
    const body = createElement('body', {
      style: {
        'box-sizing': 'border-box',
      }
    }, [p, pre, hr, p_3]);
    BODY.append(body);

    await snapshot();
  });

  it('margin-bottom 5em with aqua background', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.three {margin-bottom: 5em; background-color: aqua;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const p_4 = createElement('p', {
      class: 'three',
      style: {
        'margin-bottom': '5em',
        'background-color': 'aqua',
        'margin-top': '0',
        'box-sizing': 'border-box',
      }
    }, createText(`This sentence should have a bottom margin of 5 em, which will require extra text in order to make sure that the margin isn't applied to each line.`));
    
    const body = createElement('body', {
      style: {
        'box-sizing': 'border-box',
      }
    }, [p, pre, hr, p_4]);
    BODY.append(body);

    await snapshot();
  });

  it('margin-bottom 25% with aqua background', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.four {margin-bottom: 25%; background-color: aqua;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const p_5 = createElement('p', {
      class: 'four',
      style: {
        'margin-bottom': '25%',
        'background-color': 'aqua',
        'margin-top': '0',
        'box-sizing': 'border-box',
      }
    }, createText(`This element should have a bottom margin of 25%, which will require extra text in order to make sure that the margin isn't applied to each line.`));
    
    const body = createElement('body', {
      style: {
        'box-sizing': 'border-box',
      }
    }, [p, pre, hr, p_5]);
    BODY.append(body);

    await snapshot();
  });

  it('margin-bottom 0 with consecutive zero elements', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.zero {background-color: silver; margin-bottom: 0;}
P, UL {margin-top: 0;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const p_6 = createElement('p', {
      class: 'zero',
      style: {
        'background-color': 'silver',
        'margin-bottom': '0',
        'margin-top': '0',
        'box-sizing': 'border-box',
      }
    }, createText('This element has a class of zero.'));
    
    const p_7 = createElement('p', {
      class: 'zero',
      style: {
        'background-color': 'silver',
        'margin-bottom': '0',
        'margin-top': '0',
        'box-sizing': 'border-box',
      }
    }, createText('This element also has a class of zero.'));
    
    const body = createElement('body', {
      style: {
        'box-sizing': 'border-box',
      }
    }, [p, pre, hr, p_6, p_7]);
    BODY.append(body);

    await snapshot();
  });

  it('margin-bottom 25px on ul with list items', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.two {margin-bottom: 25px; background-color: aqua;}
.five {margin-bottom: 25px;}
P, UL {margin-top: 0;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const li = createElement('li', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('This list has a margin-bottom of 25px, and a light blue background.'));
    const li_1 = createElement('li', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('Therefore, it ought to have such a margin.'));
    const li_2 = createElement('li', {
      class: 'five',
      style: {
        'margin-bottom': '25px',
        'box-sizing': 'border-box',
      }
    }, createText('This list item has a bottom margin of 25px, which should cause it to be offset in some fashion.'));
    const li_3 = createElement('li', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('This list item has no special styles applied to it.'));
    const ul = createElement('ul', {
      class: 'two',
      style: {
        'margin-bottom': '25px',
        'background-color': 'aqua',
        'margin-top': '0',
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

  it('margin-bottom -10px with aqua background', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.six {margin-bottom: -10px; background-color: aqua;}
P, UL {margin-top: 0;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const p_8 = createElement('p', {
      class: 'six',
      style: {
        'margin-bottom': '-10px',
        'background-color': 'aqua',
        'margin-top': '0',
        'box-sizing': 'border-box',
      }
    }, createText('This paragraph has a bottom margin of -10px, which should cause elements after it to be shifted "upward" on the page, and no top margin.  No other styles have been applied to it besides a light blue background color.  In all other respects, the element should be normal.'));
    
    const body = createElement('body', {
      style: {
        'box-sizing': 'border-box',
      }
    }, [p, pre, hr, p_8]);
    BODY.append(body);

    await snapshot();
  });

  it('margin-bottom 0 final element one', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.zero {background-color: silver; margin-bottom: 0;}
P, UL {margin-top: 0;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const p_9 = createElement('p', {
      class: 'zero',
      style: {
        'background-color': 'silver',
        'margin-bottom': '0',
        'margin-top': '0',
        'box-sizing': 'border-box',
      }
    }, createText('This element has a class of zero.'));
    
    const body = createElement('body', {
      style: {
        'box-sizing': 'border-box',
      }
    }, [p, pre, hr, p_9]);
    BODY.append(body);

    await snapshot();
  });

  it('margin-bottom 0 final element two', async () => {
    const p = createElement('p', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText('The style declarations which apply to the text below are:'));
    const pre = createElement('pre', {
      style: {
        'box-sizing': 'border-box',
      }
    }, createText(`.zero {background-color: silver; margin-bottom: 0;}
P, UL {margin-top: 0;}`));
    const hr = createElement('hr', {
      style: {
        'box-sizing': 'border-box',
      }
    });
    
    const p_10 = createElement('p', {
      class: 'zero',
      style: {
        'background-color': 'silver',
        'margin-bottom': '0',
        'margin-top': '0',
        'box-sizing': 'border-box',
      }
    }, createText('This element also has a class of zero.'));
    
    const body = createElement('body', {
      style: {
        'box-sizing': 'border-box',
      }
    }, [p, pre, hr, p_10]);
    BODY.append(body);

    await snapshot();
  });
});
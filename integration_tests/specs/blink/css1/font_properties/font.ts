describe('CSS1 Test Suite: 5.2.7 font', () => {

  it('font italic small-caps 13pt Helvetica', async () => {
    // Create container with base font size
    const container = createElementWithStyle('div', {
      fontSize: '12px',
      padding: '20px',
      backgroundColor: 'white'
    });

    // Test case 1: italic small-caps 13pt Helvetica
    const one = createElementWithStyle('p', {
      font: 'italic small-caps 13pt Helvetica',
      margin: '10px 0'
    }, createText('This element should be 13pt. Helvetica which is in small-cap italics.'));

    append(container, one);
    append(BODY, container);

    await snapshot();
  });

  it('font 150%/150% serif', async () => {
    // Create container with base font size
    const container = createElementWithStyle('div', {
      fontSize: '12px',
      padding: '20px',
      backgroundColor: 'white'
    });

    // Test case 2: 150%/150% serif
    const two = createElementWithStyle('p', {
      font: '150%/150% serif',
      margin: '10px 0'
    }, createText('This element should be in a serif font. Its font-size should be 150% the base font size, and its line-height should 150% of that value (18px and 27px, respectively). Extra text is included for the purposes of testing this more effectively.'));

    append(container, two);
    append(BODY, container);

    await snapshot();
  });

  it('font 150%/150% sans-serif', async () => {
    // Create container with base font size
    const container = createElementWithStyle('div', {
      fontSize: '12px',
      padding: '20px',
      backgroundColor: 'white'
    });

    // Test case 3: 150%/150% sans-serif
    const three = createElementWithStyle('p', {
      font: '150%/150% sans-serif',
      margin: '10px 0'
    }, createText('This element should be in a sans-serif font. Its font-size should be 150% the base font size, and its line-height should 150% of that value (18px and 27px, respectively). Extra text is included for the purposes of testing this more effectively.'));

    append(container, three);
    append(BODY, container);

    await snapshot();
  });

  it('font small/200% cursive', async () => {
    // Create container with base font size
    const container = createElementWithStyle('div', {
      fontSize: '12px',
      padding: '20px',
      backgroundColor: 'white'
    });

    // Test case 4: small/200% cursive
    const four = createElementWithStyle('p', {
      font: 'small/200% cursive',
      margin: '10px 0'
    }, createText('This element should be in a cursive font, \'small\' in size, with a line-height 200% the height of the text\'s actual size. For example, if the font-size value small is calculated at 10px, then the line-height should be 20px. The actual value of the font-size is UA-dependent. Extra text is included for the purposes of testing this more effectively.'));

    append(container, four);
    append(BODY, container);

    await snapshot();
  });

  it('font italic small-caps 900 150%/150% sans-serif', async () => {
    // Create container with base font size
    const container = createElementWithStyle('div', {
      fontSize: '12px',
      padding: '20px',
      backgroundColor: 'white'
    });

    // Test case 5: italic small-caps 900 150%/150% sans-serif
    const five = createElementWithStyle('p', {
      font: 'italic small-caps 900 150%/150% sans-serif',
      margin: '10px 0'
    }, createText('This element should be in a sans-serif font, italicized and small caps, with a weight of 900. Its font-size should be 150% the base font size, and its line-height should be 150% of that value (18px and 27px, respectively). Extra text is included for the purposes of testing this more effectively.'));

    append(container, five);
    append(BODY, container);

    await snapshot();
  });

  it('font italic small-caps 100 150%/300% sans-serif', async () => {
    // Create container with base font size
    const container = createElementWithStyle('div', {
      fontSize: '12px',
      padding: '20px',
      backgroundColor: 'white'
    });

    // Test case 6: italic small-caps 100 150%/300% sans-serif
    const six = createElementWithStyle('p', {
      font: 'italic small-caps 100 150%/300% sans-serif',
      margin: '10px 0'
    }, createText('This element should be in a sans-serif font, italicized and small caps, with a weight of 100. Its font-size should be 150% the base font size, and its line-height should be 300% of that value (18px and 54px, respectively). Extra text is included for the purposes of testing this more effectively.'));

    append(container, six);
    append(BODY, container);

    await snapshot();
  });

  it('font italic small-caps 900 150%/2em monospace', async () => {
    // Create container with base font size
    const container = createElementWithStyle('div', {
      fontSize: '12px',
      padding: '20px',
      backgroundColor: 'white'
    });

    // Test case 7: italic small-caps 900 150%/2em monospace
    const seven = createElementWithStyle('p', {
      font: 'italic small-caps 900 150%/2em monospace',
      margin: '10px 0'
    }, createText('This element should be in a monospace font, italicized and small caps, with a weight of 900. Its font-size should be 150% the base font size, and its line-height should be 2em, or twice the element\'s font size (18px and 36px, respectively). Extra text is included for the purposes of testing this more effectively.'));

    append(container, seven);
    append(BODY, container);

    await snapshot();
  });

  it('font italic small-caps 500 150%/1in sans-serif', async () => {
    // Create container with base font size
    const container = createElementWithStyle('div', {
      fontSize: '12px',
      padding: '20px',
      backgroundColor: 'white'
    });

    // Test case 8: italic small-caps 500 150%/1in sans-serif
    const eight = createElementWithStyle('p', {
      font: 'italic small-caps 500 150%/1in sans-serif',
      margin: '10px 0'
    }, createText('This element should be in a sans-serif font, italicized and small caps, with a weight of 500. Its font-size should be 150% the base font size, or 18px, and its line-height should be 1in. Extra text is included for the purposes of testing this more effectively.'));

    append(container, eight);
    append(BODY, container);

    await snapshot();
  });

  it('font oblique normal 700 18px/200% sans-serif', async () => {
    // Create container with base font size
    const container = createElementWithStyle('div', {
      fontSize: '12px',
      padding: '20px',
      backgroundColor: 'white'
    });

    // Test case 9: oblique normal 700 18px/200% sans-serif
    const nine = createElementWithStyle('p', {
      font: 'oblique normal 700 18px/200% sans-serif',
      margin: '10px 0'
    }, createText('This element should be in a sans-serif font, oblique and not small-caps, with a weight of 700. Its font-size should be 18 pixels, and its line-height should be 36px (200% this element\'s font size). Extra text is included for the purposes of testing this more effectively.'));

    append(container, nine);
    append(BODY, container);

    await snapshot();
  });

  it('font normal 400 80%/2.5 sans-serif', async () => {
    // Create container with base font size
    const container = createElementWithStyle('div', {
      fontSize: '12px',
      padding: '20px',
      backgroundColor: 'white'
    });

    // Test case 10: normal 400 80%/2.5 sans-serif
    const ten = createElementWithStyle('p', {
      font: 'normal 400 80%/2.5 sans-serif',
      margin: '10px 0'
    }, createText('This element should be in a sans-serif font, with a weight of 400. Its font-size should be 80% of 12px, or 9.6px, and its line-height shoud be 2.5 times that, or 24px. Extra text is included for the purposes of testing this more effectively.'));

    append(container, ten);
    append(BODY, container);

    await snapshot();
  });

  it('font with silver background span', async () => {
    // Create container with base font size
    const container = createElementWithStyle('div', {
      fontSize: '12px',
      padding: '20px',
      backgroundColor: 'white'
    });

    // Test case 11: Test with silver background
    const eleven = createElementWithStyle('p', {
      font: 'italic small-caps 100 150%/300% sans-serif',
      margin: '10px 0'
    });
    const span = createElementWithStyle('span', {
      backgroundColor: 'silver'
    }, createText('This element should be in a sans-serif font, italicized and small caps, with a weight of 100. Its font-size should be 150% the base font size, and its line-height should be 300% of that value (18px and 54px, respectively). The text should have a silver background. The background color has been set on an inline element and should therefore only cover the text, not the interline spacing.'));
    eleven.appendChild(span);

    append(container, eleven);
    append(BODY, container);

    await snapshot();
  });

});

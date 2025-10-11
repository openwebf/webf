describe('CSS1 Test Suite: 5.2.2 font-family', () => {
  it('should render different font families correctly', async () => {
    // Create container
    const container = createElementWithStyle('div', {
      padding: '20px',
      backgroundColor: 'white'
    });

    // First division with serif base
    const divA = createElementWithStyle('div', {
      fontFamily: 'serif',
      marginBottom: '20px'
    });

    const divABase = createElementWithStyle('p', {
      margin: '10px 0'
    }, createText('This sentence is normal for the first division, which is the next five sentences; it should be a serif font.'));

    const one = createElementWithStyle('p', {
      fontFamily: 'serif',
      margin: '10px 0'
    }, createText('This sentence should be in a serif font.'));

    const two = createElementWithStyle('p', {
      fontFamily: 'sans-serif',
      margin: '10px 0'
    }, createText('This sentence should be in a sans-serif font.'));

    const three = createElementWithStyle('p', {
      fontFamily: 'cursive',
      margin: '10px 0'
    }, createText('This sentence should be in a cursive font.'));

    const four = createElementWithStyle('p', {
      fontFamily: 'fantasy',
      margin: '10px 0'
    }, createText('This sentence should be in a fantasy font.'));

    const five = createElementWithStyle('p', {
      fontFamily: 'monospace',
      margin: '10px 0'
    }, createText('This sentence should be in a monospace font.'));

    append(divA, divABase);
    append(divA, one);
    append(divA, two);
    append(divA, three);
    append(divA, four);
    append(divA, five);

    // Test fallback font families
    const six = createElementWithStyle('p', {
      fontFamily: 'sans-serif,cursive',
      margin: '10px 0'
    }, createText('This sentence should be in a sans-serif font, not cursive.'));

    const seven = createElementWithStyle('p', {
      fontFamily: 'monospace,serif',
      margin: '10px 0'
    }, createText('This sentence should be in a monospace font, not serif.'));

    // Second division with monospace base
    const divB = createElementWithStyle('div', {
      fontFamily: 'monospace',
      marginTop: '20px'
    });

    const divBBase = createElementWithStyle('p', {
      margin: '10px 0'
    }, createText('This sentence is normal for the first division, which is the next five sentences; it should be a monospace font.'));

    const oneB = createElementWithStyle('p', {
      fontFamily: 'serif',
      margin: '10px 0'
    }, createText('This sentence should be in a serif font.'));

    const twoB = createElementWithStyle('p', {
      fontFamily: 'sans-serif',
      margin: '10px 0'
    }, createText('This sentence should be in a sans-serif font.'));

    const threeB = createElementWithStyle('p', {
      fontFamily: 'cursive',
      margin: '10px 0'
    }, createText('This sentence should be in a cursive font.'));

    const fourB = createElementWithStyle('p', {
      fontFamily: 'fantasy',
      margin: '10px 0'
    }, createText('This sentence should be in a fantasy font.'));

    const fiveB = createElementWithStyle('p', {
      fontFamily: 'monospace',
      margin: '10px 0'
    }, createText('This sentence should be in a monospace font.'));

    append(divB, divBBase);
    append(divB, oneB);
    append(divB, twoB);
    append(divB, threeB);
    append(divB, fourB);
    append(divB, fiveB);

    // Add all elements to container
    append(container, divA);
    append(container, six);
    append(container, seven);
    append(container, divB);

    append(BODY, container);

    await snapshot();
  });

});

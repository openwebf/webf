describe('CSS1 Test Suite: 5.2.3 font-style', () => {

  it('should render different font styles correctly', async () => {
    // Create container
    const container = createElementWithStyle('div', {
      padding: '20px',
      backgroundColor: 'white'
    });

    // Test case 1: italic with normal span
    const one = createElementWithStyle('p', {
      fontStyle: 'italic',
      margin: '10px 0'
    });
    one.appendChild(createText('This paragraph should be in italics, but the last word of the sentence should be '));
    const oneSpan = createElementWithStyle('span', {
      fontStyle: 'normal'
    }, createText('normal'));
    one.appendChild(oneSpan);
    one.appendChild(createText('.'));

    // Test case 2: oblique
    const two = createElementWithStyle('p', {
      fontStyle: 'oblique',
      margin: '10px 0'
    }, createText('This paragraph should be oblique.'));

    // Test case 3: italic element with normal override
    const three = createElementWithStyle('p', {
      margin: '10px 0'
    });
    const italic = createElementWithStyle('i', {
      fontStyle: 'normal'
    }, createText('This paragraph should be normal.'));
    three.appendChild(italic);

    // Add all elements to container
    append(container, one);
    append(container, two);
    append(container, three);

    append(BODY, container);

    await snapshot();
  });

});
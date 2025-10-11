describe('CSS1 Test Suite: 5.2.4 font-variant', () => {

  xit('should render font variants correctly', async () => {
    // Create container
    const container = createElementWithStyle('div', {
      padding: '20px',
      backgroundColor: 'white'
    });

    // Test case 1: small-caps
    const one = createElementWithStyle('p', {
      fontVariant: 'small-caps',
      margin: '10px 0'
    }, createText('This Paragraph should be in Small Caps.'));

    // Test case 2: small-caps with normal span
    const two = createElementWithStyle('p', {
      fontVariant: 'small-caps',
      margin: '10px 0'
    });
    two.appendChild(createText('This Paragraph should be in Small Caps, but the Last Word in the Sentence should be '));
    const twoSpan = createElementWithStyle('span', {
      fontVariant: 'normal'
    }, createText('Normal'));
    two.appendChild(twoSpan);
    two.appendChild(createText('.'));

    // Add all elements to container
    append(container, one);
    append(container, two);

    append(BODY, container);

    await snapshot();
  });

});
describe('Text element reflow in horizontal flex layout', () => {
  it('should correctly reflow text when width changes in horizontal flex layout', async () => {
    // Create a flex container with horizontal direction
    const container = document.createElement('div');
    container.style.display = 'flex';
    container.style.flexDirection = 'row';
    container.style.width = '300px';
    container.style.padding = '10px';
    container.style.border = '2px solid black';
    container.style.backgroundColor = '#f0f0f0';

    // Create a text element with auto height
    const textElement = createElement('text', {
      style: {
        flex: '1',
        padding: '5px',
        border: '1px solid blue',
        backgroundColor: 'lightblue'
      }
    }, [
      createText('This is a long text that should wrap and reflow properly when the container width changes. The height should adjust automatically based on the content.')
    ]);

    // Add elements to DOM
    container.appendChild(textElement);
    document.body.appendChild(container);

    // Take first snapshot
    await snapshot();

    // Change container width to trigger reflow
    container.style.width = '500px';

    // Take snapshot after width change
    await snapshot();

    // Make container even narrower to test another reflow scenario
    container.style.width = '200px';

    // Take final snapshot
    await snapshot();
  });

  it('should handle text with variable content in horizontal flex layout', async () => {
    // Create a flex container with horizontal direction
    const container = document.createElement('div');
    container.style.display = 'flex';
    container.style.flexDirection = 'row';
    container.style.width = '400px';
    container.style.padding = '10px';
    container.style.border = '2px solid black';

    // Create a text element with initial content
    const textElement = createElement('text', {
      style: {
        flex: '1',
        padding: '5px',
        border: '1px solid green',
        backgroundColor: 'lightgreen'
      }
    }, [
      createText('Initial short text content')
    ]);

    // Add elements to DOM
    container.appendChild(textElement);
    document.body.appendChild(container);

    // Take first snapshot
    await snapshot();

    // Change text content to trigger reflow
    textElement.textContent = 'Now this text has much more content and should expand to multiple lines within the flex container, adjusting its height automatically';

    // Take snapshot after content change
    await snapshot();

    // Change container width at the same time as changing content
    container.style.width = '250px';
    textElement.textContent = 'Changed width and content simultaneously to test complex reflow behavior';

    // Take final snapshot
    await snapshot();
  });
});

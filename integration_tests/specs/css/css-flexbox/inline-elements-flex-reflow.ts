describe('Inline elements with text in flex layout', () => {
  it('should properly reflow inline element with text in horizontal flex layout', async () => {
    // Create a flex container with horizontal direction
    const container = document.createElement('div');
    container.style.display = 'flex';
    container.style.flexDirection = 'row';
    container.style.width = '350px';
    container.style.padding = '10px';
    container.style.border = '2px solid black';
    container.style.backgroundColor = '#f0f0f0';

    // Create an inline element with text
    const inlineElement = document.createElement('span');
    inlineElement.style.display = 'inline';
    inlineElement.style.padding = '5px';
    inlineElement.style.border = '1px solid blue';
    inlineElement.style.backgroundColor = 'lightblue';
    inlineElement.textContent = 'This is an inline element with text that should reflow properly when the container width changes. The height should adjust automatically based on the content.';

    // Create another element to take up some space
    const spaceTaker = document.createElement('div');
    spaceTaker.style.width = '100px';
    spaceTaker.style.backgroundColor = 'lightgray';
    spaceTaker.textContent = 'Fixed width';

    // Add elements to DOM
    container.appendChild(spaceTaker);
    container.appendChild(inlineElement);
    document.body.appendChild(container);

    // Take first snapshot
    await snapshot();

    // Change container width to trigger reflow
    container.style.width = '600px';

    // Take snapshot after width change
    await snapshot();

    // Make container narrower to test another reflow scenario
    container.style.width = '250px';

    // Take final snapshot
    await snapshot();
  });

  it('should handle inline-block element with text in horizontal flex layout', async () => {
    // Create a flex container with horizontal direction
    const container = document.createElement('div');
    container.style.display = 'flex';
    container.style.flexDirection = 'row';
    container.style.width = '350px';
    container.style.padding = '10px';
    container.style.border = '2px solid black';

    // Create an inline-block element with text
    const inlineBlockElement = document.createElement('div');
    inlineBlockElement.style.display = 'inline-block';
    inlineBlockElement.style.flex = '1';
    inlineBlockElement.style.padding = '5px';
    inlineBlockElement.style.border = '1px solid green';
    inlineBlockElement.style.backgroundColor = 'lightgreen';
    inlineBlockElement.textContent = 'This is an inline-block element that should properly reflow its text content when width changes occur.';

    // Add elements to DOM
    container.appendChild(inlineBlockElement);
    document.body.appendChild(container);

    // Take first snapshot
    await snapshot();

    // Change container width to trigger reflow
    container.style.width = '250px';

    // Take snapshot after width change
    await snapshot();

    // Add more content to test text reflow with changed content
    inlineBlockElement.textContent = 'This is an inline-block element with significantly more text content that should properly reflow when width changes occur. Testing how the height adjusts with multiple lines of text.';

    // Take final snapshot
    await snapshot();
  });

  it('should handle inline-flex element with text in horizontal flex layout', async () => {
    // Create a flex container with horizontal direction
    const container = document.createElement('div');
    container.style.display = 'flex';
    container.style.flexDirection = 'row';
    container.style.width = '350px';
    container.style.padding = '10px';
    container.style.border = '2px solid black';

    // Create an inline-flex element with text
    const inlineFlexElement = document.createElement('div');
    inlineFlexElement.style.display = 'inline-flex';
    inlineFlexElement.style.flex = '1';
    inlineFlexElement.style.padding = '5px';
    inlineFlexElement.style.border = '1px solid purple';
    inlineFlexElement.style.backgroundColor = 'lavender';

    // Add text to the inline-flex element
    const textSpan = document.createElement('span');
    textSpan.textContent = 'This text is inside an inline-flex element which is itself inside a flex container. It should reflow properly when width changes.';
    inlineFlexElement.appendChild(textSpan);

    // Add elements to DOM
    container.appendChild(inlineFlexElement);
    document.body.appendChild(container);

    // Take first snapshot
    await snapshot();

    // Change container width to trigger reflow
    container.style.width = '250px';

    // Take snapshot after width change
    await snapshot();

    // Change text content to test reflow with different content
    textSpan.textContent = 'Updated text content in the inline-flex element to test dynamic reflow behavior with different text length.';

    // Take final snapshot
    await snapshot();
  });
});

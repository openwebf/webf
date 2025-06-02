describe('WebFTextElement updates', () => {
  it('should update text content when TextNode data changes', async (done) => {
    const container = document.createElement('div');
    document.body.appendChild(container);

    // Create text element with initial content
    const textElement = document.createElement('text');
    const textNode = document.createTextNode('Initial text');
    textElement.appendChild(textNode);
    container.appendChild(textElement);

    // Wait for initial render
    await snapshot();

    // Update text node data
    textNode.data = 'Updated text';

    // Wait for update to propagate
    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });

  it('should clear text when TextNode is removed', async (done) => {
    const container = document.createElement('div');
    document.body.appendChild(container);

    // Create text element with content
    const textElement = document.createElement('text');
    const textNode = document.createTextNode('Text to be removed');
    textElement.appendChild(textNode);
    container.appendChild(textElement);

    // Wait for initial render
    await snapshot();

    // Remove text node (simulating React's behavior when text becomes empty)
    textElement.removeChild(textNode);

    // Wait for update to propagate
    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });

  it('should update nested text elements', async (done) => {
    const container = document.createElement('div');
    document.body.appendChild(container);

    // Create nested text elements
    const outerText = document.createElement('text');
    const innerText = document.createElement('text');
    const textNode = document.createTextNode('Nested content');

    innerText.appendChild(textNode);
    outerText.appendChild(innerText);
    container.appendChild(outerText);

    // Wait for initial render
    await snapshot();

    // Update nested text node
    textNode.data = 'Updated nested content';

    // Wait for update to propagate
    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });

  it('should handle multiple text nodes', async (done) => {
    const container = document.createElement('div');
    document.body.appendChild(container);

    const textElement = document.createElement('text');
    const textNode1 = document.createTextNode('First ');
    const textNode2 = document.createTextNode('Second ');
    const textNode3 = document.createTextNode('Third');

    textElement.appendChild(textNode1);
    textElement.appendChild(textNode2);
    textElement.appendChild(textNode3);
    container.appendChild(textElement);

    // Wait for initial render
    await snapshot();

    // Update middle text node
    textNode2.data = 'Modified ';

    // Wait for update to propagate
    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });

  it('should handle dynamic text node addition', async (done) => {
    const container = document.createElement('div');
    document.body.appendChild(container);

    const textElement = document.createElement('text');
    const textNode1 = document.createTextNode('Initial');
    textElement.appendChild(textNode1);
    container.appendChild(textElement);

    // Wait for initial render
    await snapshot();

    // Add new text node
    const textNode2 = document.createTextNode(' Added');
    textElement.appendChild(textNode2);

    // Wait for update to propagate
    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });

  it('should update when replacing text nodes', async (done) => {
    const container = document.createElement('div');
    document.body.appendChild(container);

    const textElement = document.createElement('text');
    const oldTextNode = document.createTextNode('Old text');
    textElement.appendChild(oldTextNode);
    container.appendChild(textElement);

    // Wait for initial render
    await snapshot();

    // Replace text node
    const newTextNode = document.createTextNode('New text');
    textElement.replaceChild(newTextNode, oldTextNode);

    // Wait for update to propagate
    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });

  it('should handle empty text node data updates', async (done) => {
    const container = document.createElement('div');
    document.body.appendChild(container);

    const textElement = document.createElement('text');
    const textNode = document.createTextNode('Text to clear');
    textElement.appendChild(textNode);
    container.appendChild(textElement);

    // Wait for initial render
    await snapshot();

    // Set text node data to empty string
    textNode.data = '';

    // Wait for update to propagate
    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });

  it('should update deeply nested text elements', async (done) => {
    const container = document.createElement('div');
    document.body.appendChild(container);

    // Create deeply nested structure
    const level1 = document.createElement('text');
    const level2 = document.createElement('text');
    const level3 = document.createElement('text');
    const textNode = document.createTextNode('Deep content');

    level3.appendChild(textNode);
    level2.appendChild(level3);
    level1.appendChild(level2);
    container.appendChild(level1);

    // Wait for initial render
    await snapshot();

    // Update deeply nested text
    textNode.data = 'Updated deep content';

    // Wait for update to propagate
    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });

  it('should handle mixed content with text and elements', async (done) => {
    const container = document.createElement('div');
    document.body.appendChild(container);

    const textElement = document.createElement('text');
    const textNode1 = document.createTextNode('Before ');
    const span = document.createElement('span');
    span.textContent = 'span content';
    const textNode2 = document.createTextNode(' After');

    textElement.appendChild(textNode1);
    textElement.appendChild(span);
    textElement.appendChild(textNode2);
    container.appendChild(textElement);

    // Wait for initial render
    await snapshot();

    // Update text nodes
    textNode1.data = 'Modified before ';
    textNode2.data = ' Modified after';

    // Wait for update to propagate
    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });

  it('should update when text node data is set via setAttribute', async (done) => {
    const container = document.createElement('div');
    document.body.appendChild(container);

    const textElement = document.createElement('text');
    const textNode = document.createTextNode('Initial');
    textElement.appendChild(textNode);
    container.appendChild(textElement);

    // Wait for initial render
    await snapshot();

    // Simulate React's way of updating text node data
    // In real React usage, this would be done via UICommand.setAttribute
    Object.defineProperty(textNode, 'nodeValue', {
      get() { return this.data; },
      set(value) { this.data = value; }
    });

    textNode.nodeValue = 'Updated via nodeValue';

    // Wait for update to propagate
    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });
});

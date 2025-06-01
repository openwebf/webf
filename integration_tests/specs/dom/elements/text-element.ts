describe('WebF Text Element', () => {
  it('should update text node data under text element', async () => {
    const textElement = document.createElement('TEXT');
    const textNode = document.createTextNode('Initial text content');

    textElement.appendChild(textNode);
    document.body.appendChild(textElement);

    await snapshot();

    // Update text node data
    textNode.data = 'Updated text content';

    await snapshot();
  });

  it('should handle multiple text nodes in text element', async () => {
    const textElement = document.createElement('TEXT');
    const textNode1 = document.createTextNode('First ');
    const textNode2 = document.createTextNode('Second ');
    const textNode3 = document.createTextNode('Third');

    textElement.appendChild(textNode1);
    textElement.appendChild(textNode2);
    textElement.appendChild(textNode3);
    document.body.appendChild(textElement);

    await snapshot();

    // Update all text nodes
    textNode1.data = 'Updated First ';
    textNode2.data = 'Updated Second ';
    textNode3.data = 'Updated Third';

    await snapshot();
  });

  it('should handle nested text elements with text nodes', async () => {
    const outerText = document.createElement('TEXT');
    outerText.style.fontSize = '20px';
    outerText.style.color = 'blue';

    const textNode1 = document.createTextNode('Outer text ');

    const innerText = document.createElement('TEXT');
    innerText.style.color = 'red';
    innerText.style.fontWeight = 'bold';

    const textNode2 = document.createTextNode('Inner text');

    const textNode3 = document.createTextNode(' More outer text');

    innerText.appendChild(textNode2);
    outerText.appendChild(textNode1);
    outerText.appendChild(innerText);
    outerText.appendChild(textNode3);
    document.body.appendChild(outerText);

    await snapshot();

    // Update text nodes
    textNode1.data = 'Updated outer ';
    textNode2.data = 'Updated inner';
    textNode3.data = ' Updated more';

    await snapshot();
  });

  it('should handle empty text node updates in text element', async () => {
    const textElement = document.createElement('TEXT');
    textElement.style.fontSize = '16px';
    textElement.style.color = 'green';

    const textNode = document.createTextNode('');
    textElement.appendChild(textNode);
    document.body.appendChild(textElement);

    await snapshot();

    // Update from empty to content
    textNode.data = 'Now has content';

    await snapshot();

    // Update back to empty
    textNode.data = '';

    await snapshot();

    // Update to new content
    textNode.data = 'Content again';

    await snapshot();
  });

  it('should preserve CSS styling after text node updates', async () => {
    const textElement = document.createElement('TEXT');
    textElement.style.fontSize = '24px';
    textElement.style.color = '#ff6600';
    textElement.style.textDecoration = 'underline';
    textElement.style.fontFamily = 'Arial, sans-serif';
    textElement.style.letterSpacing = '2px';
    textElement.style.textShadow = '2px 2px 4px rgba(0,0,0,0.3)';

    const textNode = document.createTextNode('Styled text');
    textElement.appendChild(textNode);
    document.body.appendChild(textElement);

    await snapshot();

    // Update text and verify styling is preserved
    textNode.data = 'Updated styled text';

    await snapshot();
  });

  it('should handle nodeValue updates in text element', async () => {
    const textElement = document.createElement('TEXT');
    const textNode = document.createTextNode('Initial nodeValue');

    textElement.appendChild(textNode);
    document.body.appendChild(textElement);

    await snapshot();

    // Update using nodeValue
    textNode.nodeValue = 'Updated nodeValue';

    await snapshot();

    // Verify both properties are in sync
    expect(textNode.data).toBe('Updated nodeValue');
    expect(textNode.nodeValue).toBe('Updated nodeValue');
  });

  it('should handle textContent updates on text element', async () => {
    const textElement = document.createElement('TEXT');
    const textNode1 = document.createTextNode('First');
    const textNode2 = document.createTextNode(' Second');

    textElement.appendChild(textNode1);
    textElement.appendChild(textNode2);
    document.body.appendChild(textElement);

    await snapshot();

    // Update entire textContent
    textElement.textContent = 'Replaced all content';

    await snapshot();
  });

  it('should handle whitespace collapsing in text element', async () => {
    const textElement = document.createElement('TEXT');
    const textNode = document.createTextNode('Text   with   multiple   spaces');

    textElement.appendChild(textNode);
    document.body.appendChild(textElement);

    await snapshot();

    // Update with different whitespace
    textNode.data = 'Text\n\nwith\n\nnewlines';

    await snapshot();

    // Update with tabs
    textNode.data = 'Text\t\twith\t\ttabs';

    await snapshot();
  });

  it('should handle special characters in text element', async () => {
    const textElement = document.createElement('TEXT');
    textElement.style.fontSize = '18px';

    const textNode = document.createTextNode('Normal text');
    textElement.appendChild(textNode);
    document.body.appendChild(textElement);

    await snapshot();

    // Update with HTML entities
    textNode.data = 'Text with <html> & "quotes" \'apostrophes\'';

    await snapshot();

    // Update with Unicode
    textNode.data = 'Unicode: 你好 世界 🌍 ✨ 😊';

    await snapshot();

    // Update with symbols
    textNode.data = 'Symbols: ©®™ €£¥ ±×÷ αβγ';

    await snapshot();
  });

  it('should handle rapid consecutive updates in text element', async () => {
    const textElement = document.createElement('TEXT');
    const textNode = document.createTextNode('Start');

    textElement.appendChild(textNode);
    document.body.appendChild(textElement);

    // Perform rapid updates
    for (let i = 0; i < 50; i++) {
      textNode.data = `Update ${i}`;
    }

    await snapshot();
    expect(textNode.data).toBe('Update 49');
  });

  it('should handle text node updates when text element is detached', async () => {
    const textElement = document.createElement('TEXT');
    textElement.style.color = 'purple';
    const textNode = document.createTextNode('Original');

    textElement.appendChild(textNode);
    document.body.appendChild(textElement);

    await snapshot();

    // Detach element
    document.body.removeChild(textElement);

    // Update while detached
    textNode.data = 'Updated while detached';

    // Reattach
    document.body.appendChild(textElement);

    await snapshot();
  });

  it('should handle dynamic text node insertion and updates', async () => {
    const textElement = document.createElement('TEXT');
    textElement.style.fontSize = '16px';

    const textNode1 = document.createTextNode('First');
    textElement.appendChild(textNode1);
    document.body.appendChild(textElement);

    await snapshot();

    // Add new text node
    const textNode2 = document.createTextNode(' Second');
    textElement.appendChild(textNode2);

    await snapshot();

    // Update both
    textNode1.data = 'Updated First';
    textNode2.data = ' Updated Second';

    await snapshot();

    // Add another in the middle
    const textNode3 = document.createTextNode(' Middle');
    textElement.insertBefore(textNode3, textNode2);

    await snapshot();

    // Update the middle one
    textNode3.data = ' Updated Middle';

    await snapshot();
  });

  it('should handle text element with mixed content', async () => {
    const textElement = document.createElement('TEXT');

    const text1 = document.createTextNode('Before ');
    const span = document.createElement('span');
    span.style.color = 'red';
    span.textContent = 'span content';
    const text2 = document.createTextNode(' After');

    textElement.appendChild(text1);
    textElement.appendChild(span);
    textElement.appendChild(text2);
    document.body.appendChild(textElement);

    await snapshot();

    // Update text nodes
    text1.data = 'Updated before ';
    text2.data = ' Updated after';

    await snapshot();
  });

  it('should handle text element in flex container', async () => {
    const flex = document.createElement('div');
    flex.style.display = 'flex';
    flex.style.alignItems = 'center';
    flex.style.gap = '10px';

    const box1 = document.createElement('div');
    box1.style.width = '50px';
    box1.style.height = '50px';
    box1.style.backgroundColor = 'blue';

    const textElement = document.createElement('TEXT');
    textElement.style.fontSize = '18px';
    const textNode = document.createTextNode('Flex text');
    textElement.appendChild(textNode);

    const box2 = document.createElement('div');
    box2.style.width = '50px';
    box2.style.height = '50px';
    box2.style.backgroundColor = 'green';

    flex.appendChild(box1);
    flex.appendChild(textElement);
    flex.appendChild(box2);
    document.body.appendChild(flex);

    await snapshot();

    // Update text
    textNode.data = 'Updated flex text';

    await snapshot();
  });

  it('should handle text element with CSS inheritance', async () => {
    const parent = document.createElement('div');
    parent.style.color = 'blue';
    parent.style.fontSize = '20px';
    parent.style.fontFamily = 'Arial';

    const textElement = document.createElement('TEXT');
    const textNode = document.createTextNode('Inherited styles');

    textElement.appendChild(textNode);
    parent.appendChild(textElement);
    document.body.appendChild(parent);

    await snapshot();

    // Update text
    textNode.data = 'Updated with inherited styles';

    await snapshot();

    // Override some inherited styles
    textElement.style.color = 'red';
    textElement.style.fontWeight = 'bold';

    await snapshot();
  });
});

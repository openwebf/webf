describe('flexbox column content fit size', () => {
  it('should fit content width with flex-direction column', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      display: 'flex',
      flexDirection: 'column',
      backgroundColor: '#f0f0f0',
      padding: '10px',
      alignItems: 'flex-start', // This ensures children fit their content width
    });
    document.body.appendChild(container);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      backgroundColor: 'blue',
      color: 'white',
      padding: '10px',
      marginBottom: '5px',
    });
    child1.textContent = 'Short';
    container.appendChild(child1);

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      backgroundColor: 'red',
      color: 'white',
      padding: '10px',
      marginBottom: '5px',
    });
    child2.textContent = 'This is a longer text content';
    container.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      backgroundColor: 'green',
      color: 'white',
      padding: '10px',
    });
    child3.textContent = 'Medium text';
    container.appendChild(child3);

    await snapshot();
  });

  it('should fit content with inline elements in column flex', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      display: 'flex',
      flexDirection: 'column',
      backgroundColor: '#e0e0e0',
      padding: '10px',
      alignItems: 'flex-start',
    });
    document.body.appendChild(container);

    const item1 = document.createElement('div');
    setElementStyle(item1, {
      backgroundColor: 'purple',
      color: 'white',
      padding: '5px',
      marginBottom: '5px',
    });
    const span1 = document.createElement('span');
    span1.textContent = 'Inline span element';
    item1.appendChild(span1);
    container.appendChild(item1);

    const item2 = document.createElement('div');
    setElementStyle(item2, {
      backgroundColor: 'orange',
      color: 'white',
      padding: '5px',
      marginBottom: '5px',
    });
    const button = document.createElement('button');
    button.textContent = 'Button fits content';
    item2.appendChild(button);
    container.appendChild(item2);

    const item3 = document.createElement('div');
    setElementStyle(item3, {
      backgroundColor: 'teal',
      color: 'white',
      padding: '5px',
    });
    item3.textContent = 'Text with ';
    const strong = document.createElement('strong');
    strong.textContent = 'bold part';
    item3.appendChild(strong);
    container.appendChild(item3);

    await snapshot();
  });

  it('should handle different align-items values with column direction', async () => {
    const wrapper = document.createElement('div');
    setElementStyle(wrapper, {
      display: 'flex',
      flexDirection: 'row',
      gap: '20px',
    });
    document.body.appendChild(wrapper);

    // flex-start (default behavior - content fits)
    const container1 = document.createElement('div');
    setElementStyle(container1, {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'flex-start',
      backgroundColor: '#f5f5f5',
      padding: '10px',
      minHeight: '150px',
    });
    wrapper.appendChild(container1);

    const label1 = document.createElement('div');
    label1.textContent = 'align-items: flex-start';
    setElementStyle(label1, {
      fontSize: '12px',
      marginBottom: '10px',
    });
    container1.appendChild(label1);

    ['Small', 'Medium sized content', 'Large content with more text'].forEach((text, i) => {
      const child = document.createElement('div');
      setElementStyle(child, {
        backgroundColor: ['#3498db', '#e74c3c', '#2ecc71'][i],
        color: 'white',
        padding: '8px',
        marginBottom: '5px',
      });
      child.textContent = text;
      container1.appendChild(child);
    });

    // stretch (default - stretches to container width)
    const container2 = document.createElement('div');
    setElementStyle(container2, {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'stretch',
      backgroundColor: '#f5f5f5',
      padding: '10px',
      width: '200px',
      minHeight: '150px',
    });
    wrapper.appendChild(container2);

    const label2 = document.createElement('div');
    label2.textContent = 'align-items: stretch';
    setElementStyle(label2, {
      fontSize: '12px',
      marginBottom: '10px',
    });
    container2.appendChild(label2);

    ['Small', 'Medium sized content', 'Large content with more text'].forEach((text, i) => {
      const child = document.createElement('div');
      setElementStyle(child, {
        backgroundColor: ['#3498db', '#e74c3c', '#2ecc71'][i],
        color: 'white',
        padding: '8px',
        marginBottom: '5px',
      });
      child.textContent = text;
      container2.appendChild(child);
    });

    await snapshot();
  });

  it('should handle max-width constraint with column flex', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'flex-start',
      backgroundColor: '#f0f0f0',
      padding: '10px',
    });
    document.body.appendChild(container);

    const child1 = document.createElement('div');
    setElementStyle(child1, {
      backgroundColor: '#9b59b6',
      color: 'white',
      padding: '10px',
      marginBottom: '5px',
      maxWidth: '150px',
    });
    child1.textContent = 'This text is constrained by max-width and will wrap if needed';
    container.appendChild(child1);

    const child2 = document.createElement('div');
    setElementStyle(child2, {
      backgroundColor: '#34495e',
      color: 'white',
      padding: '10px',
      marginBottom: '5px',
    });
    child2.textContent = 'This text has no max-width constraint';
    container.appendChild(child2);

    const child3 = document.createElement('div');
    setElementStyle(child3, {
      backgroundColor: '#16a085',
      color: 'white',
      padding: '10px',
      maxWidth: '100px',
    });
    child3.textContent = 'Small max-width';
    container.appendChild(child3);

    await snapshot();
  });

  it('should handle nested flex containers with content fit', async () => {
    const outerContainer = document.createElement('div');
    setElementStyle(outerContainer, {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'flex-start',
      backgroundColor: '#ecf0f1',
      padding: '15px',
    });
    document.body.appendChild(outerContainer);

    const item1 = document.createElement('div');
    setElementStyle(item1, {
      display: 'flex',
      flexDirection: 'row',
      gap: '10px',
      backgroundColor: '#3498db',
      padding: '10px',
      marginBottom: '10px',
    });
    outerContainer.appendChild(item1);

    ['A', 'B', 'C'].forEach(letter => {
      const subItem = document.createElement('div');
      setElementStyle(subItem, {
        backgroundColor: 'white',
        padding: '5px 10px',
      });
      subItem.textContent = letter;
      item1.appendChild(subItem);
    });

    const item2 = document.createElement('div');
    setElementStyle(item2, {
      backgroundColor: '#e74c3c',
      color: 'white',
      padding: '10px',
      marginBottom: '10px',
    });
    item2.textContent = 'Single item that fits content';
    outerContainer.appendChild(item2);

    const item3 = document.createElement('div');
    setElementStyle(item3, {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'flex-start',
      backgroundColor: '#2ecc71',
      padding: '10px',
    });
    outerContainer.appendChild(item3);

    ['Nested 1', 'Nested item 2', 'N3'].forEach((text, i) => {
      const nestedItem = document.createElement('div');
      setElementStyle(nestedItem, {
        backgroundColor: 'rgba(255, 255, 255, 0.8)',
        color: '#2c3e50',
        padding: '3px 8px',
        marginBottom: i < 2 ? '3px' : '0',
      });
      nestedItem.textContent = text;
      item3.appendChild(nestedItem);
    });

    await snapshot();
  });

  it('should handle overflow with fixed height container', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'flex-start',
      backgroundColor: '#f0f0f0',
      padding: '10px',
      height: '200px',
      overflow: 'auto',
      border: '2px solid #333',
    });
    document.body.appendChild(container);

    // Add multiple items that will overflow
    for (let i = 0; i < 8; i++) {
      const child = document.createElement('div');
      setElementStyle(child, {
        backgroundColor: i % 2 === 0 ? '#3498db' : '#e74c3c',
        color: 'white',
        padding: '15px',
        marginBottom: '10px',
        minHeight: '40px',
      });
      child.textContent = `Item ${i + 1} - Content that fits its width`;
      container.appendChild(child);
    }

    await snapshot();
  });

  it('should handle overflow with flex-grow items', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      display: 'flex',
      flexDirection: 'column',
      backgroundColor: '#ecf0f1',
      padding: '10px',
      height: '300px',
      overflow: 'auto',
      border: '2px solid #2c3e50',
    });
    document.body.appendChild(container);

    // Fixed height header
    const header = document.createElement('div');
    setElementStyle(header, {
      backgroundColor: '#34495e',
      color: 'white',
      padding: '10px',
      marginBottom: '10px',
      flexShrink: '0',
    });
    header.textContent = 'Fixed Header';
    container.appendChild(header);

    // Scrollable content area with flex-grow
    const content = document.createElement('div');
    setElementStyle(content, {
      flexGrow: '1',
      overflow: 'auto',
      backgroundColor: 'white',
      padding: '10px',
      marginBottom: '10px',
    });
    container.appendChild(content);

    // Add many items to content area
    for (let i = 0; i < 15; i++) {
      const item = document.createElement('div');
      setElementStyle(item, {
        backgroundColor: '#95a5a6',
        color: 'white',
        padding: '8px',
        marginBottom: '5px',
      });
      item.textContent = `Content item ${i + 1}`;
      content.appendChild(item);
    }

    // Fixed height footer
    const footer = document.createElement('div');
    setElementStyle(footer, {
      backgroundColor: '#34495e',
      color: 'white',
      padding: '10px',
      flexShrink: '0',
    });
    footer.textContent = 'Fixed Footer';
    container.appendChild(footer);

    await snapshot();
  });

  it('should handle horizontal overflow in column flex items', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'flex-start',
      backgroundColor: '#f5f5f5',
      padding: '10px',
      width: '250px',
      border: '2px solid #7f8c8d',
    });
    document.body.appendChild(container);

    // Item with nowrap text that overflows horizontally
    const item1 = document.createElement('div');
    setElementStyle(item1, {
      backgroundColor: '#9b59b6',
      color: 'white',
      padding: '10px',
      marginBottom: '10px',
      whiteSpace: 'nowrap',
      overflow: 'auto',
      maxWidth: '200px',
    });
    item1.textContent = 'This is a very long text that will not wrap and will cause horizontal scrolling';
    container.appendChild(item1);

    // Item with overflow hidden
    const item2 = document.createElement('div');
    setElementStyle(item2, {
      backgroundColor: '#3498db',
      color: 'white',
      padding: '10px',
      marginBottom: '10px',
      whiteSpace: 'nowrap',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      maxWidth: '200px',
    });
    item2.textContent = 'This text will be truncated with ellipsis if it is too long';
    container.appendChild(item2);

    // Normal wrapping item
    const item3 = document.createElement('div');
    setElementStyle(item3, {
      backgroundColor: '#2ecc71',
      color: 'white',
      padding: '10px',
      maxWidth: '200px',
    });
    item3.textContent = 'This text will wrap normally within the max-width constraint';
    container.appendChild(item3);

    await snapshot();
  });

  it('should handle nested scrollable areas in column flex', async () => {
    const outerContainer = document.createElement('div');
    setElementStyle(outerContainer, {
      display: 'flex',
      flexDirection: 'column',
      height: '400px',
      backgroundColor: '#ecf0f1',
      padding: '10px',
      border: '2px solid #34495e',
    });
    document.body.appendChild(outerContainer);

    // Top section with its own scroll
    const topSection = document.createElement('div');
    setElementStyle(topSection, {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'flex-start',
      height: '150px',
      overflow: 'auto',
      backgroundColor: '#3498db',
      padding: '10px',
      marginBottom: '10px',
    });
    outerContainer.appendChild(topSection);

    for (let i = 0; i < 8; i++) {
      const item = document.createElement('div');
      setElementStyle(item, {
        backgroundColor: 'rgba(255, 255, 255, 0.9)',
        padding: '5px 10px',
        marginBottom: '5px',
      });
      item.textContent = `Top section item ${i + 1}`;
      topSection.appendChild(item);
    }

    // Middle section that grows
    const middleSection = document.createElement('div');
    setElementStyle(middleSection, {
      flexGrow: '1',
      display: 'flex',
      flexDirection: 'column',
      overflow: 'hidden',
      backgroundColor: '#e74c3c',
      padding: '10px',
      marginBottom: '10px',
    });
    outerContainer.appendChild(middleSection);

    const scrollableMiddle = document.createElement('div');
    setElementStyle(scrollableMiddle, {
      flexGrow: '1',
      overflow: 'auto',
      backgroundColor: 'rgba(255, 255, 255, 0.1)',
      padding: '10px',
    });
    middleSection.appendChild(scrollableMiddle);

    for (let i = 0; i < 12; i++) {
      const item = document.createElement('div');
      setElementStyle(item, {
        backgroundColor: 'rgba(255, 255, 255, 0.8)',
        color: '#c0392b',
        padding: '5px 10px',
        marginBottom: '5px',
      });
      item.textContent = `Middle scrollable item ${i + 1}`;
      scrollableMiddle.appendChild(item);
    }

    // Bottom fixed section
    const bottomSection = document.createElement('div');
    setElementStyle(bottomSection, {
      backgroundColor: '#2c3e50',
      color: 'white',
      padding: '15px',
      textAlign: 'center',
    });
    bottomSection.textContent = 'Fixed Bottom Section';
    outerContainer.appendChild(bottomSection);

    await snapshot();
  });

  it('should handle overflow with min-height and max-height constraints', async () => {
    const wrapper = document.createElement('div');
    setElementStyle(wrapper, {
      display: 'flex',
      gap: '20px',
    });
    document.body.appendChild(wrapper);

    // Container with min-height
    const container1 = document.createElement('div');
    setElementStyle(container1, {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'flex-start',
      backgroundColor: '#f0f0f0',
      padding: '10px',
      minHeight: '150px',
      maxHeight: '250px',
      overflow: 'auto',
      border: '2px solid #3498db',
      width: '200px',
    });
    wrapper.appendChild(container1);

    const label1 = document.createElement('div');
    label1.textContent = 'min/max-height container';
    setElementStyle(label1, {
      fontSize: '12px',
      fontWeight: 'bold',
      marginBottom: '10px',
    });
    container1.appendChild(label1);

    // Add items that might overflow
    for (let i = 0; i < 10; i++) {
      const child = document.createElement('div');
      setElementStyle(child, {
        backgroundColor: i % 2 === 0 ? '#3498db' : '#e74c3c',
        color: 'white',
        padding: '8px',
        marginBottom: '5px',
      });
      child.textContent = `Item ${i + 1} fits content width`;
      container1.appendChild(child);
    }

    // Container with flex-basis and overflow
    const container2 = document.createElement('div');
    setElementStyle(container2, {
      display: 'flex',
      flexDirection: 'column',
      backgroundColor: '#f0f0f0',
      padding: '10px',
      height: '300px',
      border: '2px solid #2ecc71',
      width: '200px',
    });
    wrapper.appendChild(container2);

    const label2 = document.createElement('div');
    label2.textContent = 'flex-basis with overflow';
    setElementStyle(label2, {
      fontSize: '12px',
      fontWeight: 'bold',
      marginBottom: '10px',
      flexShrink: '0',
    });
    container2.appendChild(label2);

    const scrollArea = document.createElement('div');
    setElementStyle(scrollArea, {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'flex-start',
      flexBasis: '200px',
      flexGrow: '1',
      overflow: 'auto',
      backgroundColor: 'white',
      padding: '10px',
    });
    container2.appendChild(scrollArea);

    for (let i = 0; i < 15; i++) {
      const child = document.createElement('div');
      setElementStyle(child, {
        backgroundColor: '#95a5a6',
        color: 'white',
        padding: '6px 10px',
        marginBottom: '4px',
      });
      child.textContent = `Scrollable item ${i + 1}`;
      scrollArea.appendChild(child);
    }

    await snapshot();
  });

  it('should handle intrinsic size with text content', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'flex-start',
      backgroundColor: '#f5f5f5',
      padding: '15px',
      gap: '10px',
    });
    document.body.appendChild(container);

    // Single word - minimal intrinsic width
    const item1 = document.createElement('div');
    setElementStyle(item1, {
      backgroundColor: '#3498db',
      color: 'white',
      padding: '10px',
    });
    item1.textContent = 'Word';
    container.appendChild(item1);

    // Multiple words - natural text width
    const item2 = document.createElement('div');
    setElementStyle(item2, {
      backgroundColor: '#e74c3c',
      color: 'white',
      padding: '10px',
    });
    item2.textContent = 'Multiple words in a line';
    container.appendChild(item2);

    // Long word that might overflow
    const item3 = document.createElement('div');
    setElementStyle(item3, {
      backgroundColor: '#9b59b6',
      color: 'white',
      padding: '10px',
    });
    item3.textContent = 'Supercalifragilisticexpialidocious';
    container.appendChild(item3);

    // Text with different font sizes
    const item4 = document.createElement('div');
    setElementStyle(item4, {
      backgroundColor: '#2ecc71',
      color: 'white',
      padding: '10px',
    });
    const small = document.createElement('span');
    small.textContent = 'Small ';
    setElementStyle(small, { fontSize: '12px' });
    const large = document.createElement('span');
    large.textContent = 'Large';
    setElementStyle(large, { fontSize: '24px' });
    item4.appendChild(small);
    item4.appendChild(large);
    container.appendChild(item4);

    // Pre-formatted text maintaining whitespace
    const item5 = document.createElement('div');
    setElementStyle(item5, {
      backgroundColor: '#f39c12',
      color: 'white',
      padding: '10px',
      whiteSpace: 'pre',
    });
    item5.textContent = 'Pre   formatted    text';
    container.appendChild(item5);

    await snapshot();
  });

  it('should handle intrinsic size with images', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'flex-start',
      backgroundColor: '#ecf0f1',
      padding: '15px',
      gap: '10px',
    });
    document.body.appendChild(container);

    // Image with natural dimensions
    const item1 = document.createElement('div');
    setElementStyle(item1, {
      backgroundColor: '#3498db',
      padding: '10px',
    });
    const img1 = document.createElement('img');
    img1.src = 'assets/100x100-green.png';
    img1.alt = 'Natural size image';
    item1.appendChild(img1);
    container.appendChild(item1);

    // Image with text alongside
    const item2 = document.createElement('div');
    setElementStyle(item2, {
      backgroundColor: '#e74c3c',
      color: 'white',
      padding: '10px',
      display: 'flex',
      alignItems: 'center',
      gap: '10px',
    });
    const img2 = document.createElement('img');
    img2.src = 'assets/50x50.png';
    img2.alt = 'Small image';
    item2.appendChild(img2);
    const text2 = document.createElement('span');
    text2.textContent = 'Image with text';
    item2.appendChild(text2);
    container.appendChild(item2);

    // Image with max-width constraint
    const item3 = document.createElement('div');
    setElementStyle(item3, {
      backgroundColor: '#9b59b6',
      padding: '10px',
    });
    const img3 = document.createElement('img');
    img3.src = 'assets/300x200.png';
    img3.alt = 'Constrained image';
    setElementStyle(img3, {
      maxWidth: '150px',
      height: 'auto',
    });
    item3.appendChild(img3);
    container.appendChild(item3);

    // Multiple images in a row
    const item4 = document.createElement('div');
    setElementStyle(item4, {
      backgroundColor: '#2ecc71',
      padding: '10px',
      display: 'flex',
      gap: '5px',
    });
    for (let i = 0; i < 3; i++) {
      const img = document.createElement('img');
      img.src = 'assets/30x30.png';
      img.alt = `Icon ${i + 1}`;
      item4.appendChild(img);
    }
    container.appendChild(item4);

    await snapshot();
  });

  it('should handle mixed content with intrinsic sizing', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'flex-start',
      backgroundColor: '#f8f9fa',
      padding: '15px',
      gap: '15px',
    });
    document.body.appendChild(container);

    // Card with image and text
    const card1 = document.createElement('div');
    setElementStyle(card1, {
      backgroundColor: 'white',
      border: '1px solid #ddd',
      borderRadius: '8px',
      padding: '15px',
      display: 'flex',
      flexDirection: 'column',
      gap: '10px',
    });
    const cardImg = document.createElement('img');
    cardImg.src = 'assets/200x150.png';
    cardImg.alt = 'Card image';
    setElementStyle(cardImg, {
      width: '100%',
      height: 'auto',
      maxWidth: '200px',
    });
    card1.appendChild(cardImg);
    const cardTitle = document.createElement('h3');
    cardTitle.textContent = 'Card Title';
    setElementStyle(cardTitle, {
      margin: '0',
      fontSize: '18px',
    });
    card1.appendChild(cardTitle);
    const cardText = document.createElement('p');
    cardText.textContent = 'This is some card content that will determine the width.';
    setElementStyle(cardText, {
      margin: '0',
      fontSize: '14px',
      color: '#666',
    });
    card1.appendChild(cardText);
    container.appendChild(card1);

    // Inline elements with mixed content
    const item2 = document.createElement('div');
    setElementStyle(item2, {
      backgroundColor: '#e3f2fd',
      padding: '12px',
      borderRadius: '4px',
    });
    const icon = document.createElement('img');
    icon.src = 'assets/24x24.png';
    icon.alt = 'Icon';
    setElementStyle(icon, {
      verticalAlign: 'middle',
      marginRight: '8px',
    });
    item2.appendChild(icon);
    const label = document.createElement('span');
    label.textContent = 'Label with icon';
    setElementStyle(label, {
      verticalAlign: 'middle',
    });
    item2.appendChild(label);
    container.appendChild(item2);

    // Text with inline code
    const item3 = document.createElement('div');
    setElementStyle(item3, {
      backgroundColor: 'white',
      border: '1px solid #e0e0e0',
      padding: '10px',
      fontFamily: 'monospace',
    });
    item3.textContent = 'Use ';
    const code = document.createElement('code');
    code.textContent = 'display: flex';
    setElementStyle(code, {
      backgroundColor: '#f5f5f5',
      padding: '2px 4px',
      borderRadius: '3px',
    });
    item3.appendChild(code);
    const restText = document.createTextNode(' for layouts');
    item3.appendChild(restText);
    container.appendChild(item3);

    await snapshot();
  });

  it('should handle min-content and max-content sizing', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      display: 'flex',
      flexDirection: 'column',
      backgroundColor: '#f0f0f0',
      padding: '15px',
      gap: '10px',
      width: '400px',
    });
    document.body.appendChild(container);

    // Default intrinsic sizing
    const item1 = document.createElement('div');
    setElementStyle(item1, {
      backgroundColor: '#3498db',
      color: 'white',
      padding: '10px',
      alignSelf: 'flex-start',
    });
    item1.textContent = 'Default intrinsic width with some text content';
    container.appendChild(item1);

    // Width: min-content
    const item2 = document.createElement('div');
    setElementStyle(item2, {
      backgroundColor: '#e74c3c',
      color: 'white',
      padding: '10px',
      width: 'min-content',
    });
    item2.textContent = 'Width set to min-content will wrap aggressively';
    container.appendChild(item2);

    // Width: max-content
    const item3 = document.createElement('div');
    setElementStyle(item3, {
      backgroundColor: '#9b59b6',
      color: 'white',
      padding: '10px',
      width: 'max-content',
    });
    item3.textContent = 'Width set to max-content prefers not to wrap';
    container.appendChild(item3);

    // Width: fit-content with max limit
    const item4 = document.createElement('div');
    setElementStyle(item4, {
      backgroundColor: '#2ecc71',
      color: 'white',
      padding: '10px',
      width: 'fit-content',
      maxWidth: '200px',
    });
    item4.textContent = 'Width fit-content with max-width constraint will wrap when needed';
    container.appendChild(item4);

    // Comparison with fixed width
    const item5 = document.createElement('div');
    setElementStyle(item5, {
      backgroundColor: '#f39c12',
      color: 'white',
      padding: '10px',
      width: '150px',
    });
    item5.textContent = 'Fixed width 150px for comparison';
    container.appendChild(item5);

    await snapshot();
  });

  it('should handle intrinsic sizing with word-break and overflow-wrap', async () => {
    const container = document.createElement('div');
    setElementStyle(container, {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'flex-start',
      backgroundColor: '#f5f5f5',
      padding: '15px',
      gap: '10px',
    });
    document.body.appendChild(container);

    // Normal text behavior
    const item1 = document.createElement('div');
    setElementStyle(item1, {
      backgroundColor: '#3498db',
      color: 'white',
      padding: '10px',
      maxWidth: '200px',
    });
    item1.textContent = 'Verylongwordthatmightoverflowthecontainer normal behavior';
    container.appendChild(item1);

    // Word-break: break-all
    const item2 = document.createElement('div');
    setElementStyle(item2, {
      backgroundColor: '#e74c3c',
      color: 'white',
      padding: '10px',
      maxWidth: '200px',
      wordBreak: 'break-all',
    });
    item2.textContent = 'Verylongwordthatmightoverflowthecontainer with break-all';
    container.appendChild(item2);

    // Overflow-wrap: break-word
    const item3 = document.createElement('div');
    setElementStyle(item3, {
      backgroundColor: '#9b59b6',
      color: 'white',
      padding: '10px',
      maxWidth: '200px',
      overflowWrap: 'break-word',
    });
    item3.textContent = 'Verylongwordthatmightoverflowthecontainer with break-word';
    container.appendChild(item3);

    // Hyphens (if supported)
    const item4 = document.createElement('div');
    setElementStyle(item4, {
      backgroundColor: '#2ecc71',
      color: 'white',
      padding: '10px',
      maxWidth: '200px',
      hyphens: 'auto',
      lang: 'en',
    });
    item4.textContent = 'Internationalization implementation considerations';
    container.appendChild(item4);

    await snapshot();
  });
});
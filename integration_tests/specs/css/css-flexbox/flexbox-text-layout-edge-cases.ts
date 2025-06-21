describe('Text layout edge cases in flex containers', () => {
  it('should handle text with inline spans and flex items', async () => {
    // Test case inspired by the commented example in App.tsx
    const container = document.createElement('div');
    container.className = 'App';
    container.style.padding = '20px';

    const flexContainer = document.createElement('div');
    flexContainer.style.display = 'flex';
    flexContainer.style.alignItems = 'flex-start';
    flexContainer.style.border = '1px solid #000';
    flexContainer.style.padding = '10px';

    // Create a bullet point
    const bullet = document.createElement('div');
    bullet.style.marginRight = '8px';
    bullet.style.marginTop = '12px';
    bullet.style.height = '6px';
    bullet.style.width = '6px';
    bullet.style.borderRadius = '50%';
    bullet.style.backgroundColor = '#333';

    // Create main text span with nested span
    const mainSpan = document.createElement('span');
    mainSpan.id = 'span1';
    mainSpan.style.border = '1px solid #f00';
    mainSpan.style.minWidth = '0';
    mainSpan.style.wordBreak = 'break-all';
    mainSpan.textContent = '若您已付款：请第一时间提交订单申诉并联系 ';

    const nestedSpan = document.createElement('span');
    nestedSpan.id = 'span11';
    nestedSpan.style.border = '1px solid #00f';
    nestedSpan.style.color = 'blue';
    nestedSpan.style.display = 'inline';
    nestedSpan.style.paddingRight = '4px';
    nestedSpan.textContent = 'MEXC 客服客服';

    mainSpan.appendChild(nestedSpan);

    flexContainer.appendChild(bullet);
    flexContainer.appendChild(mainSpan);
    container.appendChild(flexContainer);
    document.body.appendChild(container);

    // Take initial snapshot
    await snapshot();

    // Change container width to test text wrapping
    flexContainer.style.width = '250px';

    // Take snapshot with constrained width
    await snapshot();

    // Make even narrower
    flexContainer.style.width = '180px';

    // Take final snapshot
    await snapshot();
  });

  it('should handle justify-between layout with text overflow', async () => {
    // Test case inspired by the first commented wrap example
    const container = document.createElement('div');
    container.className = 'App';
    container.style.padding = '20px';

    const flexContainer = document.createElement('div');
    flexContainer.style.display = 'flex';
    flexContainer.style.alignItems = 'center';
    flexContainer.style.justifyContent = 'space-between';
    flexContainer.style.border = '1px solid #000';
    flexContainer.style.padding = '10px';

    // Left side text
    const leftText = document.createElement('span');
    leftText.style.color = '#666';
    leftText.style.fontSize = '14px';
    leftText.style.maxWidth = '50%';
    leftText.textContent = 'qqqqqq';

    // Right side container with text and button
    const rightContainer = document.createElement('div');
    rightContainer.style.display = 'flex';
    rightContainer.style.maxWidth = '50%';
    rightContainer.style.alignItems = 'center';

    const rightText = document.createElement('span');
    rightText.style.color = '#333';
    rightText.style.fontSize = '14px';
    rightText.style.maxWidth = '100%';
    rightText.style.textAlign = 'right';
    rightText.textContent = '阿斯顿发的法师打发打发打发打发三大发2323啥打法是2 打发';

    const copyButton = document.createElement('div');
    copyButton.style.marginLeft = '8px';
    copyButton.style.cursor = 'pointer';
    copyButton.style.color = 'blue';
    copyButton.style.fontSize = '14px';
    copyButton.textContent = 'Copy';

    rightContainer.appendChild(rightText);
    rightContainer.appendChild(copyButton);
    flexContainer.appendChild(leftText);
    flexContainer.appendChild(rightContainer);
    container.appendChild(flexContainer);
    document.body.appendChild(container);

    // Take initial snapshot
    await snapshot();

    // Change container width to test responsive behavior
    flexContainer.style.width = '300px';

    // Take snapshot with constrained width
    await snapshot();

    // Make even narrower to test text overflow
    flexContainer.style.width = '200px';

    // Take final snapshot
    await snapshot();
  });

  it('should handle column flex layout with text elements', async () => {
    // Test case inspired by the second commented example
    const container = document.createElement('div');
    container.id = 'div_1';
    container.style.display = 'flex';
    container.style.alignItems = 'center';
    container.style.flexDirection = 'column';
    container.style.border = '1px solid #000';
    container.style.padding = '20px';

    // Top text element
    const topText = document.createElement('span');
    topText.style.color = '#666';
    topText.style.fontSize = '14px';
    topText.style.maxWidth = '50%';
    topText.style.border = '1px solid red';
    topText.style.padding = '5px';
    topText.textContent = 'qqqqqq';

    // Bottom container with flex layout
    const bottomContainer = document.createElement('div');
    bottomContainer.style.display = 'flex';
    bottomContainer.style.maxWidth = '50%';
    bottomContainer.style.alignItems = 'center';
    bottomContainer.style.marginTop = '10px';

    const bottomText = document.createElement('span');
    bottomText.style.color = '#333';
    bottomText.style.fontSize = '14px';
    bottomText.style.maxWidth = '100%';
    bottomText.style.textAlign = 'right';
    bottomText.style.border = '1px solid blue';
    bottomText.style.padding = '5px';
    bottomText.textContent = '阿斯顿发的法师打发打发打发打发三大发2323啥打法是2 打发';

    const actionButton = document.createElement('div');
    actionButton.style.marginLeft = '8px';
    actionButton.style.border = '1px solid green';
    actionButton.style.padding = '5px';
    actionButton.style.cursor = 'pointer';
    actionButton.style.color = 'green';
    actionButton.textContent = 'Copy';

    bottomContainer.appendChild(bottomText);
    bottomContainer.appendChild(actionButton);
    container.appendChild(topText);
    container.appendChild(bottomContainer);
    document.body.appendChild(container);

    // Take initial snapshot
    await snapshot();

    // Change container width
    container.style.width = '300px';

    // Take snapshot with defined width
    await snapshot();

    // Make narrower to test text wrapping in column layout
    container.style.width = '200px';

    // Take final snapshot
    await snapshot();
  });

  it('should handle complex nested flex with text truncation', async () => {
    // Test case inspired by the third commented example
    const outerContainer = document.createElement('div');
    outerContainer.style.position = 'relative';
    outerContainer.style.display = 'flex';
    outerContainer.style.minHeight = '100px';
    outerContainer.style.flexDirection = 'column';
    outerContainer.style.padding = '20px';

    const innerContainer = document.createElement('div');
    innerContainer.style.display = 'flex';
    innerContainer.style.flexDirection = 'column';
    innerContainer.style.border = '1px solid red';
    innerContainer.style.padding = '10px';

    const flexRow = document.createElement('div');
    flexRow.style.display = 'flex';
    flexRow.style.justifyContent = 'space-between';
    flexRow.style.border = '1px solid green';
    flexRow.style.padding = '5px';

    // Left text
    const leftLabel = document.createElement('span');
    leftLabel.style.color = '#666';
    leftLabel.style.fontSize = '14px';
    leftLabel.style.maxWidth = '50%';
    leftLabel.textContent = '123';

    // Right container with flex layout
    const rightContainer = document.createElement('div');
    rightContainer.style.color = '#333';
    rightContainer.style.display = 'flex';
    rightContainer.style.maxWidth = '50%';
    rightContainer.style.alignItems = 'center';

    const nameText = document.createElement('span');
    nameText.style.fontSize = '14px';
    nameText.style.width = '4px'; // Very narrow width to test flex behavior
    nameText.style.flex = '1';
    nameText.style.textAlign = 'right';
    nameText.style.border = '1px solid red';
    nameText.style.overflow = 'hidden';
    nameText.style.textOverflow = 'ellipsis';
    nameText.style.whiteSpace = 'nowrap';
    nameText.textContent = '张三';

    const spacer = document.createElement('div');
    spacer.style.marginLeft = '8px';

    rightContainer.appendChild(nameText);
    rightContainer.appendChild(spacer);
    flexRow.appendChild(leftLabel);
    flexRow.appendChild(rightContainer);
    innerContainer.appendChild(flexRow);
    outerContainer.appendChild(innerContainer);
    document.body.appendChild(outerContainer);

    // Take initial snapshot
    await snapshot();

    // Change the name to something longer
    nameText.textContent = '张三李四王五赵六孙七';

    // Take snapshot with longer text
    await snapshot();

    // Change container width to test responsive behavior
    outerContainer.style.width = '200px';

    // Take final snapshot
    await snapshot();
  });

  it('should handle flex items with minWidth 0 and text content', async () => {
    // Test specific to minWidth: 0 behavior with flex-basis 0%
    const container = document.createElement('div');
    container.style.display = 'flex';
    container.style.width = '300px';
    container.style.border = '2px solid black';
    container.style.padding = '10px';

    // First item without minWidth: 0
    const item1 = document.createElement('div');
    item1.style.flex = '1 1 0%';
    item1.style.padding = '8px';
    item1.style.border = '1px solid red';
    item1.style.backgroundColor = 'lightcoral';
    item1.textContent = 'Long text without minWidth 0 - should not shrink below content width';

    // Second item with minWidth: 0
    const item2 = document.createElement('div');
    item2.style.flex = '1 1 0%';
    item2.style.minWidth = '0';
    item2.style.padding = '8px';
    item2.style.border = '1px solid blue';
    item2.style.backgroundColor = 'lightblue';
    item2.style.overflow = 'hidden';
    item2.style.textOverflow = 'ellipsis';
    item2.style.whiteSpace = 'nowrap';
    item2.textContent = 'Long text with minWidth 0 - should shrink and show ellipsis';

    container.appendChild(item1);
    container.appendChild(item2);
    document.body.appendChild(container);

    // Take initial snapshot
    await snapshot();

    // Make container narrower to see the difference
    container.style.width = '200px';

    // Take snapshot with narrower container
    await snapshot();

    // Even narrower
    container.style.width = '150px';

    // Take final snapshot
    await snapshot();
  });
});
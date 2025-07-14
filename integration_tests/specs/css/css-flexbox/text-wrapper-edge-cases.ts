describe('Text wrapper edge cases for flexbox', () => {
  xit('should handle empty text content with flex containers', async () => {
    const container = document.createElement('div');
    container.style.display = 'flex';
    container.style.width = '200px';
    container.style.border = '1px solid #000';
    container.style.padding = '10px';

    // Empty text element
    const emptyText = document.createElement('span');
    emptyText.style.flex = '1';
    emptyText.style.minWidth = '0';
    emptyText.style.border = '1px solid red';
    emptyText.style.padding = '5px';
    emptyText.textContent = '';

    // Non-empty text element
    const normalText = document.createElement('span');
    normalText.style.flex = '1';
    normalText.style.minWidth = '0';
    normalText.style.border = '1px solid blue';
    normalText.style.padding = '5px';
    normalText.textContent = 'Normal text content';

    container.appendChild(emptyText);
    container.appendChild(normalText);
    document.body.appendChild(container);

    await snapshot();

    // Add content to previously empty element
    emptyText.textContent = 'Now has content';
    await snapshot();
  });

  it('should handle single character text wrapping', async () => {
    const container = document.createElement('div');
    container.style.display = 'flex';
    container.style.width = '100px';
    container.style.border = '1px solid #000';
    container.style.padding = '5px';

    // Single character
    const singleChar = document.createElement('span');
    singleChar.style.flex = '1';
    singleChar.style.minWidth = '0';
    singleChar.style.border = '1px solid red';
    singleChar.style.padding = '2px';
    singleChar.style.fontSize = '20px';
    singleChar.textContent = 'A';

    // Chinese single character
    const chineseSingleChar = document.createElement('span');
    chineseSingleChar.style.flex = '1';
    chineseSingleChar.style.minWidth = '0';
    chineseSingleChar.style.border = '1px solid blue';
    chineseSingleChar.style.padding = '2px';
    chineseSingleChar.style.fontSize = '20px';
    chineseSingleChar.textContent = '中';

    container.appendChild(singleChar);
    container.appendChild(chineseSingleChar);
    document.body.appendChild(container);

    await snapshot();

    // Make container even narrower
    container.style.width = '50px';
    await snapshot();
  });

  it('should handle text with special characters and numbers', async () => {
    const container = document.createElement('div');
    container.style.display = 'flex';
    container.style.flexDirection = 'column';
    container.style.width = '200px';
    container.style.border = '1px solid #000';
    container.style.padding = '10px';
    container.style.gap = '5px';

    // Text with special characters
    const specialChars = document.createElement('span');
    specialChars.style.border = '1px solid red';
    specialChars.style.padding = '5px';
    specialChars.style.minWidth = '0';
    specialChars.textContent = '!@#$%^&*()_+-=[]{}|;:\'",.<>?/~`';

    // Text with numbers
    const numbers = document.createElement('span');
    numbers.style.border = '1px solid green';
    numbers.style.padding = '5px';
    numbers.style.minWidth = '0';
    numbers.textContent = '1234567890 9876543210 1111222233334444';

    // Mixed special chars and text
    const mixed = document.createElement('span');
    mixed.style.border = '1px solid blue';
    mixed.style.padding = '5px';
    mixed.style.minWidth = '0';
    mixed.textContent = 'Price: $123.45 (discount: 20%) -> Final: $98.76';

    container.appendChild(specialChars);
    container.appendChild(numbers);
    container.appendChild(mixed);
    document.body.appendChild(container);

    await snapshot();

    // Narrow container
    container.style.width = '150px';
    await snapshot();

    // Very narrow container
    container.style.width = '100px';
    await snapshot();
  });

  it('should handle text with different font sizes in flex container', async () => {
    const container = document.createElement('div');
    container.style.display = 'flex';
    container.style.alignItems = 'baseline';
    container.style.width = '300px';
    container.style.border = '1px solid #000';
    container.style.padding = '10px';

    // Large text
    const largeText = document.createElement('span');
    largeText.style.fontSize = '24px';
    largeText.style.border = '1px solid red';
    largeText.style.padding = '5px';
    largeText.style.flex = '1';
    largeText.style.minWidth = '0';
    largeText.textContent = 'Large Text 大字';

    // Medium text
    const mediumText = document.createElement('span');
    mediumText.style.fontSize = '16px';
    mediumText.style.border = '1px solid green';
    mediumText.style.padding = '5px';
    mediumText.style.flex = '1';
    mediumText.style.minWidth = '0';
    mediumText.textContent = 'Medium Text 中字';

    // Small text
    const smallText = document.createElement('span');
    smallText.style.fontSize = '12px';
    smallText.style.border = '1px solid blue';
    smallText.style.padding = '5px';
    smallText.style.flex = '1';
    smallText.style.minWidth = '0';
    smallText.textContent = 'Small Text 小字';

    container.appendChild(largeText);
    container.appendChild(mediumText);
    container.appendChild(smallText);
    document.body.appendChild(container);

    await snapshot();

    // Narrow container
    container.style.width = '200px';
    await snapshot();

    // Very narrow container
    container.style.width = '150px';
    await snapshot();
  });

  it('should handle text with whitespace variations', async () => {
    const container = document.createElement('div');
    container.style.display = 'flex';
    container.style.flexDirection = 'column';
    container.style.width = '200px';
    container.style.border = '1px solid #000';
    container.style.padding = '10px';
    container.style.gap = '5px';

    // Text with multiple spaces
    const multipleSpaces = document.createElement('span');
    multipleSpaces.style.border = '1px solid red';
    multipleSpaces.style.padding = '5px';
    multipleSpaces.style.minWidth = '0';
    multipleSpaces.textContent = 'Text     with     multiple     spaces';

    // Text with leading/trailing spaces
    const leadingTrailing = document.createElement('span');
    leadingTrailing.style.border = '1px solid green';
    leadingTrailing.style.padding = '5px';
    leadingTrailing.style.minWidth = '0';
    leadingTrailing.textContent = '   Leading and trailing spaces   ';

    // Text with tabs and newlines (should be treated as spaces)
    const tabsNewlines = document.createElement('span');
    tabsNewlines.style.border = '1px solid blue';
    tabsNewlines.style.padding = '5px';
    tabsNewlines.style.minWidth = '0';
    tabsNewlines.style.whiteSpace = 'pre';
    tabsNewlines.textContent = 'Text\twith\ttabs\nand\nnewlines';

    container.appendChild(multipleSpaces);
    container.appendChild(leadingTrailing);
    container.appendChild(tabsNewlines);
    document.body.appendChild(container);

    await snapshot();

    // Test with different white-space settings
    multipleSpaces.style.whiteSpace = 'pre';
    leadingTrailing.style.whiteSpace = 'pre-wrap';
    tabsNewlines.style.whiteSpace = 'nowrap';

    await snapshot();
  });

  it('should handle nested flex containers with text wrapping', async () => {
    const outerContainer = document.createElement('div');
    outerContainer.style.display = 'flex';
    outerContainer.style.flexDirection = 'column';
    outerContainer.style.width = '250px';
    outerContainer.style.border = '2px solid #000';
    outerContainer.style.padding = '10px';

    // First level nested container
    const level1Container = document.createElement('div');
    level1Container.style.display = 'flex';
    level1Container.style.border = '1px solid red';
    level1Container.style.padding = '5px';
    level1Container.style.marginBottom = '5px';

    // Second level nested container
    const level2Container = document.createElement('div');
    level2Container.style.display = 'flex';
    level2Container.style.flex = '1';
    level2Container.style.border = '1px solid green';
    level2Container.style.padding = '5px';

    // Text in deeply nested container
    const nestedText = document.createElement('span');
    nestedText.style.flex = '1';
    nestedText.style.minWidth = '0';
    nestedText.style.border = '1px solid blue';
    nestedText.style.padding = '3px';
    nestedText.textContent = 'Deeply nested text that should wrap properly even in complex layouts';

    // Button in nested container
    const nestedButton = document.createElement('div');
    nestedButton.style.marginLeft = '5px';
    nestedButton.style.padding = '3px 6px';
    nestedButton.style.backgroundColor = '#007bff';
    nestedButton.style.color = 'white';
    nestedButton.style.fontSize = '12px';
    nestedButton.style.whiteSpace = 'nowrap';
    nestedButton.textContent = 'Btn';

    level2Container.appendChild(nestedText);
    level2Container.appendChild(nestedButton);
    level1Container.appendChild(level2Container);
    outerContainer.appendChild(level1Container);

    // Add another level for more complexity
    const anotherLevel1 = document.createElement('div');
    anotherLevel1.style.display = 'flex';
    anotherLevel1.style.justifyContent = 'space-between';
    anotherLevel1.style.border = '1px solid orange';
    anotherLevel1.style.padding = '5px';

    const leftText = document.createElement('span');
    leftText.style.maxWidth = '60%';
    leftText.style.minWidth = '0';
    leftText.textContent = 'Left side text content';

    const rightText = document.createElement('span');
    rightText.style.maxWidth = '35%';
    rightText.style.minWidth = '0';
    rightText.style.textAlign = 'right';
    rightText.textContent = 'Right side';

    anotherLevel1.appendChild(leftText);
    anotherLevel1.appendChild(rightText);
    outerContainer.appendChild(anotherLevel1);

    document.body.appendChild(outerContainer);

    await snapshot();

    // Test with narrower container
    outerContainer.style.width = '180px';
    await snapshot();

    // Very narrow
    outerContainer.style.width = '120px';
    await snapshot();
  });
});
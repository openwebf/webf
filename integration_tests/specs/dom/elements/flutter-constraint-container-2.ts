describe('flutter-constraint-container-2 and flutter-constraint-container-2-item with WebFWidgetElementChild', () => {
  it('should properly display content with constrained size from Flutter widget', async () => {
    const container = document.createElement('flutter-constraint-container-2');
    document.body.appendChild(container);

    // Add some content to the container
    const text = document.createElement('div');
    text.textContent = 'This content should fit the container constraints';
    text.style.backgroundColor = '#f0f0f0';
    text.style.padding = '10px';
    text.style.height = '100%';
    text.style.width = '100%';
    container.appendChild(text);

    await snapshot();
  });

  it('should allow inner elements to receive and use container constraints', async () => {
    const container = document.createElement('flutter-constraint-container-2');
    document.body.appendChild(container);

    // Create a div that should respect the parent's constraints
    const innerDiv = document.createElement('div');
    innerDiv.style.backgroundColor = 'yellow';
    innerDiv.style.height = '100%'; // Should use the height from the WebFWidgetElementChild constraints
    innerDiv.style.width = '100%';  // Should use the width from the WebFWidgetElementChild constraints
    innerDiv.style.border = '1px solid green';
    innerDiv.textContent = 'This div should fit the constraint container';
    container.appendChild(innerDiv);

    await snapshot();
  });

  it('should handle nested elements with different size constraints', async () => {
    const container = document.createElement('flutter-constraint-container-2');
    document.body.appendChild(container);

    // Create a nested structure with absolute and relative sizes
    const outerDiv = document.createElement('div');
    outerDiv.style.backgroundColor = 'lightgray';
    outerDiv.style.padding = '15px';
    outerDiv.style.height = '200px';
    outerDiv.style.width = '250px';
    outerDiv.style.border = '2px dashed blue';

    const innerDiv = document.createElement('div');
    innerDiv.style.backgroundColor = 'salmon';
    innerDiv.style.height = '50%';
    innerDiv.style.width = '50%';
    innerDiv.style.border = '1px solid black';
    innerDiv.textContent = 'Inner element (50%)';
    
    outerDiv.appendChild(innerDiv);
    container.appendChild(outerDiv);

    await snapshot();
  });

  it('should handle flex layout within the constrained container', async () => {
    const container = document.createElement('flutter-constraint-container-2');
    document.body.appendChild(container);

    // Create a flex container within the constrained area
    const flexContainer = document.createElement('div');
    flexContainer.style.display = 'flex';
    flexContainer.style.flexDirection = 'row';
    flexContainer.style.justifyContent = 'space-between';
    flexContainer.style.height = '100%';
    flexContainer.style.width = '100%';
    flexContainer.style.backgroundColor = '#e9e9e9';
    
    // Add flex items
    for (let i = 0; i < 3; i++) {
      const item = document.createElement('div');
      item.style.flex = '1';
      item.style.margin = '5px';
      item.style.padding = '10px';
      item.style.backgroundColor = ['#ffcccc', '#ccffcc', '#ccccff'][i];
      item.style.border = '1px solid #999';
      item.textContent = `Flex Item ${i+1}`;
      flexContainer.appendChild(item);
    }
    
    container.appendChild(flexContainer);
    
    await snapshot();
  });

  it('should properly respond to dynamic content changes', async () => {
    const container = document.createElement('flutter-constraint-container-2');
    document.body.appendChild(container);

    // Create initial content
    const content = document.createElement('div');
    content.style.height = '100%';
    content.style.width = '100%';
    content.style.backgroundColor = 'lightblue';
    content.style.display = 'flex';
    content.style.alignItems = 'center';
    content.style.justifyContent = 'center';
    content.innerHTML = '<div style="background-color: white; padding: 20px;">Initial Content</div>';
    
    container.appendChild(content);
    
    await snapshot();
    
    // Dynamically change the content
    content.style.flexDirection = 'column';
    content.style.backgroundColor = 'lightgreen';
    content.innerHTML = `
      <div style="background-color: white; padding: 10px; margin: 5px; border: 1px solid black;">Item 1</div>
      <div style="background-color: white; padding: 10px; margin: 5px; border: 1px solid black;">Item 2</div>
      <div style="background-color: white; padding: 10px; margin: 5px; border: 1px solid black;">Item 3</div>
    `;
    
    await snapshot();
  });

  it('should handle complex nested layouts with mixed units', async () => {
    const container = document.createElement('flutter-constraint-container-2');
    document.body.appendChild(container);

    // Create a complex layout with mixed units
    const wrapper = document.createElement('div');
    wrapper.style.height = '100%';
    wrapper.style.width = '100%';
    wrapper.style.backgroundColor = '#f5f5f5';
    wrapper.style.padding = '10px';
    wrapper.style.boxSizing = 'border-box';
    
    // Create header
    const header = document.createElement('div');
    header.style.height = '20%';
    header.style.width = '100%';
    header.style.backgroundColor = '#4a90e2';
    header.style.color = 'white';
    header.style.display = 'flex';
    header.style.alignItems = 'center';
    header.style.justifyContent = 'center';
    header.style.fontSize = '18px';
    header.style.fontWeight = 'bold';
    header.textContent = 'Header (20% height)';
    
    // Create content area
    const content = document.createElement('div');
    content.style.height = 'calc(60% - 20px)';
    content.style.width = '100%';
    content.style.backgroundColor = 'white';
    content.style.marginTop = '10px';
    content.style.marginBottom = '10px';
    content.style.padding = '15px';
    content.style.boxSizing = 'border-box';
    content.style.overflow = 'auto';
    content.style.border = '1px solid #ddd';
    
    // Add some content paragraphs
    for (let i = 0; i < 2; i++) {
      const para = document.createElement('p');
      para.style.margin = '0 0 10px 0';
      para.textContent = `This is paragraph ${i+1} in the content area. This demonstrates complex nested layouts with mixed units inside the Flutter constraint container.`;
      content.appendChild(para);
    }
    
    // Create footer
    const footer = document.createElement('div');
    footer.style.height = '20%';
    footer.style.width = '100%';
    footer.style.backgroundColor = '#333';
    footer.style.color = 'white';
    footer.style.display = 'flex';
    footer.style.alignItems = 'center';
    footer.style.justifyContent = 'center';
    footer.textContent = 'Footer (20% height)';
    
    // Assemble the layout
    wrapper.appendChild(header);
    wrapper.appendChild(content);
    wrapper.appendChild(footer);
    container.appendChild(wrapper);
    
    await snapshot();
  });
  
  it('should properly nest item element within parent container with correct constraints', async () => {
    const container = document.createElement('flutter-constraint-container-2');
    document.body.appendChild(container);
    
    // Create a container item
    const item = document.createElement('flutter-constraint-container-2-item');
    item.style.width = '90%';
    item.style.height = '90%';
    item.style.margin = 'auto';
    
    // Add content to the item
    const content = document.createElement('div');
    content.style.width = '100%';
    content.style.height = '100%';
    content.style.backgroundColor = 'lightcoral';
    content.style.border = '2px dashed purple';
    content.style.display = 'flex';
    content.style.alignItems = 'center';
    content.style.justifyContent = 'center';
    content.textContent = 'Nested constraint item';
    
    item.appendChild(content);
    container.appendChild(item);
    
    await snapshot();
  });
  
  it('should handle multiple nested item elements with proper constraints', async () => {
    const container = document.createElement('flutter-constraint-container-2');
    document.body.appendChild(container);
    
    // Create a container for the items
    const wrapper = document.createElement('div');
    wrapper.style.display = 'flex';
    wrapper.style.flexDirection = 'row';
    wrapper.style.width = '100%';
    wrapper.style.height = '100%';
    wrapper.style.backgroundColor = '#eaeaea';
    wrapper.style.padding = '10px';
    wrapper.style.boxSizing = 'border-box';
    
    // Create multiple item elements
    for (let i = 0; i < 2; i++) {
      const item = document.createElement('flutter-constraint-container-2-item');
      item.style.flex = '1';
      item.style.margin = '5px';
      
      const content = document.createElement('div');
      content.style.width = '100%';
      content.style.height = '100%';
      content.style.backgroundColor = i === 0 ? 'lightseagreen' : 'lightsalmon';
      content.style.display = 'flex';
      content.style.alignItems = 'center';
      content.style.justifyContent = 'center';
      content.style.border = '2px solid #666';
      content.textContent = `Item ${i+1}`;
      
      item.appendChild(content);
      wrapper.appendChild(item);
    }
    
    container.appendChild(wrapper);
    
    await snapshot();
  });
});
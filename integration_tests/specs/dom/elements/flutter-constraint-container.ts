describe('flutter-constraint-container with WebFWidgetElementChild', () => {
  it('should properly display content with constrained size from Flutter widget', async () => {
    const container = document.createElement('flutter-constraint-container');
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
    const container = document.createElement('flutter-constraint-container');
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

  it('should properly handle multiple elements using the same constraints', async () => {
    const container = document.createElement('flutter-constraint-container');
    document.body.appendChild(container);

    // Create multiple elements that share the container's constraints
    for (let i = 0; i < 3; i++) {
      const div = document.createElement('div');
      div.style.backgroundColor = i % 2 === 0 ? 'lightblue' : 'lightgreen';
      div.style.margin = '5px';
      div.style.padding = '5px';
      div.style.border = '1px solid black';
      div.textContent = `Element ${i+1}`;
      container.appendChild(div);
    }

    await snapshot();
  });

  it('should handle dynamic changes to content within the constrained container', async () => {
    const container = document.createElement('flutter-constraint-container');
    document.body.appendChild(container);

    // Create initial content
    const div = document.createElement('div');
    div.style.backgroundColor = 'orange';
    div.style.padding = '10px';
    div.style.height = '50px';
    div.textContent = 'Initial content';
    container.appendChild(div);

    await snapshot();

    // Change the content dynamically
    div.style.height = '100px';
    div.style.backgroundColor = 'purple';
    div.style.color = 'white';
    div.textContent = 'Updated content with new height';

    await snapshot();
  });

  it('should respect percentage-based sizes relative to container constraints', async () => {
    const container = document.createElement('flutter-constraint-container');
    document.body.appendChild(container);

    // Create a nested structure with percentage-based sizes
    const outerDiv = document.createElement('div');
    outerDiv.style.width = '80%';      // 80% of the constrained width
    outerDiv.style.height = '80%';     // 80% of the constrained height
    outerDiv.style.backgroundColor = 'lightgray';
    outerDiv.style.display = 'flex';
    outerDiv.style.alignItems = 'center';
    outerDiv.style.justifyContent = 'center';

    const innerDiv = document.createElement('div');
    innerDiv.style.width = '50%';      // 50% of the outer div (40% of container)
    innerDiv.style.height = '50%';     // 50% of the outer div (40% of container)
    innerDiv.style.backgroundColor = 'tomato';
    innerDiv.style.display = 'flex';
    innerDiv.style.alignItems = 'center';
    innerDiv.style.justifyContent = 'center';
    innerDiv.textContent = 'Nested percentages';

    outerDiv.appendChild(innerDiv);
    container.appendChild(outerDiv);

    await snapshot();
  });
});

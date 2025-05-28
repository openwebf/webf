describe('RenderBoxModel parent box check', () => {
  it('should correctly handle layout when parent is RenderBoxModel for RenderWidget', async () => {
    // Create a container with specific dimensions and style
    const container = document.createElement('div');
    container.style.width = '300px';
    container.style.height = '200px';
    container.style.padding = '10px';
    container.style.margin = '15px';
    container.style.border = '5px solid black';
    container.style.display = 'flex';
    container.style.flexDirection = 'column';

    // Create a text element that extends RenderWidget
    const textWidget = createElement('text', {
      style: {
        width: '100%',
        backgroundColor: 'lightblue',
        padding: '10px'
      }
    }, [
      createText('Text inside flex container')
    ]);

    // Add the widget to the container
    container.appendChild(textWidget);
    document.body.appendChild(container);

    await snapshot();
  });

  it('should correctly calculate constraints for RenderWidget with multiple nesting levels', async () => {
    // Create a parent with specific dimensions
    const parent = document.createElement('div');
    parent.style.width = '400px';
    parent.style.height = '300px';
    parent.style.padding = '20px';
    parent.style.border = '5px solid black';
    parent.style.display = 'flex';

    // Create a child container
    const child = document.createElement('div');
    child.style.width = '80%';
    child.style.padding = '15px';
    child.style.border = '3px solid red';
    child.style.display = 'flex';

    // Create a text widget element inside the nested structure
    const textWidget = createElement('text', {
      style: {
        backgroundColor: 'lightgreen',
        padding: '10px'
      }
    }, [
      createText('Deeply nested text widget')
    ]);

    // Build the nested structure
    child.appendChild(textWidget);
    parent.appendChild(child);
    document.body.appendChild(parent);

    await snapshot();
  });
});

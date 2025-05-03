/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

describe('Text color change test', () => {
  it('should properly update text when text color is changed', async () => {
    const container = document.createElement('div');
    document.body.appendChild(container);
    
    const textElement = document.createElement('span');
    textElement.textContent = 'Hello World';
    textElement.style.color = 'black';
    container.appendChild(textElement);
    
    await snapshot();
    
    // Change the color, which should trigger relayout
    textElement.style.color = 'red';
    
    await snapshot();
    
    // The text should change color immediately and have proper layout
    // Clean up
    document.body.removeChild(container);
  });
  
  it('should properly update text when parent color changes', async () => {
    const container = document.createElement('div');
    document.body.appendChild(container);
    
    // Create parent with inherited color
    const parent = document.createElement('div');
    parent.style.color = 'blue';
    container.appendChild(parent);
    
    // Create text element that inherits color
    const textElement = document.createElement('span');
    textElement.textContent = 'Inherits Color';
    parent.appendChild(textElement);
    
    await snapshot();
    
    // Change the parent color, which should update the text color
    parent.style.color = 'green';
    
    await snapshot();
    
    // Clean up
    document.body.removeChild(container);
  });
  
  it('should properly update text style when toggling between states', async () => {
    const container = document.createElement('div');
    document.body.appendChild(container);
    
    // Create a text element that will toggle styles
    const textElement = document.createElement('span');
    textElement.textContent = 'Toggle Style';
    textElement.style.color = 'black';
    textElement.style.fontStyle = 'normal';
    container.appendChild(textElement);
    
    await snapshot();
    
    // Toggle style to italic and change color
    textElement.style.fontStyle = 'italic';
    textElement.style.color = 'purple';
    
    await snapshot();
    
    // Toggle back to original style
    textElement.style.fontStyle = 'normal';
    textElement.style.color = 'black';
    
    await snapshot();
    
    // Clean up
    document.body.removeChild(container);
  });
});
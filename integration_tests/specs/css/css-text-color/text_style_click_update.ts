/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

describe('Text style update on click', () => {
  it('should properly update text style when clicked (simulating React behavior)', async () => {
    // Create a container for our list
    const container = document.createElement('div');
    container.style.padding = '20px';
    document.body.appendChild(container);
    
    // Options array similar to React component
    const options = [
      { key: 'AAAA', value: 'AAAA' },
      { key: 'BBBB', value: 'BBBB' },
      { key: 'CCCC', value: 'CCCC' }
    ];
    
    // Create option elements
    const optionElements = options.map(item => {
      const div = document.createElement('div');
      div.textContent = item.key;
      div.style.padding = '10px';
      div.style.margin = '5px';
      div.style.border = '1px solid #ccc';
      div.dataset.value = item.value;
      div.style.fontStyle = 'normal'; // Default style
      div.style.color = 'black'; // Default color
      
      // Add click handler
      div.addEventListener('click', function() {
        // Reset all items
        optionElements.forEach(el => {
          el.style.fontStyle = 'normal';
          el.style.color = 'black';
        });
        
        // Set clicked item style
        this.style.fontStyle = 'italic';
        this.style.color = 'red';
      });
      
      container.appendChild(div);
      return div;
    });
    
    // Initial snapshot
    await snapshot();
    
    // Click the first item
    optionElements[0].click();
    await snapshot();
    
    // Click the second item
    optionElements[1].click();
    await snapshot();
    
    // Click the third item
    optionElements[2].click();
    await snapshot();
    
    // Cleanup
    document.body.removeChild(container);
  });
});
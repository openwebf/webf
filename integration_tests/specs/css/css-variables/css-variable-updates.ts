/*
 * Integration test for CSS variable updates and their effects on styling
 */
xdescribe('CSS Variable Updates', () => {
  // Helper function to create style elements
  function createStyle(text) {
    const style = document.createElement('style');
    style.appendChild(document.createTextNode(text));
    return style;
  }

  // Helper function to wait for a small period
  function wait(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  // Test 1: Basic variable update and propagation
  it('correctly propagates simple variable updates', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --main-color: red;
        }
        .update-test {
          color: var(--main-color);
          padding: 10px;
          margin: 5px;
          border: 1px solid black;
        }
      `)
    );

    const container = document.createElement('div');
    for (let i = 0; i < 3; i++) {
      const element = document.createElement('div');
      element.className = 'update-test';
      element.textContent = `Element ${i+1}`;
      container.appendChild(element);
    }
    document.body.appendChild(container);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Update the variable
      document.documentElement.style.setProperty('--main-color', 'blue');
      
      await wait(20);
      await snapshot();
      
      // Update again
      document.documentElement.style.setProperty('--main-color', 'green');
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 2: Update variables in different scopes
  it('handles updates to variables in different scopes', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --global-color: red;
        }
        .parent {
          --parent-color: blue;
        }
        .child {
          color: var(--global-color);
          background-color: var(--parent-color);
          padding: 10px;
          margin: 5px;
        }
      `)
    );

    const parent = document.createElement('div');
    parent.className = 'parent';
    
    const child1 = document.createElement('div');
    child1.className = 'child';
    child1.textContent = 'Child 1';
    parent.appendChild(child1);
    
    const child2 = document.createElement('div');
    child2.className = 'child';
    child2.textContent = 'Child 2';
    parent.appendChild(child2);
    
    document.body.appendChild(parent);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Update global variable
      document.documentElement.style.setProperty('--global-color', 'green');
      
      await wait(20);
      await snapshot();
      
      // Update parent variable
      parent.style.setProperty('--parent-color', 'yellow');
      
      await wait(20);
      await snapshot();
      
      // Set a child to override the parent color
      child1.style.setProperty('--parent-color', 'purple');
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 3: Variable updates in animations and transitions
  it('handles variable updates in animations and transitions', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --box-color: red;
          --box-size: 100px;
        }
        .animated-box {
          background-color: var(--box-color);
          width: var(--box-size);
          height: var(--box-size);
          transition: all 0.1s ease-in-out;
        }
      `)
    );

    const box = document.createElement('div');
    box.className = 'animated-box';
    document.body.appendChild(box);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Update color and size
      document.documentElement.style.setProperty('--box-color', 'blue');
      document.documentElement.style.setProperty('--box-size', '150px');
      
      await wait(50); // Wait for transition
      await snapshot();
      
      // Update again
      document.documentElement.style.setProperty('--box-color', 'green');
      document.documentElement.style.setProperty('--box-size', '200px');
      
      await wait(50);
      await snapshot();
      
      done();
    });
  });

  // Test 4: Variable updates affecting layout properties
  it('correctly updates layout when variables change', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --margin-size: 10px;
          --padding-size: 15px;
          --width-size: 100px;
          --display-type: block;
        }
        .layout-test {
          margin: var(--margin-size);
          padding: var(--padding-size);
          width: var(--width-size);
          background-color: lightblue;
          display: var(--display-type);
        }
        .container {
          border: 1px solid black;
        }
      `)
    );

    const container = document.createElement('div');
    container.className = 'container';
    
    for (let i = 0; i < 3; i++) {
      const element = document.createElement('div');
      element.className = 'layout-test';
      element.textContent = `Layout item ${i+1}`;
      container.appendChild(element);
    }
    
    document.body.appendChild(container);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Update margin and padding
      document.documentElement.style.setProperty('--margin-size', '20px');
      document.documentElement.style.setProperty('--padding-size', '25px');
      
      await wait(20);
      await snapshot();
      
      // Change display property
      document.documentElement.style.setProperty('--display-type', 'inline-block');
      document.documentElement.style.setProperty('--width-size', '150px');
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 5: Variable updates affecting pseudo-elements
  it('handles variable updates in pseudo-elements', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --pseudo-color: red;
          --pseudo-content: "►";
        }
        .pseudo-test {
          position: relative;
          padding: 10px;
          margin: 20px;
        }
        .pseudo-test::before {
          content: var(--pseudo-content);
          color: var(--pseudo-color);
          position: absolute;
          left: 0;
        }
      `)
    );

    const element = document.createElement('div');
    element.className = 'pseudo-test';
    element.textContent = 'Pseudo-element test';
    document.body.appendChild(element);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Update pseudo-element properties
      document.documentElement.style.setProperty('--pseudo-color', 'blue');
      document.documentElement.style.setProperty('--pseudo-content', '"✓"');
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 6: Variable updates in complex computed properties
  it('handles variable updates in calc and complex values', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --base-size: 10px;
          --multiplier: 2;
          --computed-size: calc(var(--base-size) * var(--multiplier));
        }
        .calc-test {
          width: var(--computed-size);
          height: var(--computed-size);
          margin: calc(var(--base-size) / 2);
          background-color: lightgreen;
        }
      `)
    );

    const container = document.createElement('div');
    
    for (let i = 0; i < 4; i++) {
      const element = document.createElement('div');
      element.className = 'calc-test';
      container.appendChild(element);
    }
    
    document.body.appendChild(container);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Update base size
      document.documentElement.style.setProperty('--base-size', '20px');
      
      await wait(20);
      await snapshot();
      
      // Update multiplier
      document.documentElement.style.setProperty('--multiplier', '3');
      
      await wait(20);
      await snapshot();
      
      // Update computed size directly
      document.documentElement.style.setProperty('--computed-size', '100px');
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 7: Variable updates with value type changes
  it('handles updates that change value types', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --dynamic-value: 50px;
        }
        .type-test {
          width: var(--dynamic-value);
          height: 50px;
          background-color: var(--dynamic-value, blue);
          margin: 10px;
        }
      `)
    );

    const element = document.createElement('div');
    element.className = 'type-test';
    document.body.appendChild(element);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Change from length to color
      document.documentElement.style.setProperty('--dynamic-value', 'red');
      
      await wait(20);
      await snapshot();
      
      // Change to complex value
      document.documentElement.style.setProperty('--dynamic-value', '1px solid green');
      
      await wait(20);
      await snapshot();
      
      // Change to url
      document.documentElement.style.setProperty('--dynamic-value', 'url("data:image/png;base64,iVBORw0KGgo=")');
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 8: Variable updates with different specificity rules
  it('respects specificity when updating variables', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --spec-color: black;
        }
        div {
          --spec-color: red;
        }
        .spec-class {
          --spec-color: green;
        }
        #spec-id {
          --spec-color: blue;
        }
        .test-element {
          color: var(--spec-color);
          padding: 10px;
          margin: 5px;
        }
      `)
    );

    const container = document.createElement('div');
    
    const element1 = document.createElement('div');
    element1.className = 'test-element';
    element1.textContent = 'Element 1 (should be red)';
    container.appendChild(element1);
    
    const element2 = document.createElement('div');
    element2.className = 'test-element spec-class';
    element2.textContent = 'Element 2 (should be green)';
    container.appendChild(element2);
    
    const element3 = document.createElement('div');
    element3.className = 'test-element spec-class';
    element3.id = 'spec-id';
    element3.textContent = 'Element 3 (should be blue)';
    container.appendChild(element3);
    
    document.body.appendChild(container);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Update variables at different specificity levels
      document.documentElement.style.setProperty('--spec-color', 'purple');
      
      await wait(20);
      await snapshot();
      
      // Update class-level variable
      const rules = document.styleSheets[0].cssRules;
      for (let i = 0; i < rules.length; i++) {
        if (rules[i].selectorText === '.spec-class') {
          rules[i].style.setProperty('--spec-color', 'orange');
          break;
        }
      }
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 9: Variable updates with shorthand vs longhand properties
  it('handles updates affecting shorthand and longhand properties', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --border-width: 1px;
          --border-style: solid;
          --border-color: black;
          --padding-value: 10px;
        }
        .shorthand-test {
          border: var(--border-width) var(--border-style) var(--border-color);
          padding: var(--padding-value);
          margin: 10px;
          background-color: #f0f0f0;
        }
      `)
    );

    const element = document.createElement('div');
    element.className = 'shorthand-test';
    element.textContent = 'Shorthand test';
    document.body.appendChild(element);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Update individual border properties
      document.documentElement.style.setProperty('--border-width', '3px');
      document.documentElement.style.setProperty('--border-color', 'blue');
      
      await wait(20);
      await snapshot();
      
      // Set direct shorthand that would conflict
      element.style.borderBottom = '2px dashed red';
      
      await wait(20);
      await snapshot();
      
      // Update variable again
      document.documentElement.style.setProperty('--border-style', 'dotted');
      document.documentElement.style.setProperty('--border-color', 'green');
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 10: Variable updates that cascade through multiple elements
  it('properly cascades variable updates through multiple elements', async (done) => {
    document.head.appendChild(
      createStyle(`
        .level-1 {
          --cascade-color: red;
        }
        .level-2 {
          color: var(--cascade-color);
        }
        .level-3 {
          --cascade-color: green;
        }
        .level-4 {
          color: var(--cascade-color);
        }
      `)
    );

    const level1 = document.createElement('div');
    level1.className = 'level-1';
    level1.textContent = 'Level 1';
    
    const level2 = document.createElement('div');
    level2.className = 'level-2';
    level2.textContent = 'Level 2 (inherits red)';
    level1.appendChild(level2);
    
    const level3 = document.createElement('div');
    level3.className = 'level-3';
    level3.textContent = 'Level 3 (overrides to green)';
    level2.appendChild(level3);
    
    const level4 = document.createElement('div');
    level4.className = 'level-4';
    level4.textContent = 'Level 4 (inherits green)';
    level3.appendChild(level4);
    
    document.body.appendChild(level1);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Update the top-level variable
      level1.style.setProperty('--cascade-color', 'blue');
      
      await wait(20);
      await snapshot();
      
      // Update the mid-level variable
      level3.style.setProperty('--cascade-color', 'purple');
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });
});
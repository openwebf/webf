/*
 * Integration test for CSS variables with multiple updates and race conditions
 */
describe('CSS Variable Race Conditions', () => {
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

  // Test 1: Rapid sequential updates to CSS variables
  xit('handles rapid sequential updates to CSS variables', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --rapid-color: red;
        }
        .test-element {
          color: var(--rapid-color);
          padding: 10px;
          background-color: #f0f0f0;
        }
      `)
    );

    const element = document.createElement('div');
    element.className = 'test-element';
    element.textContent = 'Rapid update test';
    document.body.appendChild(element);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Rapid sequential updates
      const colors = ['blue', 'green', 'purple', 'orange', 'cyan'];
      
      for (const color of colors) {
        document.documentElement.style.setProperty('--rapid-color', color);
        // Minimal wait to ensure updates are sequential but fast
        await wait(5);
      }
      
      // Final should be cyan
      await snapshot();
      
      done();
    });
  });

  // Test 2: Simultaneous updates to different CSS variables
  it('handles simultaneous updates to different CSS variables', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --color-1: red;
          --color-2: blue;
          --color-3: green;
        }
        .element-1 {
          color: var(--color-1);
          padding: 10px;
        }
        .element-2 {
          color: var(--color-2);
          padding: 10px;
        }
        .element-3 {
          color: var(--color-3);
          padding: 10px;
        }
      `)
    );

    const container = document.createElement('div');
    
    const element1 = document.createElement('div');
    element1.className = 'element-1';
    element1.textContent = 'Element 1';
    container.appendChild(element1);
    
    const element2 = document.createElement('div');
    element2.className = 'element-2';
    element2.textContent = 'Element 2';
    container.appendChild(element2);
    
    const element3 = document.createElement('div');
    element3.className = 'element-3';
    element3.textContent = 'Element 3';
    container.appendChild(element3);
    
    document.body.appendChild(container);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Simultaneously update all variables
      document.documentElement.style.setProperty('--color-1', 'purple');
      document.documentElement.style.setProperty('--color-2', 'orange');
      document.documentElement.style.setProperty('--color-3', 'cyan');
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 3: Updates during rapid DOM changes
  xit('handles CSS variable updates during rapid DOM changes', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --dynamic-color: red;
        }
        .dynamic-element {
          color: var(--dynamic-color);
          padding: 10px;
          margin: 5px;
        }
      `)
    );

    const container = document.createElement('div');
    document.body.appendChild(container);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Add elements and update variable rapidly
      for (let i = 0; i < 5; i++) {
        // Add new element
        const element = document.createElement('div');
        element.className = 'dynamic-element';
        element.textContent = `Dynamic element ${i+1}`;
        container.appendChild(element);
        
        // Update variable
        const colors = ['blue', 'green', 'purple', 'orange', 'cyan'];
        document.documentElement.style.setProperty('--dynamic-color', colors[i]);
        
        await wait(10);
      }
      
      await snapshot();
      
      done();
    });
  });

  // Test 4: Interleaved variable definition and usage
  xit('handles interleaved variable definition and usage', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --interleaved-color: red;
        }
        .test-element {
          color: var(--interleaved-color);
          padding: 10px;
          background-color: #f0f0f0;
        }
      `)
    );

    const container = document.createElement('div');
    document.body.appendChild(container);

    requestAnimationFrame(async () => {
      // Create initial elements
      const element1 = document.createElement('div');
      element1.className = 'test-element';
      element1.textContent = 'Element 1';
      container.appendChild(element1);
      
      await snapshot();
      
      // Update CSS variable
      document.documentElement.style.setProperty('--interleaved-color', 'blue');
      
      // Add new element - should get updated variable
      const element2 = document.createElement('div');
      element2.className = 'test-element';
      element2.textContent = 'Element 2';
      container.appendChild(element2);
      
      await wait(10);
      await snapshot();
      
      // Update CSS variable again
      document.documentElement.style.setProperty('--interleaved-color', 'green');
      
      // Add another element - should get newly updated variable
      const element3 = document.createElement('div');
      element3.className = 'test-element';
      element3.textContent = 'Element 3';
      container.appendChild(element3);
      
      await wait(10);
      await snapshot();
      
      done();
    });
  });

  // Test 5: Updates during style changes
  xit('handles CSS variable updates during style changes', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --style-color: red;
        }
        .test-element {
          color: var(--style-color);
          padding: 10px;
          transition: background-color 0.1s;
        }
      `)
    );

    const element = document.createElement('div');
    element.className = 'test-element';
    element.textContent = 'Style change test';
    document.body.appendChild(element);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Start changing direct styles
      element.style.backgroundColor = 'lightgray';
      
      // Update variable while style is changing
      await wait(5);
      document.documentElement.style.setProperty('--style-color', 'blue');
      
      await wait(10);
      await snapshot();
      
      // Change style again
      element.style.padding = '20px';
      
      // Update variable again
      await wait(5);
      document.documentElement.style.setProperty('--style-color', 'green');
      
      await wait(10);
      await snapshot();
      
      done();
    });
  });

  // Test 6: Variable dependencies with rapid updates
  xit('handles variable dependencies with rapid updates', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --primary-color: red;
          --secondary-color: var(--primary-color);
          --tertiary-color: var(--secondary-color);
        }
        .primary {
          color: var(--primary-color);
          padding: 10px;
        }
        .secondary {
          color: var(--secondary-color);
          padding: 10px;
        }
        .tertiary {
          color: var(--tertiary-color);
          padding: 10px;
        }
      `)
    );

    const container = document.createElement('div');
    
    const primary = document.createElement('div');
    primary.className = 'primary';
    primary.textContent = 'Primary element';
    container.appendChild(primary);
    
    const secondary = document.createElement('div');
    secondary.className = 'secondary';
    secondary.textContent = 'Secondary element';
    container.appendChild(secondary);
    
    const tertiary = document.createElement('div');
    tertiary.className = 'tertiary';
    tertiary.textContent = 'Tertiary element';
    container.appendChild(tertiary);
    
    document.body.appendChild(container);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Rapid updates to the primary color should propagate to dependencies
      const colors = ['blue', 'green', 'purple', 'orange', 'cyan'];
      
      for (const color of colors) {
        document.documentElement.style.setProperty('--primary-color', color);
        await wait(5);
      }
      
      await snapshot();
      
      // Break dependency chain
      document.documentElement.style.setProperty('--secondary-color', 'red');
      
      await wait(10);
      await snapshot();
      
      // Update primary again - should not affect tertiary now
      document.documentElement.style.setProperty('--primary-color', 'blue');
      
      await wait(10);
      await snapshot();
      
      done();
    });
  });

  // Test 7: CSS variable updates during animations
  xit('handles CSS variable updates during animations', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --animation-color: red;
        }
        @keyframes colorPulse {
          0% { background-color: lightblue; }
          50% { background-color: lightgreen; }
          100% { background-color: lightblue; }
        }
        .animated {
          color: var(--animation-color);
          padding: 20px;
          animation: colorPulse 0.5s infinite;
        }
      `)
    );

    const element = document.createElement('div');
    element.className = 'animated';
    element.textContent = 'Animated element';
    document.body.appendChild(element);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Update variable during animation
      await wait(100); // Wait for animation to be running
      document.documentElement.style.setProperty('--animation-color', 'blue');
      
      await wait(20);
      await snapshot();
      
      // Update again during animation
      await wait(100);
      document.documentElement.style.setProperty('--animation-color', 'green');
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 8: CSS variable updates in multiple stylesheets
  it('handles CSS variable updates in multiple stylesheets', async (done) => {
    // First stylesheet
    document.head.appendChild(
      createStyle(`
        :root {
          --sheet1-color: red;
        }
        .element-1 {
          color: var(--sheet1-color);
          padding: 10px;
        }
      `)
    );
    
    // Second stylesheet
    document.head.appendChild(
      createStyle(`
        :root {
          --sheet2-color: blue;
        }
        .element-2 {
          color: var(--sheet2-color);
          padding: 10px;
        }
      `)
    );

    const container = document.createElement('div');
    
    const element1 = document.createElement('div');
    element1.className = 'element-1';
    element1.textContent = 'Element 1';
    container.appendChild(element1);
    
    const element2 = document.createElement('div');
    element2.className = 'element-2';
    element2.textContent = 'Element 2';
    container.appendChild(element2);
    
    document.body.appendChild(container);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Update variables from both stylesheets rapidly
      document.documentElement.style.setProperty('--sheet1-color', 'green');
      document.documentElement.style.setProperty('--sheet2-color', 'purple');
      
      await wait(10);
      await snapshot();
      
      // Create a third stylesheet dynamically
      const style3 = createStyle(`
        :root {
          --sheet3-color: orange;
        }
        .element-3 {
          color: var(--sheet3-color);
          padding: 10px;
        }
      `);
      document.head.appendChild(style3);
      
      // Add element using the third stylesheet
      const element3 = document.createElement('div');
      element3.className = 'element-3';
      element3.textContent = 'Element 3';
      container.appendChild(element3);
      
      await wait(10);
      await snapshot();
      
      // Update all variables
      document.documentElement.style.setProperty('--sheet1-color', 'cyan');
      document.documentElement.style.setProperty('--sheet2-color', 'magenta');
      document.documentElement.style.setProperty('--sheet3-color', 'yellow');
      
      await wait(10);
      await snapshot();
      
      done();
    });
  });

  // Test 9: CSS variable updates with nested requestAnimationFrame calls
  xit('handles CSS variable updates with nested requestAnimationFrame calls', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --frame-color: red;
        }
        .test-element {
          color: var(--frame-color);
          padding: 10px;
          background-color: #f0f0f0;
        }
      `)
    );

    const element = document.createElement('div');
    element.className = 'test-element';
    element.textContent = 'Frame test';
    document.body.appendChild(element);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // First level update
      document.documentElement.style.setProperty('--frame-color', 'blue');
      
      requestAnimationFrame(async () => {
        // Second level update
        document.documentElement.style.setProperty('--frame-color', 'green');
        
        requestAnimationFrame(async () => {
          // Third level update
          document.documentElement.style.setProperty('--frame-color', 'purple');
          
          await wait(10);
          await snapshot();
          
          done();
        });
      });
    });
  });

  // Test 10: CSS variable updates during DOM reflow
  xit('handles CSS variable updates during DOM reflow', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --reflow-color: red;
          --reflow-width: 100px;
        }
        .reflow-container {
          display: flex;
          flex-wrap: wrap;
          width: 300px;
        }
        .reflow-item {
          color: var(--reflow-color);
          width: var(--reflow-width);
          padding: 10px;
          margin: 5px;
          background-color: #f0f0f0;
        }
      `)
    );

    const container = document.createElement('div');
    container.className = 'reflow-container';
    
    // Add several items to the container
    for (let i = 0; i < 5; i++) {
      const item = document.createElement('div');
      item.className = 'reflow-item';
      item.textContent = `Item ${i+1}`;
      container.appendChild(item);
    }
    
    document.body.appendChild(container);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Change width to trigger reflow
      document.documentElement.style.setProperty('--reflow-width', '150px');
      
      // Update color during reflow
      document.documentElement.style.setProperty('--reflow-color', 'blue');
      
      await wait(20);
      await snapshot();
      
      // Add new items to cause more reflow
      for (let i = 5; i < 8; i++) {
        const item = document.createElement('div');
        item.className = 'reflow-item';
        item.textContent = `Item ${i+1}`;
        container.appendChild(item);
      }
      
      // Update color again during reflow
      document.documentElement.style.setProperty('--reflow-color', 'green');
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 11: CSS variable updates with setTimeout timing
  xit('handles CSS variable updates with setTimeout timing', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --timeout-color: red;
        }
        .test-element {
          color: var(--timeout-color);
          padding: 10px;
          background-color: #f0f0f0;
        }
      `)
    );

    const element = document.createElement('div');
    element.className = 'test-element';
    element.textContent = 'Timeout test';
    document.body.appendChild(element);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Schedule multiple updates with setTimeout
      setTimeout(() => {
        document.documentElement.style.setProperty('--timeout-color', 'blue');
      }, 10);
      
      setTimeout(() => {
        document.documentElement.style.setProperty('--timeout-color', 'green');
      }, 20);
      
      setTimeout(() => {
        document.documentElement.style.setProperty('--timeout-color', 'purple');
      }, 30);
      
      // Wait for all timeouts to complete
      await wait(50);
      await snapshot();
      
      done();
    });
  });

  // Test 12: CSS variable updates with microtasks and macrotasks
  xit('handles CSS variable updates with microtasks and macrotasks', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --task-color: red;
        }
        .test-element {
          color: var(--task-color);
          padding: 10px;
          background-color: #f0f0f0;
        }
      `)
    );

    const element = document.createElement('div');
    element.className = 'test-element';
    element.textContent = 'Task scheduling test';
    document.body.appendChild(element);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Interleave microtasks (Promise.resolve().then) and macrotasks (setTimeout)
      
      // First update (synchronous)
      document.documentElement.style.setProperty('--task-color', 'blue');
      
      // Schedule microtask
      Promise.resolve().then(() => {
        document.documentElement.style.setProperty('--task-color', 'green');
        
        // Schedule another microtask from within a microtask
        Promise.resolve().then(() => {
          document.documentElement.style.setProperty('--task-color', 'purple');
        });
      });
      
      // Schedule macrotask
      setTimeout(() => {
        document.documentElement.style.setProperty('--task-color', 'orange');
        
        // Schedule microtask from within macrotask
        Promise.resolve().then(() => {
          document.documentElement.style.setProperty('--task-color', 'cyan');
        });
      }, 10);
      
      // Wait for all tasks to complete
      await wait(50);
      await snapshot();
      
      done();
    });
  });
});
/*
 * Integration test for interactions between CSS variables and direct style properties
 */
xdescribe('CSS Variable Style Interactions', () => {
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

  // Test 1: Basic interaction between CSS variables and direct styles
  it('prioritizes direct styles over CSS variables', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --text-color: blue;
          --bg-color: #f0f0f0;
        }
        .test-element {
          color: var(--text-color);
          background-color: var(--bg-color);
          padding: 10px;
          margin: 5px;
        }
      `)
    );

    const element = document.createElement('div');
    element.className = 'test-element';
    element.textContent = 'Element with variable styles';
    document.body.appendChild(element);

    requestAnimationFrame(async () => {
      // Initial state with CSS variable values
      await snapshot();
      
      // Apply direct style that should override CSS variable
      element.style.color = 'red';
      
      await wait(20);
      await snapshot();
      
      // Update CSS variable - direct style should still win
      document.documentElement.style.setProperty('--text-color', 'green');
      
      await wait(20);
      await snapshot();
      
      // Remove direct style - CSS variable should show again
      element.style.color = '';
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 2: Precedence with !important rules
  xit('respects !important rules in variable vs direct style conflicts', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --text-color: blue;
        }
        .test-element {
          color: var(--text-color) !important;
          background-color: var(--bg-color, lightgray);
          padding: 10px;
          margin: 5px;
        }
      `)
    );

    const element = document.createElement('div');
    element.className = 'test-element';
    element.textContent = 'Testing !important rules';
    document.body.appendChild(element);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Apply direct style - should NOT override CSS variable due to !important
      element.style.color = 'red';
      
      await wait(20);
      await snapshot();
      
      // Update CSS variable - should change the color
      document.documentElement.style.setProperty('--text-color', 'green');
      
      await wait(20);
      await snapshot();
      
      // Try to set style with !important (using cssText)
      element.style.cssText += 'color: purple !important;';
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 3: Updating CSS variables vs. updating styles directly
  it('handles sequence of updates between CSS variables and direct styles', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --box-color: blue;
          --box-size: 100px;
        }
        .test-box {
          background-color: var(--box-color);
          width: var(--box-size);
          height: var(--box-size);
          margin: 10px;
        }
      `)
    );

    const box = document.createElement('div');
    box.className = 'test-box';
    document.body.appendChild(box);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Sequence of alternating direct style and variable updates
      
      // 1. Update direct style
      box.style.backgroundColor = 'red';
      await wait(20);
      await snapshot();
      
      // 2. Update CSS variable (should not affect backgroundColor)
      document.documentElement.style.setProperty('--box-color', 'green');
      await wait(20);
      await snapshot();
      
      // 3. Update direct style again
      box.style.width = '150px';
      await wait(20);
      await snapshot();
      
      // 4. Update CSS variable (should affect height but not width)
      document.documentElement.style.setProperty('--box-size', '200px');
      await wait(20);
      await snapshot();
      
      // 5. Remove direct styles - CSS variables should take effect
      box.style.backgroundColor = '';
      box.style.width = '';
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 4: Style changes on parent elements affecting CSS variable inheritance
  xit('handles variable inheritance when styles change on parent elements', async (done) => {
    document.head.appendChild(
      createStyle(`
        .parent {
          --parent-color: blue;
        }
        .child {
          color: var(--parent-color);
          padding: 10px;
        }
        .parent.modified {
          --parent-color: green;
        }
      `)
    );

    const parent = document.createElement('div');
    parent.className = 'parent';
    
    const child = document.createElement('div');
    child.className = 'child';
    child.textContent = 'Child element inheriting color';
    parent.appendChild(child);
    
    document.body.appendChild(parent);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Modify parent class - should affect CSS variable
      parent.classList.add('modified');
      
      await wait(20);
      await snapshot();
      
      // Direct style on parent
      parent.style.setProperty('--parent-color', 'red');
      
      await wait(20);
      await snapshot();
      
      // Direct style on child - should override inherited value
      child.style.color = 'purple';
      
      await wait(20);
      await snapshot();
      
      // Remove direct style on child - should revert to parent's variable
      child.style.color = '';
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 5: Interactions with inline styles and CSS variables
  xit('handles interaction between inline styles and CSS variables', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --text-color: blue;
          --bg-color: lightgray;
        }
        .test-element {
          color: var(--text-color);
          background-color: var(--bg-color);
          padding: 10px;
          margin: 5px;
        }
      `)
    );

    // Create element with inline style
    const element = document.createElement('div');
    element.className = 'test-element';
    element.style.color = 'red'; // Inline style should override CSS variable
    element.textContent = 'Element with inline styles';
    document.body.appendChild(element);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Update CSS variable
      document.documentElement.style.setProperty('--text-color', 'green');
      
      await wait(20);
      await snapshot();
      
      // Remove inline style
      element.removeAttribute('style');
      
      await wait(20);
      await snapshot();
      
      // Add another inline style
      element.setAttribute('style', 'background-color: yellow;');
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 6: Direct style changes after CSS variables are computed
  xit('handles direct style changes after CSS variables are computed', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --computed-width: 100px;
          --computed-height: 100px;
          --computed-color: blue;
        }
        .test-element {
          width: var(--computed-width);
          height: var(--computed-height);
          background-color: var(--computed-color);
          margin: 10px;
        }
      `)
    );

    const element = document.createElement('div');
    element.className = 'test-element';
    document.body.appendChild(element);

    // Function to update styles in sequence
    async function updateStylesInSequence() {
      // Initial state
      await snapshot();
      
      // Update CSS variables
      document.documentElement.style.setProperty('--computed-width', '150px');
      document.documentElement.style.setProperty('--computed-color', 'red');
      
      await wait(20);
      await snapshot();
      
      // Now override with direct styles
      element.style.width = '200px';
      element.style.height = '200px';
      
      await wait(20);
      await snapshot();
      
      // Update CSS variables again
      document.documentElement.style.setProperty('--computed-width', '250px');
      document.documentElement.style.setProperty('--computed-height', '250px');
      document.documentElement.style.setProperty('--computed-color', 'green');
      
      await wait(20);
      await snapshot();
    }

    requestAnimationFrame(async () => {
      await updateStylesInSequence();
      done();
    });
  });

  // Test 7: Attribute style changes vs CSS variables
  it('handles attribute style changes vs CSS variables', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --link-color: blue;
          --link-decoration: underline;
        }
        .styled-link {
          color: var(--link-color);
          text-decoration: var(--link-decoration);
          padding: 5px;
        }
      `)
    );

    const link = document.createElement('a');
    link.className = 'styled-link';
    link.href = '#';
    link.textContent = 'Styled link';
    document.body.appendChild(link);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Change attribute style
      link.setAttribute('style', 'color: red; font-weight: bold;');
      
      await wait(20);
      await snapshot();
      
      // Update CSS variable
      document.documentElement.style.setProperty('--link-color', 'green');
      document.documentElement.style.setProperty('--link-decoration', 'none');
      
      await wait(20);
      await snapshot();
      
      // Remove attribute style
      link.removeAttribute('style');
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 8: Style changes during animations vs CSS variables
  it('handles style changes during animations vs CSS variables', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --animated-color: red;
          --animated-size: 100px;
        }
        .animated {
          background-color: var(--animated-color);
          width: var(--animated-size);
          height: var(--animated-size);
          transition: all 0.1s ease-in-out;
        }
        @keyframes pulse {
          0% { transform: scale(1); }
          50% { transform: scale(1.1); }
          100% { transform: scale(1); }
        }
        .pulsing {
          animation: pulse 0.5s infinite;
        }
      `)
    );

    const element = document.createElement('div');
    element.className = 'animated';
    document.body.appendChild(element);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Start animation
      element.classList.add('pulsing');
      
      await wait(50);
      await snapshot();
      
      // Update CSS variable during animation
      document.documentElement.style.setProperty('--animated-color', 'blue');
      
      await wait(50);
      await snapshot();
      
      // Apply direct style during animation
      element.style.backgroundColor = 'green';
      
      await wait(50);
      await snapshot();
      
      // Remove animation
      element.classList.remove('pulsing');
      
      await wait(50);
      await snapshot();
      
      done();
    });
  });

  // Test 9: Style specificity hierarchy with CSS variables
  it('respects style specificity hierarchy with CSS variables', async (done) => {
    document.head.appendChild(
      createStyle(`
        /* Less specific */
        div {
          --div-color: red;
        }
        
        /* More specific */
        .specific-class {
          --div-color: blue;
        }
        
        /* Even more specific */
        #specific-id {
          --div-color: green;
        }
        
        /* Most specific */
        #specific-id.specific-class {
          --div-color: purple;
        }
        
        .test-element {
          color: var(--div-color);
          padding: 10px;
        }
      `)
    );

    const element = document.createElement('div');
    element.className = 'test-element';
    element.textContent = 'Element with tag specificity';
    document.body.appendChild(element);
    
    const classElement = document.createElement('div');
    classElement.className = 'test-element specific-class';
    classElement.textContent = 'Element with class specificity';
    document.body.appendChild(classElement);
    
    const idElement = document.createElement('div');
    idElement.className = 'test-element';
    idElement.id = 'specific-id';
    idElement.textContent = 'Element with ID specificity';
    document.body.appendChild(idElement);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Change style with direct properties - should override CSS variables
      element.style.color = 'cyan';
      classElement.style.color = 'cyan';
      idElement.style.color = 'cyan';
      
      await wait(20);
      await snapshot();
      
      // Apply !important to CSS variable
      document.styleSheets[0].insertRule(`
        div {
          --div-color: yellow !important;
        }
      `, 0);
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 10: Dynamic addition and removal of style elements affecting variables
  it('handles dynamic addition and removal of style elements affecting variables', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --dynamic-color: red;
        }
        .test-element {
          color: var(--dynamic-color);
          padding: 10px;
        }
      `)
    );

    const element = document.createElement('div');
    element.className = 'test-element';
    element.textContent = 'Element with dynamically changing styles';
    document.body.appendChild(element);

    // Create a style element that we'll add and remove
    const dynamicStyle = createStyle(`
      :root {
        --dynamic-color: blue !important;
      }
    `);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Add the dynamic style
      document.head.appendChild(dynamicStyle);
      
      await wait(20);
      await snapshot();
      
      // Apply direct style
      element.style.color = 'green';
      
      await wait(20);
      await snapshot();
      
      // Remove the dynamic style
      dynamicStyle.remove();
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 11: CSSOM style changes vs CSS variables
  it('handles CSSOM style changes vs CSS variables', async (done) => {
    document.head.appendChild(
      createStyle(`
        .cssom-test {
          --cssom-color: red;
          --cssom-padding: 10px;
        }
        .styled-element {
          color: var(--cssom-color);
          padding: var(--cssom-padding);
          background-color: lightgray;
        }
      `)
    );

    const element = document.createElement('div');
    element.className = 'cssom-test styled-element';
    element.textContent = 'Element with CSSOM-modified styles';
    document.body.appendChild(element);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Modify rules using CSSOM
      const styleSheet = document.styleSheets[0];
      for (let i = 0; i < styleSheet.cssRules.length; i++) {
        const rule = styleSheet.cssRules[i];
        if (rule.selectorText === '.cssom-test') {
          rule.style.setProperty('--cssom-color', 'blue');
          break;
        }
      }
      
      await wait(20);
      await snapshot();
      
      // Apply direct style
      element.style.color = 'green';
      
      await wait(20);
      await snapshot();
      
      // Modify CSSOM again
      for (let i = 0; i < styleSheet.cssRules.length; i++) {
        const rule = styleSheet.cssRules[i];
        if (rule.selectorText === '.styled-element') {
          rule.style.backgroundColor = 'yellow';
          break;
        }
      }
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 12: Interaction between CSS variables and dynamically computed styles
  it('handles interaction between CSS variables and dynamically computed styles', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --computed-font-size: 16px;
          --computed-margin: 10px;
        }
        .parent {
          font-size: var(--computed-font-size);
          margin: var(--computed-margin);
        }
        .child {
          /* em units will be relative to parent's font-size */
          font-size: 1.5em;
          /* percentage units will be relative to parent's width */
          width: 80%;
          padding: 10px;
          background-color: lightblue;
        }
      `)
    );

    const parent = document.createElement('div');
    parent.className = 'parent';
    parent.style.width = '200px';
    
    const child = document.createElement('div');
    child.className = 'child';
    child.textContent = 'Child with computed styles';
    parent.appendChild(child);
    
    document.body.appendChild(parent);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Update CSS variable affecting parent
      document.documentElement.style.setProperty('--computed-font-size', '24px');
      
      await wait(20);
      await snapshot();
      
      // Update parent's direct style
      parent.style.width = '300px';
      
      await wait(20);
      await snapshot();
      
      // Update child's direct style
      child.style.fontSize = '1em';
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });
});
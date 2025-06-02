/*
 * Integration test for CSS variable updates with display:none elements
 * This tests the fix for the issue where CSS variables weren't updating
 * for elements with display:none
 */

xdescribe('CSS Variable Updates with display:none', () => {
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

  // Test 1: Basic variable update for display:none element
  it('updates CSS variables for display:none elements', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --test-color: red;
        }
        .test-element {
          background-color: var(--test-color);
          width: 100px;
          height: 100px;
          border: 1px solid black;
        }
        .hidden {
          display: none;
        }
      `)
    );

    const container = document.createElement('div');

    // Create visible element
    const visibleElement = document.createElement('div');
    visibleElement.className = 'test-element';
    visibleElement.textContent = 'Visible';
    container.appendChild(visibleElement);

    // Create hidden element
    const hiddenElement = document.createElement('div');
    hiddenElement.className = 'test-element hidden';
    hiddenElement.textContent = 'Hidden';
    container.appendChild(hiddenElement);

    document.body.appendChild(container);

    requestAnimationFrame(async () => {
      await snapshot();

      // Update the CSS variable
      document.documentElement.style.setProperty('--test-color', 'blue');

      await wait(20);
      await snapshot();

      // Show the hidden element to verify it has the updated color
      hiddenElement.classList.remove('hidden');

      await wait(20);
      await snapshot();

      // Hide it again and update variable again
      hiddenElement.classList.add('hidden');
      document.documentElement.style.setProperty('--test-color', 'green');

      await wait(20);

      // Show it again to verify second update took effect
      hiddenElement.classList.remove('hidden');

      await wait(20);
      await snapshot();

      done();
    });
  });

  // Test 2: Multiple nested display:none elements
  it('updates nested display:none elements', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --nested-color: red;
          --nested-size: 50px;
        }
        .container {
          border: 1px solid black;
          padding: 10px;
        }
        .parent {
          background-color: var(--nested-color);
          width: var(--nested-size);
          height: var(--nested-size);
          margin: 5px;
          display: none;
        }
        .child {
          background-color: var(--nested-color);
          width: calc(var(--nested-size) / 2);
          height: calc(var(--nested-size) / 2);
        }
        .grandchild {
          background-color: var(--nested-color);
          width: calc(var(--nested-size) / 4);
          height: calc(var(--nested-size) / 4);
        }
        .visible {
          display: block;
        }
      `)
    );

    const container = document.createElement('div');
    container.className = 'container';

    // Create nested hidden structure
    const parent = document.createElement('div');
    parent.className = 'parent';
    parent.textContent = 'Parent';

    const child = document.createElement('div');
    child.className = 'child';
    child.textContent = 'Child';
    parent.appendChild(child);

    const grandchild = document.createElement('div');
    grandchild.className = 'grandchild';
    grandchild.textContent = 'Grandchild';
    child.appendChild(grandchild);

    container.appendChild(parent);
    document.body.appendChild(container);

    requestAnimationFrame(async () => {
      await snapshot();

      // Update variables while elements are hidden
      document.documentElement.style.setProperty('--nested-color', 'blue');
      document.documentElement.style.setProperty('--nested-size', '120px');

      await wait(20);

      // Show the parent element
      parent.classList.add('visible');

      await wait(20);
      await snapshot();

      // Update variables again while visible
      document.documentElement.style.setProperty('--nested-color', 'green');

      await wait(20);
      await snapshot();

      // Hide parent and update once more
      parent.classList.remove('visible');
      document.documentElement.style.setProperty('--nested-color', 'purple');
      document.documentElement.style.setProperty('--nested-size', '150px');

      await wait(20);

      // Show again to verify final state
      parent.classList.add('visible');

      await wait(20);
      await snapshot();

      done();
    });
  });

  // Test 3: Display toggle with variable changes between toggles
  it('handles rapid display toggles with variable changes', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --toggle-color: red;
          --toggle-text: 'Initial';
        }
        .toggle-element {
          background-color: var(--toggle-color);
          width: 100px;
          height: 50px;
          border: 1px solid black;
          margin: 5px;
        }
        .hidden {
          display: none;
        }
      `)
    );

    const element = document.createElement('div');
    element.className = 'toggle-element hidden';
    document.body.appendChild(element);

    let toggleCount = 0;
    const colors = ['blue', 'green', 'purple', 'orange'];
    const texts = ['"Step 1"', '"Step 2"', '"Step 3"', '"Step 4"'];

    async function performToggleCycle() {
      if (toggleCount >= colors.length) {
        done();
        return;
      }

      // Update variables while hidden
      document.documentElement.style.setProperty('--toggle-color', colors[toggleCount]);

      await wait(10);

      // Show element
      element.classList.remove('hidden');

      await wait(20);
      await snapshot();

      // Hide element
      element.classList.add('hidden');

      await wait(10);

      toggleCount++;
      performToggleCycle();
    }

    requestAnimationFrame(async () => {
      await snapshot(); // Initial hidden state
      performToggleCycle();
    });
  });

  // Test 4: CSS variable inheritance with display:none
  it('preserves CSS variable inheritance for display:none elements', async (done) => {
    document.head.appendChild(
      createStyle(`
        .root-scope {
          --inherited-color: red;
          --inherited-size: 100px;
        }
        .middle-scope {
          --inherited-color: blue; /* Override parent */
          display: none;
        }
        .leaf-element {
          background-color: var(--inherited-color);
          width: var(--inherited-size);
          height: var(--inherited-size);
          border: 1px solid black;
        }
        .show {
          display: block;
        }
      `)
    );

    const rootScope = document.createElement('div');
    rootScope.className = 'root-scope';

    const middleScope = document.createElement('div');
    middleScope.className = 'middle-scope';
    rootScope.appendChild(middleScope);

    const leafElement = document.createElement('div');
    leafElement.className = 'leaf-element';
    leafElement.textContent = 'Leaf';
    middleScope.appendChild(leafElement);

    document.body.appendChild(rootScope);

    requestAnimationFrame(async () => {
      await snapshot();

      // Update root variable while middle is hidden
      rootScope.style.setProperty('--inherited-size', '150px');

      await wait(20);

      // Show middle scope
      middleScope.classList.add('show');

      await wait(20);
      await snapshot(); // Should show blue color (middle override) and 150px size (root)

      // Update middle scope variable
      middleScope.style.setProperty('--inherited-color', 'green');

      await wait(20);
      await snapshot();

      // Hide middle and update root again
      middleScope.classList.remove('show');
      rootScope.style.setProperty('--inherited-color', 'purple');
      rootScope.style.setProperty('--inherited-size', '200px');

      await wait(20);

      // Show again - should still show green (middle wins) and 200px (root)
      middleScope.classList.add('show');

      await wait(20);
      await snapshot();

      done();
    });
  });

  // Test 5: Media query triggered variable changes with display:none
  it('handles media query variable changes for display:none elements', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --media-color: red;
        }
        @media screen and (min-width: 1px) {
          :root {
            --media-color: blue;
          }
        }
        .media-element {
          background-color: var(--media-color);
          width: 100px;
          height: 100px;
          border: 1px solid black;
          display: none;
        }
        .visible {
          display: block;
        }
      `)
    );

    const element = document.createElement('div');
    element.className = 'media-element';
    element.textContent = 'Media test';
    document.body.appendChild(element);

    requestAnimationFrame(async () => {
      await snapshot();

      // Show element - should have blue color from media query
      element.classList.add('visible');

      await wait(20);
      await snapshot();

      // Hide and update variable directly
      element.classList.remove('visible');
      document.documentElement.style.setProperty('--media-color', 'green');

      await wait(20);

      // Show again - should have green color
      element.classList.add('visible');

      await wait(20);
      await snapshot();

      done();
    });
  });

  // Test 6: Complex selectors with display:none
  it('handles complex selectors affecting display:none elements', async (done) => {
    document.head.appendChild(
      createStyle(`
        .complex-container {
          --container-color: red;
        }
        .complex-container .nested {
          --nested-color: var(--container-color);
        }
        .complex-container .nested:nth-child(2n) {
          --nested-color: blue;
        }
        .complex-container.modified .nested {
          --nested-color: green;
        }
        .test-item {
          background-color: var(--nested-color);
          width: 50px;
          height: 50px;
          margin: 5px;
          border: 1px solid black;
          display: none;
        }
        .show {
          display: block;
        }
      `)
    );

    const container = document.createElement('div');
    container.className = 'complex-container';

    for (let i = 0; i < 4; i++) {
      const nested = document.createElement('div');
      nested.className = 'nested';

      const item = document.createElement('div');
      item.className = 'test-item';
      item.textContent = `Item ${i + 1}`;
      nested.appendChild(item);

      container.appendChild(nested);
    }

    document.body.appendChild(container);

    requestAnimationFrame(async () => {
      await snapshot();

      // Show all items
      const items = container.querySelectorAll('.test-item');
      items.forEach(item => item.classList.add('show'));

      await wait(20);
      await snapshot(); // Should show red for odd, blue for even

      // Hide all and modify container class
      items.forEach(item => item.classList.remove('show'));
      container.classList.add('modified');

      await wait(20);

      // Show again - should all be green due to modified class
      items.forEach(item => item.classList.add('show'));

      await wait(20);
      await snapshot();

      done();
    });
  });

  // Test 7: Variable updates during transitions with display:none
  xit('handles variable updates during transitions with display changes', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --transition-color: red;
          --transition-size: 50px;
        }
        .transition-element {
          background-color: var(--transition-color);
          width: var(--transition-size);
          height: var(--transition-size);
          transition: all 0.1s ease-in-out;
          border: 1px solid black;
          margin: 10px;
          display: none;
        }
        .visible {
          display: block;
        }
      `)
    );

    const element = document.createElement('div');
    element.className = 'transition-element';
    element.textContent = 'Transition';
    document.body.appendChild(element);

    requestAnimationFrame(async () => {
      await snapshot();

      // Show element
      element.classList.add('visible');

      await wait(20);
      await snapshot();

      // Update variables to trigger transition
      document.documentElement.style.setProperty('--transition-color', 'blue');
      document.documentElement.style.setProperty('--transition-size', '100px');

      await wait(50); // Wait for transition
      await snapshot();

      // Hide during another variable change
      element.classList.remove('visible');
      document.documentElement.style.setProperty('--transition-color', 'green');
      document.documentElement.style.setProperty('--transition-size', '150px');

      await wait(50);

      // Show again to see final state
      element.classList.add('visible');

      await wait(50);
      await snapshot();

      done();
    });
  });
});

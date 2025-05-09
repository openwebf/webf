/*
 * Integration test for CSS variable dependencies and complex inheritance
 */
describe('CSS Variable Inheritance and Dependencies', () => {
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

  // Test 1: Basic inheritance through DOM tree
  it('correctly inherits variables through the DOM tree', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --root-color: red;
        }
        body {
          --body-color: blue;
        }
        .parent {
          --parent-color: green;
        }
        .child {
          color: var(--root-color);
          background-color: var(--body-color);
          border: 2px solid var(--parent-color);
          padding: 10px;
          margin: 5px;
        }
        .grandchild {
          color: var(--parent-color);
          padding: 5px;
        }
      `)
    );

    const parent = document.createElement('div');
    parent.className = 'parent';
    
    const child = document.createElement('div');
    child.className = 'child';
    child.textContent = 'Child element';
    parent.appendChild(child);
    
    const grandchild = document.createElement('div');
    grandchild.className = 'grandchild';
    grandchild.textContent = 'Grandchild element';
    child.appendChild(grandchild);
    
    document.body.appendChild(parent);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Update variables at different levels
      document.documentElement.style.setProperty('--root-color', 'purple');
      
      await wait(20);
      await snapshot();
      
      document.body.style.setProperty('--body-color', 'yellow');
      
      await wait(20);
      await snapshot();
      
      parent.style.setProperty('--parent-color', 'black');
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 2: Inheritance with nested variable references
  xit('resolves nested variable references through inheritance', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --primary: red;
          --accent: blue;
          --theme-bg: var(--primary);
        }
        .container {
          --theme-bg: var(--accent);
        }
        .item {
          background-color: var(--theme-bg);
          padding: 10px;
          margin: 5px;
          width: 100px;
          height: 50px;
        }
      `)
    );

    const outsideItem = document.createElement('div');
    outsideItem.className = 'item';
    outsideItem.textContent = 'Outside (red)';
    document.body.appendChild(outsideItem);
    
    const container = document.createElement('div');
    container.className = 'container';
    
    const insideItem = document.createElement('div');
    insideItem.className = 'item';
    insideItem.textContent = 'Inside (blue)';
    container.appendChild(insideItem);
    
    document.body.appendChild(container);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Change root variables
      document.documentElement.style.setProperty('--primary', 'green');
      document.documentElement.style.setProperty('--accent', 'purple');
      
      await wait(20);
      await snapshot();
      
      // Change container's variable reference
      container.style.setProperty('--theme-bg', 'var(--primary)');
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 3: Complex inheritance chain with multiple levels
  xit('handles complex inheritance chains with multiple levels', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --level-0: black;
        }
        .level-1 {
          --level-1: var(--level-0);
        }
        .level-2 {
          --level-2: var(--level-1);
        }
        .level-3 {
          --level-3: var(--level-2);
        }
        .level-4 {
          --level-4: var(--level-3);
        }
        .level-5 {
          color: var(--level-4);
          padding: 10px;
          background-color: #f0f0f0;
        }
      `)
    );

    // Create a deeply nested structure
    const l1 = document.createElement('div');
    l1.className = 'level-1';
    
    const l2 = document.createElement('div');
    l2.className = 'level-2';
    l1.appendChild(l2);
    
    const l3 = document.createElement('div');
    l3.className = 'level-3';
    l2.appendChild(l3);
    
    const l4 = document.createElement('div');
    l4.className = 'level-4';
    l3.appendChild(l4);
    
    const l5 = document.createElement('div');
    l5.className = 'level-5';
    l5.textContent = 'Deep inheritance test';
    l4.appendChild(l5);
    
    document.body.appendChild(l1);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Update the base variable and see it propagate
      document.documentElement.style.setProperty('--level-0', 'red');
      
      await wait(30);
      await snapshot();
      
      // Update a middle level
      l2.style.setProperty('--level-2', 'blue');
      
      await wait(30);
      await snapshot();
      
      // Update the lowest level
      l4.style.setProperty('--level-4', 'green');
      
      await wait(30);
      await snapshot();
      
      done();
    });
  });

  // Test 4: Inheritance through different combinators
  it('handles inheritance through different CSS combinators', async (done) => {
    document.head.appendChild(
      createStyle(`
        .parent {
          --parent-var: red;
        }
        
        /* Child combinator */
        .parent > .direct-child {
          --direct-child-var: blue;
          color: var(--parent-var);
        }
        
        /* Descendant combinator */
        .parent .descendant {
          --descendant-var: green;
          border: 1px solid var(--parent-var);
        }
        
        /* Adjacent sibling combinator */
        .reference + .adjacent {
          --adjacent-var: purple;
          color: var(--reference-var, black);
        }
        
        /* General sibling combinator */
        .reference ~ .sibling {
          --sibling-var: orange;
          background-color: var(--adjacent-var);
        }
      `)
    );

    const parent = document.createElement('div');
    parent.className = 'parent';
    
    const directChild = document.createElement('div');
    directChild.className = 'direct-child';
    directChild.textContent = 'Direct child';
    parent.appendChild(directChild);
    
    const wrapper = document.createElement('div');
    wrapper.className = 'wrapper';
    
    const descendant = document.createElement('div');
    descendant.className = 'descendant';
    descendant.textContent = 'Descendant';
    descendant.style.padding = '10px';
    wrapper.appendChild(descendant);
    parent.appendChild(wrapper);
    
    const reference = document.createElement('div');
    reference.className = 'reference';
    reference.textContent = 'Reference element';
    reference.style.setProperty('--reference-var', 'cyan');
    document.body.appendChild(reference);
    
    const adjacent = document.createElement('div');
    adjacent.className = 'adjacent';
    adjacent.textContent = 'Adjacent sibling';
    adjacent.style.padding = '10px';
    document.body.appendChild(adjacent);
    
    const sibling = document.createElement('div');
    sibling.className = 'sibling';
    sibling.textContent = 'General sibling';
    sibling.style.padding = '10px';
    document.body.appendChild(sibling);
    
    document.body.appendChild(parent);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Update variables through the structure
      parent.style.setProperty('--parent-var', 'yellow');
      
      await wait(20);
      await snapshot();
      
      directChild.style.setProperty('--direct-child-var', 'lightblue');
      
      await wait(20);
      await snapshot();
      
      adjacent.style.setProperty('--adjacent-var', 'lightgreen');
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 5: Inheritance with pseudo-elements and pseudo-classes
  it('handles inheritance with pseudo-elements and pseudo-classes', async (done) => {
    document.head.appendChild(
      createStyle(`
        .pseudo-parent {
          --parent-color: blue;
        }
        
        .pseudo-parent:hover {
          --hover-color: red;
        }
        
        .pseudo-element {
          color: var(--parent-color);
          padding: 10px;
          position: relative;
        }
        
        .pseudo-element::before {
          content: "Before ";
          color: var(--before-color, green);
        }
        
        .pseudo-element::after {
          content: " After";
          color: var(--after-color, purple);
        }
      `)
    );

    const parent = document.createElement('div');
    parent.className = 'pseudo-parent';
    
    const element = document.createElement('div');
    element.className = 'pseudo-element';
    element.textContent = 'Pseudo test';
    parent.appendChild(element);
    
    document.body.appendChild(parent);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Update parent variable
      parent.style.setProperty('--parent-color', 'orange');
      
      await wait(20);
      await snapshot();
      
      // Set pseudo-element variables
      parent.style.setProperty('--before-color', 'cyan');
      parent.style.setProperty('--after-color', 'magenta');
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 6: Inheritance between sibling trees
  it('handles variable scoping between sibling trees', async (done) => {
    document.head.appendChild(
      createStyle(`
        .tree-a, .tree-b {
          --common-var: gray;
          padding: 10px;
          margin: 5px;
          border: 1px solid black;
        }
        
        .tree-a {
          --tree-a-var: red;
        }
        
        .tree-b {
          --tree-b-var: blue;
        }
        
        .item {
          padding: 5px;
          margin: 5px;
        }
        
        .tree-a .item {
          color: var(--tree-a-var);
          background-color: var(--common-var);
        }
        
        .tree-b .item {
          color: var(--tree-b-var);
          background-color: var(--common-var);
        }
      `)
    );

    // First tree
    const treeA = document.createElement('div');
    treeA.className = 'tree-a';
    treeA.textContent = 'Tree A';
    
    const itemA1 = document.createElement('div');
    itemA1.className = 'item';
    itemA1.textContent = 'Item A1';
    treeA.appendChild(itemA1);
    
    const itemA2 = document.createElement('div');
    itemA2.className = 'item';
    itemA2.textContent = 'Item A2';
    treeA.appendChild(itemA2);
    
    // Second tree
    const treeB = document.createElement('div');
    treeB.className = 'tree-b';
    treeB.textContent = 'Tree B';
    
    const itemB1 = document.createElement('div');
    itemB1.className = 'item';
    itemB1.textContent = 'Item B1';
    treeB.appendChild(itemB1);
    
    const itemB2 = document.createElement('div');
    itemB2.className = 'item';
    itemB2.textContent = 'Item B2';
    treeB.appendChild(itemB2);
    
    document.body.appendChild(treeA);
    document.body.appendChild(treeB);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Update common variable - should affect both trees
      document.documentElement.style.setProperty('--common-var', 'lightgray');
      
      await wait(20);
      await snapshot();
      
      // Update specific tree variables
      treeA.style.setProperty('--tree-a-var', 'green');
      treeB.style.setProperty('--tree-b-var', 'purple');
      
      await wait(20);
      await snapshot();
      
      // Set a common variable on one tree item - should only affect that item
      itemA1.style.setProperty('--common-var', 'yellow');
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 7: Variable overriding through CSS specificity
  xit('handles variable overriding through CSS specificity', async (done) => {
    document.head.appendChild(
      createStyle(`
        /* Least specific */
        div {
          --target-color: gray;
        }
        
        /* More specific */
        .level-class {
          --target-color: blue;
        }
        
        /* Even more specific */
        .container .level-class {
          --target-color: green;
        }
        
        /* Most specific */
        .container .level-class#level-id {
          --target-color: purple;
        }
        
        /* Using the variable */
        .target {
          color: var(--target-color);
          padding: 10px;
          background-color: #f0f0f0;
        }
      `)
    );

    // Create elements with different specificity
    const container = document.createElement('div');
    container.className = 'container';
    
    const normalDiv = document.createElement('div');
    normalDiv.className = 'target';
    normalDiv.textContent = 'Normal div (gray)';
    
    const levelClass = document.createElement('div');
    levelClass.className = 'level-class target';
    levelClass.textContent = 'With class (blue)';
    
    const nestedClass = document.createElement('div');
    nestedClass.className = 'level-class target';
    nestedClass.textContent = 'Nested with class (green)';
    container.appendChild(nestedClass);
    
    const idElement = document.createElement('div');
    idElement.className = 'level-class target';
    idElement.id = 'level-id';
    idElement.textContent = 'Nested with ID (purple)';
    container.appendChild(idElement);
    
    document.body.appendChild(normalDiv);
    document.body.appendChild(levelClass);
    document.body.appendChild(container);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Override at different levels
      document.styleSheets[0].insertRule(`
        /* More specific than any existing rule */
        #level-id {
          --target-color: red !important;
        }
      `, 0);
      
      await wait(20);
      await snapshot();
      
      // Set inline style variables (highest specificity)
      normalDiv.style.setProperty('--target-color', 'cyan');
      levelClass.style.setProperty('--target-color', 'orange');
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 8: Cyclical dependencies
  xit('handles cyclical variable dependencies', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --cycle-a: var(--cycle-b, blue);
          --cycle-b: var(--cycle-c, green);
          --cycle-c: var(--cycle-a, red);
        }
        
        .cycle-test-a {
          color: var(--cycle-a);
          padding: 10px;
        }
        
        .cycle-test-b {
          color: var(--cycle-b);
          padding: 10px;
        }
        
        .cycle-test-c {
          color: var(--cycle-c);
          padding: 10px;
        }
      `)
    );

    const container = document.createElement('div');
    
    const elemA = document.createElement('div');
    elemA.className = 'cycle-test-a';
    elemA.textContent = 'Cycle A';
    container.appendChild(elemA);
    
    const elemB = document.createElement('div');
    elemB.className = 'cycle-test-b';
    elemB.textContent = 'Cycle B';
    container.appendChild(elemB);
    
    const elemC = document.createElement('div');
    elemC.className = 'cycle-test-c';
    elemC.textContent = 'Cycle C';
    container.appendChild(elemC);
    
    document.body.appendChild(container);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Break the cycle by setting a direct value
      document.documentElement.style.setProperty('--cycle-a', 'purple');
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 9: Variable fallbacks with inheritance
  xit('handles variable fallbacks with inheritance', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --fallback-color: gray;
        }
        
        .parent {
          /* No value set, should inherit from root */
        }
        
        .sibling {
          --fallback-color: blue;
        }
        
        .child {
          color: var(--specific-color, var(--fallback-color));
          padding: 10px;
          background-color: #f0f0f0;
        }
      `)
    );

    const parent = document.createElement('div');
    parent.className = 'parent';
    
    const sibling = document.createElement('div');
    sibling.className = 'sibling';
    
    const childInParent = document.createElement('div');
    childInParent.className = 'child';
    childInParent.textContent = 'Child in parent (should use root fallback)';
    parent.appendChild(childInParent);
    
    const childInSibling = document.createElement('div');
    childInSibling.className = 'child';
    childInSibling.textContent = 'Child in sibling (should use sibling fallback)';
    sibling.appendChild(childInSibling);
    
    document.body.appendChild(parent);
    document.body.appendChild(sibling);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Set the specific color on parent
      parent.style.setProperty('--specific-color', 'red');
      
      await wait(20);
      await snapshot();
      
      // Update root fallback
      document.documentElement.style.setProperty('--fallback-color', 'green');
      
      await wait(20);
      await snapshot();
      
      // Remove specific color - should fall back to inheritance
      parent.style.removeProperty('--specific-color');
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 10: Inheritance across shadow DOM boundaries
  xit('handles inheritance across shadow DOM boundaries (when applicable)', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --shadow-text: red;
          --shadow-background: lightgray;
        }
        
        .shadow-host {
          --host-color: blue;
          padding: 20px;
          border: 1px solid black;
        }
      `)
    );

    // Create a shadow host
    const host = document.createElement('div');
    host.className = 'shadow-host';
    host.textContent = 'Shadow DOM Host';
    
    // If Shadow DOM is supported, create shadow elements
    let shadowContent = null;
    if (host.attachShadow) {
      const shadow = host.attachShadow({ mode: 'open' });
      
      const style = document.createElement('style');
      style.textContent = `
        .shadow-content {
          color: var(--shadow-text);
          background-color: var(--shadow-background);
          padding: 10px;
        }
        
        .shadow-child {
          color: var(--host-color);
          padding: 5px;
          margin-top: 10px;
        }
      `;
      shadow.appendChild(style);
      
      shadowContent = document.createElement('div');
      shadowContent.className = 'shadow-content';
      shadowContent.textContent = 'Shadow content';
      
      const shadowChild = document.createElement('div');
      shadowChild.className = 'shadow-child';
      shadowChild.textContent = 'Shadow child';
      shadowContent.appendChild(shadowChild);
      
      shadow.appendChild(shadowContent);
    } else {
      // Fallback for browsers that don't support Shadow DOM
      const fallback = document.createElement('div');
      fallback.textContent = 'Shadow DOM not supported in this environment';
      host.appendChild(fallback);
    }
    
    document.body.appendChild(host);

    requestAnimationFrame(async () => {
      await snapshot();
      
      if (host.shadowRoot) {
        // Update the CSS variables
        document.documentElement.style.setProperty('--shadow-text', 'green');
        host.style.setProperty('--host-color', 'purple');
        
        await wait(20);
        await snapshot();
      }
      
      done();
    });
  });

  // Test 11: Inheritance through dynamically added DOM nodes
  it('handles inheritance through dynamically added DOM nodes', async (done) => {
    document.head.appendChild(
      createStyle(`
        .dynamic-container {
          --container-color: blue;
        }
        
        .dynamic-item {
          color: var(--container-color);
          padding: 10px;
          margin: 5px;
          background-color: #f0f0f0;
        }
      `)
    );

    const container = document.createElement('div');
    container.className = 'dynamic-container';
    document.body.appendChild(container);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Add a new element
      const newItem = document.createElement('div');
      newItem.className = 'dynamic-item';
      newItem.textContent = 'Dynamically added item';
      container.appendChild(newItem);
      
      await wait(20);
      await snapshot();
      
      // Update the container variable
      container.style.setProperty('--container-color', 'red');
      
      await wait(20);
      await snapshot();
      
      // Add another element
      const newerItem = document.createElement('div');
      newerItem.className = 'dynamic-item';
      newerItem.textContent = 'Second dynamic item';
      
      // Override the inherited variable on this specific element
      newerItem.style.setProperty('--container-color', 'green');
      
      container.appendChild(newerItem);
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });

  // Test 12: Inheritance with dynamic class changes
  it('handles inheritance with dynamic class changes', async (done) => {
    document.head.appendChild(
      createStyle(`
        .base {
          --base-color: gray;
        }
        
        .theme-red {
          --theme-color: red;
        }
        
        .theme-blue {
          --theme-color: blue;
        }
        
        .theme-green {
          --theme-color: green;
        }
        
        .target {
          color: var(--theme-color, var(--base-color));
          padding: 10px;
          margin: 5px;
          background-color: #f0f0f0;
        }
      `)
    );

    const container = document.createElement('div');
    container.className = 'base theme-red';
    
    const targetElements = [];
    for (let i = 0; i < 3; i++) {
      const target = document.createElement('div');
      target.className = 'target';
      target.textContent = `Target element ${i+1}`;
      container.appendChild(target);
      targetElements.push(target);
    }
    
    document.body.appendChild(container);

    requestAnimationFrame(async () => {
      await snapshot();
      
      // Change container class
      container.className = 'base theme-blue';
      
      await wait(20);
      await snapshot();
      
      // Set individual target to override theme
      targetElements[1].classList.add('theme-green');
      
      await wait(20);
      await snapshot();
      
      // Change container class again
      container.className = 'base theme-green';
      
      await wait(20);
      await snapshot();
      
      done();
    });
  });
});
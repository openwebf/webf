/*
 * Integration test for CSS variables focusing on edge cases, updates, and interactions
 */
describe('CSS Variable Edge Cases', () => {
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

  // Test 1: Nested variable dependencies
  it('handles deeply nested variable dependencies', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --level1: var(--level2);
          --level2: var(--level3);
          --level3: var(--level4);
          --level4: var(--level5);
          --level5: var(--level6);
          --level6: red;
        }
        .test-element {
          background-color: var(--level1);
          width: 100px;
          height: 100px;
        }
      `)
    );

    const testEl = document.createElement('div');
    testEl.className = 'test-element';
    testEl.textContent = 'Deep nesting test';
    document.body.appendChild(testEl);

    requestAnimationFrame(async () => {
      await snapshot();

      // Now change the deepest variable and verify it propagates
      const root = document.documentElement;
      root.style.setProperty('--level6', 'blue');

      await wait(50);
      await snapshot();
      done();
    });
  });

  // Test 2: Circular dependencies
  it('properly handles circular variable dependencies', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --circle1: var(--circle2);
          --circle2: var(--circle3);
          --circle3: var(--circle1, green);
        }
        .test-element {
          background-color: var(--circle1);
          color: black;
          width: 100px;
          height: 100px;
          padding: 10px;
        }
      `)
    );

    const testEl = document.createElement('div');
    testEl.className = 'test-element';
    testEl.textContent = 'Circular test';
    document.body.appendChild(testEl);

    requestAnimationFrame(async () => {
      await snapshot();
      done();
    });
  });

  // Test 3: Multiple updates in sequence
  xit('handles multiple variable updates in sequence', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --dynamic-color: red;
        }
        .test-element {
          background-color: var(--dynamic-color);
          width: 100px;
          height: 100px;
          transition: background-color 0.1s; /* Small transition to verify updates */
        }
      `)
    );

    const testEl = document.createElement('div');
    testEl.className = 'test-element';
    testEl.textContent = 'Update test';
    document.body.appendChild(testEl);

    requestAnimationFrame(async () => {
      await snapshot();

      const root = document.documentElement;

      // First update
      root.style.setProperty('--dynamic-color', 'blue');
      await wait(50);
      await snapshot();

      // Second update
      root.style.setProperty('--dynamic-color', 'green');
      await wait(50);
      await snapshot();

      // Third update
      root.style.setProperty('--dynamic-color', 'purple');
      await wait(50);
      await snapshot();

      done();
    });
  });

  // Test 4: Interaction between direct styles and CSS variables
  it('handles interaction between direct styles and CSS variables', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --text-color: red;
          --bg-color: lightgray;
        }
        .test-element {
          color: var(--text-color);
          background-color: var(--bg-color);
          padding: 10px;
          margin: 10px;
        }
      `)
    );

    const testEl = document.createElement('div');
    testEl.className = 'test-element';
    testEl.textContent = 'Style interaction test';
    document.body.appendChild(testEl);

    requestAnimationFrame(async () => {
      await snapshot();

      // Apply direct style
      testEl.style.color = 'blue';
      await wait(20);
      await snapshot();

      // Update CSS variable
      document.documentElement.style.setProperty('--text-color', 'green');
      await wait(20);
      await snapshot();

      // Update direct style again
      testEl.style.color = 'purple';
      await wait(20);
      await snapshot();

      // Remove direct style
      testEl.style.color = '';
      await wait(20);
      await snapshot();

      done();
    });
  });

  // Test 5: CSS Variables and computed styles
  xit('correctly computes styles with CSS variables', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --size-base: 10px;
          --size-medium: calc(var(--size-base) * 2);
          --size-large: calc(var(--size-medium) * 2);
          --font-weight: 700;
        }
        .test-element {
          padding: var(--size-medium);
          margin: var(--size-base);
          font-size: var(--size-large);
          font-weight: var(--font-weight);
        }
      `)
    );

    const testEl = document.createElement('div');
    testEl.className = 'test-element';
    testEl.textContent = 'Computed style test';
    document.body.appendChild(testEl);

    requestAnimationFrame(async () => {
      await snapshot();

      // Update base size and watch it propagate to all calculated values
      document.documentElement.style.setProperty('--size-base', '20px');
      await wait(50);
      await snapshot();

      done();
    });
  });

  // Test 6: Variable values with complex content
  it('handles variable values with complex content', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --complex-shadow: 0 10px 15px rgba(0, 0, 0, 0.3), 0 5px 10px rgba(0, 0, 0, 0.2);
          --complex-transform: rotate(45deg) scale(1.2);
          --complex-gradient: linear-gradient(45deg, red, blue);
        }
        .shadow-test {
          width: 100px;
          height: 100px;
          background: white;
          box-shadow: var(--complex-shadow);
        }
        .transform-test {
          width: 100px;
          height: 100px;
          background: lightblue;
          transform: var(--complex-transform);
          margin: 50px;
        }
        .gradient-test {
          width: 100px;
          height: 100px;
          background: var(--complex-gradient);
          margin-top: 50px;
        }
      `)
    );

    const container = document.createElement('div');

    const shadowEl = document.createElement('div');
    shadowEl.className = 'shadow-test';
    container.appendChild(shadowEl);

    const transformEl = document.createElement('div');
    transformEl.className = 'transform-test';
    transformEl.textContent = 'Transform';
    container.appendChild(transformEl);

    const gradientEl = document.createElement('div');
    gradientEl.className = 'gradient-test';
    container.appendChild(gradientEl);

    document.body.appendChild(container);

    requestAnimationFrame(async () => {
      await snapshot();

      // Update complex values
      document.documentElement.style.setProperty('--complex-shadow', '0 5px 25px rgba(0, 0, 255, 0.5)');
      document.documentElement.style.setProperty('--complex-transform', 'rotate(-45deg) scale(0.8)');
      document.documentElement.style.setProperty('--complex-gradient', 'linear-gradient(to right, green, yellow)');

      await wait(50);
      await snapshot();

      done();
    });
  });

  // Test 7: Variable fallback values
  it('correctly uses fallback values in CSS variables', async (done) => {
    document.head.appendChild(
      createStyle(`
        .test-element {
          --undefined-var: initial;
          color: var(--non-existent-var, blue);
          background-color: var(--another-missing-var, var(--also-missing, yellow));
          padding: var(--undefined-var, 20px);
          border: 1px solid var(--border-color, green);
          width: 100px;
          height: 100px;
        }
      `)
    );

    const testEl = document.createElement('div');
    testEl.className = 'test-element';
    testEl.textContent = 'Fallback test';
    document.body.appendChild(testEl);

    requestAnimationFrame(async () => {
      await snapshot();

      // Define one of the variables and see fallback not used
      testEl.style.setProperty('--non-existent-var', 'red');
      await wait(30);
      await snapshot();

      done();
    });
  });

  // Test 8: Variable in media queries
  it('supports CSS variables in media queries', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --breakpoint: 900px;
          --small-color: blue;
          --large-color: red;
        }

        .test-element {
          width: 100px;
          height: 100px;
          background-color: var(--small-color);
        }

        @media (min-width: 0px) {
          .test-element {
            background-color: var(--large-color);
          }
        }
      `)
    );

    const testEl = document.createElement('div');
    testEl.className = 'test-element';
    testEl.textContent = 'Media query test';
    document.body.appendChild(testEl);

    requestAnimationFrame(async () => {
      await snapshot();

      // Change the variables
      document.documentElement.style.setProperty('--small-color', 'green');
      document.documentElement.style.setProperty('--large-color', 'purple');

      await wait(30);
      await snapshot();

      done();
    });
  });

  // Test 9: Updating variables in rapid succession
  it('handles rapid updates to CSS variables', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --rapid-color: red;
        }
        .test-element {
          background-color: var(--rapid-color);
          width: 100px;
          height: 100px;
        }
      `)
    );

    const testEl = document.createElement('div');
    testEl.className = 'test-element';
    testEl.textContent = 'Rapid update';
    document.body.appendChild(testEl);

    requestAnimationFrame(async () => {
      await snapshot();

      const root = document.documentElement;

      // Perform rapid updates
      root.style.setProperty('--rapid-color', 'blue');
      root.style.setProperty('--rapid-color', 'green');
      root.style.setProperty('--rapid-color', 'yellow');
      root.style.setProperty('--rapid-color', 'purple');
      root.style.setProperty('--rapid-color', 'orange');

      await wait(20);
      await snapshot();

      done();
    });
  });

  // Test 10: Variable interpolation/substitution
  it('handles variable substitution in complex values', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --r: 255;
          --g: 0;
          --b: 0;
          --size: 20px;
          --radius: 10px;
        }
        .test-element {
          background-color: rgb(var(--r), var(--g), var(--b));
          padding: var(--size);
          border-radius: var(--radius);
          width: 100px;
          height: 100px;
          display: flex;
          align-items: center;
          justify-content: center;
        }
      `)
    );

    const testEl = document.createElement('div');
    testEl.className = 'test-element';
    testEl.textContent = 'RGB test';
    document.body.appendChild(testEl);

    requestAnimationFrame(async () => {
      await snapshot();

      // // Update the variables one by one
      document.documentElement.style.setProperty('--r', '0');
      document.documentElement.style.setProperty('--g', '255');
      await wait(20);
      await snapshot();

      // // Update multiple variables at once
      document.documentElement.style.setProperty('--g', '0');
      document.documentElement.style.setProperty('--b', '255');
      document.documentElement.style.setProperty('--size', '30px');
      await wait(20);
      await snapshot();

      done();
    });
  });

  // Test 11: Variable dependencies across different elements
  xit('handles variable dependencies across different elements', async (done) => {
    document.head.appendChild(
      createStyle(`
        .parent {
          --parent-color: blue;
        }
        .child {
          --child-color: var(--parent-color);
          background-color: var(--child-color);
          width: 100px;
          height: 100px;
        }
        .sibling {
          --sibling-color: var(--child-color);
          background-color: var(--sibling-color);
          width: 100px;
          height: 100px;
          margin-top: 10px;
        }
      `)
    );

    const parentEl = document.createElement('div');
    parentEl.className = 'parent';

    const childEl = document.createElement('div');
    childEl.className = 'child';
    childEl.textContent = 'Child';
    parentEl.appendChild(childEl);

    const siblingEl = document.createElement('div');
    siblingEl.className = 'sibling';
    siblingEl.textContent = 'Sibling';
    parentEl.appendChild(siblingEl);

    document.body.appendChild(parentEl);

    requestAnimationFrame(async () => {
      await snapshot();

      // Update parent and see it propagate
      parentEl.style.setProperty('--parent-color', 'red');
      await wait(20);
      await snapshot();

      // Update child and see it affect sibling
      childEl.style.setProperty('--child-color', 'green');
      await wait(20);
      await snapshot();

      done();
    });
  });

  // Test 12: Behavior with malformed variable values
  it('handles malformed variable values gracefully', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --invalid-color: rgb(300, 0, 0); /* Invalid RGB value */
          --malformed-url: url(missing'quote);
          --incomplete-calc: calc(10px + );
        }
        .color-test {
          color: var(--invalid-color, black);
          background-color: lightgray;
          padding: 10px;
        }
        .url-test {
          background-image: var(--malformed-url, none);
          width: 100px;
          height: 50px;
        }
        .calc-test {
          width: var(--incomplete-calc, 100px);
          height: 50px;
          background-color: lightblue;
        }
      `)
    );

    const container = document.createElement('div');

    const colorEl = document.createElement('div');
    colorEl.className = 'color-test';
    colorEl.textContent = 'Invalid color';
    container.appendChild(colorEl);

    const urlEl = document.createElement('div');
    urlEl.className = 'url-test';
    container.appendChild(urlEl);

    const calcEl = document.createElement('div');
    calcEl.className = 'calc-test';
    calcEl.textContent = 'Invalid calc';
    container.appendChild(calcEl);

    document.body.appendChild(container);

    requestAnimationFrame(async () => {
      await snapshot();

      // Test with valid values replacing invalid ones
      document.documentElement.style.setProperty('--invalid-color', 'rgb(255, 0, 0)');
      document.documentElement.style.setProperty('--malformed-url', 'url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUg")');
      document.documentElement.style.setProperty('--incomplete-calc', 'calc(10px + 20px)');

      await wait(20);
      await snapshot();

      done();
    });
  });

  // Test 13: Variable updates with conflicting direct styles
  it('handles variable updates with conflicting direct styles', async (done) => {
    document.head.appendChild(
      createStyle(`
        :root {
          --text-color: blue;
          --bg-color: lightgray;
        }
        .test-element {
          color: var(--text-color);
          background-color: var(--bg-color);
          width: 150px;
          padding: 10px;
        }
      `)
    );

    const testEl = document.createElement('div');
    testEl.className = 'test-element';
    testEl.textContent = 'Conflict test';
    document.body.appendChild(testEl);

    requestAnimationFrame(async () => {
      await snapshot();

      // Set direct style
      testEl.style.color = 'red';

      await wait(20);
      await snapshot();

      // Update CSS variable - direct style should win
      document.documentElement.style.setProperty('--text-color', 'green');

      await wait(20);
      await snapshot();

      // Remove direct style - CSS variable should apply again
      testEl.style.color = '';

      await wait(20);
      await snapshot();

      done();
    });
  });
});

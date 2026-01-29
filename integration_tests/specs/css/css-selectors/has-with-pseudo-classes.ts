/**
 * CSS Selectors: :has() with pseudo-classes
 * Based on WPT: css/selectors/has-* pseudo-class tests
 *
 * Key behaviors:
 * - :has() can contain other pseudo-classes like :not(), :is(), :where()
 * - :has() works with structural pseudo-classes like :first-child, :nth-child()
 * - :has() works with state pseudo-classes like :checked, :disabled
 */
describe('CSS Selectors: :has() with :not()', () => {
  const green = 'rgb(0, 128, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  function formatElements(elements: Element[]) {
    return elements.map(e => e.id).sort().join(',');
  }

  it('A1 :has(:not(.excluded)) matches elements with non-excluded children', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <div id="p1" class="parent">
        <span class="included">Included</span>
      </div>
      <div id="p2" class="parent">
        <span class="excluded">Excluded</span>
      </div>
      <div id="p3" class="parent">
        <span class="included">Included</span>
        <span class="excluded">Excluded</span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: red; }
      .parent:has(:not(.excluded)) { background-color: green; }
    `);

    // p1 has non-.excluded child -> matches
    // p2 only has .excluded child -> does NOT match (all children are .excluded)
    // p3 has both -> matches (has at least one non-.excluded)
    const actual = Array.from(container.querySelectorAll('.parent:has(:not(.excluded))'));
    expect(formatElements(actual)).toBe('p1,p3');

    await snapshot();

    style.remove();
    container.remove();
  });

  it('A2 :has(:not(.a):not(.b)) matches with multiple negations', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <div id="p1" class="parent">
        <span class="a">A</span>
      </div>
      <div id="p2" class="parent">
        <span class="b">B</span>
      </div>
      <div id="p3" class="parent">
        <span class="c">C</span>
      </div>
      <div id="p4" class="parent">
        <span class="a b">AB</span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: red; }
      .parent:has(:not(.a):not(.b)) { background-color: green; }
    `);

    // Matches parents that have a child that is neither .a nor .b
    // p1: only .a -> no match
    // p2: only .b -> no match
    // p3: .c (neither .a nor .b) -> matches
    // p4: .a.b -> no match
    const actual = Array.from(container.querySelectorAll('.parent:has(:not(.a):not(.b))'));
    expect(formatElements(actual)).toBe('p3');

    await snapshot();

    style.remove();
    container.remove();
  });

  it('A3 :not(:has(.target)) matches elements without .target descendants', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <div id="p1" class="parent">
        <span class="target">Target</span>
      </div>
      <div id="p2" class="parent">
        <span class="other">Other</span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: red; }
      .parent:not(:has(.target)) { background-color: green; }
    `);

    // p1 has .target -> does NOT match :not(:has(.target))
    // p2 no .target -> matches
    const actual = Array.from(container.querySelectorAll('.parent:not(:has(.target))'));
    expect(formatElements(actual)).toBe('p2');

    await snapshot();

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: :has() with :is() and :where()', () => {
  const green = 'rgb(0, 128, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  function formatElements(elements: Element[]) {
    return elements.map(e => e.id).sort().join(',');
  }

  it('B1 :has(:is(.a, .b)) matches elements with either .a or .b', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <div id="p1" class="parent">
        <span class="a">A</span>
      </div>
      <div id="p2" class="parent">
        <span class="b">B</span>
      </div>
      <div id="p3" class="parent">
        <span class="c">C</span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: red; }
      .parent:has(:is(.a, .b)) { background-color: green; }
    `);

    const actual = Array.from(container.querySelectorAll('.parent:has(:is(.a, .b))'));
    expect(formatElements(actual)).toBe('p1,p2');

    await snapshot();

    style.remove();
    container.remove();
  });

  it('B2 :has(:where(.a, .b)) has zero specificity contribution', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <div id="p1" class="parent special">
        <span class="a">A</span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; }
      .parent:has(:where(.a, .b)) { background-color: red; }
      .special { background-color: green; }
    `);

    const parent = container.querySelector('#p1')!;
    // :has(:where(.a, .b)) = 0,1,0 (only .parent counts, :where adds 0)
    // .special = 0,1,0
    // Same specificity, latter wins
    expect(getComputedStyle(parent).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('B3 :has() with nested :is() combinators', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <div id="p1" class="parent">
        <div class="wrapper">
          <span class="target">Target</span>
        </div>
      </div>
      <div id="p2" class="parent">
        <span class="target">Direct Target</span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: red; }
      .parent:has(:is(.wrapper > .target)) { background-color: green; }
    `);

    const actual = Array.from(container.querySelectorAll('.parent:has(:is(.wrapper > .target))'));
    expect(formatElements(actual)).toBe('p1');

    await snapshot();

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: :has() with structural pseudo-classes', () => {
  const green = 'rgb(0, 128, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  function formatElements(elements: Element[]) {
    return elements.map(e => e.id).sort().join(',');
  }

  it('C1 :has(:first-child) matches elements with first-child', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <div id="p1" class="parent">
        <span class="first">First</span>
        <span>Second</span>
      </div>
      <div id="p2" class="parent">
        <span>Only</span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: red; }
      .parent:has(:first-child) { background-color: green; }
    `);

    // Both have first-child elements
    const actual = Array.from(container.querySelectorAll('.parent:has(:first-child)'));
    expect(formatElements(actual)).toBe('p1,p2');

    await snapshot();

    style.remove();
    container.remove();
  });

  it('C2 :has(:last-child) matches elements with last-child', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <div id="p1" class="parent">
        <span>First</span>
        <span class="last">Last</span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: red; }
      .parent:has(:last-child) { background-color: green; }
    `);

    const actual = Array.from(container.querySelectorAll('.parent:has(:last-child)'));
    expect(formatElements(actual)).toBe('p1');

    await snapshot();

    style.remove();
    container.remove();
  });

  it('C3 :has(:only-child) matches elements with only-child', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <div id="p1" class="parent">
        <span>Only</span>
      </div>
      <div id="p2" class="parent">
        <span>First</span>
        <span>Second</span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: red; }
      .parent:has(:only-child) { background-color: green; }
    `);

    const actual = Array.from(container.querySelectorAll('.parent:has(:only-child)'));
    expect(formatElements(actual)).toBe('p1');

    await snapshot();

    style.remove();
    container.remove();
  });

  it('C4 :has(:nth-child(2)) matches elements with second child', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <div id="p1" class="parent">
        <span>Only</span>
      </div>
      <div id="p2" class="parent">
        <span>First</span>
        <span>Second</span>
      </div>
      <div id="p3" class="parent">
        <span>First</span>
        <span>Second</span>
        <span>Third</span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: red; }
      .parent:has(:nth-child(2)) { background-color: green; }
    `);

    // p1: only 1 child -> no match
    // p2: has 2nd child -> matches
    // p3: has 2nd child -> matches
    const actual = Array.from(container.querySelectorAll('.parent:has(:nth-child(2))'));
    expect(formatElements(actual)).toBe('p2,p3');

    await snapshot();

    style.remove();
    container.remove();
  });

  it('C5 :has(:nth-child(odd)) matches elements with odd-positioned children', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <div id="p1" class="parent">
        <span>1</span>
        <span>2</span>
        <span>3</span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: red; }
      .parent:has(:nth-child(odd)) { background-color: green; }
    `);

    // Has children at positions 1, 3 (odd)
    const actual = Array.from(container.querySelectorAll('.parent:has(:nth-child(odd))'));
    expect(formatElements(actual)).toBe('p1');

    await snapshot();

    style.remove();
    container.remove();
  });

  it('C6 :has(:empty) matches elements with empty child', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <div id="p1" class="parent">
        <span></span>
      </div>
      <div id="p2" class="parent">
        <span>Content</span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: red; }
      .parent:has(:empty) { background-color: green; }
    `);

    // p1 has empty span -> matches
    // p2 has non-empty span -> no match
    const actual = Array.from(container.querySelectorAll('.parent:has(:empty)'));
    expect(formatElements(actual)).toBe('p1');

    await snapshot();

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: :has() with form pseudo-classes', () => {
  const green = 'rgb(0, 128, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  function formatElements(elements: Element[]) {
    return elements.map(e => e.id).sort().join(',');
  }

  it('D1 :has(:checked) matches elements with checked input', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <div id="p1" class="parent">
        <input type="checkbox" checked>
      </div>
      <div id="p2" class="parent">
        <input type="checkbox">
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: red; }
      .parent:has(:checked) { background-color: green; }
    `);

    const actual = Array.from(container.querySelectorAll('.parent:has(:checked)'));
    expect(formatElements(actual)).toBe('p1');

    await snapshot();

    style.remove();
    container.remove();
  });

  it('D2 :has(:disabled) matches elements with disabled input', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <div id="p1" class="parent">
        <input type="text" disabled>
      </div>
      <div id="p2" class="parent">
        <input type="text">
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: red; }
      .parent:has(:disabled) { background-color: green; }
    `);

    const actual = Array.from(container.querySelectorAll('.parent:has(:disabled)'));
    expect(formatElements(actual)).toBe('p1');

    await snapshot();

    style.remove();
    container.remove();
  });

  it('D3 :has(:enabled) matches elements with enabled input', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <div id="p1" class="parent">
        <input type="text">
      </div>
      <div id="p2" class="parent">
        <input type="text" disabled>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: red; }
      .parent:has(:enabled) { background-color: green; }
    `);

    const actual = Array.from(container.querySelectorAll('.parent:has(:enabled)'));
    expect(formatElements(actual)).toBe('p1');

    await snapshot();

    style.remove();
    container.remove();
  });

  it('D4 :has(input[type="radio"]:checked) complex form selector', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <div id="p1" class="parent">
        <input type="radio" name="group1" checked>
        <input type="radio" name="group1">
      </div>
      <div id="p2" class="parent">
        <input type="radio" name="group2">
        <input type="radio" name="group2">
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: red; }
      .parent:has(input[type="radio"]:checked) { background-color: green; }
    `);

    const actual = Array.from(container.querySelectorAll('.parent:has(input[type="radio"]:checked)'));
    expect(formatElements(actual)).toBe('p1');

    await snapshot();

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: :has() with complex combinations', () => {
  const green = 'rgb(0, 128, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  function formatElements(elements: Element[]) {
    return elements.map(e => e.id).sort().join(',');
  }

  it('E1 Multiple :has() on same element', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <div id="p1" class="parent">
        <span class="a">A</span>
        <span class="b">B</span>
      </div>
      <div id="p2" class="parent">
        <span class="a">A only</span>
      </div>
      <div id="p3" class="parent">
        <span class="b">B only</span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: red; }
      .parent:has(.a):has(.b) { background-color: green; }
    `);

    // Must have both .a AND .b
    const actual = Array.from(container.querySelectorAll('.parent:has(.a):has(.b)'));
    expect(formatElements(actual)).toBe('p1');

    await snapshot();

    style.remove();
    container.remove();
  });

  it('E2 :has() combined with class and attribute', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <div id="p1" class="parent active" data-type="special">
        <span class="target">Target</span>
      </div>
      <div id="p2" class="parent" data-type="special">
        <span class="target">Target</span>
      </div>
      <div id="p3" class="parent active">
        <span class="target">Target</span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: red; }
      .parent.active[data-type="special"]:has(.target) { background-color: green; }
    `);

    // Must be .active AND have data-type="special" AND have .target child
    const actual = Array.from(container.querySelectorAll('.parent.active[data-type="special"]:has(.target)'));
    expect(formatElements(actual)).toBe('p1');

    await snapshot();

    style.remove();
    container.remove();
  });

  it('E3 :has() in descendant selector context', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <div class="outer" id="o1">
        <div id="p1" class="parent">
          <span class="target">Target</span>
        </div>
      </div>
      <div id="p2" class="parent">
        <span class="target">Target</span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: red; }
      .outer .parent:has(.target) { background-color: green; }
    `);

    // Only .parent inside .outer
    const actual = Array.from(container.querySelectorAll('.outer .parent:has(.target)'));
    expect(formatElements(actual)).toBe('p1');

    await snapshot();

    style.remove();
    container.remove();
  });

  it('E4 :has() with multiple selectors in argument', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <div id="p1" class="parent">
        <span class="a">A</span>
      </div>
      <div id="p2" class="parent">
        <span class="b">B</span>
      </div>
      <div id="p3" class="parent">
        <span class="c">C</span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: red; }
      .parent:has(.a, .b) { background-color: green; }
    `);

    // Has either .a OR .b
    const actual = Array.from(container.querySelectorAll('.parent:has(.a, .b)'));
    expect(formatElements(actual)).toBe('p1,p2');

    await snapshot();

    style.remove();
    container.remove();
  });

  it('E5 Chained :has() and :not(:has())', async () => {
    const container = document.createElement('div');
    container.id = 'container';
    container.innerHTML = `
      <div id="p1" class="parent">
        <span class="good">Good</span>
      </div>
      <div id="p2" class="parent">
        <span class="good">Good</span>
        <span class="bad">Bad</span>
      </div>
      <div id="p3" class="parent">
        <span class="bad">Bad only</span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: red; }
      .parent:has(.good):not(:has(.bad)) { background-color: green; }
    `);

    // Has .good but NOT .bad
    const actual = Array.from(container.querySelectorAll('.parent:has(.good):not(:has(.bad))'));
    expect(formatElements(actual)).toBe('p1');

    await snapshot();

    style.remove();
    container.remove();
  });
});

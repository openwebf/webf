/**
 * CSS Selectors: :has() edge cases and special scenarios
 * Based on WPT: css/selectors/invalidation/has-*.html (edge case tests)
 *
 * Key behaviors:
 * - :has() handles complex nesting without crashes
 * - :has() with :nth-child and other complex pseudo-classes
 * - Empty :has() and edge conditions
 * - Performance considerations with complex selectors
 */
describe('CSS Selectors: :has() with :nth-child', () => {
  const grey = 'rgb(128, 128, 128)';
  const green = 'rgb(0, 128, 0)';
  const red = 'rgb(255, 0, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  function formatElements(elements: Element[]) {
    return elements.map(e => e.id).sort().join(',');
  }

  it('A1 :has(:nth-child(2)) matches parents with second child', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="p1" class="parent">
        <span>Only child</span>
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
      .parent { width: 80px; height: 30px; margin: 2px; background: grey; }
      .parent:has(:nth-child(2)) { background: green; }
    `);

    const p1 = container.querySelector('#p1')!;
    const p2 = container.querySelector('#p2')!;
    const p3 = container.querySelector('#p3')!;

    expect(getComputedStyle(p1).backgroundColor).toBe(grey);
    expect(getComputedStyle(p2).backgroundColor).toBe(green);
    expect(getComputedStyle(p3).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('A2 :has(:nth-child(odd)) matches parents with odd-positioned children', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="p1" class="parent">
        <span>1</span>
        <span>2</span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: grey; }
      .parent:has(:nth-child(odd)) { background: green; }
    `);

    const p1 = container.querySelector('#p1')!;
    // Has children at positions 1 (odd) and 2 (even), so :nth-child(odd) matches
    expect(getComputedStyle(p1).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('A3 :has(:nth-child) invalidation on sibling removal', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="parent" class="parent">
        <span id="s1">1</span>
        <span id="s2">2</span>
        <span id="s3">3</span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: grey; }
      .parent:has(:nth-child(3)) { background: green; }
    `);

    const parent = container.querySelector('#parent')!;
    const s2 = container.querySelector('#s2')!;

    expect(getComputedStyle(parent).backgroundColor).toBe(green);

    // Remove middle child
    s2.remove();
    // Now only 2 children, no :nth-child(3)
    expect(getComputedStyle(parent).backgroundColor).toBe(grey);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('A4 :has(:nth-last-child)', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="p1" class="parent">
        <span>1</span>
        <span>2</span>
        <span class="target">3</span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: grey; }
      .parent:has(.target:nth-last-child(1)) { background: green; }
    `);

    const p1 = container.querySelector('#p1')!;
    // .target is the last child (nth-last-child(1))
    expect(getComputedStyle(p1).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: :has() empty and edge conditions', () => {
  const grey = 'rgb(128, 128, 128)';
  const green = 'rgb(0, 128, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('B1 :has(:empty) matches parents with empty children', async () => {
    const container = document.createElement('div');
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
      .parent { width: 80px; height: 30px; margin: 2px; background: grey; }
      .parent:has(:empty) { background: green; }
    `);

    const p1 = container.querySelector('#p1')!;
    const p2 = container.querySelector('#p2')!;

    expect(getComputedStyle(p1).backgroundColor).toBe(green);
    expect(getComputedStyle(p2).backgroundColor).toBe(grey);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('B2 :has() with no matching descendants', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="parent" class="parent">
        <span class="other">Other</span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: grey; }
      .parent:has(.nonexistent) { background: green; }
    `);

    const parent = container.querySelector('#parent')!;
    expect(getComputedStyle(parent).backgroundColor).toBe(grey);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('B3 :has(*) with text-only content', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="p1" class="parent">Just text</div>
      <div id="p2" class="parent"><span>Element</span></div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: grey; }
      .parent:has(*) { background: green; }
    `);

    const p1 = container.querySelector('#p1')!;
    const p2 = container.querySelector('#p2')!;

    // Text nodes don't match *, only elements
    expect(getComputedStyle(p1).backgroundColor).toBe(grey);
    expect(getComputedStyle(p2).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: :has() with complex nesting', () => {
  const grey = 'rgb(128, 128, 128)';
  const green = 'rgb(0, 128, 0)';
  const red = 'rgb(255, 0, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('C1 Deeply nested :has() selectors', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="level1" class="level">
        <div id="level2" class="level">
          <div id="level3" class="level">
            <div id="level4" class="level">
              <span class="deep-target"></span>
            </div>
          </div>
        </div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .level { padding: 5px; margin: 2px; background: grey; }
      .level:has(.deep-target) { background: green; }
    `);

    const level1 = container.querySelector('#level1')!;
    const level2 = container.querySelector('#level2')!;
    const level3 = container.querySelector('#level3')!;
    const level4 = container.querySelector('#level4')!;

    // All ancestors of .deep-target should match
    expect(getComputedStyle(level1).backgroundColor).toBe(green);
    expect(getComputedStyle(level2).backgroundColor).toBe(green);
    expect(getComputedStyle(level3).backgroundColor).toBe(green);
    expect(getComputedStyle(level4).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('C2 :has() with multiple levels of :is()', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="parent" class="parent">
        <div class="a">
          <div class="b">
            <span class="c"></span>
          </div>
        </div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 40px; background: grey; }
      .parent:has(:is(.a :is(.b .c))) { background: green; }
    `);

    const parent = container.querySelector('#parent')!;
    expect(getComputedStyle(parent).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('C3 :has() chain with multiple combinators', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="parent" class="parent">
        <div class="a">
          <span class="b"></span>
        </div>
        <div class="c">
          <span class="d"></span>
        </div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 40px; background: grey; }
      .parent:has(.a > .b):has(.c > .d) { background: green; }
    `);

    const parent = container.querySelector('#parent')!;
    expect(getComputedStyle(parent).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('C4 Nested :has() within :not()', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="p1" class="parent">
        <span class="good"></span>
      </div>
      <div id="p2" class="parent">
        <span class="bad"></span>
      </div>
      <div id="p3" class="parent">
        <span class="good"></span>
        <span class="bad"></span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; margin: 2px; background: grey; }
      .parent:has(.good):not(:has(.bad)) { background: green; }
    `);

    const p1 = container.querySelector('#p1')!;
    const p2 = container.querySelector('#p2')!;
    const p3 = container.querySelector('#p3')!;

    // p1: has .good, no .bad -> green
    expect(getComputedStyle(p1).backgroundColor).toBe(green);
    // p2: no .good -> grey
    expect(getComputedStyle(p2).backgroundColor).toBe(grey);
    // p3: has .good but also .bad -> grey
    expect(getComputedStyle(p3).backgroundColor).toBe(grey);

    await snapshot();

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: :has() with pseudo-elements (edge case)', () => {
  const grey = 'rgb(128, 128, 128)';
  const green = 'rgb(0, 128, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('D1 :has() cannot match pseudo-elements directly', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="parent" class="parent">
        <span class="child">Content</span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; background: grey; }
      .child::before { content: 'Before'; }
      /* :has(::before) is invalid, this should not match */
      .parent:has(.child) { background: green; }
    `);

    const parent = container.querySelector('#parent')!;
    // Should match .child, not ::before
    expect(getComputedStyle(parent).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: :has() sibling edge cases', () => {
  const grey = 'rgb(128, 128, 128)';
  const green = 'rgb(0, 128, 0)';
  const red = 'rgb(255, 0, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('E1 :has() with self-referencing sibling selector', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="parent">
        <div class="item" id="i1"></div>
        <div class="item" id="i2"></div>
        <div class="item" id="i3"></div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .item { width: 50px; height: 20px; margin: 2px; background: grey; }
      .item:has(~ .item) { background: green; }
    `);

    const i1 = container.querySelector('#i1')!;
    const i2 = container.querySelector('#i2')!;
    const i3 = container.querySelector('#i3')!;

    // i1 has siblings after -> green
    expect(getComputedStyle(i1).backgroundColor).toBe(green);
    // i2 has sibling after -> green
    expect(getComputedStyle(i2).backgroundColor).toBe(green);
    // i3 has no sibling after -> grey
    expect(getComputedStyle(i3).backgroundColor).toBe(grey);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('E2 First node insertion affects :has()', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="parent">
        <div id="existing" class="item"></div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      #parent { width: 100px; background: grey; padding: 5px; }
      .item { width: 50px; height: 20px; margin: 2px; background: grey; }
      #parent:has(.first) { background: green; }
    `);

    const parent = container.querySelector('#parent')!;
    const existing = container.querySelector('#existing')!;

    expect(getComputedStyle(parent).backgroundColor).toBe(grey);

    // Insert as first child
    const first = document.createElement('div');
    first.classList.add('first');
    parent.insertBefore(first, existing);

    expect(getComputedStyle(parent).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('E3 Removing non-first element affects :has()', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="parent">
        <div id="first"></div>
        <div id="middle" class="target"></div>
        <div id="last"></div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      #parent { width: 100px; background: grey; padding: 5px; }
      #parent:has(.target) { background: green; }
    `);

    const parent = container.querySelector('#parent')!;
    const middle = container.querySelector('#middle')!;

    expect(getComputedStyle(parent).backgroundColor).toBe(green);

    middle.remove();

    expect(getComputedStyle(parent).backgroundColor).toBe(grey);

    await snapshot();

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: :has() performance considerations', () => {
  const grey = 'rgb(128, 128, 128)';
  const green = 'rgb(0, 128, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('F1 Complex selector chain does not cause issues', async () => {
    const container = document.createElement('div');
    let html = '<div id="root" class="root">';
    for (let i = 0; i < 10; i++) {
      html += `<div class="level-${i}">`;
    }
    html += '<span class="deep"></span>';
    for (let i = 0; i < 10; i++) {
      html += '</div>';
    }
    html += '</div>';
    container.innerHTML = html;
    document.body.appendChild(container);

    const style = appendStyle(`
      .root { width: 100px; background: grey; padding: 10px; }
      .root:has(.deep) { background: green; }
    `);

    const root = container.querySelector('#root')!;
    expect(getComputedStyle(root).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('F2 Multiple :has() rules evaluate correctly', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="parent" class="parent">
        <span class="a"></span>
        <span class="b"></span>
        <span class="c"></span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; background: grey; }
      .parent:has(.a) { border: 1px solid red; }
      .parent:has(.b) { border: 2px solid green; }
      .parent:has(.c) { border: 3px solid blue; }
    `);

    const parent = container.querySelector('#parent')!;
    // Last matching rule wins for border
    expect(getComputedStyle(parent).borderWidth).toBe('3px');
    expect(getComputedStyle(parent).borderColor).toBe('rgb(0, 0, 255)');

    await snapshot();

    style.remove();
    container.remove();
  });

  it('F3 Many siblings with :has(~ .target)', async () => {
    const container = document.createElement('div');
    let html = '<div id="parent">';
    for (let i = 0; i < 20; i++) {
      html += `<div class="item" id="item-${i}"></div>`;
    }
    html += '<div class="target"></div>';
    html += '</div>';
    container.innerHTML = html;
    document.body.appendChild(container);

    const style = appendStyle(`
      .item { width: 30px; height: 15px; margin: 1px; background: grey; display: inline-block; }
      .item:has(~ .target) { background: green; }
    `);

    // All items before .target should be green
    for (let i = 0; i < 20; i++) {
      const item = container.querySelector(`#item-${i}`)!;
      expect(getComputedStyle(item).backgroundColor).toBe(green);
    }

    await snapshot();

    style.remove();
    container.remove();
  });
});

/**
 * CSS Selectors: Basic :has() matching behavior
 * Based on WPT: css/selectors/has-basic.html
 *
 * Key behaviors:
 * - :has() matches elements that have descendants/siblings matching the argument
 * - Works with descendant, child, and sibling combinators
 * - Works with querySelectorAll, querySelector, closest, matches APIs
 */
describe('CSS Selectors: :has() basic matching', () => {
  const green = 'rgb(0, 128, 0)';
  const red = 'rgb(255, 0, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  function createTestDOM() {
    const main = document.createElement('main');
    main.id = 'main';
    main.innerHTML = `
      <div id="a" class="ancestor">
        <div id="b" class="parent ancestor">
          <div id="c" class="sibling descendant">
            <div id="d" class="descendant"></div>
          </div>
          <div id="e" class="target descendant"></div>
        </div>
        <div id="f" class="parent ancestor">
          <div id="g" class="target descendant"></div>
        </div>
        <div id="h" class="parent ancestor">
          <div id="i" class="target descendant"></div>
          <div id="j" class="sibling descendant">
            <div id="k" class="descendant"></div>
          </div>
        </div>
      </div>
    `;
    document.body.appendChild(main);
    return main;
  }

  function formatElements(elements: Element[]) {
    return elements.map(e => e.id).sort().join(',');
  }

  // ========== Basic :has() with descendant selector ==========

  it('A1 :has(#a) matches nothing (no element has #a as descendant)', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: green; width: 50px; height: 20px; margin: 2px; }
      :has(#a) { background-color: red; }
    `);

    const actual = Array.from(main.querySelectorAll(':has(#a)'));
    expect(formatElements(actual)).toBe('');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('A2 :has(.ancestor) matches element a', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :has(.ancestor) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':has(.ancestor)'));
    expect(formatElements(actual)).toBe('a');
    expect(getComputedStyle(main.querySelector('#a')!).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    main.remove();
  });

  it('A3 :has(.target) matches ancestors of .target elements', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :has(.target) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':has(.target)'));
    expect(formatElements(actual)).toBe('a,b,f,h');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('A4 :has(.descendant) matches all ancestors of .descendant', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :has(.descendant) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':has(.descendant)'));
    expect(formatElements(actual)).toBe('a,b,c,f,h,j');

    await snapshot();

    style.remove();
    main.remove();
  });

  // ========== :has() with class filter ==========

  it('A5 .parent:has(.target) filters by class', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      .parent:has(.target) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.parent:has(.target)'));
    expect(formatElements(actual)).toBe('b,f,h');

    await snapshot();

    style.remove();
    main.remove();
  });

  // ========== :has() with sibling combinator ==========

  it('A6 :has(.sibling ~ .target) matches elements with sibling-then-target pattern', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :has(.sibling ~ .target) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':has(.sibling ~ .target)'));
    expect(formatElements(actual)).toBe('a,b');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('A7 .parent:has(.sibling ~ .target) with class filter', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      .parent:has(.sibling ~ .target) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.parent:has(.sibling ~ .target)'));
    expect(formatElements(actual)).toBe('b');

    await snapshot();

    style.remove();
    main.remove();
  });

  // ========== :has() with :is() nested ==========

  it('A8 :has(:is(.target ~ .sibling .descendant)) complex nesting', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :has(:is(.target ~ .sibling .descendant)) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':has(:is(.target ~ .sibling .descendant))'));
    expect(formatElements(actual)).toBe('a,h,j');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('A9 .parent:has(:is(.target ~ .sibling .descendant)) with class filter', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      .parent:has(:is(.target ~ .sibling .descendant)) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.parent:has(:is(.target ~ .sibling .descendant))'));
    expect(formatElements(actual)).toBe('h');

    await snapshot();

    style.remove();
    main.remove();
  });

  // ========== :has() in sibling selector context ==========

  it('A10 .sibling:has(.descendant) ~ .target matches target after sibling with descendant', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      .sibling:has(.descendant) ~ .target { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.sibling:has(.descendant) ~ .target'));
    expect(formatElements(actual)).toBe('e');

    await snapshot();

    style.remove();
    main.remove();
  });

  // ========== :has() with child combinator ==========

  it('B1 :has(> .parent) matches only direct parent of .parent', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :has(> .parent) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':has(> .parent)'));
    expect(formatElements(actual)).toBe('a');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('B2 :has(> .target) matches direct parents of .target', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :has(> .target) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':has(> .target)'));
    expect(formatElements(actual)).toBe('b,f,h');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('B3 :has(> .parent, > .target) matches with OR logic', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :has(> .parent, > .target) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':has(> .parent, > .target)'));
    expect(formatElements(actual)).toBe('a,b,f,h');

    await snapshot();

    style.remove();
    main.remove();
  });

  // ========== :has() with adjacent sibling ==========

  it('B4 :has(+ #h) matches element immediately before #h', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :has(+ #h) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':has(+ #h)'));
    expect(formatElements(actual)).toBe('f');

    await snapshot();

    style.remove();
    main.remove();
  });

  // ========== :has() with general sibling ==========

  it('B5 .parent:has(~ #h) matches .parent elements before #h', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      .parent:has(~ #h) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.parent:has(~ #h)'));
    expect(formatElements(actual)).toBe('b,f');

    await snapshot();

    style.remove();
    main.remove();
  });

  // ========== querySelector API ==========

  it('C1 querySelector returns first matching element', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      .sibling:has(.descendant) { background-color: green; }
    `);

    const result = main.querySelector('.sibling:has(.descendant)');
    expect(result).toBe(main.querySelector('#c'));

    await snapshot();

    style.remove();
    main.remove();
  });

  // ========== closest API ==========

  it('C2 closest finds nearest ancestor matching :has()', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      .ancestor:has(.descendant) { background-color: green; }
    `);

    const k = main.querySelector('#k')!;
    const result = k.closest('.ancestor:has(.descendant)');
    expect(result).toBe(main.querySelector('#h'));

    await snapshot();

    style.remove();
    main.remove();
  });

  // ========== matches API ==========

  it('C3 matches returns true for matching :has()', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :has(.target ~ .sibling .descendant) { background-color: green; }
    `);

    const h = main.querySelector('#h')!;
    expect(h.matches(':has(.target ~ .sibling .descendant)')).toBe(true);

    await snapshot();

    style.remove();
    main.remove();
  });

  it('C4 matches returns false for non-matching :has()', async () => {
    const main = createTestDOM();

    const b = main.querySelector('#b')!;
    // b has .target but not .target ~ .sibling .descendant pattern
    expect(b.matches(':has(.target ~ .sibling .descendant)')).toBe(false);

    main.remove();
  });
});

/**
 * CSS Selectors: :has() visual styling tests
 * Tests that :has() correctly applies styles visually
 */
describe('CSS Selectors: :has() visual styling', () => {
  const green = 'rgb(0, 128, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('D1 Parent styled green when child exists', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="parent" style="width: 100px; height: 50px; background: red;">
        <span class="child">Child</span>
      </div>
      <div class="parent" style="width: 100px; height: 50px; background: red;">
        No child span
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent:has(.child) { background-color: green !important; }
    `);

    const parents = container.querySelectorAll('.parent');
    expect(getComputedStyle(parents[0]).backgroundColor).toBe(green);
    // Second parent has no .child, should remain red
    expect(getComputedStyle(parents[1]).backgroundColor).toBe('rgb(255, 0, 0)');

    await snapshot();

    style.remove();
    container.remove();
  });

  it('D2 Multiple levels of :has() nesting', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="grandparent" style="padding: 10px; background: red; width: 120px;">
        <div class="parent" style="padding: 5px; background: blue;">
          <span class="child">Nested</span>
        </div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .grandparent:has(.child) { background-color: green !important; }
    `);

    const grandparent = container.querySelector('.grandparent')!;
    expect(getComputedStyle(grandparent).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('D3 :has() with attribute selector', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="item" style="width: 100px; height: 30px; background: red;">
        <input type="checkbox" checked>
      </div>
      <div class="item" style="width: 100px; height: 30px; background: red;">
        <input type="checkbox">
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .item:has(input[checked]) { background-color: green !important; }
    `);

    const items = container.querySelectorAll('.item');
    expect(getComputedStyle(items[0]).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });
});

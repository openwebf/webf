/**
 * CSS Selectors: Basic :is()/:where() matching behavior
 * Based on WPT: css/selectors/is-where-basic.html
 *
 * Key behaviors:
 * - :is() matches any of its arguments
 * - :where() matches any of its arguments (with zero specificity)
 * - Both work with combinators, IDs, classes, and element types
 */
describe('CSS Selectors: :is() and :where() basic matching', () => {
  const green = 'rgb(0, 128, 0)';

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
      <div id="a"><div id="d"></div></div>
      <div id="b"><div id="e"></div></div>
      <div id="c"><div id="f"></div></div>
    `;
    document.body.appendChild(main);
    return main;
  }

  function formatElements(elements: Element[]) {
    return elements.map(e => e.id).sort().join(',');
  }

  // ========== Empty :is() ==========

  it('A1 Empty :is() matches nothing', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :is() { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':is()'));
    expect(formatElements(actual)).toBe('');

    await snapshot();

    style.remove();
    main.remove();
  });

  // ========== :is() with single ID ==========

  it('A2 :is(#a) matches element with id a', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :is(#a) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':is(#a)'));
    expect(formatElements(actual)).toBe('a');
    expect(getComputedStyle(main.querySelector('#a')!).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    main.remove();
  });

  // ========== :is() with multiple IDs ==========

  it('A3 :is(#a, #f) matches both elements', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :is(#a, #f) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':is(#a, #f)'));
    expect(formatElements(actual)).toBe('a,f');
    expect(getComputedStyle(main.querySelector('#a')!).backgroundColor).toBe(green);
    expect(getComputedStyle(main.querySelector('#f')!).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    main.remove();
  });

  // ========== Combined :is() and :where() ==========

  it('A4 :is(#a, #c) :where(#a #d, #c #f) matches descendants', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :is(#a, #c) :where(#a #d, #c #f) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':is(#a, #c) :where(#a #d, #c #f)'));
    expect(formatElements(actual)).toBe('d,f');

    await snapshot();

    style.remove();
    main.remove();
  });

  // ========== Child combinator with :is() ==========

  it('A5 #c > :is(#c > #f) matches nested child', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      #c > :is(#c > #f) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('#c > :is(#c > #f)'));
    expect(formatElements(actual)).toBe('f');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('A6 #c > :is(#b > #f) matches nothing (wrong parent)', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: green; width: 50px; height: 20px; margin: 2px; }
      #c > :is(#b > #f) { background-color: red; }
    `);

    const actual = Array.from(main.querySelectorAll('#c > :is(#b > #f)'));
    expect(formatElements(actual)).toBe('');

    await snapshot();

    style.remove();
    main.remove();
  });

  // ========== Element type with :is() and ID ==========

  it('A7 #a div:is(#d) matches element d', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      #a div:is(#d) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('#a div:is(#d)'));
    expect(formatElements(actual)).toBe('d');

    await snapshot();

    style.remove();
    main.remove();
  });

  // ========== :is(div) with child combinator ==========

  it('A8 :is(div) > div matches all nested divs', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :is(div) > div { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':is(div) > div'));
    expect(formatElements(actual)).toBe('d,e,f');

    await snapshot();

    style.remove();
    main.remove();
  });

  // ========== :is(*) universal selector ==========

  it('A9 :is(*) > div matches all divs with parent', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: green; width: 50px; height: 20px; margin: 2px; }
    `);

    const actual = Array.from(main.querySelectorAll(':is(*) > div'));
    expect(formatElements(actual)).toBe('a,b,c,d,e,f');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('A10 :is(*) div matches all divs', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: green; width: 50px; height: 20px; margin: 2px; }
    `);

    const actual = Array.from(main.querySelectorAll(':is(*) div'));
    expect(formatElements(actual)).toBe('a,b,c,d,e,f');

    await snapshot();

    style.remove();
    main.remove();
  });

  // ========== :where() with child combinator ==========

  it('B1 div > :where(#e, #f) matches e and f', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      div > :where(#e, #f) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('div > :where(#e, #f)'));
    expect(formatElements(actual)).toBe('e,f');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('B2 div > :where(*) matches all nested divs', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      div > :where(*) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('div > :where(*)'));
    expect(formatElements(actual)).toBe('d,e,f');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('B3 :is(*) > :where(*) matches all elements with parent', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: green; width: 50px; height: 20px; margin: 2px; }
    `);

    const actual = Array.from(main.querySelectorAll(':is(*) > :where(*)'));
    expect(formatElements(actual)).toBe('a,b,c,d,e,f');

    await snapshot();

    style.remove();
    main.remove();
  });

  // ========== Adjacent sibling combinator with :is() ==========

  it('C1 :is(#a + #b) + :is(#c) matches c', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :is(#a + #b) + :is(#c) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':is(#a + #b) + :is(#c)'));
    expect(formatElements(actual)).toBe('c');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('C2 :is(#a, #b) + div matches b and c', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :is(#a, #b) + div { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':is(#a, #b) + div'));
    expect(formatElements(actual)).toBe('b,c');

    await snapshot();

    style.remove();
    main.remove();
  });
});

/**
 * CSS Selectors: :where() zero specificity
 * Key behavior: :where() contributes zero specificity
 */
describe('CSS Selectors: :where() zero specificity', () => {
  const green = 'rgb(0, 128, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('D1 :where(#id) has zero specificity, loses to element type', async () => {
    const target = document.createElement('div');
    target.id = 'target';
    target.className = 'box';
    target.textContent = 'Target';
    document.body.appendChild(target);

    const style = appendStyle(`
      .box { width: 100px; height: 50px; }
      :where(#target) { background-color: red; }
      div { background-color: green; }
    `);

    await snapshot();
    expect(getComputedStyle(target).backgroundColor).toBe(green);

    style.remove();
    target.remove();
  });

  it('D2 :where(.class) has zero specificity, loses to element type', async () => {
    const target = document.createElement('div');
    target.className = 'target box';
    target.textContent = 'Target';
    document.body.appendChild(target);

    const style = appendStyle(`
      .box { width: 100px; height: 50px; }
      :where(.target) { background-color: red; }
      div { background-color: green; }
    `);

    await snapshot();
    expect(getComputedStyle(target).backgroundColor).toBe(green);

    style.remove();
    target.remove();
  });

  it('D3 :is(#id) has full specificity, wins over element type', async () => {
    const target = document.createElement('div');
    target.id = 'target';
    target.className = 'box';
    target.textContent = 'Target';
    document.body.appendChild(target);

    const style = appendStyle(`
      .box { width: 100px; height: 50px; }
      div { background-color: red; }
      :is(#target) { background-color: green; }
    `);

    await snapshot();
    expect(getComputedStyle(target).backgroundColor).toBe(green);

    style.remove();
    target.remove();
  });

  it('D4 :where() inside compound selector still has zero specificity contribution', async () => {
    const target = document.createElement('div');
    target.id = 'target';
    target.className = 'box';
    target.textContent = 'Target';
    document.body.appendChild(target);

    const style = appendStyle(`
      .box { width: 100px; height: 50px; }
      div:where(#target) { background-color: red; }
      div.box { background-color: green; }
    `);

    await snapshot();
    // div:where(#target) = 0,0,1 (only div counts)
    // div.box = 0,1,1
    // div.box wins
    expect(getComputedStyle(target).backgroundColor).toBe(green);

    style.remove();
    target.remove();
  });

  it('D5 :is() takes highest specificity from arguments', async () => {
    const target = document.createElement('div');
    target.id = 'target';
    target.className = 'box other';
    target.textContent = 'Target';
    document.body.appendChild(target);

    const style = appendStyle(`
      .box { width: 100px; height: 50px; }
      .other { background-color: red; }
      :is(.box, #target) { background-color: green; }
    `);

    await snapshot();
    // :is(.box, #target) = 1,0,0 (takes #target's specificity)
    // .other = 0,1,0
    // :is wins
    expect(getComputedStyle(target).backgroundColor).toBe(green);

    style.remove();
    target.remove();
  });
});

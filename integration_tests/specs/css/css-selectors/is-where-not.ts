/**
 * CSS Selectors: :is() and :where() inside :not()
 * Based on WPT: css/selectors/is-where-not.html
 *
 * Key behaviors:
 * - :is() and :where() can be used inside :not()
 * - :not(:is(...)) negates elements matching any argument
 * - :not(:where(...)) same behavior but with zero specificity contribution
 */
describe('CSS Selectors: :is()/:where() inside :not()', () => {
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

  // ========== :not(:is(#id)) ==========

  it('A1 :not(:is(#a)) excludes element a', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      #main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :not(:is(#a)) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':not(:is(#a))'));
    expect(formatElements(actual)).toBe('b,c,d,e,f');

    await waitForFrame();
    await snapshot();

    style.remove();
    main.remove();
  });

  it('A2 :not(:where(#b)) excludes element b', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      #main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :not(:where(#b)) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':not(:where(#b))'));
    expect(formatElements(actual)).toBe('a,c,d,e,f');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('A3 :not(:where(:root #c)) excludes element c', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      #main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :not(:where(:root #c)) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':not(:where(:root #c))'));
    expect(formatElements(actual)).toBe('a,b,d,e,f');

    await snapshot();

    style.remove();
    main.remove();
  });

  // ========== :not(:is(#id, #id)) with multiple IDs ==========

  it('B1 :not(:is(#a, #b)) excludes a and b', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      #main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :not(:is(#a, #b)) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':not(:is(#a, #b))'));
    expect(formatElements(actual)).toBe('c,d,e,f');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('B2 :not(:is(#b div)) excludes e (b descendant)', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      #main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :not(:is(#b div)) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':not(:is(#b div))'));
    expect(formatElements(actual)).toBe('a,b,c,d,f');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('B3 :not(:is(#a div, div + div)) excludes d, b, c', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      #main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :not(:is(#a div, div + div)) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':not(:is(#a div, div + div))'));
    expect(formatElements(actual)).toBe('a,e,f');

    await snapshot();

    style.remove();
    main.remove();
  });

  // ========== :not(:is(element-type)) ==========

  it('C1 :not(:is(span)) excludes nothing (no spans)', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      #main div { background-color: green; width: 50px; height: 20px; margin: 2px; }
      :not(:is(span)) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':not(:is(span))'));
    expect(formatElements(actual)).toBe('a,b,c,d,e,f');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('C2 :not(:is(div)) matches nothing (all are divs)', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      #main div { background-color: green; width: 50px; height: 20px; margin: 2px; }
    `);

    const actual = Array.from(main.querySelectorAll(':not(:is(div))'));
    expect(formatElements(actual)).toBe('');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('C3 :not(:is(*)) matches nothing (all elements match *)', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      #main div { background-color: green; width: 50px; height: 20px; margin: 2px; }
    `);

    const actual = Array.from(main.querySelectorAll(':not(:is(*))'));
    expect(formatElements(actual)).toBe('');

    await snapshot();

    style.remove();
    main.remove();
  });

  // ========== Double negation ==========

  it('D1 :not(:is(:not(div))) matches all divs', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      #main div { background-color: green; width: 50px; height: 20px; margin: 2px; }
    `);

    const actual = Array.from(main.querySelectorAll(':not(:is(:not(div)))'));
    expect(formatElements(actual)).toBe('a,b,c,d,e,f');

    await snapshot();

    style.remove();
    main.remove();
  });

  // ========== Complex selectors with :not(:is()) ==========

  it('E1 :not(:is(span, b, i)) excludes nothing (no such elements)', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      #main div { background-color: green; width: 50px; height: 20px; margin: 2px; }
    `);

    const actual = Array.from(main.querySelectorAll(':not(:is(span, b, i))'));
    expect(formatElements(actual)).toBe('a,b,c,d,e,f');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('E2 :not(:is(span, b, i, div)) matches nothing', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      #main div { background-color: green; width: 50px; height: 20px; margin: 2px; }
    `);

    const actual = Array.from(main.querySelectorAll(':not(:is(span, b, i, div))'));
    expect(formatElements(actual)).toBe('');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('E3 :not(:is(#b ~ div div, * + #c)) complex selector', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      #main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :not(:is(#b ~ div div, * + #c)) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':not(:is(#b ~ div div, * + #c))'));
    expect(formatElements(actual)).toBe('a,b,d,e');

    await snapshot();

    style.remove();
    main.remove();
  });

  // ========== Nested :not with :is/:where ==========

  it('F1 :not(:is(div > :not(#e))) excludes d and f', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      #main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :not(:is(div > :not(#e))) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':not(:is(div > :not(#e)))'));
    expect(formatElements(actual)).toBe('a,b,c,e');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('F2 :not(:is(div > :not(:where(#e, #f)))) with :where', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      #main div { background-color: red; width: 50px; height: 20px; margin: 2px; }
      :not(:is(div > :not(:where(#e, #f)))) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll(':not(:is(div > :not(:where(#e, #f))))'));
    expect(formatElements(actual)).toBe('a,b,c,e,f');

    await snapshot();

    style.remove();
    main.remove();
  });
});

describe('CSS Selectors: :not(:is()) specificity', () => {
  const green = 'rgb(0, 128, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('G1 :not(:is(#id)) has ID specificity', async () => {
    const target = document.createElement('div');
    target.id = 'other';
    target.className = 'box';
    document.body.appendChild(target);

    const style = appendStyle(`
      .box { width: 100px; height: 50px; }
      .box.box.box.box { background-color: red; }
      :not(:is(#nonexistent)) { background-color: green; }
    `);

    await snapshot();
    // :not(:is(#nonexistent)) = 1,0,0
    // .box.box.box.box = 0,4,0
    // :not wins
    expect(getComputedStyle(target).backgroundColor).toBe(green);

    style.remove();
    target.remove();
  });

  it('G2 :not(:where(#id)) has zero specificity', async () => {
    const target = document.createElement('div');
    target.id = 'other';
    target.className = 'box';
    document.body.appendChild(target);

    const style = appendStyle(`
      .box { width: 100px; height: 50px; }
      :not(:where(#nonexistent)) { background-color: red; }
      div { background-color: green; }
    `);

    await snapshot();
    // :not(:where(#nonexistent)) = 0,0,0
    // div = 0,0,1
    // div wins
    expect(getComputedStyle(target).backgroundColor).toBe(green);

    style.remove();
    target.remove();
  });
});

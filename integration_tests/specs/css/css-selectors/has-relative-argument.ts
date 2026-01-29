/**
 * CSS Selectors: :has() with relative selectors
 * Based on WPT: css/selectors/has-relative-argument.html
 *
 * Key behaviors:
 * - :has() can use child combinator (>)
 * - :has() can use adjacent sibling combinator (+)
 * - :has() can use general sibling combinator (~)
 * - These can be combined with descendant selectors
 */
describe('CSS Selectors: :has() with descendant combinators', () => {
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
      <div id="d01">
        <div id="d02" class="x">
          <div id="d03" class="a"></div>
          <div id="d04"></div>
          <div id="d05" class="b"></div>
        </div>
        <div id="d06" class="x">
          <div id="d07" class="x">
            <div id="d08" class="a"></div>
          </div>
        </div>
        <div id="d09" class="x">
          <div id="d10" class="a">
            <div id="d11" class="b"></div>
          </div>
        </div>
        <div id="d12" class="x">
          <div id="d13" class="a">
            <div id="d14">
              <div id="d15" class="b"></div>
            </div>
          </div>
          <div id="d16" class="b"></div>
        </div>
      </div>
    `;
    document.body.appendChild(main);
    return main;
  }

  function formatElements(elements: Element[]) {
    return elements.map(e => e.id).sort().join(',');
  }

  // ========== Basic descendant with :has() ==========

  it('A1 .x:has(.a) matches .x elements containing .a anywhere', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 15px; margin: 2px; }
      .x:has(.a) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(.a)'));
    expect(formatElements(actual)).toBe('d02,d06,d07,d09,d12');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('A2 .x:has(.a > .b) matches .x with .a > .b pattern', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 15px; margin: 2px; }
      .x:has(.a > .b) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(.a > .b)'));
    expect(formatElements(actual)).toBe('d09');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('A3 .x:has(.a .b) matches .x with .a descendant .b', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 15px; margin: 2px; }
      .x:has(.a .b) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(.a .b)'));
    expect(formatElements(actual)).toBe('d09,d12');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('A4 .x:has(.a + .b) matches .x with adjacent .a + .b', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 15px; margin: 2px; }
      .x:has(.a + .b) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(.a + .b)'));
    expect(formatElements(actual)).toBe('d12');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('A5 .x:has(.a ~ .b) matches .x with general sibling .a ~ .b', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 15px; margin: 2px; }
      .x:has(.a ~ .b) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(.a ~ .b)'));
    expect(formatElements(actual)).toBe('d02,d12');

    await snapshot();

    style.remove();
    main.remove();
  });
});

describe('CSS Selectors: :has() with child combinator (>)', () => {
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
      <div id="d01">
        <div id="d02" class="x">
          <div id="d03" class="a"></div>
          <div id="d04"></div>
          <div id="d05" class="b"></div>
        </div>
        <div id="d06" class="x">
          <div id="d07" class="x">
            <div id="d08" class="a"></div>
          </div>
        </div>
        <div id="d09" class="x">
          <div id="d10" class="a">
            <div id="d11" class="b"></div>
          </div>
        </div>
        <div id="d12" class="x">
          <div id="d13" class="a">
            <div id="d14">
              <div id="d15" class="b"></div>
            </div>
          </div>
          <div id="d16" class="b"></div>
        </div>
      </div>
    `;
    document.body.appendChild(main);
    return main;
  }

  function formatElements(elements: Element[]) {
    return elements.map(e => e.id).sort().join(',');
  }

  it('B1 .x:has(> .a) matches .x with direct child .a', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 15px; margin: 2px; }
      .x:has(> .a) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(> .a)'));
    expect(formatElements(actual)).toBe('d02,d07,d09,d12');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('B2 .x:has(> .a > .b) matches .x with direct > .a > .b', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 15px; margin: 2px; }
      .x:has(> .a > .b) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(> .a > .b)'));
    expect(formatElements(actual)).toBe('d09');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('B3 .x:has(> .a .b) matches .x with > .a then descendant .b', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 15px; margin: 2px; }
      .x:has(> .a .b) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(> .a .b)'));
    expect(formatElements(actual)).toBe('d09,d12');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('B4 .x:has(> .a + .b) matches .x with direct child then adjacent', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 15px; margin: 2px; }
      .x:has(> .a + .b) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(> .a + .b)'));
    expect(formatElements(actual)).toBe('d12');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('B5 .x:has(> .a ~ .b) matches .x with direct > then general sibling', async () => {
    const main = createTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 50px; height: 15px; margin: 2px; }
      .x:has(> .a ~ .b) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(> .a ~ .b)'));
    expect(formatElements(actual)).toBe('d02,d12');

    await snapshot();

    style.remove();
    main.remove();
  });
});

describe('CSS Selectors: :has() with adjacent sibling combinator (+)', () => {
  const green = 'rgb(0, 128, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  function createSiblingTestDOM() {
    const main = document.createElement('main');
    main.id = 'main';
    main.innerHTML = `
      <div id="d17">
        <div id="d18" class="x"></div>
        <div id="d19" class="x"></div>
        <div id="d20" class="a"></div>
        <div id="d21" class="x"></div>
        <div id="d22" class="a">
          <div id="d23" class="b"></div>
        </div>
        <div id="d24" class="x"></div>
        <div id="d25" class="a">
          <div id="d26">
            <div id="d27" class="b"></div>
          </div>
        </div>
        <div id="d28" class="x"></div>
        <div id="d29" class="a"></div>
        <div id="d30" class="b">
          <div id="d31" class="c"></div>
        </div>
        <div id="d32" class="x"></div>
        <div id="d33" class="a"></div>
        <div id="d34" class="b">
          <div id="d35">
            <div id="d36" class="c"></div>
          </div>
        </div>
        <div id="d37" class="x"></div>
        <div id="d38" class="a"></div>
        <div id="d39" class="b"></div>
        <div id="d40" class="x"></div>
        <div id="d41" class="a"></div>
        <div id="d42"></div>
        <div id="d43" class="b">
          <div id="d44" class="x">
            <div id="d45" class="c"></div>
          </div>
        </div>
        <div id="d46" class="x"></div>
        <div id="d47" class="a"></div>
      </div>
    `;
    document.body.appendChild(main);
    return main;
  }

  function formatElements(elements: Element[]) {
    return elements.map(e => e.id).sort().join(',');
  }

  it('C1 .x:has(+ .a) matches .x immediately before .a', async () => {
    const main = createSiblingTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 30px; height: 10px; margin: 1px; }
      .x:has(+ .a) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(+ .a)'));
    expect(formatElements(actual)).toBe('d19,d21,d24,d28,d32,d37,d40,d46');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('C2 .x:has(+ .a > .b) matches .x before .a with direct child .b', async () => {
    const main = createSiblingTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 30px; height: 10px; margin: 1px; }
      .x:has(+ .a > .b) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(+ .a > .b)'));
    expect(formatElements(actual)).toBe('d21');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('C3 .x:has(+ .a .b) matches .x before .a with descendant .b', async () => {
    const main = createSiblingTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 30px; height: 10px; margin: 1px; }
      .x:has(+ .a .b) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(+ .a .b)'));
    expect(formatElements(actual)).toBe('d21,d24');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('C4 .x:has(+ .a + .b) matches .x before .a + .b sequence', async () => {
    const main = createSiblingTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 30px; height: 10px; margin: 1px; }
      .x:has(+ .a + .b) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(+ .a + .b)'));
    expect(formatElements(actual)).toBe('d28,d32,d37');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('C5 .x:has(+ .a ~ .b) matches .x before .a with later sibling .b', async () => {
    const main = createSiblingTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 30px; height: 10px; margin: 1px; }
      .x:has(+ .a ~ .b) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(+ .a ~ .b)'));
    expect(formatElements(actual)).toBe('d19,d21,d24,d28,d32,d37,d40');

    await snapshot();

    style.remove();
    main.remove();
  });
});

describe('CSS Selectors: :has() with general sibling combinator (~)', () => {
  const green = 'rgb(0, 128, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  function createSiblingTestDOM() {
    const main = document.createElement('main');
    main.id = 'main';
    main.innerHTML = `
      <div id="d17">
        <div id="d18" class="x"></div>
        <div id="d19" class="x"></div>
        <div id="d20" class="a"></div>
        <div id="d21" class="x"></div>
        <div id="d22" class="a">
          <div id="d23" class="b"></div>
        </div>
        <div id="d24" class="x"></div>
        <div id="d25" class="a">
          <div id="d26">
            <div id="d27" class="b"></div>
          </div>
        </div>
        <div id="d28" class="x"></div>
        <div id="d29" class="a"></div>
        <div id="d30" class="b">
          <div id="d31" class="c"></div>
        </div>
        <div id="d32" class="x"></div>
        <div id="d33" class="a"></div>
        <div id="d34" class="b">
          <div id="d35">
            <div id="d36" class="c"></div>
          </div>
        </div>
        <div id="d37" class="x"></div>
        <div id="d38" class="a"></div>
        <div id="d39" class="b"></div>
        <div id="d40" class="x"></div>
        <div id="d41" class="a"></div>
        <div id="d42"></div>
        <div id="d43" class="b">
          <div id="d44" class="x">
            <div id="d45" class="c"></div>
          </div>
        </div>
        <div id="d46" class="x"></div>
        <div id="d47" class="a"></div>
      </div>
    `;
    document.body.appendChild(main);
    return main;
  }

  function formatElements(elements: Element[]) {
    return elements.map(e => e.id).sort().join(',');
  }

  it('D1 .x:has(~ .a) matches .x with any later sibling .a', async () => {
    const main = createSiblingTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 30px; height: 10px; margin: 1px; }
      .x:has(~ .a) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(~ .a)'));
    expect(formatElements(actual)).toBe('d18,d19,d21,d24,d28,d32,d37,d40,d46');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('D2 .x:has(~ .a > .b) matches .x with later sibling .a > .b', async () => {
    const main = createSiblingTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 30px; height: 10px; margin: 1px; }
      .x:has(~ .a > .b) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(~ .a > .b)'));
    expect(formatElements(actual)).toBe('d18,d19,d21');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('D3 .x:has(~ .a .b) matches .x with later sibling .a containing .b', async () => {
    const main = createSiblingTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 30px; height: 10px; margin: 1px; }
      .x:has(~ .a .b) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(~ .a .b)'));
    expect(formatElements(actual)).toBe('d18,d19,d21,d24');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('D4 .x:has(~ .a + .b) matches .x with later .a + .b sequence', async () => {
    const main = createSiblingTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 30px; height: 10px; margin: 1px; }
      .x:has(~ .a + .b) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(~ .a + .b)'));
    expect(formatElements(actual)).toBe('d18,d19,d21,d24,d28,d32,d37');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('D5 .x:has(~ .a + .b > .c) matches complex chain', async () => {
    const main = createSiblingTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 30px; height: 10px; margin: 1px; }
      .x:has(~ .a + .b > .c) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(~ .a + .b > .c)'));
    expect(formatElements(actual)).toBe('d18,d19,d21,d24,d28');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('D6 .x:has(~ .a + .b .c) matches with descendant .c', async () => {
    const main = createSiblingTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 30px; height: 10px; margin: 1px; }
      .x:has(~ .a + .b .c) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(~ .a + .b .c)'));
    expect(formatElements(actual)).toBe('d18,d19,d21,d24,d28,d32');

    await snapshot();

    style.remove();
    main.remove();
  });
});

describe('CSS Selectors: :has() complex nested patterns', () => {
  const green = 'rgb(0, 128, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  function createNestedTestDOM() {
    const main = document.createElement('main');
    main.id = 'main';
    main.innerHTML = `
      <div>
        <div id="d48" class="x">
          <div id="d49" class="x">
            <div id="d50" class="x d">
              <div id="d51" class="x d">
                <div id="d52" class="x">
                  <div id="d53" class="x e">
                    <div id="d54" class="f"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div id="d55" class="x"></div>
        <div id="d56" class="x d"></div>
        <div id="d57" class="x d"></div>
        <div id="d58" class="x"></div>
        <div id="d59" class="x e"></div>
        <div id="d60" class="f"></div>
      </div>
    `;
    document.body.appendChild(main);
    return main;
  }

  function formatElements(elements: Element[]) {
    return elements.map(e => e.id).sort().join(',');
  }

  it('E1 .x:has(.d .e) matches .x with .d descendant containing .e', async () => {
    const main = createNestedTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 30px; height: 10px; margin: 1px; }
      .x:has(.d .e) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(.d .e)'));
    expect(formatElements(actual)).toBe('d48,d49,d50');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('E2 .x:has(.d .e) .f selects .f inside matching elements', async () => {
    const main = createNestedTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 30px; height: 10px; margin: 1px; }
      .x:has(.d .e) .f { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(.d .e) .f'));
    expect(formatElements(actual)).toBe('d54');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('E3 .x:has(> .d) matches .x with direct child .d', async () => {
    const main = createNestedTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 30px; height: 10px; margin: 1px; }
      .x:has(> .d) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(> .d)'));
    expect(formatElements(actual)).toBe('d49,d50');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('E4 .x:has(> .d) .f selects .f inside :has(> .d) matches', async () => {
    const main = createNestedTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 30px; height: 10px; margin: 1px; }
      .x:has(> .d) .f { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(> .d) .f'));
    expect(formatElements(actual)).toBe('d54');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('E5 .x:has(~ .d ~ .e) matches .x with .d then .e siblings', async () => {
    const main = createNestedTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 30px; height: 10px; margin: 1px; }
      .x:has(~ .d ~ .e) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(~ .d ~ .e)'));
    expect(formatElements(actual)).toBe('d48,d55,d56');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('E6 .x:has(~ .d ~ .e) ~ .f selects .f after :has() matches', async () => {
    const main = createNestedTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 30px; height: 10px; margin: 1px; }
      .x:has(~ .d ~ .e) ~ .f { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(~ .d ~ .e) ~ .f'));
    expect(formatElements(actual)).toBe('d60');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('E7 .x:has(+ .d ~ .e) matches .x immediately before .d with later .e', async () => {
    const main = createNestedTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 30px; height: 10px; margin: 1px; }
      .x:has(+ .d ~ .e) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(+ .d ~ .e)'));
    expect(formatElements(actual)).toBe('d55,d56');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('E8 .x:has(+ .d ~ .e) ~ .f selects sibling .f', async () => {
    const main = createNestedTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 30px; height: 10px; margin: 1px; }
      .x:has(+ .d ~ .e) ~ .f { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.x:has(+ .d ~ .e) ~ .f'));
    expect(formatElements(actual)).toBe('d60');

    await snapshot();

    style.remove();
    main.remove();
  });
});

describe('CSS Selectors: :has() in compound selectors', () => {
  const green = 'rgb(0, 128, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  function createCompoundTestDOM() {
    const main = document.createElement('main');
    main.id = 'main';
    main.innerHTML = `
      <div>
        <div id="d48" class="x">
          <div id="d49" class="x">
            <div id="d50" class="x d">
              <div id="d51" class="x d">
                <div id="d52" class="x">
                  <div id="d53" class="x e">
                    <div id="d54" class="f"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div id="d55" class="x"></div>
        <div id="d56" class="x d"></div>
        <div id="d57" class="x d"></div>
        <div id="d58" class="x"></div>
        <div id="d59" class="x e"></div>
        <div id="d60" class="f"></div>
      </div>
    `;
    document.body.appendChild(main);
    return main;
  }

  function formatElements(elements: Element[]) {
    return elements.map(e => e.id).sort().join(',');
  }

  it('F1 .d .x:has(.e) matches .x inside .d that has .e', async () => {
    const main = createCompoundTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 30px; height: 10px; margin: 1px; }
      .d .x:has(.e) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.d .x:has(.e)'));
    expect(formatElements(actual)).toBe('d51,d52');

    await snapshot();

    style.remove();
    main.remove();
  });

  it('F2 .d ~ .x:has(~ .e) matches .x sibling of .d with later .e sibling', async () => {
    const main = createCompoundTestDOM();
    const style = appendStyle(`
      main div { background-color: red; width: 30px; height: 10px; margin: 1px; }
      .d ~ .x:has(~ .e) { background-color: green; }
    `);

    const actual = Array.from(main.querySelectorAll('.d ~ .x:has(~ .e)'));
    expect(formatElements(actual)).toBe('d57,d58');

    await snapshot();

    style.remove();
    main.remove();
  });
});

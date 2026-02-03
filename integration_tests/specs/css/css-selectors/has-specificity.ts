/**
 * CSS Selectors: :has() specificity
 * Based on WPT: css/selectors/has-specificity.html
 *
 * Key behaviors:
 * - :has() specificity is calculated from its most specific argument
 * - :has(#id) has higher specificity than :has(.class)
 * - Comma-separated arguments take the highest specificity
 * - :has() with element types adds to specificity
 */
describe('CSS Selectors: :has() specificity calculations', () => {
  const green = 'rgb(0, 128, 0)';
  const red = 'rgb(255, 0, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  function createTestDOM() {
    const div = document.createElement('div');
    div.id = 'div';
    div.className = 'baz';
    div.innerHTML = `<p><span id="foo" class="foo"></span><span class="bar"></span><li></li></p>`;
    document.body.appendChild(div);
    return div;
  }

  // ========== ID vs Class specificity ==========

  it('A1 :has(#foo) wins over :has(.foo) - ID higher than class', async () => {
    const div = createTestDOM();
    const style = appendStyle(`
      #div { width: 100px; height: 50px; }
      :has(#foo) { background-color: green; }
      :has(.foo) { background-color: red; }
    `);

    // :has(#foo) = 1,0,0 in the argument
    // :has(.foo) = 0,1,0 in the argument
    // :has(#foo) wins
    expect(getComputedStyle(div).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    div.remove();
  });

  it('A2 :has(span#foo) wins over :has(#foo) - element + ID higher', async () => {
    const div = createTestDOM();
    const style = appendStyle(`
      #div { width: 100px; height: 50px; }
      :has(span#foo) { background-color: green; }
      :has(#foo) { background-color: red; }
    `);

    // :has(span#foo) = 1,0,1 in the argument
    // :has(#foo) = 1,0,0 in the argument
    // :has(span#foo) wins
    expect(getComputedStyle(div).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    div.remove();
  });

  // ========== Comma-separated arguments ==========

  it('A3 :has(.bar, #foo) has same specificity as :has(#foo, .bar) - order does not matter', async () => {
    const div = createTestDOM();
    const style = appendStyle(`
      #div { width: 100px; height: 50px; }
      :has(.bar, #foo) { background-color: red; }
      :has(#foo, .bar) { background-color: green; }
    `);

    // Both have same specificity (1,0,0 from #foo), latter wins
    expect(getComputedStyle(div).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    div.remove();
  });

  it('A4 :has(.bar, #foo) wins over :has(.foo, .bar) - ID in list wins', async () => {
    const div = createTestDOM();
    const style = appendStyle(`
      #div { width: 100px; height: 50px; }
      :has(.bar, #foo) { background-color: green; }
      :has(.foo, .bar) { background-color: red; }
    `);

    // :has(.bar, #foo) takes specificity of #foo = 1,0,0
    // :has(.foo, .bar) = 0,1,0
    // :has(.bar, #foo) wins
    expect(getComputedStyle(div).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    div.remove();
  });

  // ========== Combinator specificity ==========

  it('A5 :has(span + span) wins over :has(span) - more elements', async () => {
    const div = createTestDOM();
    const style = appendStyle(`
      #div { width: 100px; height: 50px; }
      :has(span + span) { background-color: green; }
      :has(span) { background-color: red; }
    `);

    // :has(span + span) = 0,0,2 in the argument
    // :has(span) = 0,0,1 in the argument
    // :has(span + span) wins
    expect(getComputedStyle(div).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    div.remove();
  });

  // ========== Mixed selector types ==========

  it('A6 :has(span, li, #foo) wins over :has(span, li, p) - ID in list', async () => {
    const div = createTestDOM();
    const style = appendStyle(`
      #div { width: 100px; height: 50px; }
      :has(span, li, #foo) { background-color: green; }
      :has(span, li, p) { background-color: red; }
    `);

    // :has(span, li, #foo) takes #foo specificity = 1,0,0
    // :has(span, li, p) = 0,0,1
    // :has(span, li, #foo) wins
    expect(getComputedStyle(div).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    div.remove();
  });

  // ========== :has() vs class on element ==========

  it('A7 div.baz wins over div:has(.foo) when latter comes first', async () => {
    const div = createTestDOM();
    const style = appendStyle(`
      #div { width: 100px; height: 50px; }
      div:has(.foo) { background-color: red; }
      div.baz { background-color: green; }
    `);

    // div:has(.foo) = 0,1,1 (div=0,0,1 + .foo=0,1,0)
    // div.baz = 0,1,1 (div=0,0,1 + .baz=0,1,0)
    // Same specificity, latter wins
    expect(getComputedStyle(div).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    div.remove();
  });

  it('A8 div:has(.foo) wins over div.baz when latter comes first', async () => {
    const div = createTestDOM();
    const style = appendStyle(`
      #div { width: 100px; height: 50px; }
      div.baz { background-color: red; }
      div:has(.foo) { background-color: green; }
    `);

    // Same specificity (0,1,1), latter wins
    expect(getComputedStyle(div).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    div.remove();
  });
});

describe('CSS Selectors: :has() specificity with multiple selectors', () => {
  const green = 'rgb(0, 128, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('B1 :has() with nested ID wins over :has() with class chain', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="parent" id="p1">
        <div class="child" id="child1">
          <span id="deep">Deep</span>
        </div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 100px; height: 50px; }
      .parent:has(.child .deep) { background-color: red; }
      .parent:has(#deep) { background-color: green; }
    `);

    const parent = container.querySelector('.parent')!;
    // :has(.child .deep) = 0,2,0
    // :has(#deep) = 1,0,0
    // ID wins
    expect(getComputedStyle(parent).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('B2 Multiple classes in :has() vs single ID', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="parent">
        <div class="a b c" id="target">Target</div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 100px; height: 50px; }
      .parent:has(.a.b.c) { background-color: red; }
      .parent:has(#target) { background-color: green; }
    `);

    const parent = container.querySelector('.parent')!;
    // :has(.a.b.c) = 0,3,0
    // :has(#target) = 1,0,0
    // ID (1,0,0) > classes (0,3,0)
    expect(getComputedStyle(parent).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('B3 :has() specificity combines with outer selector', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="outer" id="outer">
        <div class="inner">
          <span class="target">Target</span>
        </div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .outer { width: 100px; height: 50px; }
      div:has(.target) { background-color: red; }
      .outer:has(.target) { background-color: green; }
    `);

    const outer = container.querySelector('.outer')!;
    // div:has(.target) = 0,1,1
    // .outer:has(.target) = 0,2,0
    // .outer wins (0,2,0 > 0,1,1)
    expect(getComputedStyle(outer).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('B4 :has() with attribute selector specificity', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="parent">
        <input type="text" class="input" data-valid="true">
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 100px; height: 50px; }
      .parent:has(.input) { background-color: red; }
      .parent:has([data-valid]) { background-color: green; }
    `);

    const parent = container.querySelector('.parent')!;
    // Both have same specificity (0,1,0 from attribute or class)
    // Latter wins
    expect(getComputedStyle(parent).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('B5 Attribute selector in :has() has class-level specificity', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="parent">
        <input type="text" id="input1" data-valid="true">
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 100px; height: 50px; }
      .parent:has([data-valid]) { background-color: red; }
      .parent:has(#input1) { background-color: green; }
    `);

    const parent = container.querySelector('.parent')!;
    // :has([data-valid]) = 0,1,0
    // :has(#input1) = 1,0,0
    // ID wins
    expect(getComputedStyle(parent).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: :has() specificity edge cases', () => {
  const green = 'rgb(0, 128, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('C1 :has(*) has zero specificity from universal selector', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="parent">
        <span>Child</span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 100px; height: 50px; }
      .parent:has(*) { background-color: red; }
      .parent:has(span) { background-color: green; }
    `);

    const parent = container.querySelector('.parent')!;
    // :has(*) = 0,0,0 (universal adds nothing)
    // :has(span) = 0,0,1
    // span wins
    expect(getComputedStyle(parent).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('C2 Empty :has() list with valid selector', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="parent">
        <span class="child">Child</span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 100px; height: 50px; }
      .parent:has(.child) { background-color: green; }
    `);

    const parent = container.querySelector('.parent')!;
    expect(getComputedStyle(parent).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('C3 :has() with pseudo-class adds to specificity', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="parent">
        <input type="checkbox" checked>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 100px; height: 50px; }
      .parent:has(input) { background-color: red; }
      .parent:has(input:checked) { background-color: green; }
    `);

    const parent = container.querySelector('.parent')!;
    // :has(input) = 0,0,1
    // :has(input:checked) = 0,1,1 (:checked is pseudo-class = 0,1,0)
    // input:checked wins
    expect(getComputedStyle(parent).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('C4 Deeply nested :has() with :is()', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="parent">
        <div class="a">
          <span id="target">Target</span>
        </div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 100px; height: 50px; }
      .parent:has(:is(.a span)) { background-color: red; }
      .parent:has(:is(.a #target)) { background-color: green; }
    `);

    const parent = container.querySelector('.parent')!;
    // :has(:is(.a span)) = 0,1,1
    // :has(:is(.a #target)) = 1,1,0
    // #target in :is() wins
    expect(getComputedStyle(parent).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });
});

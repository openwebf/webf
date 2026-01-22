/**
 * CSS Selectors: Nested :is() and :where() selectors
 * Based on WPT: css/selectors/is-nested.html
 *
 * Key behaviors:
 * - :is() can be nested inside :is()
 * - Specificity is calculated from the highest-specificity argument at each level
 * - :where() nested in :is() contributes zero specificity for its part
 */
describe('CSS Selectors: Nested :is() specificity', () => {
  const red = 'rgb(255, 0, 0)';
  const yellow = 'rgb(255, 255, 0)';
  const green = 'rgb(0, 128, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('A1 Nested :is() chooses highest specificity for class outside', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="a"></div>
      <div class="b" id="b2"></div>
      <div class="c" id="c2">
        <div class="e"></div>
        <div class="d" id="d1">Yellow</div>
      </div>
    `;
    document.body.appendChild(container);

    const d1 = container.querySelector('#d1') as HTMLElement;
    const style = appendStyle(`
      .a+.b+.c>.e+.d {
        color: black;
        font-size: 10px;
        width: 10px;
      }
      .e:is(.b+.f, .e:is(*, .c>.e, .g, *))+.d {
        color: red;
        font-size: 20px;
      }
      .a+.b+.c>.e+.d {
        color: yellow;
      }
    `);

    await snapshot();
    expect(getComputedStyle(d1).color).toBe(yellow);
    expect(getComputedStyle(d1).fontSize).toBe('20px');
    expect(getComputedStyle(d1).width).toBe('10px');

    style.remove();
    container.remove();
  });

  it('A2 Nested :is() specificity for class within arguments', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="a"></div>
      <div class="c" id="c2">
        <div class="e" id="e1">Red</div>
      </div>
    `;
    document.body.appendChild(container);

    const e1 = container.querySelector('#e1') as HTMLElement;
    const style = appendStyle(`
      .a+.c>.e {
        color: black;
      }
      .e:is(.b+.f, :is(.c>.e, .g)) {
        color: red;
      }
      .c>.e {
        color: black;
      }
    `);

    await snapshot();
    expect(getComputedStyle(e1).color).toBe(red);

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: Nested :is()/:where() combinations', () => {
  const green = 'rgb(0, 128, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('B1 :is(:is(.a)) matches correctly', async () => {
    const target = document.createElement('div');
    target.className = 'a target';
    document.body.appendChild(target);

    const style = appendStyle(`
      .target { width: 100px; height: 50px; background-color: red; }
      :is(:is(.a)) { background-color: green; }
    `);

    await snapshot();
    expect(getComputedStyle(target).backgroundColor).toBe(green);

    style.remove();
    target.remove();
  });

  it('B2 :is(:is(:is(.a))) triple nested matches correctly', async () => {
    const target = document.createElement('div');
    target.className = 'a target';
    document.body.appendChild(target);

    const style = appendStyle(`
      .target { width: 100px; height: 50px; background-color: red; }
      :is(:is(:is(.a))) { background-color: green; }
    `);

    await snapshot();
    expect(getComputedStyle(target).backgroundColor).toBe(green);

    style.remove();
    target.remove();
  });

  it('B3 :where(:where(.a)) nested matches correctly', async () => {
    const target = document.createElement('div');
    target.className = 'a target';
    document.body.appendChild(target);

    const style = appendStyle(`
      .target { width: 100px; height: 50px; }
      :where(:where(.a)) { background-color: red; }
      div { background-color: green; }
    `);

    await snapshot();
    // :where(:where(.a)) = 0,0,0
    // div = 0,0,1
    // div wins
    expect(getComputedStyle(target).backgroundColor).toBe(green);

    style.remove();
    target.remove();
  });

  it('B4 :is(:where(.a, #id)) nested uses zero for :where part', async () => {
    const target = document.createElement('div');
    target.id = 'target';
    target.className = 'a box';
    document.body.appendChild(target);

    const style = appendStyle(`
      .box { width: 100px; height: 50px; }
      :is(:where(.a, #target)) { background-color: red; }
      div { background-color: green; }
    `);

    await snapshot();
    // :is(:where(.a, #target)) = 0,0,0 (:where contributes 0)
    // div = 0,0,1
    // div wins
    expect(getComputedStyle(target).backgroundColor).toBe(green);

    style.remove();
    target.remove();
  });

  it('B5 :where(:is(.a, #id)) uses :is specificity inside :where', async () => {
    const target = document.createElement('div');
    target.id = 'target';
    target.className = 'a box';
    document.body.appendChild(target);

    const style = appendStyle(`
      .box { width: 100px; height: 50px; }
      :where(:is(.a, #target)) { background-color: red; }
      div { background-color: green; }
    `);

    await snapshot();
    // :where(:is(.a, #target)) = 0,0,0 (outer :where makes everything 0)
    // div = 0,0,1
    // div wins
    expect(getComputedStyle(target).backgroundColor).toBe(green);

    style.remove();
    target.remove();
  });

  it('B6 :is(.a, :is(#id)) takes highest from any level', async () => {
    const target = document.createElement('div');
    target.id = 'target';
    target.className = 'box';
    document.body.appendChild(target);

    const style = appendStyle(`
      .box { width: 100px; height: 50px; }
      .box.box.box.box { background-color: red; }
      :is(.box, :is(#target)) { background-color: green; }
    `);

    await snapshot();
    // :is(.box, :is(#target)) = 1,0,0 (nested :is(#target) = 1,0,0)
    // .box.box.box.box = 0,4,0
    // :is wins
    expect(getComputedStyle(target).backgroundColor).toBe(green);

    style.remove();
    target.remove();
  });
});

describe('CSS Selectors: Complex nested :is()/:where()', () => {
  const green = 'rgb(0, 128, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('C1 :is(.a :is(.b .c)) with descendant combinators', async () => {
    const container = document.createElement('div');
    container.className = 'a';
    container.innerHTML = `
      <div class="b">
        <div class="c target" id="target">Target</div>
      </div>
    `;
    document.body.appendChild(container);

    const target = container.querySelector('#target') as HTMLElement;
    const style = appendStyle(`
      .target { width: 100px; height: 50px; background-color: red; }
      :is(.a :is(.b .c)) { background-color: green; }
    `);

    await snapshot();
    expect(getComputedStyle(target).backgroundColor).toBe(green);

    style.remove();
    container.remove();
  });

  it('C2 :is(.a > :is(.b > .c)) with child combinators', async () => {
    const container = document.createElement('div');
    container.className = 'a';
    container.innerHTML = `
      <div class="b">
        <div class="c target" id="target">Target</div>
      </div>
    `;
    document.body.appendChild(container);

    const target = container.querySelector('#target') as HTMLElement;
    const style = appendStyle(`
      .target { width: 100px; height: 50px; background-color: red; }
      :is(.a > :is(.b > .c)) { background-color: green; }
    `);

    await snapshot();
    // `:is(.b > .c)` matches the `.c` element. Therefore `.a > :is(.b > .c)`
    // would require that same `.c` element to be a direct child of both `.a`
    // (outer `>`) and `.b` (inner `>`), which is not true for `.a > .b > .c`.
    expect(getComputedStyle(target).backgroundColor).toBe('rgb(255, 0, 0)');

    style.remove();
    container.remove();
  });

  it('C3 :is(:is(.a, .b), :is(.c, .d)) matches any of four classes', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="a target" id="t1">A</div>
      <div class="b target" id="t2">B</div>
      <div class="c target" id="t3">C</div>
      <div class="d target" id="t4">D</div>
      <div class="e target" id="t5">E (no match)</div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .target { width: 60px; height: 30px; margin: 2px; background-color: red; display: inline-block; }
      :is(:is(.a, .b), :is(.c, .d)) { background-color: green; }
    `);

    await snapshot();
    expect(getComputedStyle(container.querySelector('#t1')!).backgroundColor).toBe(green);
    expect(getComputedStyle(container.querySelector('#t2')!).backgroundColor).toBe(green);
    expect(getComputedStyle(container.querySelector('#t3')!).backgroundColor).toBe(green);
    expect(getComputedStyle(container.querySelector('#t4')!).backgroundColor).toBe(green);
    expect(getComputedStyle(container.querySelector('#t5')!).backgroundColor).toBe('rgb(255, 0, 0)');

    style.remove();
    container.remove();
  });

  it('C4 Deeply nested :is() with ID selector', async () => {
    const target = document.createElement('div');
    target.id = 'target';
    target.className = 'a b c box';
    document.body.appendChild(target);

    const style = appendStyle(`
      .box { width: 100px; height: 50px; }
      .a.b.c.a.b.c { background-color: red; }
      :is(:is(:is(:is(#target)))) { background-color: green; }
    `);

    await snapshot();
    // :is(:is(:is(:is(#target)))) = 1,0,0
    // .a.b.c.a.b.c = 0,6,0
    // :is wins
    expect(getComputedStyle(target).backgroundColor).toBe(green);

    style.remove();
    target.remove();
  });

  it('C5 Mixed :is() and :where() nesting', async () => {
    const target = document.createElement('div');
    target.id = 'target';
    target.className = 'a box';
    document.body.appendChild(target);

    const style = appendStyle(`
      .box { width: 100px; height: 50px; }
      :is(.a, :where(#target, .b)) { background-color: green; }
      div { background-color: red; }
    `);

    await snapshot();
    // :is(.a, :where(#target, .b)) - highest is .a = 0,1,0
    // div = 0,0,1
    // :is wins
    expect(getComputedStyle(target).backgroundColor).toBe(green);

    style.remove();
    target.remove();
  });
});

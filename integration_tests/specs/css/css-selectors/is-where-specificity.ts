/**
 * CSS Selectors: :is() and :where() specificity behavior
 * Based on WPT: css/selectors/is-specificity.html
 *
 * Key behaviors:
 * - :is() uses the highest specificity among its arguments
 * - :where() always has zero specificity contribution
 * - Specificity is calculated at parse time, not match time
 */
describe('CSS Selectors: :is() specificity', () => {
  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('A1 :is() uses highest possible specificity', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="b c"></div>
      <div class="a d e"></div>
      <div class="q r"></div>
      <div class="p s t"></div>
      <div id="target"></div>
    `;
    document.body.appendChild(container);

    const target = container.querySelector('#target') as HTMLElement;
    const style = appendStyle(`
      .b.c + .d + .q.r + .s + #target {
        font-size: 10px;
        height: 10px;
        width: 10px;
      }
      :is(.a, .b.c + .d, .q) + :is(* + .p, .q.r + .s, * + .t) + #target {
        height: 20px;
        width: 20px;
      }
      .b.c + .d + .q.r + .s + #target {
        width: 30px;
      }
    `);

    await snapshot();
    expect(getComputedStyle(target).width).toBe('30px');
    expect(getComputedStyle(target).height).toBe('20px');
    expect(getComputedStyle(target).fontSize).toBe('10px');

    style.remove();
    container.remove();
  });

  it('A2 :is() with ID selector has highest specificity', async () => {
    const target = document.createElement('div');
    target.id = 'target';
    target.className = 'box item special';
    document.body.appendChild(target);

    const style = appendStyle(`
      .box { width: 100px; height: 50px; }
      .box.item.special { background-color: red; }
      :is(#target, .box) { background-color: green; }
    `);

    await snapshot();
    // :is(#target, .box) = 1,0,0 (ID specificity)
    // .box.item.special = 0,3,0
    // :is wins because 1,0,0 > 0,3,0
    expect(getComputedStyle(target).backgroundColor).toBe('rgb(0, 128, 0)');

    style.remove();
    target.remove();
  });

  it('A3 :is() specificity applies even when matching lower-specificity argument', async () => {
    const target = document.createElement('div');
    target.className = 'box';
    document.body.appendChild(target);

    const style = appendStyle(`
      .box { width: 100px; height: 50px; }
      div.box { background-color: red; }
      :is(.box, #nonexistent) { background-color: green; }
    `);

    await snapshot();
    // :is(.box, #nonexistent) = 1,0,0 (takes ID specificity even when .box matches)
    // div.box = 0,1,1
    // :is wins
    expect(getComputedStyle(target).backgroundColor).toBe('rgb(0, 128, 0)');

    style.remove();
    target.remove();
  });

  it('A4 Multiple :is() selectors accumulate specificity', async () => {
    const target = document.createElement('div');
    target.id = 'target';
    target.className = 'a b';
    document.body.appendChild(target);

    const style = appendStyle(`
      #target { width: 100px; height: 50px; }
      :is(.a):is(.b) { background-color: red; }
      :is(#target) { background-color: green; }
    `);

    await snapshot();
    // :is(.a):is(.b) = 0,2,0
    // :is(#target) = 1,0,0
    // :is(#target) wins
    expect(getComputedStyle(target).backgroundColor).toBe('rgb(0, 128, 0)');

    style.remove();
    target.remove();
  });

  it('A5 :is() with compound selectors takes highest', async () => {
    const target = document.createElement('div');
    target.id = 'x';
    target.className = 'a b c';
    document.body.appendChild(target);

    const style = appendStyle(`
      .a.b.c { width: 100px; height: 50px; }
      :is(.a.b, #x, .c) { background-color: green; }
      .a.b.c.a.b { background-color: red; }
    `);

    await snapshot();
    // :is(.a.b, #x, .c) = 1,0,0 (highest is #x)
    // .a.b.c.a.b = 0,5,0
    // :is wins
    expect(getComputedStyle(target).backgroundColor).toBe('rgb(0, 128, 0)');

    style.remove();
    target.remove();
  });
});

describe('CSS Selectors: :where() zero specificity', () => {
  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('B1 :where(#id) has zero specificity', async () => {
    const target = document.createElement('div');
    target.id = 'target';
    document.body.appendChild(target);

    const style = appendStyle(`
      div { width: 100px; height: 50px; background-color: green; }
      :where(#target) { background-color: red; }
    `);

    await snapshot();
    // :where(#target) = 0,0,0
    // div = 0,0,1
    // div wins
    expect(getComputedStyle(target).backgroundColor).toBe('rgb(0, 128, 0)');

    style.remove();
    target.remove();
  });

  it('B2 :where(.class) has zero specificity', async () => {
    const target = document.createElement('div');
    target.className = 'target';
    document.body.appendChild(target);

    const style = appendStyle(`
      div { width: 100px; height: 50px; background-color: green; }
      :where(.target) { background-color: red; }
    `);

    await snapshot();
    // :where(.target) = 0,0,0
    // div = 0,0,1
    // div wins
    expect(getComputedStyle(target).backgroundColor).toBe('rgb(0, 128, 0)');

    style.remove();
    target.remove();
  });

  it('B3 :where() inside compound has zero contribution', async () => {
    const target = document.createElement('div');
    target.id = 'target';
    target.className = 'box';
    document.body.appendChild(target);

    const style = appendStyle(`
      div { width: 100px; height: 50px; }
      div:where(#target) { background-color: red; }
      .box { background-color: green; }
    `);

    await snapshot();
    // div:where(#target) = 0,0,1 (only div counts, :where contributes nothing)
    // .box = 0,1,0
    // .box wins
    expect(getComputedStyle(target).backgroundColor).toBe('rgb(0, 128, 0)');

    style.remove();
    target.remove();
  });

  it('B4 :where() with multiple arguments still zero specificity', async () => {
    const target = document.createElement('div');
    target.id = 'target';
    target.className = 'a b c';
    document.body.appendChild(target);

    const style = appendStyle(`
      div { width: 100px; height: 50px; background-color: green; }
      :where(#target, .a.b.c, div.a.b.c) { background-color: red; }
    `);

    await snapshot();
    // :where(#target, .a.b.c, div.a.b.c) = 0,0,0
    // div = 0,0,1
    // div wins
    expect(getComputedStyle(target).backgroundColor).toBe('rgb(0, 128, 0)');

    style.remove();
    target.remove();
  });

  it('B5 :where() nested in :is() only :where() part is zero', async () => {
    // `.box :where(#target)` requires that `#target` is a descendant of a
    // `.box` element; `#target` being `.box` itself is not sufficient.
    const container = document.createElement('div');
    container.className = 'box';
    const target = document.createElement('div');
    target.id = 'target';
    container.appendChild(target);
    document.body.appendChild(container);

    const style = appendStyle(`
      .box { width: 100px; height: 50px; }
      #target { width: 100%; height: 100%; }
      :is(.box :where(#target)) { background-color: green; }
      div { background-color: red; }
    `);

    await snapshot();
    // :is(.box :where(#target)) = 0,1,0 (.box contributes, :where(#target) = 0)
    // div = 0,0,1
    // :is wins
    expect(getComputedStyle(target).backgroundColor).toBe('rgb(0, 128, 0)');

    style.remove();
    container.remove();
  });

  it('B6 Nested :where() remains zero specificity', async () => {
    const target = document.createElement('div');
    target.id = 'target';
    target.className = 'box';
    document.body.appendChild(target);

    const style = appendStyle(`
      div { width: 100px; height: 50px; background-color: green; }
      :where(:where(#target)) { background-color: red; }
    `);

    await snapshot();
    // :where(:where(#target)) = 0,0,0
    // div = 0,0,1
    // div wins
    expect(getComputedStyle(target).backgroundColor).toBe('rgb(0, 128, 0)');

    style.remove();
    target.remove();
  });
});

describe('CSS Selectors: :is() vs :where() comparison', () => {
  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('C1 :is() beats :where() with same arguments', async () => {
    const target = document.createElement('div');
    target.id = 'target';
    document.body.appendChild(target);

    const style = appendStyle(`
      #target { width: 100px; height: 50px; }
      :where(#target) { background-color: red; }
      :is(#target) { background-color: green; }
    `);

    await snapshot();
    // :where(#target) = 0,0,0
    // :is(#target) = 1,0,0
    // :is wins
    expect(getComputedStyle(target).backgroundColor).toBe('rgb(0, 128, 0)');

    style.remove();
    target.remove();
  });

  it('C2 :where() wins by source order when same specificity', async () => {
    const target = document.createElement('div');
    target.id = 'target';
    document.body.appendChild(target);

    const style = appendStyle(`
      #target { width: 100px; height: 50px; }
      :where(#target) { background-color: red; }
      :where(#target) { background-color: green; }
    `);

    await snapshot();
    // Both have 0,0,0 specificity, last one wins
    expect(getComputedStyle(target).backgroundColor).toBe('rgb(0, 128, 0)');

    style.remove();
    target.remove();
  });

  it('C3 :is() in later rule wins when same specificity as earlier :is()', async () => {
    const target = document.createElement('div');
    target.id = 'target';
    target.className = 'box';
    document.body.appendChild(target);

    const style = appendStyle(`
      #target { width: 100px; height: 50px; }
      :is(#target) { background-color: red; }
      :is(#target) { background-color: green; }
    `);

    await snapshot();
    // Both have 1,0,0 specificity, last one wins
    expect(getComputedStyle(target).backgroundColor).toBe('rgb(0, 128, 0)');

    style.remove();
    target.remove();
  });

  it('C4 :where() with class loses to element type', async () => {
    const target = document.createElement('div');
    target.className = 'target';
    document.body.appendChild(target);

    const style = appendStyle(`
      .target { width: 100px; height: 50px; }
      :where(.target.target.target) { background-color: red; }
      div { background-color: green; }
    `);

    await snapshot();
    // :where(.target.target.target) = 0,0,0
    // div = 0,0,1
    // div wins
    expect(getComputedStyle(target).backgroundColor).toBe('rgb(0, 128, 0)');

    style.remove();
    target.remove();
  });
});

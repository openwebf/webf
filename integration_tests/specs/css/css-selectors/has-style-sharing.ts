/**
 * CSS Selectors: :has() style sharing optimization tests
 * Based on WPT: css/selectors/has-style-sharing-*.html
 *
 * Key behaviors:
 * - Style sharing optimizations should not interfere with :has() matching
 * - Elements that appear identical should still match correctly when :has() conditions differ
 * - Works with child combinator (>), pseudo-classes, and various selectors
 */
describe('CSS Selectors: :has() style sharing - basic', () => {
  const green = 'rgb(0, 128, 0)';
  const blue = 'rgb(0, 0, 255)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('A1 Style sharing with :has(> span) - first div has span, second does not', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="parent"><span></span></div>
      <div class="parent"></div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent {
        background: blue;
        padding: 10px;
        margin: 5px;
        width: 80px;
        height: 30px;
      }
      .parent:has(> span) {
        background: green;
      }
      span {
        display: inline-block;
        width: 10px;
        height: 10px;
        background-color: pink;
      }
    `);

    const parents = container.querySelectorAll('.parent');
    // First has span child -> green
    expect(getComputedStyle(parents[0]).backgroundColor).toBe(green);
    // Second has no span -> blue
    expect(getComputedStyle(parents[1]).backgroundColor).toBe(blue);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('A2 Style sharing with :has(span) descendant - nested structure', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="parent">
        <div class="inner"><span></span></div>
      </div>
      <div class="parent">
        <div class="inner"></div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent {
        background: blue;
        padding: 10px;
        margin: 5px;
        width: 80px;
      }
      .parent:has(span) {
        background: green;
      }
      span {
        display: inline-block;
        width: 10px;
        height: 10px;
        background-color: pink;
      }
    `);

    const parents = container.querySelectorAll('.parent');
    // First has span descendant -> green
    expect(getComputedStyle(parents[0]).backgroundColor).toBe(green);
    // Second has no span -> blue
    expect(getComputedStyle(parents[1]).backgroundColor).toBe(blue);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('A3 Style sharing with multiple identical elements', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="box"><span class="marker"></span></div>
      <div class="box"></div>
      <div class="box"><span class="marker"></span></div>
      <div class="box"></div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .box {
        background: blue;
        padding: 5px;
        margin: 3px;
        width: 60px;
        height: 20px;
      }
      .box:has(.marker) {
        background: green;
      }
      .marker {
        display: inline-block;
        width: 8px;
        height: 8px;
        background: pink;
      }
    `);

    const boxes = container.querySelectorAll('.box');
    expect(getComputedStyle(boxes[0]).backgroundColor).toBe(green);
    expect(getComputedStyle(boxes[1]).backgroundColor).toBe(blue);
    expect(getComputedStyle(boxes[2]).backgroundColor).toBe(green);
    expect(getComputedStyle(boxes[3]).backgroundColor).toBe(blue);

    await snapshot();

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: :has() style sharing - with child combinator', () => {
  const green = 'rgb(0, 128, 0)';
  const blue = 'rgb(0, 0, 255)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('B1 :has(> .direct) only matches direct children', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="parent">
        <span class="direct"></span>
      </div>
      <div class="parent">
        <div><span class="direct"></span></div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent {
        background: blue;
        padding: 10px;
        margin: 5px;
        width: 80px;
        height: 30px;
      }
      .parent:has(> .direct) {
        background: green;
      }
    `);

    const parents = container.querySelectorAll('.parent');
    // First has direct .direct child -> green
    expect(getComputedStyle(parents[0]).backgroundColor).toBe(green);
    // Second has .direct as grandchild -> blue
    expect(getComputedStyle(parents[1]).backgroundColor).toBe(blue);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('B2 :has(> div > span) matches specific nesting', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="parent">
        <div><span></span></div>
      </div>
      <div class="parent">
        <span></span>
      </div>
      <div class="parent">
        <div><div><span></span></div></div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent {
        background: blue;
        padding: 10px;
        margin: 5px;
        width: 80px;
        height: 30px;
      }
      .parent:has(> div > span) {
        background: green;
      }
    `);

    const parents = container.querySelectorAll('.parent');
    // First: div > span pattern -> green
    expect(getComputedStyle(parents[0]).backgroundColor).toBe(green);
    // Second: direct span, no div -> blue
    expect(getComputedStyle(parents[1]).backgroundColor).toBe(blue);
    // Third: div > div > span, extra nesting -> blue
    expect(getComputedStyle(parents[2]).backgroundColor).toBe(blue);

    await snapshot();

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: :has() style sharing - with pseudo-classes', () => {
  const green = 'rgb(0, 128, 0)';
  const blue = 'rgb(0, 0, 255)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('C1 :has() with :first-child pseudo', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="parent">
        <span class="target"></span>
        <span></span>
      </div>
      <div class="parent">
        <span></span>
        <span class="target"></span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent {
        background: blue;
        padding: 10px;
        margin: 5px;
        width: 80px;
        height: 30px;
      }
      .parent:has(.target:first-child) {
        background: green;
      }
    `);

    const parents = container.querySelectorAll('.parent');
    // First: .target is first-child -> green
    expect(getComputedStyle(parents[0]).backgroundColor).toBe(green);
    // Second: .target is not first-child -> blue
    expect(getComputedStyle(parents[1]).backgroundColor).toBe(blue);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('C2 :has() with :last-child pseudo', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="parent">
        <span></span>
        <span class="target"></span>
      </div>
      <div class="parent">
        <span class="target"></span>
        <span></span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent {
        background: blue;
        padding: 10px;
        margin: 5px;
        width: 80px;
        height: 30px;
      }
      .parent:has(.target:last-child) {
        background: green;
      }
    `);

    const parents = container.querySelectorAll('.parent');
    // First: .target is last-child -> green
    expect(getComputedStyle(parents[0]).backgroundColor).toBe(green);
    // Second: .target is not last-child -> blue
    expect(getComputedStyle(parents[1]).backgroundColor).toBe(blue);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('C3 :has() with :nth-child pseudo', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="parent">
        <span></span>
        <span class="target"></span>
        <span></span>
      </div>
      <div class="parent">
        <span class="target"></span>
        <span></span>
        <span></span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent {
        background: blue;
        padding: 10px;
        margin: 5px;
        width: 80px;
        height: 30px;
      }
      .parent:has(.target:nth-child(2)) {
        background: green;
      }
    `);

    const parents = container.querySelectorAll('.parent');
    // First: .target is 2nd child -> green
    expect(getComputedStyle(parents[0]).backgroundColor).toBe(green);
    // Second: .target is 1st child -> blue
    expect(getComputedStyle(parents[1]).backgroundColor).toBe(blue);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('C4 :has() with :only-child pseudo', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="parent">
        <span class="target"></span>
      </div>
      <div class="parent">
        <span class="target"></span>
        <span></span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent {
        background: blue;
        padding: 10px;
        margin: 5px;
        width: 80px;
        height: 30px;
      }
      .parent:has(.target:only-child) {
        background: green;
      }
    `);

    const parents = container.querySelectorAll('.parent');
    // First: .target is only-child -> green
    expect(getComputedStyle(parents[0]).backgroundColor).toBe(green);
    // Second: .target has sibling -> blue
    expect(getComputedStyle(parents[1]).backgroundColor).toBe(blue);

    await snapshot();

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: :has() style sharing - with sibling combinators', () => {
  const green = 'rgb(0, 128, 0)';
  const blue = 'rgb(0, 0, 255)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('D1 :has(+ .sibling) adjacent sibling', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="parent">
        <span class="item"></span>
        <span class="sibling"></span>
      </div>
      <div class="parent">
        <span class="item"></span>
        <span></span>
        <span class="sibling"></span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent {
        background: blue;
        padding: 10px;
        margin: 5px;
        width: 80px;
        height: 30px;
      }
      .parent:has(.item + .sibling) {
        background: green;
      }
    `);

    const parents = container.querySelectorAll('.parent');
    // First: .item + .sibling exists -> green
    expect(getComputedStyle(parents[0]).backgroundColor).toBe(green);
    // Second: .sibling is not adjacent to .item -> blue
    expect(getComputedStyle(parents[1]).backgroundColor).toBe(blue);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('D2 :has(~ .sibling) general sibling', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="parent">
        <span class="item"></span>
        <span></span>
        <span class="sibling"></span>
      </div>
      <div class="parent">
        <span class="sibling"></span>
        <span class="item"></span>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent {
        background: blue;
        padding: 10px;
        margin: 5px;
        width: 80px;
        height: 30px;
      }
      .parent:has(.item ~ .sibling) {
        background: green;
      }
    `);

    const parents = container.querySelectorAll('.parent');
    // First: .sibling follows .item -> green
    expect(getComputedStyle(parents[0]).backgroundColor).toBe(green);
    // Second: .sibling precedes .item -> blue
    expect(getComputedStyle(parents[1]).backgroundColor).toBe(blue);

    await snapshot();

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: :has() style sharing - complex scenarios', () => {
  const green = 'rgb(0, 128, 0)';
  const blue = 'rgb(0, 0, 255)';
  const red = 'rgb(255, 0, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('E1 Multiple :has() rules with different conditions', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="box"><span class="a"></span></div>
      <div class="box"><span class="b"></span></div>
      <div class="box"><span class="a"></span><span class="b"></span></div>
      <div class="box"></div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .box {
        background: blue;
        padding: 5px;
        margin: 3px;
        width: 60px;
        height: 20px;
      }
      .box:has(.a) {
        background: green;
      }
      .box:has(.b) {
        background: red;
      }
    `);

    const boxes = container.querySelectorAll('.box');
    // Has only .a -> green (first rule)
    expect(getComputedStyle(boxes[0]).backgroundColor).toBe(green);
    // Has only .b -> red (second rule overrides)
    expect(getComputedStyle(boxes[1]).backgroundColor).toBe(red);
    // Has both -> red (second rule wins due to cascade)
    expect(getComputedStyle(boxes[2]).backgroundColor).toBe(red);
    // Has neither -> blue
    expect(getComputedStyle(boxes[3]).backgroundColor).toBe(blue);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('E2 Deeply nested :has() matching', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="outer">
        <div class="middle">
          <div class="inner">
            <span class="deep"></span>
          </div>
        </div>
      </div>
      <div class="outer">
        <div class="middle">
          <div class="inner"></div>
        </div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .outer {
        background: blue;
        padding: 10px;
        margin: 5px;
        width: 100px;
      }
      .outer:has(.deep) {
        background: green;
      }
    `);

    const outers = container.querySelectorAll('.outer');
    // First has deeply nested .deep -> green
    expect(getComputedStyle(outers[0]).backgroundColor).toBe(green);
    // Second has no .deep -> blue
    expect(getComputedStyle(outers[1]).backgroundColor).toBe(blue);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('E3 :has() with attribute selectors', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="parent">
        <input type="text" data-valid="true">
      </div>
      <div class="parent">
        <input type="text">
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent {
        background: blue;
        padding: 10px;
        margin: 5px;
        width: 80px;
        height: 30px;
      }
      .parent:has([data-valid]) {
        background: green;
      }
    `);

    const parents = container.querySelectorAll('.parent');
    // First has input with data-valid -> green
    expect(getComputedStyle(parents[0]).backgroundColor).toBe(green);
    // Second has input without data-valid -> blue
    expect(getComputedStyle(parents[1]).backgroundColor).toBe(blue);

    await snapshot();

    style.remove();
    container.remove();
  });
});

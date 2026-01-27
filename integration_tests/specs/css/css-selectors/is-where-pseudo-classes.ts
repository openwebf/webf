/**
 * CSS Selectors: :is() and :where() combined with pseudo-classes
 * Based on WPT: css/selectors/is-where-pseudo-classes.html
 *
 * Key behaviors:
 * - :is() and :where() work correctly with pseudo-classes like :enabled, :disabled
 * - :is() and :where() work with structural pseudo-classes like :nth-child()
 * - Combined selectors match elements that satisfy both conditions
 */
describe('CSS Selectors: :is()/:where() with :enabled/:disabled', () => {
  const green = 'rgb(0, 128, 0)';
  const blue = 'rgb(0, 0, 255)';
  const black = 'rgb(0, 0, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('A1 :is() with :enabled matches enabled buttons', async () => {
    const container = document.createElement('main');
    container.innerHTML = `
      <button id="a">A</button>
      <button id="b">B</button>
      <button id="c">C</button>
      <button id="d" disabled>D</button>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      button { color: black; width: 40px; height: 30px; margin: 4px; }
      :is(#a, #c):is(:enabled) { color: green; }
    `);

    await snapshot();
    expect(getComputedStyle(container.querySelector('#a')!).color).toBe(green);
    expect(getComputedStyle(container.querySelector('#b')!).color).toBe(black);
    expect(getComputedStyle(container.querySelector('#c')!).color).toBe(green);
    expect(getComputedStyle(container.querySelector('#d')!).color).toBe(black);

    style.remove();
    container.remove();
  });

  it('A2 :is() with :disabled matches disabled buttons', async () => {
    const container = document.createElement('main');
    container.innerHTML = `
      <button id="a">A</button>
      <button id="b" disabled>B</button>
      <button id="c" disabled>C</button>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      button { color: black; width: 40px; height: 30px; margin: 4px; }
      :is(#b, #c):is(:disabled) { color: green; }
    `);

    await snapshot();
    expect(getComputedStyle(container.querySelector('#a')!).color).toBe(black);
    expect(getComputedStyle(container.querySelector('#b')!).color).toBe(green);
    expect(getComputedStyle(container.querySelector('#c')!).color).toBe(green);

    style.remove();
    container.remove();
  });

  it('A3 :where() with :enabled has zero specificity contribution', async () => {
    const container = document.createElement('main');
    container.innerHTML = `
      <button id="a">A</button>
      <button id="b" disabled>B</button>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      button { width: 40px; height: 30px; margin: 4px; }
      :where(#a):where(:enabled) { color: red; }
      button { color: green; }
    `);

    await snapshot();
    // :where(#a):where(:enabled) = 0,0,0
    // button = 0,0,1
    // button wins
    expect(getComputedStyle(container.querySelector('#a')!).color).toBe(green);

    style.remove();
    container.remove();
  });

  it('A4 Combined :is() with multiple pseudo-class states', async () => {
    const container = document.createElement('main');
    container.innerHTML = `
      <button id="a">A</button>
      <button id="b">B</button>
      <button id="c" disabled>C</button>
      <button id="d" disabled>D</button>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      button { color: black; width: 40px; height: 30px; margin: 4px; }
      button:is(:enabled, :disabled) { color: green; }
    `);

    await snapshot();
    // All buttons match either :enabled or :disabled
    expect(getComputedStyle(container.querySelector('#a')!).color).toBe(green);
    expect(getComputedStyle(container.querySelector('#b')!).color).toBe(green);
    expect(getComputedStyle(container.querySelector('#c')!).color).toBe(green);
    expect(getComputedStyle(container.querySelector('#d')!).color).toBe(green);

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: :is()/:where() with :nth-child()', () => {
  const green = 'rgb(0, 128, 0)';
  const blue = 'rgb(0, 0, 255)';
  const black = 'rgb(0, 0, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('B1 :is() with :nth-child(odd)', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="item" id="i1">1</div>
      <div class="item" id="i2">2</div>
      <div class="item" id="i3">3</div>
      <div class="item" id="i4">4</div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .item { color: black; width: 40px; height: 30px; margin: 4px; }
      :is(.item):is(:nth-child(odd)) { color: green; }
    `);

    await snapshot();
    expect(getComputedStyle(container.querySelector('#i1')!).color).toBe(green);
    expect(getComputedStyle(container.querySelector('#i2')!).color).toBe(black);
    expect(getComputedStyle(container.querySelector('#i3')!).color).toBe(green);
    expect(getComputedStyle(container.querySelector('#i4')!).color).toBe(black);

    style.remove();
    container.remove();
  });

  it('B2 :is() with :nth-child(even)', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="item" id="i1">1</div>
      <div class="item" id="i2">2</div>
      <div class="item" id="i3">3</div>
      <div class="item" id="i4">4</div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .item { color: black; width: 40px; height: 30px; margin: 4px; }
      :is(.item):is(:nth-child(even)) { color: green; }
    `);

    await snapshot();
    expect(getComputedStyle(container.querySelector('#i1')!).color).toBe(black);
    expect(getComputedStyle(container.querySelector('#i2')!).color).toBe(green);
    expect(getComputedStyle(container.querySelector('#i3')!).color).toBe(black);
    expect(getComputedStyle(container.querySelector('#i4')!).color).toBe(green);

    style.remove();
    container.remove();
  });

  it('B3 :where() with :nth-child has zero specificity', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="item" id="i1">1</div>
      <div class="item" id="i2">2</div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .item { width: 40px; height: 30px; margin: 4px; }
      :where(.item):where(:nth-child(1)) { color: red; }
      div { color: green; }
    `);

    await snapshot();
    // :where specificity = 0,0,0
    // div = 0,0,1
    // div wins
    expect(getComputedStyle(container.querySelector('#i1')!).color).toBe(green);

    style.remove();
    container.remove();
  });

  it('B4 :is() with :first-child', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="item" id="i1">First</div>
      <div class="item" id="i2">Second</div>
      <div class="item" id="i3">Third</div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .item { color: black; width: 60px; height: 30px; margin: 4px; }
      :is(.item):is(:first-child) { color: green; }
    `);

    await snapshot();
    expect(getComputedStyle(container.querySelector('#i1')!).color).toBe(green);
    expect(getComputedStyle(container.querySelector('#i2')!).color).toBe(black);
    expect(getComputedStyle(container.querySelector('#i3')!).color).toBe(black);

    style.remove();
    container.remove();
  });

  it('B5 :is() with :last-child', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="item" id="i1">First</div>
      <div class="item" id="i2">Second</div>
      <div class="item" id="i3">Last</div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .item { color: black; width: 60px; height: 30px; margin: 4px; }
      :is(.item):is(:last-child) { color: green; }
    `);

    await snapshot();
    expect(getComputedStyle(container.querySelector('#i1')!).color).toBe(black);
    expect(getComputedStyle(container.querySelector('#i2')!).color).toBe(black);
    expect(getComputedStyle(container.querySelector('#i3')!).color).toBe(green);

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: :is()/:where() with :only-child', () => {
  const green = 'rgb(0, 128, 0)';
  const black = 'rgb(0, 0, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('C1 :is() with :only-child matches single child', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="parent" id="p1">
        <div class="child" id="c1">Only child</div>
      </div>
      <div class="parent" id="p2">
        <div class="child" id="c2">First</div>
        <div class="child" id="c3">Second</div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .child { color: black; width: 80px; height: 30px; margin: 4px; }
      :is(.child):is(:only-child) { color: green; }
    `);

    await snapshot();
    expect(getComputedStyle(container.querySelector('#c1')!).color).toBe(green);
    expect(getComputedStyle(container.querySelector('#c2')!).color).toBe(black);
    expect(getComputedStyle(container.querySelector('#c3')!).color).toBe(black);

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: :is()/:where() with :empty', () => {
  const green = 'rgb(0, 128, 0)';
  const black = 'rgb(0, 0, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('D1 :is() with :empty matches empty elements', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div class="box" id="b1"></div>
      <div class="box" id="b2">Has content</div>
      <div class="box" id="b3"></div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .box { background-color: black; width: 80px; height: 30px; margin: 4px; }
      :is(.box):is(:empty) { background-color: green; }
    `);

    await snapshot();
    expect(getComputedStyle(container.querySelector('#b1')!).backgroundColor).toBe(green);
    expect(getComputedStyle(container.querySelector('#b2')!).backgroundColor).toBe(black);
    expect(getComputedStyle(container.querySelector('#b3')!).backgroundColor).toBe(green);

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: Complex :is()/:where() with pseudo-classes', () => {
  const green = 'rgb(0, 128, 0)';
  const blue = 'rgb(0, 0, 255)';
  const black = 'rgb(0, 0, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('E1 Complex :is() with main and :where() and :enabled', async () => {
    const container = document.createElement('main');
    container.innerHTML = `
      <button id="a">A</button>
      <button id="b">B</button>
      <button id="c">C</button>
      <button id="d" disabled>D</button>
      <button id="e" disabled>E</button>
      <button id="f" disabled>F</button>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      button { color: black; width: 30px; height: 25px; margin: 2px; }
      :is(main :where(main #a), #c:nth-child(odd), #d):is(:enabled) { color: green; }
      button:is(:nth-child(even), span #e):is(:enabled, :where(:disabled)) { color: blue; }
    `);

    await snapshot();
    expect(getComputedStyle(container.querySelector('#a')!).color).toBe(green);
    expect(getComputedStyle(container.querySelector('#b')!).color).toBe(blue);
    expect(getComputedStyle(container.querySelector('#c')!).color).toBe(green);
    expect(getComputedStyle(container.querySelector('#d')!).color).toBe(blue);
    expect(getComputedStyle(container.querySelector('#e')!).color).toBe(black);
    expect(getComputedStyle(container.querySelector('#f')!).color).toBe(blue);

    style.remove();
    container.remove();
  });

  it('E2 :is() combining structural and state pseudo-classes', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <input type="text" id="i1" value="First" />
      <input type="text" id="i2" value="Second" disabled />
      <input type="text" id="i3" value="Third" />
      <input type="text" id="i4" value="Fourth" disabled />
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      input { color: black; width: 80px; height: 25px; margin: 4px; }
      :is(input):is(:nth-child(odd)):is(:enabled) { color: green; }
    `);

    await snapshot();
    expect(getComputedStyle(container.querySelector('#i1')!).color).toBe(green);
    expect(getComputedStyle(container.querySelector('#i2')!).color).toBe(black);
    expect(getComputedStyle(container.querySelector('#i3')!).color).toBe(green);
    expect(getComputedStyle(container.querySelector('#i4')!).color).toBe(black);

    style.remove();
    container.remove();
  });
});

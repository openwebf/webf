/**
 * CSS Selectors: :has() invalidation tests
 * Based on WPT: css/selectors/invalidation/has-*.html
 *
 * Key behaviors:
 * - Style invalidation triggers correctly when DOM changes
 * - Class/attribute changes update :has() matching
 * - Element insertion/removal triggers re-evaluation
 * - Works with various combinator positions
 */
describe('CSS Selectors: :has() invalidation - class changes', () => {
  const grey = 'rgb(128, 128, 128)';
  const green = 'rgb(0, 128, 0)';
  const red = 'rgb(255, 0, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('A1 Adding class triggers :has() match', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="subject" class="parent">
        <div id="child"></div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { color: grey; width: 80px; height: 30px; background: grey; }
      .parent:has(.target) { color: green; background: green; }
    `);

    const subject = container.querySelector('#subject')!;
    const child = container.querySelector('#child')!;

    // Initial: no .target class
    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    // Add .target class
    child.classList.add('target');
    expect(getComputedStyle(subject).backgroundColor).toBe(green);

    await snapshot();

    // Remove .target class
    child.classList.remove('target');
    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    style.remove();
    container.remove();
  });

  it('A2 Class change on nested element triggers invalidation', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="subject" class="parent">
        <div class="middle">
          <div id="deep"></div>
        </div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { color: grey; width: 80px; height: 30px; background: grey; }
      .parent:has(.target) { background: green; }
    `);

    const subject = container.querySelector('#subject')!;
    const deep = container.querySelector('#deep')!;

    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    deep.classList.add('target');
    expect(getComputedStyle(subject).backgroundColor).toBe(green);

    await snapshot();

    deep.classList.remove('target');
    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    style.remove();
    container.remove();
  });

  it('A3 Multiple class toggles maintain correct state', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="subject" class="parent">
        <div id="child1"></div>
        <div id="child2"></div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; background: grey; }
      .parent:has(.target) { background: green; }
    `);

    const subject = container.querySelector('#subject')!;
    const child1 = container.querySelector('#child1')!;
    const child2 = container.querySelector('#child2')!;
    const grey = 'rgb(128, 128, 128)';
    const green = 'rgb(0, 128, 0)';

    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    child1.classList.add('target');
    expect(getComputedStyle(subject).backgroundColor).toBe(green);

    child2.classList.add('target');
    expect(getComputedStyle(subject).backgroundColor).toBe(green);

    child1.classList.remove('target');
    // Still has child2 with .target
    expect(getComputedStyle(subject).backgroundColor).toBe(green);

    child2.classList.remove('target');
    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    await snapshot();

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: :has() invalidation - element insertion', () => {
  const grey = 'rgb(128, 128, 128)';
  const green = 'rgb(0, 128, 0)';
  const red = 'rgb(255, 0, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('B1 Inserting element triggers :has() match', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="subject" class="parent"></div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; background: grey; }
      .parent:has(.target) { background: green; }
    `);

    const subject = container.querySelector('#subject')!;

    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    // Insert element with .target
    const newElement = document.createElement('div');
    newElement.classList.add('target');
    subject.appendChild(newElement);

    expect(getComputedStyle(subject).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('B2 Removing element triggers :has() unmatch', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="subject" class="parent">
        <div id="target" class="target"></div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; background: grey; }
      .parent:has(.target) { background: green; }
    `);

    const subject = container.querySelector('#subject')!;
    const target = container.querySelector('#target')!;
    const green = 'rgb(0, 128, 0)';
    const grey = 'rgb(128, 128, 128)';

    expect(getComputedStyle(subject).backgroundColor).toBe(green);

    // Remove target element
    target.remove();

    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('B3 Insert before triggers :has(+ sibling) match', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="parent">
        <div id="subject"></div>
        <div id="sibling2"></div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      #parent div { width: 50px; height: 20px; background: grey; margin: 2px; }
      #subject:has(+ #sibling1 + #sibling2) { background: red; }
    `);

    const subject = container.querySelector('#subject')!;
    const sibling2 = container.querySelector('#sibling2')!;
    const grey = 'rgb(128, 128, 128)';
    const red = 'rgb(255, 0, 0)';

    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    // Insert sibling1 before sibling2
    const sibling1 = document.createElement('div');
    sibling1.id = 'sibling1';
    sibling2.before(sibling1);

    expect(getComputedStyle(subject).backgroundColor).toBe(red);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('B4 Remove sibling triggers :has(+) unmatch', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="parent">
        <div id="subject"></div>
        <div id="sibling1"></div>
        <div id="sibling2" class="target"></div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      #parent div { width: 50px; height: 20px; background: grey; margin: 2px; }
      #subject:has(+ .target) { background: green; }
    `);

    const subject = container.querySelector('#subject')!;
    const sibling1 = container.querySelector('#sibling1')!;
    const grey = 'rgb(128, 128, 128)';
    const green = 'rgb(0, 128, 0)';

    // Initially sibling1 is between subject and .target
    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    // Remove sibling1, now .target is adjacent
    sibling1.remove();

    expect(getComputedStyle(subject).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: :has() invalidation - attribute changes', () => {
  const grey = 'rgb(128, 128, 128)';
  const green = 'rgb(0, 128, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('C1 Adding attribute triggers :has([attr]) match', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="subject" class="parent">
        <div id="child"></div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; background: grey; }
      .parent:has([data-active]) { background: green; }
    `);

    const subject = container.querySelector('#subject')!;
    const child = container.querySelector('#child')!;

    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    child.setAttribute('data-active', 'true');
    expect(getComputedStyle(subject).backgroundColor).toBe(green);

    await snapshot();

    child.removeAttribute('data-active');
    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    style.remove();
    container.remove();
  });

  it('C2 Changing attribute value triggers invalidation', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="subject" class="parent">
        <div id="child" data-status="inactive"></div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; background: grey; }
      .parent:has([data-status="active"]) { background: green; }
    `);

    const subject = container.querySelector('#subject')!;
    const child = container.querySelector('#child')!;

    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    child.setAttribute('data-status', 'active');
    expect(getComputedStyle(subject).backgroundColor).toBe(green);

    await snapshot();

    child.setAttribute('data-status', 'inactive');
    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: :has() invalidation - form pseudo-classes', () => {
  const grey = 'rgb(128, 128, 128)';
  const green = 'rgb(0, 128, 0)';
  const red = 'rgb(255, 0, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('D1 :has(:checked) updates when checkbox toggled', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="subject" class="parent">
        <input type="checkbox" id="checkbox">
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; background: grey; }
      .parent:has(:checked) { background: green; }
    `);

    const subject = container.querySelector('#subject')!;
    const checkbox = container.querySelector('#checkbox') as HTMLInputElement;

    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    checkbox.checked = true;
    expect(getComputedStyle(subject).backgroundColor).toBe(green);

    await snapshot();

    checkbox.checked = false;
    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    style.remove();
    container.remove();
  });

  it('D2 :has(:disabled) updates when disabled toggled', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="subject" class="parent">
        <input type="text" id="input">
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; background: grey; }
      .parent:has(:disabled) { background: red; }
    `);

    const subject = container.querySelector('#subject')!;
    const input = container.querySelector('#input') as HTMLInputElement;

    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    input.disabled = true;
    expect(getComputedStyle(subject).backgroundColor).toBe(red);

    await snapshot();

    input.disabled = false;
    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    style.remove();
    container.remove();
  });

  it('D3 :not(:has(:enabled)) double negation', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="subject" class="parent">
        <input type="text" id="input">
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      .parent { width: 80px; height: 30px; background: grey; }
      .parent:not(:has(:enabled)) { background: green; }
    `);

    const subject = container.querySelector('#subject')!;
    const input = container.querySelector('#input') as HTMLInputElement;

    // Input is enabled, so :has(:enabled) matches, :not(:has(:enabled)) does not
    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    input.disabled = true;
    // Now input is disabled, :has(:enabled) does not match, :not(:has(:enabled)) matches
    expect(getComputedStyle(subject).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: :has() invalidation - sibling positions', () => {
  const grey = 'rgb(128, 128, 128)';
  const green = 'rgb(0, 128, 0)';
  const blue = 'rgb(0, 0, 255)';
  const yellow = 'rgb(255, 255, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('E1 :has(~ .sibling) invalidation on sibling class change', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="parent">
        <div id="subject"></div>
        <div id="s1"></div>
        <div id="s2"></div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      #parent div { width: 50px; height: 20px; background: grey; margin: 2px; }
      #subject:has(~ .target) { background: green; }
    `);

    const subject = container.querySelector('#subject')!;
    const s2 = container.querySelector('#s2')!;

    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    s2.classList.add('target');
    expect(getComputedStyle(subject).backgroundColor).toBe(green);

    await snapshot();

    s2.classList.remove('target');
    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    style.remove();
    container.remove();
  });

  it('E2 :has(+ .adjacent) only matches immediate sibling', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="parent">
        <div id="subject"></div>
        <div id="s1"></div>
        <div id="s2"></div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      #parent div { width: 50px; height: 20px; background: grey; margin: 2px; }
      #subject:has(+ .target) { background: green; }
    `);

    const subject = container.querySelector('#subject')!;
    const s1 = container.querySelector('#s1')!;
    const s2 = container.querySelector('#s2')!;

    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    // Adding .target to non-adjacent sibling should not match
    s2.classList.add('target');
    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    // Adding .target to adjacent sibling should match
    s1.classList.add('target');
    expect(getComputedStyle(subject).backgroundColor).toBe(green);

    await snapshot();

    style.remove();
    container.remove();
  });

  it('E3 Complex sibling chain invalidation', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="parent">
        <div id="subject"></div>
        <div id="s1"></div>
        <div id="s2"></div>
        <div id="s3"></div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      #parent div { width: 50px; height: 20px; background: grey; margin: 2px; }
      #subject:has(~ #s1 ~ #s2 ~ #s3) { background: green; }
    `);

    const subject = container.querySelector('#subject')!;
    const s2 = container.querySelector('#s2')!;

    expect(getComputedStyle(subject).backgroundColor).toBe(green);

    // Remove s2 to break the chain
    s2.remove();
    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    await snapshot();

    style.remove();
    container.remove();
  });
});

describe('CSS Selectors: :has() invalidation - ancestor position', () => {
  const grey = 'rgb(128, 128, 128)';
  const green = 'rgb(0, 128, 0)';
  const red = 'rgb(255, 0, 0)';

  function appendStyle(cssText: string) {
    const style = document.createElement('style');
    style.textContent = cssText;
    document.head.appendChild(style);
    return style;
  }

  it('F1 :has() in ancestor affects descendant styling', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="ancestor">
        <div id="parent">
          <div id="subject"></div>
        </div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      #subject { width: 50px; height: 20px; background: grey; }
      div:has(.target) #subject { background: red; }
      div:has(> .target) #subject { background: green; }
    `);

    const subject = container.querySelector('#subject')!;
    const parent = container.querySelector('#parent')!;

    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    // Add .target to parent (direct child of ancestor)
    parent.classList.add('target');
    // ancestor:has(> .target) matches, so green
    expect(getComputedStyle(subject).backgroundColor).toBe(green);

    await snapshot();

    parent.classList.remove('target');
    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    style.remove();
    container.remove();
  });

  it('F2 Deep descendant change affects ancestor :has()', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="ancestor">
        <div id="parent">
          <div id="child">
            <div id="deep"></div>
          </div>
        </div>
        <div id="subject"></div>
      </div>
    `;
    document.body.appendChild(container);

    const style = appendStyle(`
      #subject { width: 50px; height: 20px; background: grey; }
      #ancestor:has(.target) #subject { background: green; }
    `);

    const subject = container.querySelector('#subject')!;
    const deep = container.querySelector('#deep')!;

    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    deep.classList.add('target');
    expect(getComputedStyle(subject).backgroundColor).toBe(green);

    await snapshot();

    deep.classList.remove('target');
    expect(getComputedStyle(subject).backgroundColor).toBe(grey);

    style.remove();
    container.remove();
  });
});

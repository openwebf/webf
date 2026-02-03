/**
 * CSS Selectors: :has() with explicit :scope
 * Based on WPT: css/selectors/has-argument-with-explicit-scope.html
 *
 * Key behaviors:
 * - :scope within :has() refers to the element being queried from
 * - Descendants of scope cannot have scope as descendant
 * - :has(:scope) patterns have equivalent simpler forms
 */
describe('CSS Selectors: :has() with explicit :scope', () => {
  function formatElements(elements: Element[]) {
    return elements.map(e => e.id).sort().join(',');
  }

  function createTestDOM() {
    const main = document.createElement('main');
    main.innerHTML = `
      <div id="d01" class="a">
        <div id="scope1" class="b">
          <div id="d02" class="c">
            <div id="d03" class="c">
              <div id="d04" class="d"></div>
            </div>
          </div>
          <div id="d05" class="e"></div>
        </div>
      </div>
      <div id="d06">
        <div id="scope2" class="b">
          <div id="d07" class="c">
            <div id="d08" class="c">
              <div id="d09"></div>
            </div>
          </div>
        </div>
      </div>
    `;
    document.body.appendChild(main);
    return main;
  }

  // ========== :has(:scope) cannot match descendants ==========

  it('A1 :has(:scope) matches nothing - descendants cannot have scope as descendant', async () => {
    const main = createTestDOM();
    const scope1 = main.querySelector('#scope1')!;

    const actual = Array.from(scope1.querySelectorAll(':has(:scope)'));
    expect(formatElements(actual)).toBe('');

    await snapshot();

    main.remove();
  });

  it('A2 :has(:scope .c) matches nothing - scope cannot be descendant of descendants', async () => {
    const main = createTestDOM();
    const scope1 = main.querySelector('#scope1')!;

    const actual = Array.from(scope1.querySelectorAll(':has(:scope .c)'));
    expect(formatElements(actual)).toBe('');

    await snapshot();

    main.remove();
  });

  it('A3 :has(.a :scope) matches nothing - .a is ancestor of scope', async () => {
    const main = createTestDOM();
    const scope1 = main.querySelector('#scope1')!;

    const actual = Array.from(scope1.querySelectorAll(':has(.a :scope)'));
    expect(formatElements(actual)).toBe('');

    await snapshot();

    main.remove();
  });

  // ========== :has(:scope) with external context ==========

  it('B1 .a:has(:scope) .c matches descendants of .a when scoped inside', async () => {
    const main = createTestDOM();
    const scope1 = main.querySelector('#scope1')!;
    const d02 = main.querySelector('#d02')!;
    const d03 = main.querySelector('#d03')!;

    const actual = Array.from(scope1.querySelectorAll('.a:has(:scope) .c'));
    expect(formatElements(actual)).toBe('d02,d03');

    await snapshot();

    main.remove();
  });

  it('B2 .a:has(:scope) .c equivalent to :is(.a :scope .c)', async () => {
    const main = createTestDOM();
    const scope1 = main.querySelector('#scope1')!;

    const result1 = Array.from(scope1.querySelectorAll('.a:has(:scope) .c'));
    const result2 = Array.from(scope1.querySelectorAll(':is(.a :scope .c)'));
    expect(formatElements(result1)).toBe(formatElements(result2));

    await snapshot();

    main.remove();
  });

  it('B3 .a:has(:scope) .c returns empty when scope not inside .a', async () => {
    const main = createTestDOM();
    const scope2 = main.querySelector('#scope2')!;

    const actual = Array.from(scope2.querySelectorAll('.a:has(:scope) .c'));
    expect(formatElements(actual)).toBe('');

    await snapshot();

    main.remove();
  });

  // ========== :has(:is(:scope ...)) patterns ==========

  it('C1 .c:has(:is(:scope .d)) matches .c elements containing .d', async () => {
    const main = createTestDOM();
    const scope1 = main.querySelector('#scope1')!;
    const d02 = main.querySelector('#d02')!;
    const d03 = main.querySelector('#d03')!;

    const actual = Array.from(scope1.querySelectorAll('.c:has(:is(:scope .d))'));
    expect(formatElements(actual)).toBe('d02,d03');

    await snapshot();

    main.remove();
  });

  it('C2 .c:has(:is(:scope .d)) equivalent to :scope .c:has(.d)', async () => {
    const main = createTestDOM();
    const scope1 = main.querySelector('#scope1')!;

    const result1 = Array.from(scope1.querySelectorAll('.c:has(:is(:scope .d))'));
    const result2 = Array.from(scope1.querySelectorAll(':scope .c:has(.d)'));
    expect(formatElements(result1)).toBe(formatElements(result2));

    await snapshot();

    main.remove();
  });

  it('C3 .c:has(:is(:scope .d)) equivalent to .c:has(.d)', async () => {
    const main = createTestDOM();
    const scope1 = main.querySelector('#scope1')!;

    const result1 = Array.from(scope1.querySelectorAll('.c:has(:is(:scope .d))'));
    const result2 = Array.from(scope1.querySelectorAll('.c:has(.d)'));
    expect(formatElements(result1)).toBe(formatElements(result2));

    await snapshot();

    main.remove();
  });

  it('C4 .c:has(:is(:scope .d)) returns empty when no .d exists', async () => {
    const main = createTestDOM();
    const scope2 = main.querySelector('#scope2')!;

    const actual = Array.from(scope2.querySelectorAll('.c:has(:is(:scope .d))'));
    expect(formatElements(actual)).toBe('');

    await snapshot();

    main.remove();
  });
});

describe('CSS Selectors: :has() with :scope in complex selectors', () => {
  function formatElements(elements: Element[]) {
    return elements.map(e => e.id).sort().join(',');
  }

  it('D1 :scope combined with :has() in compound selector', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="outer">
        <div id="scope" class="target">
          <div id="inner" class="child"></div>
        </div>
      </div>
    `;
    document.body.appendChild(container);

    const scope = container.querySelector('#scope')!;
    // :scope:has(.child) should match the scope element itself if it has .child
    const matches = scope.matches(':scope:has(.child)');
    expect(matches).toBe(true);

    await snapshot();

    container.remove();
  });

  it('D2 :scope in :has() with sibling combinators', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="parent">
        <div id="scope" class="item"></div>
        <div id="sibling" class="item"></div>
      </div>
    `;
    document.body.appendChild(container);

    const scope = container.querySelector('#scope')!;
    // Elements that have a sibling after :scope
    const actual = Array.from(scope.querySelectorAll(':has(~ .item)'));
    // Should be empty because we're querying descendants of scope
    expect(formatElements(actual)).toBe('');

    await snapshot();

    container.remove();
  });

  it('D3 :has(:scope) with matches API', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div id="outer">
        <div id="inner"></div>
      </div>
    `;
    document.body.appendChild(container);

    const outer = container.querySelector('#outer')!;
    const inner = container.querySelector('#inner')!;

    // inner cannot have outer (its ancestor) as descendant
    expect(inner.matches(':has(:scope)')).toBe(false);

    await snapshot();

    container.remove();
  });
});

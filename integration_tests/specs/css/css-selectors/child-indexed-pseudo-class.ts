/**
 * Matching of child-indexed pseudo-classes
 * Based on WPT: css/selectors/child-indexed-pseudo-class.html
 */
describe('CSS Selectors: child-indexed pseudo-classes', () => {
  const rootOfSubtreeSelectors: Array<[string, boolean]> = [
    [':first-child', true],
    [':last-child', true],
    [':only-child', true],
    [':first-of-type', true],
    [':last-of-type', true],
    [':only-of-type', true],
    [':nth-child(1)', true],
    [':nth-child(n)', true],
    [':nth-last-child(1)', true],
    [':nth-last-child(n)', true],
    [':nth-of-type(1)', true],
    [':nth-of-type(n)', true],
    [':nth-last-of-type(1)', true],
    [':nth-last-of-type(n)', true],
    [':nth-child(2)', false],
    [':nth-last-child(2)', false],
    [':nth-of-type(2)', false],
    [':nth-last-of-type(2)', false],
  ];

  function check(element: Element, qsRoot?: ParentNode) {
    for (const [selector, expected] of rootOfSubtreeSelectors) {
      expect(element.matches(selector)).toBe(expected, `matches(${selector})`);

      if (qsRoot) {
        expect(element === qsRoot.querySelector(selector)).toBe(expected, `querySelector(${selector})`);
        const qsa = qsRoot.querySelectorAll(selector);
        expect(qsa.length > 0 && element === qsa[0]).toBe(expected, `querySelectorAll(${selector})`);
      }
    }
  }

  it('documentElement matches expected selectors', async () => {
    check(document.documentElement, document);
    await snapshot();
  });

  it('detached element matches expected selectors', async () => {
    check(document.createElement('div'));
    await snapshot();
  });

  // We don't support `document.createDocumentFragment` yet.
  xit('document fragment root matches expected selectors', async () => {
    const fragment = document.createDocumentFragment();
    const div = document.createElement('div');
    fragment.appendChild(div);
    check(div, fragment);
    await snapshot();
  });
});


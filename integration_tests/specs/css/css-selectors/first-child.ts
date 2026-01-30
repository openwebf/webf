/**
 * CSS Selectors: :first-child
 * Based on WPT: css/selectors/first-child.html
 */
describe('CSS Selectors: :first-child', () => {
  it('ignores non-element siblings when matching', async () => {
    const container = document.createElement('div');
    container.innerHTML = `
      <div>
        <div id="target1">Whitespace nodes should be ignored.</div>
      </div>

      <div>
        <div id="target2">There is the second child element.</div>
        <blockquote></blockquote>
      </div>

      <div>
        <!-- -->
        <div id="target3">A comment node should be ignored.</div>
      </div>

      <div>
        .
        <div id="target4">Non-whitespace text node should be ignored.</div>
      </div>

      <div>
        <blockquote></blockquote>
        <div id="target5" data-expected="false">The second child should not be matched.</div>
      </div>
    `;
    document.body.appendChild(container);

    for (let i = 1; i <= 5; ++i) {
      const target = container.querySelector(`#target${i}`) as HTMLElement;
      expect(target).not.toBeNull();

      const shouldMatch = target.dataset.expected !== 'false';
      expect(target.matches(':first-child')).toBe(shouldMatch);
    }

    await snapshot();

    container.remove();
  });
});


describe('RTL inline dir override', () => {
  it('should keep LTR phone number order inside RTL container', async () => {
    const container = document.createElement('div');
    container.style.direction = 'rtl';
    container.style.width = '340px';
    container.style.border = '1px solid #999';
    container.style.padding = '12px';
    container.style.fontFamily = 'monospace';
    container.style.fontSize = '24px';
    container.style.lineHeight = '32px';

    const title = document.createElement('div');
    title.textContent = 'RTL container';
    title.style.fontSize = '14px';
    title.style.lineHeight = '18px';
    title.style.marginBottom = '8px';
    title.style.opacity = '0.7';

    const withDir = document.createElement('div');
    withDir.textContent = 'dir=ltr: ';
    const span = document.createElement('span');
    span.id = 'phone';
    span.setAttribute('dir', 'ltr');
    span.textContent = '+86987123456';
    withDir.appendChild(span);

    const withoutDir = document.createElement('div');
    withoutDir.style.marginTop = '8px';
    withoutDir.textContent = 'no dir: +86987123456';

    container.appendChild(title);
    container.appendChild(withDir);
    container.appendChild(withoutDir);
    document.body.appendChild(container);

    await snapshot();

    // Optional: if Range geometry APIs exist, assert '+' is left of the last digit visually.
    const textNode = span.firstChild;
    if (textNode && typeof document.createRange === 'function') {
      const rangePlus = document.createRange();
      rangePlus.setStart(textNode, 0);
      rangePlus.setEnd(textNode, 1);

      const rangeLast = document.createRange();
      rangeLast.setStart(textNode, span.textContent!.length - 1);
      rangeLast.setEnd(textNode, span.textContent!.length);

      const plusRect = rangePlus.getBoundingClientRect?.();
      const lastRect = rangeLast.getBoundingClientRect?.();
      if (plusRect && lastRect) {
        expect(plusRect.left).toBeLessThan(lastRect.left);
      }
    }

    document.body.removeChild(container);
  });
});


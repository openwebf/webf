describe('First-paint barrier: synchronous flush', () => {
  it('unblocks getComputedStyle() during RouterLink subtree mount', () => {
    const style = document.createElement('style');
    style.textContent = '.sync-flush-box { color: rgb(255, 0, 0); }';
    document.head.appendChild(style);

    const routerLink = document.createElement('webf-router-link');
    document.body.appendChild(routerLink);

    const target = document.createElement('div');
    target.className = 'sync-flush-box';
    target.textContent = 'sync flush';
    routerLink.appendChild(target);

    let color = '';
    try {
      color = getComputedStyle(target).color;
    } catch (e) {
      fail(`getComputedStyle threw: ${String(e)}`);
      return;
    }

    expect(color.indexOf('255, 0, 0') >= 0 || color === 'red').toBeTrue();

    style.remove();
    routerLink.remove();
  });
});

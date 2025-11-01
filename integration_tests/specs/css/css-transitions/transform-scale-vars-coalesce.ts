describe('Transition transform with CSS variables (coalesced)', () => {
  it('scaleX/scaleY updated in same frame both animate', (done) => {
    const el = document.createElement('div');
    document.body.appendChild(el);

    // Initial styles with var() driven scale on both axes.
    setElementStyle(el, {
      position: 'absolute',
      left: '0',
      top: '0',
      width: '96px',
      height: '96px',
      backgroundColor: '#4c6ef5',
      color: '#fff',
      transitionProperty: 'transform',
      transitionDuration: '300ms',
      transitionTimingFunction: 'ease-out',
      transform: 'scaleX(var(--sx)) scaleY(var(--sy))',
    });

    // Set starting custom property values (.9) — note the leading dot.
    el.style.setProperty('--sx', '.9');
    el.style.setProperty('--sy', '.9');

    let ended = false;
    el.addEventListener('transitionend', async (evt: Event) => {
      if (ended) return;
      ended = true;
      // At the end, both axes should have animated to ~1.1.
      const t = getComputedStyle(el).getPropertyValue('transform');
      // Expect a 2D matrix like: matrix(a, b, c, d, e, f)
      let a = 1, d = 1;
      if (t && t.startsWith('matrix(')) {
        const nums = t.slice(7, -1).split(',').map((s) => parseFloat(s.trim()));
        // a = scaleX, d = scaleY for pure scale with no rotation/skew.
        a = nums[0];
        d = nums[3];
      }
      expect(a).not.toBeLessThan(1.05);
      expect(d).not.toBeLessThan(1.05);
      await snapshot();
      done();
    }, { once: true });

    requestAnimationFrame(async () => {
      await snapshot();
      // Update both variables in the same frame. The transition scheduler
      // should coalesce into a single transform transition where both axes
      // animate from 0.9 -> 1.1.
      el.style.setProperty('--sx', '1.1');
      el.style.setProperty('--sy', '1.1');
    });
  });
});


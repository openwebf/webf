// Spec: Var-driven transform updates scheduled before transition properties are configured
// should still animate once transition-* is applied in the same frame (post-frame drain).
//
// Repro sequence:
// 1) Element has transform: translateX(var(--x)) rotate(var(--r)) scaleX(var(--sx)) scaleY(var(--sy))
// 2) No transition config initially.
// 3) Update variables first, then set transition-property + duration in the same rAF.
// Expected: A transform transition runs (transitionend fires) and the element animates.

describe('CSS Transition with vars configured later in frame', () => {
  it('var update before transition config still animates', async (done) => {
    const el = createElement('div', {
      style: {
        position: 'absolute',
        left: '0',
        top: '0',
        width: '96px',
        height: '96px',
        backgroundColor: '#0ea5e9',
        color: '#fff',
        // No transition yet; transform depends on vars
        transform: 'translate(var(--x), var(--y)) rotate(var(--r)) scaleX(var(--sx)) scaleY(var(--sy))'
      }
    });
    document.body.appendChild(el);

    // Set initial variables
    el.style.setProperty('--x', '0px');
    el.style.setProperty('--y', '0px');
    el.style.setProperty('--r', '0deg');
    el.style.setProperty('--sx', '1');
    el.style.setProperty('--sy', '1');

    let ended = false;
    el.addEventListener('transitionend', async () => {
      if (ended) return;
      ended = true;
      // Verify transform is no longer identity (rough check)
      const t = getComputedStyle(el).getPropertyValue('transform');
      expect(t).toBeTruthy();
      await snapshot();
      done();
    }, { once: true });

    await snapshot();

    requestAnimationFrame(() => {
      // 1) Change variables first: schedule var-notify before transition config
      el.style.setProperty('--x', '32px');
      el.style.setProperty('--y', '0px');
      el.style.setProperty('--r', '15deg');
      el.style.setProperty('--sx', '1.1');
      el.style.setProperty('--sy', '1.1');

      // 2) Configure transition afterwards in the same frame
      el.style.transitionProperty = 'transform';
      el.style.transitionDuration = '300ms';
      el.style.transitionTimingFunction = 'ease-out';
    });
  });
});


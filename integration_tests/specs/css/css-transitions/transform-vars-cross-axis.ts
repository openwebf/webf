describe('CSS Transition with vars cross-axis reuse', () => {
  it('horizontal then vertical translate via Tailwind-like vars', async (done) => {
    const el = document.createElement('div');
    document.body.appendChild(el);

    // Tailwind-like transform variable setup: translate driven by custom properties.
    setElementStyle(el, {
      position: 'absolute',
      left: '0',
      top: '0',
      width: '96px',
      height: '96px',
      backgroundColor: '#0ea5e9',
      color: '#fff',
      transitionProperty: 'transform',
      transitionDuration: '150ms',
      transitionTimingFunction: 'cubic-bezier(0.4, 0, 0.2, 1)',
      transform:
        'translate(var(--tw-translate-x), var(--tw-translate-y)) ' +
        'rotate(0deg) skewX(0deg) skewY(0deg) scaleX(1) scaleY(1)',
    });

    // Initial vars at origin.
    el.style.setProperty('--tw-translate-x', '0');
    el.style.setProperty('--tw-translate-y', '0');

    function translation(el: HTMLElement): { x: number; y: number } {
      const t = getComputedStyle(el).transform;
      if (!t || t === 'none') return { x: 0, y: 0 };
      const m = t.match(/matrix\(([^)]+)\)/);
      if (!m) return { x: 0, y: 0 };
      const parts = m[1].split(',').map(s => parseFloat(s.trim()));
      // matrix(a, b, c, d, e, f) -> translation is (e, f).
      return { x: parts[4] || 0, y: parts[5] || 0 };
    }

    // Phase 1: horizontal transition to the right using --tw-translate-x.
    requestAnimationFrame(() => {
      el.style.setProperty('--tw-translate-x', '1.5rem'); // ~24px at 16px root
    });

    // After the 150ms horizontal transition, reset back to origin.
    setTimeout(() => {
      el.style.setProperty('--tw-translate-x', '0');

      // After returning to origin, start a vertical-only transition with longer duration.
      setTimeout(() => {
        el.style.transitionDuration = '500ms';
        el.style.setProperty('--tw-translate-y', '1rem'); // ~16px downward

        // Sample mid-transition: expect primarily Y movement, not residual X.
        setTimeout(async () => {
          const { x, y } = translation(el);
          // At mid animation we should have moved noticeably on Y, and X
          // should be near zero (no reused horizontal path).
          expect(Math.abs(x)).toBeLessThan(5);
          expect(y).toBeGreaterThan(5);

          await snapshot();
          done();
        }, 260); // ~halfway through the 500ms vertical transition
      }, 220); // allow the 150ms reset-to-origin transition to complete
    }, 220); // allow the initial 150ms horizontal transition to complete
  });
});


describe('transition: transform + background-color using CSS variables (Tailwind-like)', () => {
  it('animates translateY via var() and updates background color', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .host {
        position: relative;
        width: 200px;
        height: 200px;
        border: 1px solid #000;
        background: #fff;
        overflow: hidden;
      }
      .box {
        width: 80px;
        height: 80px;
        border-radius: 8px;
        /* Tailwind-like transform variable setup */
        --tw-translate-x: 0;
        --tw-translate-y: 0;
        --tw-rotate: 0deg;
        --tw-skew-x: 0deg;
        --tw-skew-y: 0deg;
        --tw-scale-x: 1;
        --tw-scale-y: 1;
        --tw-bg-opacity: 1;

        transition-property: transform, background-color;
        transition-duration: 300ms;
        transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);

        background-color: rgb(147 197 253 / var(--tw-bg-opacity, 1));
        transform:
          translate(var(--tw-translate-x), var(--tw-translate-y))
          rotate(var(--tw-rotate))
          skewX(var(--tw-skew-x))
          skewY(var(--tw-skew-y))
          scaleX(var(--tw-scale-x))
          scaleY(var(--tw-scale-y));
      }
      .box.active {
        --tw-translate-y: -0.5rem; /* -8px at 16px root */
        --tw-scale-x: 1.05;
        --tw-scale-y: 1.05;
        background-color: rgb(96 165 250 / var(--tw-bg-opacity, 1));
      }
    `;
    document.head.appendChild(style);

    const host = document.createElement('div');
    host.className = 'host';
    const box = document.createElement('div');
    box.className = 'box';
    host.appendChild(box);
    document.body.appendChild(host);

    // Initial state snapshot
    await snapshot();

    // Trigger transition to active
    box.classList.add('active');

    // Wait slightly longer than duration
    await new Promise((r) => setTimeout(r, 360));

    // Post-transition snapshot
    await snapshot();

    // Programmatic assertions for extra safety
    const cs = getComputedStyle(box);
    // Background color should be the final value (opaque)
    expect(cs.backgroundColor).toBe('rgb(96, 165, 250)');

    // Transform should not be identity; translation Y should be negative
    const t = cs.transform;
    expect(t).not.toBe('none');
    const m = t.match(/matrix\(([^)]+)\)/);
    if (m) {
      const parts = m[1].split(',').map((s) => parseFloat(s.trim()));
      // matrix(a, b, c, d, e, f) -> translation is (e, f)
      const e = parts[4];
      const f = parts[5];
      expect(isFinite(e)).toBe(true);
      expect(isFinite(f)).toBe(true);
      expect(f).toBeLessThan(0);
    }
  });
});


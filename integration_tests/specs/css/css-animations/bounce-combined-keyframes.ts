// Verifies that combined keyframe selectors like "0%, 100%" are parsed into
// multiple keyframes and the animation plays across segments, with per-keyframe
// easing applied.

describe('CSS Animations: combined keyframe selectors (0%, 100%)', () => {
  function parseTranslateY(transform: string): number | null {
    // Expect either 'none' or 'matrix(a, b, c, d, tx, ty)'
    if (!transform || transform === 'none') return null;
    const m = transform.match(/matrix\(([^)]+)\)/);
    if (!m) return null;
    const parts = m[1].split(',').map((s) => parseFloat(s.trim()));
    if (parts.length !== 6) return null;
    return parts[5]; // ty
  }

  it('parses 0%,100% + 50% and animates segments for bounce', async () => {
    // Keep sizes stable so translateY(-25%) is a visible negative offset.
    document.body.style.margin = '0';
    const style = document.createElement('style');
    style.textContent = `
      @keyframes bounce {
        0%, 100% {
          transform: translateY(-25%);
          animation-timing-function: cubic-bezier(0.8, 0, 1, 1);
        }
        50% {
          transform: none;
          animation-timing-function: cubic-bezier(0, 0, 0.2, 1);
        }
      }
      .box {
        width: 120px; height: 120px;
        background: #7c3aed;
        animation: bounce 0.6s ease-in-out infinite both;
      }
    `;
    document.head.appendChild(style);

    const el = document.createElement('div');
    el.className = 'box';
    document.body.appendChild(el);

    // Allow layout/paint and initial keyframe application.
    await waitForOnScreen(el);
    await snapshot();
    let t0 = getComputedStyle(el).getPropertyValue('transform');
    const y0 = parseTranslateY(t0);
    // Early segment should be above baseline (negative translateY) with visible magnitude.
    expect(y0).not.toBe(null);
    const startAbs = Math.abs(y0 as number);
    expect((y0 as number) < 0).toBe(true);
    expect(startAbs).toBeGreaterThan(8);

    // Around mid-cycle ~0.3s: transform should be none (50% keyframe).
    await sleep(0.3);
    let tm = getComputedStyle(el).getPropertyValue('transform');
    let midAbs = 0;
    if (tm !== 'none') {
      const ym = parseTranslateY(tm) ?? 0;
      midAbs = Math.abs(ym);
    }
    // Mid segment (around 50%) should be nearer baseline than start.
    expect(midAbs).toBeLessThan(startAbs);

    // Near end of cycle ~0.55s: should be negative again.
    await sleep(0.25);
    let t1 = getComputedStyle(el).getPropertyValue('transform');
    const y1 = parseTranslateY(t1);
    expect(y1).not.toBe(null);
    expect((y1 as number) < 0).toBe(true);
    expect(Math.abs(y1 as number)).toBeGreaterThan(5);
  });
});

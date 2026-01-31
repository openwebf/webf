// Ensures that combined selectors using 'from' and 'to' are treated like 0% and 100%
// when combined in a single keyframe block.

describe('CSS Animations: combined keyframe selectors (from, to)', () => {
  function parseTranslateY(transform: string): number | null {
    if (!transform || transform === 'none') return null;
    const m = transform.match(/matrix\(([^)]+)\)/);
    if (!m) return null;
    const parts = m[1].split(',').map((s) => parseFloat(s.trim()));
    if (parts.length !== 6) return null;
    return parts[5];
  }

  it('parses from,to + 50% and animates as expected', async () => {
    document.body.style.margin = '0';
    const style = document.createElement('style');
    style.textContent = `
      @keyframes bounce2 {
        from, to {
          transform: translateY(-25%);
        }
        50% { transform: none; }
      }
      .box2 { width: 120px; height: 120px; background: #22c55e; animation: bounce2 0.6s linear infinite both; }
    `;
    document.head.appendChild(style);

    const el = document.createElement('div');
    el.className = 'box2';
    document.body.appendChild(el);

    await waitForOnScreen(el);
    const y0 = parseTranslateY(getComputedStyle(el).getPropertyValue('transform'));
    expect(y0).not.toBe(null);
    const startAbs = Math.abs(y0 as number);
    expect((y0 as number) < 0).toBe(true);
    expect(startAbs).toBeGreaterThan(8);

    await sleep(0.30);
    const mid = getComputedStyle(el).getPropertyValue('transform');
    let midAbs = 0;
    if (mid !== 'none') {
      const ym = parseTranslateY(mid) ?? 0;
      midAbs = Math.abs(ym);
    }
    expect(midAbs).toBeLessThan(startAbs);
  });
});

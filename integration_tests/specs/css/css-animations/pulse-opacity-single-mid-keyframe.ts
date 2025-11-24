// Verifies that a single mid-iteration opacity keyframe like
// `50% { opacity: .5 }` produces a smooth fade-out and fade-in loop
// without visible jumps at iteration boundaries (matches Chrome behavior).

describe('CSS Animations: single mid-iteration opacity keyframe', () => {
  it('animates opacity from 1 -> 0.5 -> 1 continuously', async () => {
    document.body.style.margin = '0';

    const style = document.createElement('style');
    style.textContent = `
      @keyframes pulse {
        50% {
          opacity: .5;
        }
      }
      .dot {
        width: 80px;
        height: 80px;
        border-radius: 9999px;
        background: #22c55e;
        display: inline-block;
        animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
      }
    `;
    document.head.appendChild(style);

    const el = document.createElement('div');
    el.className = 'dot';
    document.body.appendChild(el);

    const getOpacity = () => parseFloat(getComputedStyle(el).getPropertyValue('opacity') || '1');

    // Initial state near t=0: should be close to 1.
    await waitForOnScreen(el);
    const o0 = getOpacity();

    // Around 25% of the cycle (~0.5s): opacity should be decreasing toward 0.5.
    await sleep(0.5);
    const o25 = getOpacity();

    // Around 50% of the cycle (~1.0s): near the mid keyframe, close to 0.5.
    await sleep(0.5);
    const o50 = getOpacity();

    // Around 75% of the cycle (~1.5s): opacity should be increasing back toward 1.0.
    await sleep(0.5);
    const o75 = getOpacity();

    // Start of the next iteration (~2.0s): opacity should be back near 1.0,
    // not stuck at 0.5 or jumping from 0.5 to 1.0 abruptly.
    await sleep(0.5);
    const o100 = getOpacity();

    // Basic monotonicity checks around the loop:
    // - early value near 1
    // - mid value is lower
    // - late-mid value rises again
    // - next-cycle start value is near the original
    expect(o0).toBeGreaterThan(0.9);
    expect(o25).toBeLessThan(o0);
    expect(o50).toBeLessThan(o25);
    expect(o75).toBeGreaterThan(o50);
    expect(o100).toBeGreaterThan(o75);
    expect(Math.abs(o100 - o0)).toBeLessThan(0.15);

    await snapshot();
  });
});


// Spec: Transitions are gated on layout availability
// Expected: No transition fired when element lacks a render box (e.g., display:none)
// Then, once visible and sized, subsequent changes trigger transitions as usual.

describe('CSS Transition pre-layout gating', () => {
  it('skips transitions before layout, runs after visible', async (done) => {
    const el = createElement('div', {
      style: {
        display: 'none',
        width: '50px',
        height: '50px',
        background: 'red',
        opacity: '1',
        transition: 'opacity 200ms linear'
      }
    });
    document.body.appendChild(el);

    let fired = 0;
    el.addEventListener('transitionend', () => fired++);

    // Change while display:none — should not animate.
    el.style.opacity = '0.2';
    await sleep(0.4);
    expect(fired).toEqual(0);

    // Make visible with size, then change opacity to animate.
    el.style.display = 'block';
    await sleep(0.02); // allow layout

    el.addEventListener('transitionend', () => {
      expect(fired).toBeGreaterThan(0);
      done();
    }, { once: true });

    requestAnimationFrame(() => {
      el.style.opacity = '1';
    });
  });
});


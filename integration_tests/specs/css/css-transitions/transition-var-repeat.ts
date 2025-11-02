// Spec: Var-driven transform transitions should continue to work repeatedly.
// After one transition finishes (ending with a var()-based transform string),
// toggling the variable back should schedule and run another transition.

describe('CSS Transition with vars repeated toggles', () => {
  it('animates on second var toggle after first transition ends', async (done) => {
    const el = createElement('div', {
      style: {
        position: 'absolute',
        left: '0',
        top: '112px',
        width: '96px',
        height: '96px',
        backgroundColor: '#22c55e',
        color: '#fff',
        transitionProperty: 'transform',
        transitionDuration: '240ms',
        transitionTimingFunction: 'ease-out',
        transform: 'translateX(var(--x)) scaleX(var(--sx)) scaleY(var(--sy))'
      }
    });
    document.body.appendChild(el);

    // Initial vars
    el.style.setProperty('--x', '0px');
    el.style.setProperty('--sx', '1');
    el.style.setProperty('--sy', '1');

    let phase = 0;
    el.addEventListener('transitionend', async () => {
      phase++;
      if (phase === 1) {
        // First transition finished; toggle back to initial via vars
        requestAnimationFrame(() => {
          el.style.setProperty('--x', '0px');
          el.style.setProperty('--sx', '1');
          el.style.setProperty('--sy', '1');
        });
      } else if (phase === 2) {
        await snapshot();
        done();
      }
    });

    await snapshot();

    // First toggle to non-defaults
    requestAnimationFrame(() => {
      el.style.setProperty('--x', '40px');
      el.style.setProperty('--sx', '1.1');
      el.style.setProperty('--sy', '1.1');
    });
  });
});


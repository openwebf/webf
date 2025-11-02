// Spec: Alias variable changes should capture previous resolved value for transitions
// Repro: transform: scale(var(--scale)); --scale -> var(--a) changes to var(--b)
// Expected: A transform transition should run when alias target changes.
// NOTE: Currently skipped pending prev-var capture in setCSSVariable for alias cases
// (lib/src/css/variable.dart:132) so _notifyCSSVariableChanged has a non-null prev value.

describe('CSS Variables alias transition', () => {
  it('transition on transform when alias changes var(--scale): var(--a) -> var(--b)', async (done) => {
    const el = createElement('div', {
      style: {
        width: '50px',
        height: '50px',
        background: '#0af',
        transition: 'transform 300ms linear',
        transform: 'scale(var(--scale))'
      }
    });
    document.body.appendChild(el);

    // Chain alias: --scale -> --a initially.
    el.style.setProperty('--a', '1');
    el.style.setProperty('--scale', 'var(--a)');

    let ended = false;
    el.addEventListener('transitionend', async () => {
      if (ended) return;
      ended = true;
      await snapshot();
      done();
    });

    await snapshot();

    requestAnimationFrame(() => {
      // Introduce new alias target and then redirect --scale to it.
      el.style.setProperty('--b', '2');
      el.style.setProperty('--scale', 'var(--b)');
    });
  });
});


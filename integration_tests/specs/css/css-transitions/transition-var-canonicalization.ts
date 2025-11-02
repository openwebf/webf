// Spec: Var-driven transitions should respect canonical property mapping
// Repro: transition-property: background-position; value driven by background-position-x via var(--pos)
// Expected: Changing --pos should trigger a transition (run/start/end) even though the longhand is used.
// NOTE: Currently skipped pending canonicalization fix in CSSVariableMixin._notifyCSSVariableChanged
// (lib/src/css/variable.dart:317) to match _canonicalTransitionKey in transitions.

describe('CSS Transition + vars canonicalization', () => {
  it('var-driven background-position-x transitions when property=background-position', async (done) => {
    const el = createElement('div', {
      style: {
        width: '160px',
        height: '20px',
        backgroundImage: 'url(assets/bg.jpg)',
        backgroundRepeat: 'no-repeat',
        backgroundPositionY: '0%'
      }
    });
    document.body.appendChild(el);

    // Configure transition on shorthand key only.
    el.style.transitionProperty = 'background-position';
    el.style.transitionDuration = '200ms';

    // Drive longhand via var so dependency is recorded on background-position-x.
    el.style.backgroundPositionX = 'var(--pos)';
    el.style.setProperty('--pos', '0%');

    let fired = false;
    el.addEventListener('transitionend', async () => {
      if (fired) return;
      fired = true;
      await snapshot();
      done();
    });

    await snapshot();

    requestAnimationFrame(() => {
      // Change the variable to move X from 0% -> 100%.
      el.style.setProperty('--pos', '100%');
    });
  });
});


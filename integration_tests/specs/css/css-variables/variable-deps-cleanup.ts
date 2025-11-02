// Spec: Dependency map cleanup behavior (functional)
// Intent: When a property is switched from var(...) to a concrete value,
// subsequent changes to the variable should not affect that property.

describe('CSS Variables dependency cleanup (functional)', () => {
  it('property overwritten to non-var should not update on later var change', async () => {
    const el = createElement('div', {
      style: {
        width: '10px',
        height: '10px',
        color: 'var(--c)'
      }
    });
    document.body.appendChild(el);

    // Initial variable flow sets color red.
    el.style.setProperty('--c', 'red');
    await sleep(0.02);

    // Overwrite property to concrete value (blue), breaking var dependency.
    el.style.color = 'blue';
    await sleep(0.02);

    // Change variable; functional expectation: computed color remains blue.
    el.style.setProperty('--c', 'green');
    await sleep(0.05);

    const color = getComputedStyle(el).color;
    // Normalize possible rgb/rgba forms by checking substring.
    expect(color.indexOf('0, 0, 255') >= 0 || color === 'blue').toBeTrue();
  });
});


describe('transition parsing with decimal seconds (issue #266)', () => {
  xit('parses transition: all 0.5s ease-out and reflects subproperties', async () => {
    const el = document.createElement('div');
    el.style.transition = 'all 0.5s ease-out';

    // Reflection via CSSStyleDeclaration subproperties verifies parsing
    expect(el.style.transitionProperty).toBe('all');
    expect(el.style.transitionDuration).toBe('0.5s');
    // timing function may normalize to cubic-bezier; accept either
    const tf = el.style.transitionTimingFunction;
    expect(tf === 'ease-out' || tf.startsWith('cubic-bezier')).toBe(true);

    document.body.appendChild(el);
    await snapshot();
  });
});


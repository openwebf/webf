describe('RenderWidget flex custom element centered badge', () => {
  it('centers text inside a constrained custom element flex circle', async () => {
    // Create the custom flutter-backed element defined in playground.dart:
    // <sample-container> wraps its HTML child in a ConstrainedBox(28×28)
    // and WebFWidgetElementChild, so the inner DIV is clamped to 28×28.
    const container = document.createElement('sample-container');

    const inner = document.createElement('div');
    inner.id = 'badge';
    inner.className =
      'w-10 h-10 rounded-full bg-gradient-to-br from-purple-400 to-purple-600 flex items-center justify-center text-white font-semibold';
    inner.setAttribute(
      'style',
      [
        'width: 40px', // tailwind w-10
        'height: 40px', // tailwind h-10
        'border-radius: 9999px',
        'display: flex',
        'align-items: center',
        'justify-content: center',
        'background: linear-gradient(to bottom right, #a855f7, #7c3aed)',
        'color: white',
        'font-weight: 600',
        'line-height: 30px', // explicit line-height that used to cause mis-centering
      ].join(';'),
    );
    inner.textContent = 'AB';

    container.appendChild(inner);
    document.body.appendChild(container);

    await waitForOnScreen(container);
    await waitForFrame();

    const rect = inner.getBoundingClientRect();

    // The badge is driven by Flutter constraints to 28×28 via ConstrainedBox(maxWidth/Height:28),
    // so the DOM box should reflect that clamped size (with a bit of tolerance for transforms).
    expect(Math.abs(rect.width - 28)).toBeLessThanOrEqual(2);
    expect(Math.abs(rect.height - 28)).toBeLessThanOrEqual(2);

    // Vertical centering sanity check: the text baseline should sit near the visual center.
    // We don't have direct baseline metrics here, but we can at least assert that the
    // flex line does not overflow predominantly to one side. A circle with centered text
    // should have roughly equal top/bottom padding; we approximate that by verifying that
    // the circle is square and rely on snapshot for precise visual centering.
    expect(Math.abs(rect.width - rect.height)).toBeLessThanOrEqual(2);

    await snapshot(container);
  });
});


describe('RenderWidget flex native-flex container', () => {
  it('lays out inner WebF div with finite width under Flutter Row constraints', async () => {
    // <native-flex> is a custom WidgetElement backed by a Flutter Row that wraps
    // its first HTML child in WebFWidgetElementChild. Previously, when the Row
    // provided unbounded main-axis constraints, the inner DIV could end up with
    // an infinite width during IFC, causing a RenderFlowLayout assertion.
    //
    // This spec ensures that the inner DIV behaves like a flex item sized by
    // its content and produces a finite, positive width.

    const container = document.createElement('native-flex');

    const inner = document.createElement('div');
    inner.id = 'bug';
    inner.textContent = '123';

    container.appendChild(inner);
    document.body.appendChild(container);

    await waitForOnScreen(container);
    await waitForFrame();

    const bug = document.getElementById('bug') as HTMLElement | null;
    expect(bug).not.toBeNull();

    const rect = bug!.getBoundingClientRect();

    // The inner DIV should resolve to a finite, positive width instead of
    // inheriting an infinite main-axis constraint from the Flutter Row.
    expect(rect.width).toBeGreaterThan(0);
    expect(Number.isFinite(rect.width)).toBe(true);

    await snapshot();
  });
});


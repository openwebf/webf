describe('TransitionEvent properties', () => {
  it('exposes propertyName and elapsedTime for background-color transitions', (done) => {
    const el = document.createElement('div');
    el.style.width = '50px';
    el.style.height = '50px';
    el.style.backgroundColor = 'rgb(248, 113, 113)'; // Tailwind red-400-ish
    el.style.transitionProperty = 'background-color';
    el.style.transitionDuration = '200ms';
    el.style.transitionTimingFunction = 'linear';
    document.body.appendChild(el);

    const seen: { type: string; propertyName: string; elapsed: number }[] = [];

    function record(e: TransitionEvent) {
      seen.push({ type: e.type, propertyName: e.propertyName, elapsed: e.elapsedTime });
    }

    el.addEventListener('transitionrun', record);
    el.addEventListener('transitionstart', record);
    el.addEventListener('transitionend', (e: TransitionEvent) => {
      record(e);

      // All events should report the transitioned property in hyphenated form.
      for (const s of seen) {
        expect(s.propertyName).toBe('background-color');
      }

      // elapsedTime is 0 for run/start, > 0 for end.
      const run = seen.find((s) => s.type === 'transitionrun');
      const start = seen.find((s) => s.type === 'transitionstart');
      const end = seen.find((s) => s.type === 'transitionend');
      expect(run).not.toBeUndefined();
      expect(start).not.toBeUndefined();
      expect(end).not.toBeUndefined();
      if (run && start && end) {
        expect(run.elapsed).toBe(0);
        expect(start.elapsed).toBe(0);
        expect(end.elapsed).toBeGreaterThan(0);
      }

      done();
    });

    // Trigger background-color transition.
    requestAnimationFrame(() => {
      el.style.backgroundColor = 'transparent';
    });
  });
});

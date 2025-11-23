describe('transition: background-color red <-> transparent without black mid-step', () => {
  const RED_RGB = 'rgb(248, 113, 113)';

  function parseRgb(input: string): { r: number; g: number; b: number } {
    // Handles both rgb(...) and rgba(...) forms.
    const m = input.match(/rgba?\(([^)]+)\)/);
    if (!m) {
      throw new Error('Unexpected color format: ' + input);
    }
    const parts = m[1].split(',').map((s) => s.trim());
    const r = parseFloat(parts[0]);
    const g = parseFloat(parts[1]);
    const b = parseFloat(parts[2]);
    return { r, g, b };
  }

  function waitForTransitionEnd(el: HTMLElement): Promise<void> {
    return new Promise<void>((resolve) => {
      const onEnd = (e: Event) => {
        if ((e as TransitionEvent).propertyName === 'background-color') {
          el.removeEventListener('transitionend', onEnd as any);
          resolve();
        }
      };
      el.addEventListener('transitionend', onEnd as any);
    });
  }

  it('fades red -> transparent without drifting toward black', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .host {
        width: 200px;
        height: 120px;
        padding: 16px;
        background: #fff;
      }
      .box {
        width: 100px;
        height: 80px;
        border-radius: 8px;
        transition-property: background-color;
        transition-duration: 400ms;
        transition-timing-function: linear;
        background-color: ${RED_RGB};
      }
      .box.off {
        background-color: transparent;
      }
    `;
    document.head.appendChild(style);

    const host = document.createElement('div');
    host.className = 'host';
    const box = document.createElement('div');
    box.className = 'box';
    host.appendChild(box);
    document.body.appendChild(host);

    // Initial state: solid red
    await snapshot();
    let cs = getComputedStyle(box);
    expect(cs.backgroundColor).toBe(RED_RGB);

    const midSamples: string[] = [];

    box.addEventListener('transitionrun', () => {
      // Sample roughly mid-way through the transition.
      setTimeout(() => {
        const mid = getComputedStyle(box).backgroundColor;
        midSamples.push(mid);
      }, 220);
    });

    // Trigger red -> transparent
    box.classList.add('off');

    await waitForTransitionEnd(box);

    // End state should be fully transparent.
    cs = getComputedStyle(box);
    // Depending on implementation this may be 'transparent' or 'rgba(0, 0, 0, 0)'.
    expect(cs.backgroundColor === 'transparent' || cs.backgroundColor === 'rgba(0, 0, 0, 0)').toBe(true);

    // Mid-step sample should stay close to red, not drift toward pure black.
    expect(midSamples.length).toBeGreaterThan(0);
    const mid = parseRgb(midSamples[0]);
    // Require a clearly red-ish color: high red channel and non-trivial green/blue.
    expect(mid.r).toBeGreaterThan(150);
    expect(mid.g).toBeGreaterThan(40);
    expect(mid.b).toBeGreaterThan(40);

    await snapshot();
  });

  it('fades transparent -> red without drifting toward black', async () => {
    const style = document.createElement('style');
    style.textContent = `
      .host2 {
        width: 200px;
        height: 120px;
        padding: 16px;
        background: #fff;
      }
      .box2 {
        width: 100px;
        height: 80px;
        border-radius: 8px;
        transition-property: background-color;
        transition-duration: 400ms;
        transition-timing-function: linear;
        background-color: transparent;
      }
      .box2.on {
        background-color: ${RED_RGB};
      }
    `;
    document.head.appendChild(style);

    const host = document.createElement('div');
    host.className = 'host2';
    const box = document.createElement('div');
    box.className = 'box2';
    host.appendChild(box);
    document.body.appendChild(host);

    await snapshot();

    const midSamples: string[] = [];

    box.addEventListener('transitionrun', () => {
      setTimeout(() => {
        const mid = getComputedStyle(box).backgroundColor;
        midSamples.push(mid);
      }, 220);
    });

    box.classList.add('on');

    await waitForTransitionEnd(box);

    const cs = getComputedStyle(box);
    expect(cs.backgroundColor).toBe(RED_RGB);

    expect(midSamples.length).toBeGreaterThan(0);
    const mid = parseRgb(midSamples[0]);
    // Mid-step should already be noticeably red, not nearly black.
    expect(mid.r).toBeGreaterThan(150);
    expect(mid.g).toBeGreaterThan(40);
    expect(mid.b).toBeGreaterThan(40);

    await snapshot();
  });
});

